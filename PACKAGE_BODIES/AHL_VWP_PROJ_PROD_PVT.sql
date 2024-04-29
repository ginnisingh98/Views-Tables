--------------------------------------------------------
--  DDL for Package Body AHL_VWP_PROJ_PROD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_PROJ_PROD_PVT" AS
/* $Header: AHLVPRDB.pls 120.50.12010000.24 2010/03/22 09:32:11 skpathak ship $ */

-- Global CONSTANTS
G_PKG_NAME             CONSTANT VARCHAR2(30) := 'AHL_VWP_PROJ_PROD_PVT';
--G_DEBUG     VARCHAR2(1):= FND_PROFILE.VALUE('AHL_API_FILE_DEBUG_ON');
G_DEBUG                VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;

G_PM_PRODUCT_CODE      CONSTANT VARCHAR2(30) := 'AHL';

------------------------------------
-- Common constants and variables --
------------------------------------
l_log_current_level     NUMBER      := fnd_log.g_current_runtime_level;
l_log_statement         NUMBER      := fnd_log.level_statement;
l_log_procedure         NUMBER      := fnd_log.level_procedure;
l_log_error             NUMBER      := fnd_log.level_error;
l_log_unexpected        NUMBER      := fnd_log.level_unexpected;
-----------------------------------------------------------------

--  Record Type for track on tasks for which jobs has been created
TYPE Job_Rec_Type IS RECORD
   (TASK_ID              NUMBER,
    WORKORDER_ID         NUMBER,
    RETURN_STATUS        VARCHAR2(30));

--  Table Type for Unit config check on SerialId
TYPE Job_Tbl_Type IS TABLE OF Job_Rec_Type
   INDEX BY BINARY_INTEGER;

--  Table Type for Dept for Tasks
TYPE Dept_Tbl_Type IS TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------
--  Procedure name : Push_to_Production
--  Type           : Private
--  Function       : To push a visit to production
--  Parameters     :
--
--  Standard IN  Parameters :
--      p_api_version      IN  NUMBER   Required
--      p_init_msg_list    IN  VARCHAR2 Default  FND_API.G_FALSE
--      p_commit           IN  VARCHAR2 Default  FND_API.G_FALSE
--      p_validation_level IN  NUMBER   Default  FND_API.G_VALID_LEVEL_FULL
--      p_default          IN  VARCHAR2 Default  FND_API.G_TRUE
--      p_module_type      IN  VARCHAR2 Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status    OUT VARCHAR2 Required
--      x_msg_count        OUT NUMBER   Required
--      x_msg_data         OUT VARCHAR2 Required
--
--  Push_to_Production Parameters:
--      p_visit_id         IN  NUMBER   Required
--      p_release_flag     IN  VARCHAR2 Required
--         The visit id which is to be pushed to production.
--
--  Version :
--      Initial Version   1.0
-------------------------------------------------------------------
PROCEDURE Push_to_Production
    (p_api_version       IN  NUMBER,
     p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
     p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
     p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
     p_module_type       IN  VARCHAR2  := Null,
     p_visit_id          IN  NUMBER,
     p_release_flag      IN  VARCHAR2  := 'N',
     p_orig_visit_id     IN  NUMBER    := NULL, -- By yazhou   08/06/04 for TC changes
     x_return_status     OUT NOCOPY VARCHAR2,
     x_msg_count         OUT NOCOPY NUMBER,
     x_msg_data          OUT NOCOPY VARCHAR2
    );

-------------------------------------------------------------------
--  Procedure name : Push_MR_to_Production
--  Type           : Private
--  Function       : To push a MR to production
--  Parameters     :
--
--  Standard IN  Parameters :
--      p_api_version          IN  NUMBER   Required
--      p_init_msg_list        IN  VARCHAR2 Default  FND_API.G_FALSE
--      p_commit               IN  VARCHAR2 Default  FND_API.G_FALSE
--      p_validation_level     IN  NUMBER   Default  FND_API.G_VALID_LEVEL_FULL
--      p_module_type          IN  VARCHAR2 Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status        OUT VARCHAR2 Required
--      x_msg_count            OUT NUMBER   Required
--      x_msg_data             OUT VARCHAR2 Required
--
--  Push_to_Production Parameters:
--      p_visit_id             IN  NUMBER   Required
--      p_unit_effectivity_id  IN  NUMBER   Required
--      p_release_flag         IN  VARCHAR2 optional
--
--  Version :
--      Initial Version   1.0 Created by Yazhou
-------------------------------------------------------------------
PROCEDURE Push_MR_to_Production
    (p_api_version          IN  NUMBER,
     p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
     p_commit               IN  VARCHAR2  := Fnd_Api.g_false,
     p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
     p_module_type          IN  VARCHAR2  := Null,
     p_visit_id             IN  NUMBER,
     p_unit_effectivity_id  IN  NUMBER,
     p_release_flag         IN  VARCHAR2  := 'N',
     x_return_status        OUT NOCOPY VARCHAR2,
     x_msg_count            OUT NOCOPY NUMBER,
     x_msg_data             OUT NOCOPY VARCHAR2
     );

-------------------------------------------------------------------
--  Procedure name : Add_MR_to_Project
--  Type           : Private
--  Function       : To add Project Task for all the tasks for a given MR
--                  when SR tasks are created in prodution
--  Parameters     :
--
--  Standard IN  Parameters :
--      p_api_version         IN  NUMBER   Required
--      p_init_msg_list       IN  VARCHAR2 Default  FND_API.G_FALSE
--      p_commit              IN  VARCHAR2 Default  FND_API.G_FALSE
--      p_validation_level    IN  NUMBER   Default  FND_API.G_VALID_LEVEL_FULL
--      p_default             IN  VARCHAR2 Default  FND_API.G_TRUE
--      p_module_type         IN  VARCHAR2 Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status       OUT VARCHAR2 Required
--      x_msg_count           OUT NUMBER   Required
--      x_msg_data            OUT VARCHAR2 Required
--
--  Add_Task_to_Project Parameters:
--      p_visit_id            IN  NUMBER   Required
--      p_unit_effectivity_id IN  NUMBER   Required
--
--  Version :
--      Initial Version   1.0 29-Jul-2005 Yazhou
-------------------------------------------------------------------
PROCEDURE Add_MR_to_Project(
   p_api_version         IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit              IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level    IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type         IN  VARCHAR2  := Null,
   p_visit_id            IN  NUMBER,
   p_unit_effectivity_id IN  NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2
  );

-------------------------------------------------------------------
--  Procedure name : Create_Project
--  Type           : Private
--  Function       : To create Project when visit is pushed to projects
--  Parameters     :
--
--------------------------------------------------------------------
PROCEDURE Create_Project(
   p_visit_id      IN  NUMBER,
   x_return_status OUT NOCOPY VARCHAR2
   );

------------------------------------------------------------------
--  Procedure name : Validate_tasks_bef_production
--  Type           : Private
--  Function       : Validate the tasks before pushing the tasks to prodn.
--  Parameters     :
--
--  Standard OUT Parameters :
--      x_return_status OUT VARCHAR2      Required
--      x_msg_count     OUT NUMBER        Required
--      x_msg_data      OUT VARCHAR2      Required
--
--  Validate_tasks_bef_production Parameters:
--      p_visit_id      IN  NUMBER        Required
--      p_tasks_tbl     IN  Task_Tbl_Type Required
--      x_tasks_tbl     OUT Task_Tbl_Type Required
--
--  Version :
--      30 November, 2007  RNAHATA  Initial Version - 1.0
-------------------------------------------------------------------

PROCEDURE Validate_tasks_bef_production(
    p_visit_id       IN         NUMBER,
    p_tasks_tbl      IN         Task_Tbl_Type,
    x_tasks_tbl      OUT NOCOPY Task_Tbl_Type,
    x_return_status  OUT NOCOPY VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2
);

-------------------------------------------------------------------
--  Procedure name : Push_tasks_to_production
--  Type           : Private
--  Function       : Push the selected tasks to production.
--  Parameters     :
--
--  Standard IN  Parameters :
--      p_api_version      IN  NUMBER        Required
--      p_init_msg_list    IN  VARCHAR2      Default  FND_API.G_FALSE
--      p_commit           IN  VARCHAR2      Default  FND_API.G_FALSE
--      p_validation_level IN  NUMBER        Default  FND_API.G_VALID_LEVEL_FULL
--      p_module_type      IN  VARCHAR2      Default  Null
--
--  Standard OUT Parameters :
--      x_return_status    OUT VARCHAR2      Required
--      x_msg_count        OUT NUMBER        Required
--      x_msg_data         OUT VARCHAR2      Required
--
--  Push_tasks_to_production Parameters:
--       p_visit_id        IN  NUMBER        Required
--       p_tasks_tbl       IN  Task_Tbl_Type Required
--       p_release_flag    IN  VARCHAR2      Default = 'N'
--
--  Version :
--      30 November, 2007  RNAHATA  Initial Version - 1.0
-------------------------------------------------------------------

PROCEDURE Push_tasks_to_production(
    p_api_version      IN         NUMBER,
    p_init_msg_list    IN         VARCHAR2  := Fnd_Api.g_false,
    p_validation_level IN         NUMBER    := Fnd_Api.g_valid_level_full,
    p_module_type      IN         VARCHAR2  := Null,
    p_visit_id         IN         NUMBER,
    p_tasks_tbl        IN         Task_Tbl_Type,
    p_release_flag     IN         VARCHAR2  := 'N',
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2
);

-- AnRaj added for ACL changes in VWP
-- Bug number 4297066
-------------------------------------------------------------------
--  Procedure name      : check_unit_quarantined
--  Type                : Private
--  Function            : To check whether the Unit is quarantined
--  Parameters          : p_visit_id
--  Parameters          : item_instance_id
----------------------------------------------------------------------
PROCEDURE check_unit_quarantined(
      p_visit_id       IN  NUMBER,
      item_instance_id IN  NUMBER
  );

-------------------------------------------------------------------
--  Procedure name : Aggregate_Task_Material_Reqrs
--  Type           : Private
--  Function       : Find the total requirment of a specific
--                   item at the task level
--  Parameters     :
--
--  Standard OUT Parameters :
--      x_return_status OUT  VARCHAR2 Required
--      x_msg_count     OUT  NUMBER   Required
--      x_msg_data      OUT  VARCHAR2 Required
--
--  Aggregate_Task_Material_Reqrs Parameters:
--      p_task_id       IN   NUMBER   Required
--
--  Version :
--      30 November, 2007  RNAHATA  Initial Version - 1.0
-------------------------------------------------------------------
PROCEDURE Aggregate_Task_Material_Reqrs
    (p_api_version      IN         NUMBER,
     p_init_msg_list    IN         VARCHAR2,
     p_commit           IN         VARCHAR2,
     p_validation_level IN         NUMBER,
     p_module_type      IN         VARCHAR2,
     p_task_id          IN         NUMBER,
     p_rel_tsk_flag     IN         VARCHAR2 := 'Y',
     x_return_status    OUT NOCOPY VARCHAR2,
     x_msg_count        OUT NOCOPY NUMBER,
     x_msg_data         OUT NOCOPY VARCHAR2
    );

PROCEDURE Aggregate_Material_Reqrs
    (p_api_version      IN          NUMBER,
     p_init_msg_list    IN          VARCHAR2,
     p_commit           IN          VARCHAR2,
     p_validation_level IN          NUMBER,
     p_module_type      IN          VARCHAR2,
     p_visit_id         IN          NUMBER,
     x_return_status    OUT NOCOPY  VARCHAR2,
     x_msg_count        OUT NOCOPY  NUMBER,
     x_msg_data         OUT NOCOPY  VARCHAR2
    );

-- Added by rnahata for Bug 5758813
-------------------------------------------------------------------
--  Procedure name    : Update_Project_Task_Times
--  Type              : Private
--  Function          : Update the project task start/end dates
--      with the workorder schedule start/end dates
--  Parameters :
--  Standard IN Parameters :
--  p_commit      IN    VARCHAR2  Fnd_Api.G_FALSE
--
--  Update_Project_Task_Times Parameters  :
--  p_prd_workorder_tbl   IN    AHL_PRD_WORKORDER_PVT.PRD_WORKORDER_TBL Required
--
--  Standard OUT Parameters :
--      x_return_status    OUT   VARCHAR2   Required
--      x_msg_count        OUT   NUMBER     Required
--      x_msg_data         OUT   VARCHAR2   Required
--
--  Version :
--      17 April, 2008    Bug#5758813  RNAHATA  Initial Version - 1.0
-------------------------------------------------------------------
PROCEDURE Update_Project_Task_Times
( p_prd_workorder_tbl IN         AHL_PRD_WORKORDER_PVT.PRD_WORKORDER_TBL,
  p_commit            IN         VARCHAR2 := Fnd_Api.G_FALSE,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
) ;
-- End changes by rnahata for Bug 5758813

--TCHIMIRA::P2P CP ER 9151144::02-DEC-2009::BEGIN
--------------------------------------------------------------------
-- PROCEDURE
--    BG_Release_Visit
--
-- PURPOSE
--    To carry push to Production as a background process
--  Parameters :

--  Standard IN Parameters :
--      p_commit      IN    VARCHAR2  Fnd_Api.G_FALSE
--
--  Standard OUT Parameters :
--      x_return_status    OUT   VARCHAR2   Required
--      x_msg_count        OUT   NUMBER     Required
--      x_msg_data         OUT   VARCHAR2   Required

--  BG_Release_visit Parameters  :
--      p_visit_id         IN    NUMBER      Required
--         visit id is required to get visit number and passed to concurrent program
--      p_release_flag     IN    VARCHAR2    Required
--         This is passed to concurrent program as an argument
--      x_request_id       OUT   NUMBER     Required
--         Stores request id that is passed from concurrent program

--  Version :
--      02 Dec, 2009    P2P CP ER 9151144 TCHIMIRA  Initial Version - 1.0
--------------------------------------------------------------------
PROCEDURE BG_Release_Visit
( p_api_version      IN            NUMBER,
  p_init_msg_list    IN            VARCHAR2  := Fnd_Api.G_FALSE,
  p_commit           IN            VARCHAR2  := Fnd_Api.G_FALSE,
  p_validation_level IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
  p_module_type      IN            VARCHAR2  := NULL,
  p_visit_id         IN            NUMBER,
  p_release_flag     IN            VARCHAR2 := 'U',
  x_request_id        OUT NOCOPY NUMBER,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
)
IS
  --Standard local variables
  L_API_NAME         CONSTANT VARCHAR2(30)  := 'BG_Release_Visit';
  L_API_VERSION      CONSTANT NUMBER        := 1.0;
  L_DEBUG_KEY        CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
  l_msg_data                  VARCHAR2(2000);
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_Error_Tbl_Type            Error_Tbl_Type;
  l_error_msg                 VARCHAR2(5000);
  l_error_count               NUMBER;
  l_commit                    VARCHAR2(1) := 'F';
  l_validate_error            CONSTANT VARCHAR2(1) := 'V';
  l_req_id                    NUMBER;
  l_phase_code                VARCHAR2(1);
  l_curr_org_id               NUMBER;

  -- To find visit related information
  CURSOR c_visit (c_id IN NUMBER) IS
   SELECT * FROM AHL_VISITS_B
     WHERE VISIT_ID = c_id
     FOR UPDATE OF OBJECT_VERSION_NUMBER;
  c_visit_rec c_visit%ROWTYPE;

  --Cursor to fetch phase
  CURSOR c_conc_req_phase(c_id IN NUMBER) IS
  SELECT FCR.PHASE_CODE
  FROM FND_CONCURRENT_REQUESTS FCR, AHL_VISITS_B AVB
  WHERE FCR.REQUEST_ID = AVB.REQUEST_ID
  AND AVB.VISIT_ID = c_id;

BEGIN

    IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,L_DEBUG_KEY||'.begin','At the start of the PLSQL procedure. Visit Id = ' || p_visit_id);
    END IF;
    -- Standard start of API savepoint
    SAVEPOINT BG_Release_Visit_Pvt;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.Initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check for Required Parameters
    IF(p_visit_id IS NULL OR p_visit_id = FND_API.G_MISS_NUM) THEN
        FND_MESSAGE.Set_Name(G_PM_PRODUCT_CODE,'AHL_VWP_CST_INPUT_MISS');
        FND_MSG_PUB.ADD;
        IF (l_log_unexpected >= l_log_current_level)THEN
            fnd_log.string
            (
                l_log_unexpected,
                'ahl.plsql.AHL_VWP_CST_WO_PVT.Release_Visit',
                'Visit id is mandatory but found null in input '
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    OPEN c_conc_req_phase(p_visit_id);
    FETCH c_conc_req_phase INTO l_phase_code;
    CLOSE c_conc_req_phase;

    IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,L_DEBUG_KEY,'l_phase_code : '||l_phase_code);
    END IF;

    IF(l_phase_code IN('R' , 'P')) THEN
      FND_MESSAGE.Set_Name(G_PM_PRODUCT_CODE,'AHL_VWP_CP_P2P_IN_PROGS');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_log_statement >= l_log_current_level)THEN
         fnd_log.string (l_log_statement,L_DEBUG_KEY, 'Before Calling AHL_VWP_PROJ_PROD_PVT.Validate_Before_Production');
    END IF;

    --Valdate before push to production happens
    AHL_VWP_PROJ_PROD_PVT.Validate_Before_Production
              (p_api_version      => l_api_version,
               p_init_msg_list    => p_init_msg_list,
               p_commit           => l_commit,
               p_validation_level => p_validation_level,
               p_module_type      => p_module_type,
               p_visit_id         => p_visit_id,
               x_error_tbl        => l_error_tbl_type,
               x_return_status    => l_return_status,
               x_msg_count        => l_msg_count,
               x_msg_data         => l_msg_data);

    IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string (l_log_statement, L_DEBUG_KEY, 'After Calling AHL_VWP_PROJ_PROD_PVT.Validate_Before_Production - l_return_status = '||l_return_status);
    END IF;

    IF l_error_tbl_type.COUNT > 0 THEN
       l_return_status := l_validate_error;
       x_return_status := l_validate_error;
    ELSIF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      -- Check Error Message stack.
       x_msg_count := FND_MSG_PUB.count_msg;

       IF (l_log_statement >= l_log_current_level)THEN
          fnd_log.string ( l_log_statement, L_DEBUG_KEY,'Errors from AHL_VWP_PROJ_PROD_PVT.Validate_Before_Production - '||x_msg_count);
       END IF;
       RAISE Fnd_Api.g_exc_error;
    ELSE

       IF(l_phase_code IN('R' , 'P')) THEN
              FND_MESSAGE.Set_Name(G_PM_PRODUCT_CODE,'AHL_VWP_CP_P2P_IN_PROGS');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF (l_log_statement >= l_log_current_level) THEN
              FND_LOG.STRING(l_log_statement,L_DEBUG_KEY,
                             ' Before calling concurrent program to push the visit to production ');
       END IF;

       OPEN c_visit(p_visit_id);
       FETCH c_visit INTO c_visit_rec;

       IF (l_log_statement >= l_log_current_level) THEN
                fnd_log.string(l_log_statement,L_DEBUG_KEY, 'concurrent parameter values  p_api_version ->       '||p_api_version||' , visit_number -> '||c_visit_rec.visit_number||' , p_release_flag -> '||p_release_flag);
       END IF;

       l_curr_org_id := MO_GLOBAL.get_current_org_id();
       FND_REQUEST.SET_ORG_ID(l_curr_org_id);
       l_req_id := FND_REQUEST.SUBMIT_REQUEST(
                        application =>  'AHL',
                        program     => 'AHLVWPP2P',
                        argument1   => p_api_version,
                        argument2   => c_visit_rec.visit_number,
                        argument3   => p_release_flag);

       IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,L_DEBUG_KEY,'l_req_id = '|| l_req_id);
       END IF;

       IF (l_req_id = 0) THEN
         IF (l_log_statement >= l_log_current_level) THEN
                fnd_log.string(l_log_statement,L_DEBUG_KEY, ' Concurrent program request failed.');
         END IF;
       ELSE
         IF (l_log_statement >= l_log_current_level) THEN
                fnd_log.string(l_log_statement,L_DEBUG_KEY, ' Concurrent program request successful.');
         END IF;

        x_request_id := l_req_id;
       --Update the table with l_req_id
       UPDATE ahl_visits_b
        SET REQUEST_ID = l_req_id,
	OBJECT_VERSION_NUMBER = object_version_number + 1,
        LAST_UPDATE_DATE      = SYSDATE,
        LAST_UPDATED_BY       = Fnd_Global.USER_ID,
        LAST_UPDATE_LOGIN     = Fnd_Global.LOGIN_ID
        WHERE visit_id = p_visit_id;
        CLOSE c_visit;
        COMMIT WORK;

      END IF;
    END IF;
    IF (l_log_procedure >= l_log_current_level)THEN
        fnd_log.string ( l_log_procedure,L_DEBUG_KEY ||'.end','At the end of PLSQL procedure, x_return_status=' || x_return_status);
    END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      ROLLBACK TO BG_Release_Visit_Pvt;
      FND_MSG_PUB.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data,
            p_encoded => fnd_api.g_false);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO BG_Release_Visit_Pvt;
      FND_MSG_PUB.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data,
            p_encoded => fnd_api.g_false);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO BG_Release_Visit_Pvt;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      fnd_msg_pub.add_exc_msg(
            p_pkg_name       => G_PKG_NAME,
            p_procedure_name => 'BG_Release_Visit',
            p_error_text     => SUBSTR(SQLERRM,1,500));
      END IF;
    FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

END BG_Release_Visit;
--------------------------------------------------------------------
-- PROCEDURE
--    BG_Push_to_Production
--
-- PURPOSE
--    Made as an executable for the P2P CP
--  BG_Push_to_Production Parameters :
--      p_visit_number      IN    NUMBER
--      errbuf              OUT   VARCHAR2   Required
--         Defines in pl/sql to store procedure to get error messages into log file
--      retcode             OUT   NUMBER     Required
--         To get the status of the concurrent program

--  Version :
--      02 Dec, 2009    P2P CP ER 9151144 TCHIMIRA  Initial Version - 1.0
--------------------------------------------------------------------
PROCEDURE BG_Push_to_Production(
    errbuf            OUT NOCOPY VARCHAR2,
    retcode           OUT NOCOPY NUMBER,
    p_api_version     IN  NUMBER,
    p_visit_number    IN  NUMBER,
    p_release_flag    IN  VARCHAR2 := 'U'
)
IS


-- Local variables section
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_return_status         VARCHAR2(1);
l_api_version           NUMBER := 1.0;
l_api_name              VARCHAR2(30) := 'BG_Push_to_Production';
l_err_msg               VARCHAR2(2000);
l_msg_index_out         NUMBER;
l_visit_id              NUMBER;

BEGIN

   -- Standard start of API savepoint
   SAVEPOINT BG_Push_to_Production;

   -- 1. Initialize error message stack by default
   FND_MSG_PUB.Initialize;

   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      retcode := 2;
      errbuf := FND_MSG_PUB.Get;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- 2. Dump all input parameters
   fnd_file.put_line(fnd_file.log, '*************API input parameters**************');
   fnd_file.put_line(fnd_file.log, 'p_visit_number -> '|| p_visit_number);
   fnd_file.put_line(fnd_file.log, 'p_release_flag -> '||p_release_flag);
   fnd_file.put_line(fnd_file.log, 'fnd_global.USER_ID -> '|| fnd_global.USER_ID);
   fnd_file.put_line(fnd_file.log, 'fnd_global.RESP_ID -> '||fnd_global.RESP_ID);
   fnd_file.put_line(fnd_file.log, 'fnd_global.PROG_APPL_ID -> '|| fnd_global.PROG_APPL_ID);
   fnd_file.put_line(fnd_file.log, 'mo_global.get_current_org_id -> '|| mo_global.get_current_org_id());

   SELECT visit_id INTO l_visit_id FROM AHL_VISITS_B WHERE visit_number = p_visit_number;

   IF l_visit_id IS NOT NULL THEN

   fnd_file.put_line(fnd_file.log, 'before calling AHL_VWP_PROJ_PROD_PVT.Release_visit');
   fnd_file.put_line(fnd_file.log, 'visit_id -> '||l_visit_id);

      AHL_VWP_PROJ_PROD_PVT.Release_Visit(
             p_api_version      =>         p_api_version,
             p_module_type      =>         'JSP',  --passing p_module_type as JSP
             p_visit_id         =>         l_visit_id,
             p_release_flag     =>         p_release_flag,
             x_return_status    =>         l_return_status,
             x_msg_count        =>         l_msg_count,
             x_msg_data         =>         l_msg_data);

       l_msg_count := FND_MSG_PUB.Count_Msg;
       IF (l_msg_count > 0) THEN
          fnd_file.put_line(fnd_file.log, 'Following error occured while pushing the visit to production..');
          IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
              RAISE FND_API.G_EXC_ERROR;
          ELSE
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       END IF;
   END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO BG_Push_to_Production;
   retcode := 2;
   FOR i IN 1..l_msg_count
       LOOP
         fnd_msg_pub.get( p_msg_index => i,
                          p_encoded   => FND_API.G_FALSE,
                          p_data      => l_err_msg,
                          p_msg_index_out => l_msg_index_out);

         fnd_file.put_line(FND_FILE.LOG, 'Err message-'||l_msg_index_out||':' || l_err_msg);
       END LOOP;


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO BG_Push_to_Production;
   retcode := 2;
   l_msg_count := Fnd_Msg_Pub.count_msg;
   FOR i IN 1..l_msg_count
       LOOP
         fnd_msg_pub.get( p_msg_index => i,
                          p_encoded   => FND_API.G_FALSE,
                          p_data      => l_err_msg,
                          p_msg_index_out => l_msg_index_out);

         fnd_file.put_line(FND_FILE.LOG, 'Err message-'||l_msg_index_out||':' || l_err_msg);
       END LOOP;


 WHEN OTHERS THEN
   ROLLBACK TO BG_Push_to_Production;
   retcode := 2;
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => 'BG_Push_to_Production',
                             p_error_text     => SUBSTR(SQLERRM,1,500));
   END IF;
   l_msg_count := Fnd_Msg_Pub.count_msg;
   FOR i IN 1..l_msg_count
     LOOP
        fnd_msg_pub.get( p_msg_index => i,
                         p_encoded   => FND_API.G_FALSE,
                         p_data      => l_err_msg,
                         p_msg_index_out => l_msg_index_out);

        fnd_file.put_line(FND_FILE.LOG, 'Err message-'||l_msg_index_out||':' || l_err_msg);
     END LOOP;


END BG_Push_to_Production;
--TCHIMIRA::P2P CP ER 9151144::02-DEC-2009::END

--****************************************************************--
--------------------------------------------------------------------
--              VWP INTEGRATION WITH PROJECTS                     --
--------------------------------------------------------------------
--****************************************************************--

--------------------------------------------------------------------
-- PROCEDURE
--    Integrate_to_Projects
--
-- PURPOSE
--    To Integrate with Projects i.e creating projects for
--    visits and project tasks for all associated visit task
--------------------------------------------------------------------
PROCEDURE Integrate_to_Projects (
   p_api_version      IN         NUMBER,
   p_init_msg_list    IN         VARCHAR2 := Fnd_Api.g_false,
   p_commit           IN         VARCHAR2 := Fnd_Api.g_false,
   p_validation_level IN         NUMBER   := Fnd_Api.g_valid_level_full,
   p_module_type      IN         VARCHAR2 := Null,
   p_visit_id         IN         NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2)

IS
   L_API_VERSION CONSTANT NUMBER        := 1.0;
   L_API_NAME    CONSTANT VARCHAR2(30)  := 'Integrate_to_Projects';
   L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   -- To find visit related information
   CURSOR c_visit (x_id IN NUMBER) IS
    SELECT * FROM AHL_VISITS_VL
    WHERE VISIT_ID = x_id;
   c_visit_rec c_visit%ROWTYPE;

BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Integrate_to_Projects;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Visit Id = ' || p_visit_id);
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_boolean(p_init_msg_list) THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,L_DEBUG_KEY,'Visit Id= '|| p_visit_id);
   END IF;

   OPEN c_visit (p_visit_id);
   FETCH c_visit INTO c_visit_rec;
   CLOSE c_visit;

   IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,L_DEBUG_KEY,'Visits Project Id = '|| c_visit_rec.PROJECT_ID);
   END IF;

   IF c_visit_rec.PROJECT_ID IS NULL THEN
       IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,L_DEBUG_KEY,'Before calling Create_Project');
       END IF;

      -- Call Create_Project local procedure to create project  tasks
         Create_Project (
                p_visit_id      => p_visit_id,
                x_return_status => x_return_status);

       IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,L_DEBUG_KEY,'After calling Create_Project - '||x_return_status);
       END IF;
   ELSE
       IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,L_DEBUG_KEY,'Before calling Update_Project');
       END IF;

      -- Call Update_Project local procedure to update project tasks
      Update_Project (
             p_api_version      => p_api_version,
             p_init_msg_list    => p_init_msg_list,
             p_commit           => p_commit,
             p_validation_level => p_validation_level,
             p_module_type      => p_module_type,
             p_visit_id         => p_visit_id,
             x_return_status    => x_return_status,
             x_msg_count        => x_msg_count,
             x_msg_data         => x_msg_data);

       IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,L_DEBUG_KEY,'After calling Update_Project - '||x_return_status);
       END IF;
   END IF;

 ---------------------------End of Body-------------------------------------
  --
  -- END of API body.
  --
  -- Standard check of p_commit.
   IF Fnd_Api.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END IF;

   Fnd_Msg_Pub.count_and_get(
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
  );

   IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,L_DEBUG_KEY ||'.end','End of PL/SQL procedure');
   END IF;

EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Integrate_to_Projects;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Integrate_to_Projects;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN OTHERS THEN
      ROLLBACK TO Integrate_to_Projects;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error) THEN
         Fnd_Msg_Pub.add_exc_msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
END Integrate_to_Projects;

--------------------------------------------------------------------
-- PROCEDURE
--    Add_Task_to_Project
--
-- PURPOSE
--
--
--------------------------------------------------------------------
PROCEDURE Add_Task_to_Project(
   p_api_version      IN         NUMBER,
   p_init_msg_list    IN         VARCHAR2  := Fnd_Api.g_false,
   p_commit           IN         VARCHAR2  := Fnd_Api.g_false,
   p_validation_level IN         NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type      IN         VARCHAR2  := Null,
   p_visit_task_id    IN         NUMBER,

   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2
 )
IS
   L_API_VERSION  CONSTANT NUMBER := 1.0;
   L_API_NAME     CONSTANT VARCHAR2(30)  := 'Add_Task_to_Project';
   L_DEBUG_KEY    CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   G_EXC_ERROR             EXCEPTION;
   l_msg_count             NUMBER;
   l_task_id               NUMBER;
   l_pa_project_id_out     NUMBER;
   l_msg_index_out         NUMBER;
   l_return_status         VARCHAR2(1);
   l_chk_project           VARCHAR2(1);
   l_proj_ref_flag         VARCHAR2(1);
   l_project_tsk_flag      VARCHAR2(1);
   l_default               VARCHAR2(30);
   l_msg_data              VARCHAR2(2000);
   l_pa_project_number_out VARCHAR2(25);
   l_commit                VARCHAR2(1) := 'F';
   l_init_msg_list         VARCHAR2(1) := 'F';

    -- To find visit related information
   CURSOR c_visit (x_id IN NUMBER) IS
    SELECT * FROM AHL_VISITS_VL
    WHERE VISIT_ID = x_id;
   c_visit_rec c_visit%ROWTYPE;

   -- To find tasks information for visit
   CURSOR c_task (x_id IN NUMBER) IS
    SELECT T1.PROJECT_ID, T1.VISIT_NUMBER, T2.*
    FROM  AHL_VISITS_VL T1, AHL_VISIT_TASKS_VL T2
    WHERE VISIT_TASK_ID = x_id
    AND T1.VISIT_ID = T2.VISIT_ID;

   c_task_rec c_task%ROWTYPE;

BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Add_Task_to_Project;

   -- Debug info.
   IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,L_DEBUG_KEY ||'.begin','At the start of PLSQL procedure');
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_boolean(p_init_msg_list) THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      L_API_NAME,G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,L_DEBUG_KEY,'Visit Task Id = '|| p_visit_task_id);
   END IF;

   ----------------------------------------- Cursor ----------------------------------
   OPEN c_task (p_visit_task_id);
   FETCH c_task INTO c_task_rec;
   CLOSE c_task;

   OPEN c_Visit(c_task_rec.visit_id);
   FETCH c_visit INTO c_visit_rec;
   CLOSE c_Visit;
   ----------------------------------------- Start of Body ----------------------------------
   -- To check Project responsibilites
   -- post 11.5.10 change                                                  -- Post 11.5.10
   -- change start

   -- RROY
   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Before calling AHL_VWP_RULES_PVT.Check_Proj_Responsibility.');
   END IF;

   AHL_VWP_RULES_PVT.Check_Proj_Responsibility
           (x_check_project    => l_chk_project,
            x_return_status    => l_return_status);

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'After calling AHL_VWP_RULES_PVT.Check_Proj_Responsibility. Return Status = ' ||
                     l_return_status);
   END IF;

   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Errors from AHL_VWP_RULES_PVT.Check_Proj_Responsibility.');
      END IF;
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSE
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   IF l_chk_project = 'Y' THEN
     IF c_task_rec.PROJECT_TASK_ID IS NULL THEN
     -- change end
       IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'Before calling PA_PROJECT_PUB.CHECK_UNIQUE_TASK_NUMBER.');
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'p_project_id = ' || c_visit_rec.project_id);
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'p_pm_project_reference = ' || c_visit_rec.visit_number);
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'p_task_number = ' || c_task_rec.visit_task_number);
       END IF;

        PA_PROJECT_PUB.Check_Unique_Task_Number
        ( p_api_version_number      => 1,
          p_init_msg_list           => l_init_msg_list,
          p_return_status           => l_return_status,
          p_msg_count               => l_msg_count,
          p_msg_data                => l_msg_data,
          p_project_id              => c_visit_rec.project_id,
          p_pm_project_reference    => c_visit_rec.visit_number,
          p_task_number             => c_task_rec.visit_task_number,
          p_unique_task_number_flag => l_project_tsk_flag
        );

       IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'After calling PA_PROJECT_PUB.check_unique_task_number. p_unique_task_number_flag = ' ||
                         l_project_tsk_flag || ' Return Status = ' || l_return_status);
          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'Errors from PA_PROJECT_PUB.check_unique_task_number. Message count: ' ||
                            l_msg_count || ', message data: ' || l_msg_data);
          END IF;
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'Before calling PA_PROJECT_PUB.check_unique_task_reference.');
       END IF;

       PA_PROJECT_PUB.Check_Unique_Task_Reference
          (p_api_version_number    => 1,
           p_init_msg_list         => l_init_msg_list,
           p_return_status         => l_return_status,
           p_msg_count             => l_msg_count,
           p_msg_data              => l_msg_data,
           p_project_id            => c_visit_rec.project_id,
           p_pm_project_reference  => c_visit_rec.visit_number,
           p_pm_task_reference     => c_task_rec.visit_task_number,
           p_unique_task_ref_flag  => l_proj_ref_flag
      );

       IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,L_DEBUG_KEY,'After calling -- Check_Unique_Task_Reference l_proj_ref_flag = ' || l_proj_ref_flag);
       END IF;

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Errors from PA_PROJECT_PUB.check_unique_task_number. Message count: ' ||
                            l_msg_count || ', message data: ' || l_msg_data);
         END IF;
         IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSE
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

       IF l_project_tsk_flag = 'Y' AND l_proj_ref_flag = 'Y' THEN
          IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,L_DEBUG_KEY,'Before calling PA_PROJECT_PUB.ADD_TASK..');
            fnd_log.string(l_log_statement,L_DEBUG_KEY,'c_task_rec.PROJECT_ID=: ' || c_task_rec.PROJECT_ID);
            fnd_log.string(l_log_statement,L_DEBUG_KEY,'c_task_rec.VISIT_NUMBER=: ' || c_task_rec.VISIT_NUMBER);
            fnd_log.string(l_log_statement,L_DEBUG_KEY,'c_task_rec.VISIT_TASK_NUMBER=: ' || c_task_rec.VISIT_TASK_NUMBER);
            fnd_log.string(l_log_statement,L_DEBUG_KEY,'c_task_rec.VISIT_TASK_NAME=: ' || c_task_rec.VISIT_TASK_NAME);
            fnd_log.string(l_log_statement,L_DEBUG_KEY,'c_task_rec.DESCRIPTION=: ' || c_task_rec.DESCRIPTION);
          END IF;

          PA_PROJECT_PUB.ADD_TASK
               (p_api_version_number      => 1
               ,p_commit            => l_commit
               ,p_init_msg_list          => l_init_msg_list
               ,p_msg_count            => l_msg_count
               ,p_msg_data            => l_msg_data
               ,p_return_status          => l_return_status
               ,p_pm_product_code        => G_PM_PRODUCT_CODE
               ,p_pm_project_reference      => c_task_rec.VISIT_NUMBER
               ,p_pa_project_id          => c_task_rec.PROJECT_ID
               ,p_pm_task_reference        => c_task_rec.VISIT_TASK_NUMBER
               ,p_pa_task_number            => c_task_rec.VISIT_TASK_NUMBER
               -- SKPATHAK :: Bug 8321556 :: 23-MAR-2009 :: Use SUBSTRB instead of SUBSTR
               ,p_task_name            => SUBSTRB( c_task_rec.VISIT_TASK_NAME , 1,15)
               -- AnRaj: Changed for Bug#5069540
                /** Begin changes by rnahata for Bug 5758813 **/
                -- ,p_task_description   => SUBSTR(c_task_rec.DESCRIPTION,1,250)
                ,p_task_description      => c_task_rec.visit_task_name
               --Fix for the Bug 7009212. rnahata truncated the dates
               ,p_task_start_date       => trunc(c_task_rec.start_date_time)
               ,p_task_completion_date  => trunc(c_task_rec.end_date_time)
                /** End changes by rnahata for Bug 5758813 **/
               ,p_pa_project_id_out      => l_pa_project_id_out
               ,p_pa_project_number_out    => l_pa_project_number_out
               ,p_task_id            => l_task_id
                );

          IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,L_DEBUG_KEY,'After calling PA_PROJECT_PUB.ADD_TASK - l_return_status = '||l_return_status);
          END IF;

          IF (l_return_status <> 'S') THEN
            IF (fnd_msg_pub.count_msg > 0 ) THEN
              FOR i IN 1..fnd_msg_pub.count_msg
              LOOP
                fnd_msg_pub.get( p_msg_index => i,
                                 p_encoded   => 'F',
                                 p_data      => l_msg_data,
                                 p_msg_index_out => l_msg_index_out);

                IF (l_log_statement >= l_log_current_level) THEN
                  fnd_log.string(l_log_statement,L_DEBUG_KEY,'Error - '||l_msg_data);
                END IF;
              END LOOP;
            ELSE
              IF (l_log_statement >= l_log_current_level) THEN
                  fnd_log.string(l_log_statement,L_DEBUG_KEY,'Another Error - '||l_msg_data);
              END IF;
            END IF;
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
          END IF;

          IF l_return_status = 'S' THEN
            UPDATE AHL_VISIT_TASKS_B
            SET PROJECT_TASK_ID = l_task_id,
                OBJECT_VERSION_NUMBER = object_version_number + 1,
                --TCHIMIRA::BUG 9222622 ::15-DEC-2009::UPDATE WHO COLUMNS
                LAST_UPDATE_DATE      = SYSDATE,
                LAST_UPDATED_BY       = Fnd_Global.USER_ID,
                LAST_UPDATE_LOGIN     = Fnd_Global.LOGIN_ID
            WHERE VISIT_TASK_ID = p_visit_task_id;
          END IF;

        ELSIF l_project_tsk_flag = 'N' AND l_proj_ref_flag = 'Y' THEN
          x_return_status := Fnd_Api.g_ret_sts_error;
          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
             Fnd_Message.set_name ('AHL', 'AHL_VWP_PROJ_TSK_REF_NOT_UNIQ');
             Fnd_Msg_Pub.ADD;
          END IF;
        ELSIF l_project_tsk_flag = 'Y' AND l_proj_ref_flag = 'N' THEN
          x_return_status := Fnd_Api.g_ret_sts_error;
          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
             Fnd_Message.set_name ('AHL', 'AHL_VWP_PROJ_TSK_NUM_NOT_UNIQ');
             Fnd_Msg_Pub.ADD;
          END IF;
        ELSE
          x_return_status := Fnd_Api.g_ret_sts_error;
          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
             Fnd_Message.set_name ('AHL', 'AHL_VWP_PROJ_TASK_NOT_UNIQUE');
             Fnd_Msg_Pub.ADD;
          END IF;
        END IF;
   END IF;

 END IF; -- l_chk_project
 ---------------------------End of Body-------------------------------------
  --
  -- END of API body.
  --
  -- Standard check of p_commit.

   IF Fnd_Api.To_Boolean (p_commit) THEN
      COMMIT WORK;
   END IF;

   Fnd_Msg_Pub.count_and_get(
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
  );

   IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,L_DEBUG_KEY ||'.end','End of the procedure');
   END IF;

EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Add_Task_to_Project;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Add_Task_to_Project;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN OTHERS THEN
      ROLLBACK TO Add_Task_to_Project;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error) THEN
         Fnd_Msg_Pub.add_exc_msg (G_PKG_NAME, L_API_NAME);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
END Add_Task_to_Project;

--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Task_to_Project
--
-- PURPOSE
--    To delete Project and its tasks if visit in VWP is deleted
--------------------------------------------------------------------
PROCEDURE Delete_Task_to_Project(
   p_visit_task_id   IN  NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2)
AS
  -- Define local Variables
   L_API_NAME      CONSTANT VARCHAR2(30) := 'Delete_Task_to_Project';
   L_DEBUG_KEY         CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   l_count           NUMBER;
   l_msg_count       NUMBER;
   l_project_id      NUMBER;
   l_task_id         NUMBER;
   i                 NUMBER;

   l_return_status   VARCHAR2(1);
   l_chk_project     VARCHAR2(1);
   l_del_task_flag   VARCHAR2(1);
   l_commit          VARCHAR2(1) := 'F';
   l_init_msg_list   VARCHAR2(1) := 'F';
   l_default         VARCHAR2(30);
   l_msg_data        VARCHAR2(2000);
   G_EXC_ERROR       EXCEPTION;

 -- Define local Cursors
   -- To find all tasks related information
   CURSOR c_Task (x_id IN NUMBER) IS
      SELECT * FROM Ahl_Visit_Tasks_VL
      WHERE Visit_Task_ID = x_id;
      c_task_rec    c_Task%ROWTYPE;

    -- To find visit related information
   CURSOR c_visit (x_id IN NUMBER) IS
    SELECT * FROM AHL_VISITS_VL
    WHERE VISIT_ID = x_id;
   c_visit_rec c_visit%ROWTYPE;

BEGIN

    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

    IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,L_DEBUG_KEY ||'.begin','At the start of the procedure');
    END IF;

    OPEN c_task (p_visit_task_id);
    FETCH c_task INTO c_task_rec;
    CLOSE c_task;

    OPEN c_visit (c_task_rec.visit_id);
    FETCH c_visit INTO c_visit_rec;
    CLOSE c_visit;

    -- To check Project responsibilites
    -- Post 11.5.10
    -- RROY
   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Before calling AHL_VWP_RULES_PVT.Check_Proj_Responsibility');
   END IF;
    AHL_VWP_RULES_PVT.Check_Proj_Responsibility
          ( x_check_project    => l_chk_project,
            x_return_status    => l_return_status);

     IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,
                       L_DEBUG_KEY,
                       'After calling AHL_VWP_RULES_PVT.Check_Proj_Responsibility. Return Status = ' || l_return_status);
     END IF;

     IF (l_return_status <> Fnd_Api.G_RET_STS_SUCCESS) THEN
        IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Errors from AHL_VWP_RULES_PVT.Check_Proj_Responsibility');
        END IF;
        x_return_status := l_return_status;
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSE
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
     END IF;

    IF l_chk_project = 'Y' THEN
        IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,L_DEBUG_KEY,'Before calling PA_PROJECT_PUB.CHECK_DELETE_TASK_OK');
           fnd_log.string(l_log_statement,L_DEBUG_KEY,'c_visit_rec.PROJECT_ID - '|| c_visit_rec.PROJECT_ID);
           fnd_log.string(l_log_statement,L_DEBUG_KEY,'c_visit_rec.visit_number - '|| c_visit_rec.visit_number);
           fnd_log.string(l_log_statement,L_DEBUG_KEY,'c_task_rec.PROJECT_TASK_ID - '|| c_task_rec.PROJECT_TASK_ID);
           fnd_log.string(l_log_statement,L_DEBUG_KEY,'c_task_rec.VISIT_TASK_NUMBER - '|| c_task_rec.VISIT_TASK_NUMBER);
           fnd_log.string(l_log_statement,L_DEBUG_KEY,'l_del_task_flag - '|| l_del_task_flag);
        END IF;

        PA_PROJECT_PUB.CHECK_DELETE_TASK_OK
                ( p_api_version_number     => 1
                  , p_init_msg_list         =>  l_init_msg_list
                  , p_return_status         => l_return_status
                  , p_msg_count           => l_msg_count
                  , p_msg_data           => l_msg_data
                  , p_project_id       => c_visit_rec.PROJECT_ID
                  , p_pm_project_reference   =>  c_visit_rec.visit_number
                  , p_task_id           =>  c_task_rec.PROJECT_TASK_ID
                  , p_pm_task_reference     =>  c_task_rec.VISIT_TASK_NUMBER
                  , p_delete_task_ok_flag   => l_del_task_flag
                );

      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'After calling PA_PROJECT_PUB.check_delete_task_ok. Return Status = ' ||
                        l_return_status || ', delete task flag = ' || l_del_task_flag);
      END IF;

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Errors from PA_PROJECT_PUB.check_delete_task_ok. Message count: ' ||
                            l_msg_count || ', message data: ' || l_msg_data);
         END IF;
         x_return_status := l_return_status;
         RAISE FND_API.G_EXC_ERROR;
      ELSE
         IF l_del_task_flag = 'Y' THEN
            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'Before calling PA_PROJECT_PUB.delete_task.');
            END IF;

            PA_PROJECT_PUB.DELETE_TASK
                    ( p_api_version_number    =>   1
                     ,p_commit              =>   l_commit
                     ,p_init_msg_list        =>   l_init_msg_list
                     ,p_msg_count          =>  l_msg_count
                     ,p_msg_data          =>  l_msg_data
                     ,p_return_status        =>  l_return_status
                     ,p_pm_product_code        =>  G_PM_PRODUCT_CODE
                     ,p_pm_project_reference  =>   c_visit_rec.visit_number
                     ,p_pa_project_id        =>  c_visit_rec.PROJECT_ID
                     ,p_pm_task_reference    =>  c_task_rec.VISIT_TASK_NUMBER
                     ,p_pa_task_id          =>  c_task_rec.PROJECT_TASK_ID
                     ,p_cascaded_delete_flag  =>  'N'
                     ,p_project_id          =>  l_project_id
                     ,p_task_id              =>  l_task_id
                    );

            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'After calling PA_PROJECT_PUB.delete_task. Return Status = ' ||
                              l_return_status);
            END IF;

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               IF (l_log_statement >= l_log_current_level) THEN
                  fnd_log.string(l_log_statement,
                                 L_DEBUG_KEY,
                                 'Errors from PA_PROJECT_PUB.delete_task. Message count: ' ||
                                 l_msg_count || ', message data: ' || l_msg_data);
               END IF;
               x_return_status := Fnd_Api.g_ret_sts_error;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
          END IF;
        END IF;
    END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;

END Delete_Task_to_Project;

--------------------------------------------------------------------
-- PROCEDURE
--    Create_Project
--
-- PURPOSE
--    To create Project and project tasks for the visit and its tasks
--------------------------------------------------------------------
PROCEDURE Create_Project(
   p_visit_id        IN  NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2)
AS
--
  -- Define local Variables
   L_API_NAME     CONSTANT VARCHAR2(30) := 'Create_Project';
   L_DEBUG_KEY    CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
   l_count                 NUMBER;
   l_msg_count             NUMBER;
   l_obj_version           NUMBER;
   l_created_project_id    NUMBER;
   l_msg_index_out         NUMBER;
   i                       NUMBER;
   Z                       NUMBER;
   CREATED_FROM_PROJECT_ID NUMBER;
   l_return_status         VARCHAR2(1);
   l_chk_project           VARCHAR2(1);
   l_workflow_started      VARCHAR2(1);
   l_valid_flag            VARCHAR2(1):= 'N';
   l_commit                VARCHAR2(1) := 'F';
   l_init_msg_list         VARCHAR2(1) := 'F';
   l_project_flag          VARCHAR2(1):= 'N';
   l_default               VARCHAR2(30);
   l_msg_data              VARCHAR2(2000);
   G_EXC_ERROR             EXCEPTION;

   -- Define local table and record datatypes
   l_project_rec        PA_PROJECT_PUB.PROJECT_IN_REC_TYPE;
   l_project_out        PA_PROJECT_PUB.PROJECT_OUT_REC_TYPE;
   l_task_in            PA_PROJECT_PUB.TASK_IN_TBL_TYPE;
   l_task_out           PA_PROJECT_PUB.TASK_OUT_TBL_TYPE;
   l_key_members        PA_PROJECT_PUB.PROJECT_ROLE_TBL_TYPE;
   l_class_categories   PA_PROJECT_PUB.CLASS_CATEGORY_TBL_TYPE;
   -- Post 11.5.10
   -- RROY
   l_param_data         PJM_PROJECT_PARAM_PUB.ParamRecType;
   -- yazhou 26Sept2005 starts
   -- ER#4618348
   -- l_project_name_prefix  VARCHAR2(10);
   l_project_num_prefix      VARCHAR2(10);
   l_visit_name_len          NUMBER;
   -- yazhou 26Sept2005 ends
   --Bug#5587893
   /*sowsubra - Added a new profile that enables user to specify project status
   when a visit is pushed to prodn.*/
   l_project_status_code   VARCHAR2(30);
   l_new_txns_flag         VARCHAR2(1):= 'N'; -- Added by rnahata for Bug 6334682

   -- Define local Cursors
   -- To find visit related information
   CURSOR c_visit (x_id IN NUMBER) IS
    SELECT * FROM AHL_VISITS_VL
    WHERE VISIT_ID = x_id;
   c_visit_rec c_visit%ROWTYPE;

   -- To find count for tasks for visit
   CURSOR c_task_ct (x_id IN NUMBER) IS
    SELECT count(*) FROM AHL_VISIT_TASKS_VL
    WHERE VISIT_ID = x_id
     AND NVL(status_code, 'Y') <> NVL ('DELETED', 'X')    ;

   -- To find tasks information for visit
   CURSOR c_task (x_id IN NUMBER) IS
    SELECT * FROM AHL_VISIT_TASKS_VL
    WHERE VISIT_ID = x_id
     AND NVL(status_code, 'Y') <> NVL ('DELETED', 'X')    ;
   c_task_rec c_task%ROWTYPE;

   -- To find tasks information for visit
   CURSOR c_task_OVN (x_id IN NUMBER, x_task_num IN NUMBER) IS
    SELECT OBJECT_VERSION_NUMBER FROM AHL_VISIT_TASKS_VL
    WHERE VISIT_ID = x_id AND VISIT_TASK_NUMBER = x_task_num;

   -- To get the cost group for the Org
   CURSOR c_cost_group(p_org_id IN NUMBER) IS
   SELECT default_cost_group_id
   FROM mtl_parameters
    WHERE organization_id = p_org_id;

   -- Added by rnahata for Bug 6334682
   CURSOR c_new_txns_flag(c_project_status_code IN VARCHAR) IS
    SELECT ENABLED_FLAG FROM PA_PROJECT_STATUS_CONTROLS
    WHERE PROJECT_STATUS_CODE LIKE c_project_status_code
     AND ACTION_CODE LIKE 'NEW_TXNS';

   /*Added by rnahata for Bug 5758813 - fetches the task details for all the tasks in the visit
    The first part of the union fetches task details for all the Planned and Unplanned tasks.
    The second part fetches task details of all the MR/NR/SR Summary tasks.
    The third part fetches task details of all the manually created Summary and Unassociated tasks.
    */
   CURSOR get_prj_route_dtls_cur (p_visit_id IN NUMBER) IS
    SELECT SUBSTR(NVL(ar.route_no,avt.visit_task_name),1,20) task_name,
    SUBSTR(NVL(ar.title,avt.visit_task_name),1,250) description,
    avt.visit_task_name, avt.visit_task_number, avt.start_date_time task_start_date,
    avt.end_date_time task_end_date
    FROM ahl_routes_vl ar,ahl_visit_tasks_vl avt, ahl_mr_routes mrr
    WHERE avt.visit_id = p_visit_id
     AND NVL(avt.status_code,'Y') = 'PLANNING'
     AND avt.task_type_code NOT IN ('SUMMARY','UNASSOCIATED')
     AND avt.mr_route_id = mrr.mr_route_id (+)
     AND mrr.route_id = ar.route_id (+)
    UNION ALL
    SELECT SUBSTR(NVL(amh.title,avt.visit_task_name),1,20) task_name, NVL(amh.title,avt.visit_task_name) description,
    avt.visit_task_name, avt.visit_task_number, avt.start_date_time task_start_date,
    avt.end_date_time task_end_date
    FROM ahl_mr_headers_v amh,ahl_visit_tasks_vl avt
    WHERE avt.visit_id = p_visit_id
     AND NVL(avt.status_code,'Y') = 'PLANNING'
     AND avt.task_type_code = 'SUMMARY'
     AND avt.summary_task_flag = 'N'
     AND avt.mr_id = amh.mr_header_id (+)
    UNION ALL
    SELECT SUBSTR(avt.visit_task_name,1,20) task_name, avt.visit_task_name description,
    avt.visit_task_name, avt.visit_task_number, avt.start_date_time task_start_date,
    avt.end_date_time task_end_date
    FROM ahl_visit_tasks_vl avt
    WHERE avt.visit_id = p_visit_id
     AND NVL(avt.status_code,'Y') = 'PLANNING'
     AND ((avt.task_type_code = 'SUMMARY' AND avt.summary_task_flag = 'Y')
          OR (avt.task_type_code ='UNASSOCIATED'))
    ORDER BY 4;
   -- End changes by rnahata for Bug 5758813

    get_prj_route_dtls_rec  get_prj_route_dtls_cur%ROWTYPE;

BEGIN
   --  Initialize API return status to success
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Visit Id = ' || p_visit_id);
   END IF;

    --Bug#5587893
    /*sowsubra - starts */
    l_project_status_code := nvl(FND_PROFILE.VALUE('AHL_INITIAL_PROJECT_STATUS'),'SUBMITTED');

    /*
    IF (l_project_status_code IS NULL) THEN
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AHL', 'AHL_PROJECT_STATUS_NOT_SET');
         Fnd_Msg_Pub.ADD;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
    */
   /*sowsubra - ends */

    -- Begin changes by rnahata for Bug 6334682
    IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'Initial project status code is: ' || l_project_status_code);
    END IF;
    OPEN c_new_txns_flag(l_project_status_code);
    FETCH c_new_txns_flag INTO l_new_txns_flag;
    CLOSE c_new_txns_flag;
    IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'Create New Transaction Flag = ' || l_new_txns_flag);
    END IF;
    IF (l_new_txns_flag =  'N') THEN
       IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
          Fnd_Message.SET_NAME('AHL','AHL_PRJ_NEW_TXN_DISABLED');
          Fnd_Message.SET_TOKEN('PRJ_STATUS', l_project_status_code);
          Fnd_Msg_Pub.ADD;
       END IF;
       RAISE Fnd_Api.G_EXC_ERROR;
    END IF;
    -- End changes by rnahata for Bug 6334682

   OPEN c_Visit(p_visit_id);
   FETCH c_visit INTO c_visit_rec;
   CLOSE c_Visit;

   IF (c_visit_rec.START_DATE_TIME IS NOT NULL
       AND c_visit_rec.START_DATE_TIME <> Fnd_Api.G_MISS_DATE
       AND c_visit_rec.DEPARTMENT_ID IS NOT NULL
       AND c_visit_rec.DEPARTMENT_ID <> FND_API.G_MISS_NUM) THEN

      -- Post 11.5.10
      -- RROY
      IF c_visit_rec.project_template_id IS NOT NULL THEN
         CREATED_FROM_PROJECT_ID := c_visit_rec.project_template_id;
      ELSE
         CREATED_FROM_PROJECT_ID := nvl(FND_PROFILE.VALUE('AHL_DEFAULT_PA_TEMPLATE_ID'),0);
      END IF;

      IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,L_DEBUG_KEY,'CREATED_FROM_PROJECT_ID = '||CREATED_FROM_PROJECT_ID);
      END IF;

      -- yazhou 26Sept2005 starts
      -- ER#4618348

      --l_project_name_prefix := SUBSTR(FND_PROFILE.VALUE('AHL_PROJECT_PREFIX'),1,10);
      l_project_num_prefix := SUBSTR(FND_PROFILE.VALUE('AHL_PROJECT_NUM_PREFIX'),1,10);

      IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,L_DEBUG_KEY,'l_project_num_prefix = '||l_project_num_prefix);
      END IF;

      --l_visit_name_len := 30 - nvl(length(SubStr(l_project_name_prefix,1,255)),0);

      -- TO CREATE PROJECT IN PROJECTS
      l_Project_rec.PM_PROJECT_REFERENCE      := l_project_num_prefix || to_char(c_visit_rec.visit_number);
--    l_Project_rec.PROJECT_NAME              := l_project_name_prefix|| SUBSTR(c_visit_rec.visit_name,1,l_visit_name_len);
      l_Project_rec.PROJECT_NAME              := l_project_num_prefix || to_char(c_visit_rec.visit_number);
-- yazhou 26Sept2005 ends
      l_Project_rec.CREATED_FROM_PROJECT_ID   := CREATED_FROM_PROJECT_ID;
-- yazhou 08Nov2005 starts
-- Changed by jaramana on April 28, 2005 to fix Bug 4273892
--    l_Project_rec.PROJECT_STATUS_CODE       := 'ACTIVE';
-- Changed by sowsubra to fix Bug#5587893
--    l_Project_rec.PROJECT_STATUS_CODE       := 'SUBMITTED';
      l_Project_rec.PROJECT_STATUS_CODE       := l_project_status_code ;
-- yazhou 08Nov2005 ends

-- AnRaj: Changed for Bug#5069540
      -- SKPATHAK :: Bug 8321556 :: 23-MAR-2009 :: Use SUBSTRB instead of SUBSTR
      l_Project_rec.DESCRIPTION               := SUBSTRB(c_visit_rec.description,1,250);
      --Fix for the Bug 7009212. rnahata truncated the time components
      l_Project_rec.START_DATE              := trunc(c_visit_rec.start_date_time);
      l_Project_rec.COMPLETION_DATE         := trunc(c_visit_rec.close_date_time);
      l_Project_rec.SCHEDULED_START_DATE    := trunc(c_visit_rec.start_date_time);
      --rnahata End

      OPEN c_task_ct(p_visit_id);
      FETCH c_task_ct INTO l_count;
      CLOSE c_task_ct;

      IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,L_DEBUG_KEY,'Tasks Count = '||l_count);
      END IF;

      IF l_count > 0 THEN
        IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,L_DEBUG_KEY,'Inside Tasks as Count more than zero');
        END IF;
        -- Begin changes by rnahata for Bug 5758813
        OPEN get_prj_route_dtls_cur(p_visit_id);
        i:=1;
        LOOP
             FETCH get_prj_route_dtls_cur INTO get_prj_route_dtls_rec;
             EXIT WHEN get_prj_route_dtls_cur%NOTFOUND;
             l_task_in(i).PM_TASK_REFERENCE         := get_prj_route_dtls_rec.visit_task_number;
             l_task_in(i).TASK_NAME                 := get_prj_route_dtls_rec.task_name;
             l_task_in(i).PA_TASK_NUMBER            := get_prj_route_dtls_rec.visit_task_number;
             l_task_in(i).TASK_DESCRIPTION          := get_prj_route_dtls_rec.description;
             --Fix for the Bug 7009212. rnahata truncated the time components
             l_task_in(i).TASK_START_DATE           := trunc(get_prj_route_dtls_rec.task_start_date);
             l_task_in(i).TASK_COMPLETION_DATE      := trunc(get_prj_route_dtls_rec.task_end_date);
             --rnahata End
             i := i + 1;
         END LOOP;
         CLOSE get_prj_route_dtls_cur;
         -- End changes by rnahata for Bug 5758813
      END IF; -- End of l_count

      IF l_task_in.COUNT > 0 THEN
        i := l_task_in.FIRST;
        LOOP
          IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,L_DEBUG_KEY,'TASK REFERENCE - '|| l_task_in(i).PM_TASK_REFERENCE);
            fnd_log.string(l_log_statement,L_DEBUG_KEY,'TASK NAME - '|| l_task_in(i).TASK_NAME);
            fnd_log.string(l_log_statement,L_DEBUG_KEY,'TASK NUMBER - '|| l_task_in(i).PA_TASK_NUMBER);
          END IF;
            EXIT WHEN i = l_task_in.LAST ;
            i := l_task_in.NEXT(i);
         END LOOP;
      END IF;  -- End of l_task_in

      -- To check Project responsibilites
      -- Post 11.5.10
      -- RROY

      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Before calling AHL_VWP_RULES_PVT.Check_Proj_Responsibility');
      END IF;

      AHL_VWP_RULES_PVT.Check_Proj_Responsibility
      (x_check_project => l_chk_project,
       x_return_status => l_return_status);

      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'After calling AHL_VWP_RULES_PVT.Check_Proj_Responsibility. Return Status = ' || l_return_status);
      END IF;

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Errors from AHL_VWP_RULES_PVT.Check_Proj_Responsibility');
         END IF;
         x_return_status := l_return_status;
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSE
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      IF l_chk_project = 'Y' THEN
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Before calling PA_PROJECT_PUB.check_unique_project_reference to check for ' || l_project_num_prefix || c_visit_rec.visit_number);
         END IF;

         PA_PROJECT_PUB.Check_Unique_Project_Reference(
            p_api_version_number      => 1,
            p_init_msg_list           => l_init_msg_list,
            p_return_status           => l_return_status,
            p_msg_count               => l_msg_count,
            p_msg_data                => l_msg_data,
            -- Modified by rnahata on February 19, 2008 for Bug 6685071
            -- by prepending the l_project_num_prefix
            p_pm_project_reference    => l_project_num_prefix || c_visit_rec.visit_number,
            p_unique_project_ref_flag => l_project_flag);

         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Returned from PA_PROJECT_PUB.check_unique_project_reference: p_unique_project_ref_flag = ' || l_project_flag || ', Return Status = ' || l_return_status );
         END IF;

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'Errors from PA_PROJECT_PUB.check_unique_project_reference. Message count: ' ||
                              l_msg_count || ', message data: ' || l_msg_data);
            END IF;
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSE
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

         IF l_project_flag = 'Y' THEN
            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'Before calling PA_PROJECT_PUB.create_project');
            END IF;

            PA_PROJECT_PUB.CREATE_PROJECT
            (p_api_version_number => 1,
             p_commit             => l_commit,
             p_init_msg_list      => l_init_msg_list,
             p_msg_count          => l_msg_count,
             p_msg_data           => l_msg_data,
             p_return_status      => x_return_status,
             p_workflow_started   => l_workflow_started,
             p_pm_product_code    => G_PM_PRODUCT_CODE,
             p_project_in         => l_project_rec,
             p_project_out        => l_project_out,
             p_key_members        => l_key_members,
             p_class_categories   => l_class_categories,
             p_tasks_in           => l_task_in,
             p_tasks_out          => l_task_out
            );

            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'After calling PA_PROJECT_PUB.create_project. Project_Id = ' ||
                              l_project_out.pa_project_id || ' Return Status = ' || x_return_status);
            END IF;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               IF (l_log_statement >= l_log_current_level) THEN
                  fnd_log.string(l_log_statement,
                                 L_DEBUG_KEY,
                                 'Errors from PA_PROJECT_PUB.create_project. Message count: ' ||
                                 l_msg_count || ', message data: ' || l_msg_data);
               END IF;
               IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
               ELSE
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

            IF x_return_status = 'S' THEN
               UPDATE AHL_VISITS_B
               SET PROJECT_ID = l_project_out.pa_project_id,
                   OBJECT_VERSION_NUMBER = c_visit_rec.object_version_number + 1,
                   --TCHIMIRA::BUG 9222622 ::15-DEC-2009::UPDATE WHO COLUMNS
                   LAST_UPDATE_DATE      = SYSDATE,
                   LAST_UPDATED_BY       = Fnd_Global.USER_ID,
                   LAST_UPDATE_LOGIN     = Fnd_Global.LOGIN_ID
               WHERE VISIT_ID = p_visit_id;
               -- RROY
               -- Post 11.5.10
               -- Call Create_Project_Parameter API
               -- RROY
               -- Confirm the parameters
               -- Other parameters are not mandatory

               OPEN c_cost_group(c_visit_rec.organization_id);
               FETCH c_cost_group INTO l_param_data.cost_group_id;
               CLOSE c_cost_group;

               l_param_data.project_id := l_project_out.pa_project_id;
               l_param_data.organization_id := c_visit_rec.organization_id;
               --l_param_data.cost_group_id := NVL(l_param_data.cost_group_id,1);
               l_param_data.wip_acct_class_code := NULL;
               l_param_data.eam_acct_class_code := NULL;
               l_param_data.ipv_expenditure_type := NULL;
               l_param_data.erv_expenditure_type := NULL;
               l_param_data.freight_expenditure_type := NULL;
               l_param_data.tax_expenditure_type := NULL;
               l_param_data.misc_expenditure_type := NULL;
               l_param_data.ppv_expenditure_type := NULL;
               l_param_data.dir_item_expenditure_type := 'Machine Usage';
               -- yazhou 06Oct2005 starts
               -- Bug fix #4658861
               --l_param_data.start_date_active := c_visit_rec.start_date_time;
               --l_param_data.end_date_active := c_visit_rec.close_date_time;
               l_param_data.start_date_active := NULL;
               l_param_data.end_date_active := NULL;
               -- yazhou 06Oct2005 ends
               -- Changes made by jaramana on May 5, 2006 to accommodate PJM Bug 5197977/5194650
               IF (l_log_statement >= l_log_current_level) THEN
                   FND_LOG.STRING(l_log_statement, L_DEBUG_KEY, 'About to set MFG_ORGANIZATION_ID Profile with ' || c_visit_rec.organization_id);
               END IF;
               FND_PROFILE.PUT('MFG_ORGANIZATION_ID', TO_CHAR(c_visit_rec.organization_id));

               PJM_PROJECT_PARAM_PUB.Create_Project_Parameter(
                    p_api_version   => 1.0,
                    p_init_msg_list => l_init_msg_list,
                    p_commit        => l_commit,
                    x_return_status => l_return_status,
                    x_msg_count     => l_msg_count,
                    x_msg_data      => l_msg_data,
                    p_param_data    => l_param_data);

               IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                  IF (l_log_statement >= l_log_current_level) THEN
                     fnd_log.string(l_log_statement,
                                    L_DEBUG_KEY,
                                    'Errors from PJM_PROJECT_PARAM_PUB.Create_Project_Parameter. Message count: ' ||
                                    l_msg_count || ', message data: ' || l_msg_data);
                  END IF;

                  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                  ELSE
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;
               -- RROY
               IF l_task_out.COUNT > 0 THEN
                  z := l_task_out.FIRST;
                  LOOP
                     IF (l_log_statement >= l_log_current_level) THEN
                        fnd_log.string(l_log_statement,
                                       L_DEBUG_KEY,
                                       'Updating all tasks project_task_id = ' ||
                                       l_task_out(z).pa_task_id);
                     END IF;

                     OPEN c_Task_OVN(p_visit_id,l_task_in(z).PA_TASK_NUMBER);
                     FETCH c_Task_OVN INTO l_obj_version;
                     CLOSE c_Task_OVN;

                     UPDATE AHL_VISIT_TASKS_B
                     SET PROJECT_TASK_ID = l_task_out(z).pa_task_id,
                         OBJECT_VERSION_NUMBER = l_obj_version + 1,
                         --TCHIMIRA::BUG 9222622 ::15-DEC-2009::UPDATE WHO COLUMNS
                         LAST_UPDATE_DATE      = SYSDATE,
                         LAST_UPDATED_BY       = Fnd_Global.USER_ID,
                         LAST_UPDATE_LOGIN     = Fnd_Global.LOGIN_ID
                     WHERE VISIT_ID = p_visit_id AND VISIT_TASK_NUMBER = l_task_in(z).PA_TASK_NUMBER;

                     EXIT WHEN z = l_task_out.LAST ;
                     z := l_task_out.NEXT(z);
                  END LOOP;
               END IF; -- End of l_task_out.COUNT
            END IF; -- End of x_return_status = 'S'
         ELSE -- Else of l_project_flag = 'Y'
            x_return_status := Fnd_Api.g_ret_sts_error;
            IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
              Fnd_Message.set_name ('AHL', 'AHL_VWP_PROJECT_NOT_UNIQUE');
              Fnd_Msg_Pub.ADD;
            END IF;
         END IF; -- End of l_project_flag = 'Y'
      END IF;  --- End of l_chk_project = 'Y'
   ELSIF c_visit_rec.START_DATE_TIME IS NULL or c_visit_rec.START_DATE_TIME = Fnd_Api.G_MISS_DATE THEN
      x_return_status := Fnd_Api.g_ret_sts_error;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AHL', 'AHL_VWP_VISIT_ST_DT_MISSING');
         Fnd_Msg_Pub.ADD;
      END IF;
   END IF;  -- End of Start Time and Department null Check

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;
END Create_Project;

--------------------------------------------------------------------
-- PROCEDURE
--    Update_Project
--
-- PURPOSE
--    To update Project status to CLOSED when visit is set as Closed/Canceled
--------------------------------------------------------------------
PROCEDURE Update_Project(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type       IN  VARCHAR2  := Null,
   p_visit_id          IN  NUMBER,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2)
AS
  -- Define local Variables
   L_API_NAME     CONSTANT VARCHAR2(30)  := 'Update_Project';
   L_API_VERSION  CONSTANT NUMBER := 1.0;
   L_DEBUG_KEY    CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
   l_count                 NUMBER;
   l_msg_count             NUMBER;
   l_created_project_id    NUMBER;
   i                       NUMBER;
   l_msg_index_out         NUMBER;
   CREATED_FROM_PROJECT_ID NUMBER;
   l_return_status         VARCHAR2(1);
   l_chk_project           VARCHAR2(1);
   l_workflow_started      VARCHAR2(1);
   l_valid_flag            VARCHAR2(1):= 'N';
   l_commit                VARCHAR2(1) := 'F';
   l_init_msg_list         VARCHAR2(1) := 'F';
   l_default               VARCHAR2(30);
   l_msg_data              VARCHAR2(2000);
   G_EXC_ERROR             EXCEPTION;

  -- Define local table and record datatypes
   l_project_rec       PA_PROJECT_PUB.PROJECT_IN_REC_TYPE;
   l_project_out       PA_PROJECT_PUB.PROJECT_OUT_REC_TYPE;
   l_param_data        PJM_PROJECT_PARAM_PUB.ParamRecType;
   l_task_in           PA_PROJECT_PUB.TASK_IN_TBL_TYPE;
   l_task_out          PA_PROJECT_PUB.TASK_OUT_TBL_TYPE;
   l_key_members       PA_PROJECT_PUB.PROJECT_ROLE_TBL_TYPE;
   l_class_categories  PA_PROJECT_PUB.CLASS_CATEGORY_TBL_TYPE;

   -- yazhou 26Sept2005 starts
   -- ER#4618348
   -- l_project_name_prefix  VARCHAR2(10);
   l_project_num_prefix      VARCHAR2(10);
   l_visit_name_len          NUMBER;
   -- yazhou 26Sept2005 ends

 -- Define local Cursors
    -- To find visit related information
   CURSOR c_visit (x_id IN NUMBER) IS
    SELECT * FROM AHL_VISITS_VL
    WHERE VISIT_ID = x_id;
   c_visit_rec c_visit%ROWTYPE;

  -- To find count for tasks for visit
   CURSOR c_task_ct (x_id IN NUMBER) IS
    SELECT count(*) FROM AHL_VISIT_TASKS_VL
    WHERE VISIT_ID = x_id
     AND NVL(status_code, 'Y') <> NVL ('DELETED', 'X')    ;

   -- To find tasks information for visit
   CURSOR c_task (x_id IN NUMBER) IS
    SELECT * FROM AHL_VISIT_TASKS_VL
    WHERE VISIT_ID = x_id
     AND NVL(status_code, 'Y') <> NVL ('DELETED', 'X')    ;
   c_task_rec c_task%ROWTYPE;

  -- To find tasks information for visit
   CURSOR c_task_proj (x_id IN NUMBER) IS
    SELECT TASK_ID, TASK_NUMBER
    FROM PA_TASKS
    WHERE PROJECT_ID = x_id;
   c_task_proj_rec c_task_proj%ROWTYPE;

  CURSOR c_pjm_param(x_proj_id IN NUMBER,x_org_id IN NUMBER) IS
  SELECT 'x'
  FROM   pjm_project_parameters_v
  WHERE  project_id = x_proj_id
  AND    organization_id = x_org_id;

  l_dummy VARCHAR2(1);

  -- To get the cost group for the Org
  CURSOR c_cost_group(p_org_id IN NUMBER) IS
  SELECT default_cost_group_id
  FROM mtl_parameters
  WHERE organization_id = p_org_id;

  --Bug#5587893
  /*sowsubra - starts*/
  -- To get the project status for visit updation
  CURSOR c_proj_status_code(x_id IN NUMBER) IS
  SELECT ppa.project_status_code
  FROM ahl_visits_b avb, pa_projects_all ppa
  WHERE avb.visit_id = x_id
  AND avb.project_id = ppa.project_id;

  l_prj_status_code_fdb   pa_projects_all.project_status_code%TYPE;
  /*sowsubra - ends*/

  /*
  Modified by rnahata for Bug 5758813
  Fetches the task details for all the tasks in the visit
  The first part of the union fetches task details for all the Planned and Unplanned tasks.
  The second part fetches task details of all the MR/NR/SR Summary tasks.
  The third part fetches task details of all the manually created Summary and Unassociated tasks.
  */
  CURSOR get_prj_route_dtls_cur (p_visit_id IN NUMBER) IS
   SELECT SUBSTR(NVL(ar.route_no,avt.visit_task_name),1,20) task_name,
   SUBSTR(NVL(ar.title,avt.visit_task_name),1,250) description,
   avt.visit_task_name, avt.visit_task_number, avt.start_date_time task_start_date,
   avt.end_date_time task_end_date, avt.project_Task_id project_task_id
   FROM ahl_routes_vl ar,ahl_visit_tasks_vl avt, ahl_mr_routes mrr
   WHERE avt.visit_id = p_visit_id
    AND NVL(avt.status_code,'Y') = 'PLANNING'
    AND avt.task_type_code NOT IN ('SUMMARY','UNASSOCIATED')
    AND avt.mr_route_id = mrr.mr_route_id (+)
    AND mrr.route_id = ar.route_id (+)
   UNION ALL
   SELECT SUBSTR(NVL(amh.title,avt.visit_task_name),1,20) task_name, NVL(amh.title,avt.visit_task_name) description,
   avt.visit_task_name, avt.visit_task_number, avt.start_date_time task_start_date,
   avt.end_date_time task_end_date, avt.project_Task_id project_task_id
   FROM ahl_mr_headers_v amh,ahl_visit_tasks_vl avt
   WHERE avt.visit_id = p_visit_id
    AND NVL(avt.status_code,'Y') = 'PLANNING'
    AND avt.task_type_code = 'SUMMARY'
    AND avt.summary_task_flag = 'N'
    AND avt.mr_id = amh.mr_header_id (+)
   UNION ALL
   SELECT SUBSTR(avt.visit_task_name,1,20) task_name, avt.visit_task_name description,
   avt.visit_task_name, avt.visit_task_number, avt.start_date_time task_start_date,
   avt.end_date_time task_end_date, avt.project_Task_id project_task_id
   FROM ahl_visit_tasks_vl avt
   WHERE avt.visit_id = p_visit_id
    AND NVL(avt.status_code,'Y') = 'PLANNING'
    AND ((avt.task_type_code = 'SUMMARY' AND avt.summary_task_flag = 'Y')
     OR (avt.task_type_code ='UNASSOCIATED'))
   ORDER BY 4;
  -- End changes by rnahata for Bug 5758813

  get_prj_route_dtls_rec  get_prj_route_dtls_cur%ROWTYPE;

BEGIN
    SAVEPOINT Update_project;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Visit Id = ' || p_visit_id);
   END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF Fnd_Api.to_boolean(p_init_msg_list) THEN
      Fnd_Msg_Pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
    THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- To check Project responsibilites
    -- Post 11.5.10
    -- RROY
   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Before calling AHL_VWP_RULES_PVT.Check_Proj_Responsibility');
   END IF;
    AHL_VWP_RULES_PVT.Check_Proj_Responsibility
          ( x_check_project    => l_chk_project,
            x_return_status    => l_return_status);

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'After calling AHL_VWP_RULES_PVT.Check_Proj_Responsibility. Return Status = ' || l_return_status);
   END IF;

   IF (l_return_status <> Fnd_Api.G_RET_STS_SUCCESS) THEN
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Errors from AHL_VWP_RULES_PVT.Check_Proj_Responsibility');
      END IF;
      x_return_status := l_return_status;
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSE
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

    IF l_chk_project = 'Y' THEN
      OPEN c_Visit(p_visit_id);
      FETCH c_visit INTO c_visit_rec;
      CLOSE c_Visit;

      --Bug#5587893
      OPEN c_proj_status_code(p_visit_id);
      FETCH c_proj_status_code INTO l_prj_status_code_fdb;
      CLOSE c_proj_status_code;

      IF p_module_type = 'DEL' AND (c_visit_rec.start_date_time is null OR c_visit_rec.start_date_time =Fnd_Api.G_MISS_DATE) then
        c_visit_rec.start_date_time := SYSDATE;
      END IF;

      IF (c_visit_rec.START_DATE_TIME IS NOT NULL
        AND c_visit_rec.START_DATE_TIME <> Fnd_Api.G_MISS_DATE
        AND c_visit_rec.DEPARTMENT_ID IS NOT NULL
        AND c_visit_rec.DEPARTMENT_ID <> FND_API.G_MISS_NUM) THEN

        IF c_visit_rec.project_template_id IS NOT NULL THEN
          CREATED_FROM_PROJECT_ID := c_visit_rec.project_template_id;
        ELSE
          CREATED_FROM_PROJECT_ID := nvl(FND_PROFILE.VALUE('AHL_DEFAULT_PA_TEMPLATE_ID'),0);
        END IF;

        -- yazhou 26Sept2005 starts
        -- ER#4618348

        --l_project_name_prefix := SUBSTR(FND_PROFILE.VALUE('AHL_PROJECT_PREFIX'),1,10);
        l_project_num_prefix := SUBSTR(FND_PROFILE.VALUE('AHL_PROJECT_NUM_PREFIX'),1,10);

        IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,L_DEBUG_KEY,'l_project_num_prefix = ' || l_project_num_prefix);
        END IF;

        --l_visit_name_len := 30 - nvl(length(SubStr(l_project_name_prefix,1,255)),0);

        -- TO UPDATE PROJECT IN PROJECTS
        l_Project_rec.PM_PROJECT_REFERENCE      := l_project_num_prefix || to_char(c_visit_rec.visit_number);
        --l_Project_rec.PROJECT_NAME            := l_project_name_prefix|| SUBSTR(c_visit_rec.visit_name,1,l_visit_name_len);
        l_Project_rec.PROJECT_NAME              := l_project_num_prefix || to_char(c_visit_rec.visit_number);
        -- yazhou 26Sept2005 ends
        l_Project_rec.CREATED_FROM_PROJECT_ID   := CREATED_FROM_PROJECT_ID;
        -- AnRaj: Changed for Bug#5069540
        -- SKPATHAK :: Bug 8321556 :: 23-MAR-2009 :: Use SUBSTRB instead of SUBSTR
        l_Project_rec.DESCRIPTION               := SUBSTRB(c_visit_rec.description,1,250);
        --Fix for the Bug 7009212; rnahata truncated the dates
        l_Project_rec.START_DATE                := trunc(c_visit_rec.start_date_time);
        l_Project_rec.COMPLETION_DATE           := trunc(c_visit_rec.close_date_time);
        l_Project_rec.SCHEDULED_START_DATE      := trunc(c_visit_rec.start_date_time);
        --rnahata End
        l_Project_rec.PA_PROJECT_ID             := c_visit_rec.PROJECT_ID;
        /*-- Post 11.5.10
        -- RROY
        IF c_visit_rec.status_code = 'CLOSED' OR c_visit_rec.status_code = 'CANCELLED' THEN
               l_Project_rec.PROJECT_STATUS_CODE := 'CLOSED';
             ELSIF p_module_type = 'UPT' OR p_module_type = 'DEL' THEN
               l_Project_rec.PROJECT_STATUS_CODE := 'REJECTED';
             END IF;
        -- RROY*/
        -- Merge process for 11.5 10 bug fix on CMRDV10P env.
        -- Start
        IF c_visit_rec.status_code = 'CLOSED' OR c_visit_rec.status_code = 'CANCELLED' THEN
          l_Project_rec.PROJECT_STATUS_CODE := 'CLOSED';
        ELSIF p_module_type = 'UPT' OR p_module_type = 'DEL' THEN
          l_Project_rec.PROJECT_STATUS_CODE := 'REJECTED';
        ELSE
        -- yazhou 08Nov2005 starts
        -- Changed by jaramana on April 28, 2005 to fix Bug 4273892
        --l_Project_rec.PROJECT_STATUS_CODE       := 'ACTIVE';
        --l_Project_rec.PROJECT_STATUS_CODE := 'SUBMITTED';
        --Bug#5587893
        l_Project_rec.PROJECT_STATUS_CODE := l_prj_status_code_fdb;
        -- yazhou 08Nov2005 ends
      END IF;
      -- End

      IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,L_DEBUG_KEY,'After assigning all values to project record type');
      END IF;

      OPEN c_task_ct(p_visit_id);
      FETCH c_task_ct INTO l_count;
      CLOSE c_task_ct;

      IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,L_DEBUG_KEY,'Number of tasks = ' || l_count);
      END IF;

      IF l_count > 0 THEN
         -- Begin changes by rnahata for Bug 5758813
         OPEN get_prj_route_dtls_cur(p_visit_id);
         i := 1;
         LOOP
            FETCH get_prj_route_dtls_cur INTO get_prj_route_dtls_rec;
            EXIT WHEN get_prj_route_dtls_cur%NOTFOUND;
            l_task_in(i).PM_TASK_REFERENCE         := get_prj_route_dtls_rec.visit_task_number;
            l_task_in(i).TASK_NAME                 := get_prj_route_dtls_rec.task_name;
            l_task_in(i).PA_TASK_NUMBER            := get_prj_route_dtls_rec.visit_task_number;
            l_task_in(i).TASK_DESCRIPTION          := get_prj_route_dtls_rec.description;
            --Fix for the Bug 7009212; rnahata truncated the dates
            l_task_in(i).TASK_START_DATE           := trunc(get_prj_route_dtls_rec.task_start_date);
            l_task_in(i).TASK_COMPLETION_DATE      := trunc(get_prj_route_dtls_rec.task_end_date);
            --rnahata End
            l_task_in(i).PA_TASK_ID                := get_prj_route_dtls_rec.project_task_id;
            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'Visit Task ' || i || ': Name = ' || l_task_in(i).TASK_NAME);
            END IF;
            i := i + 1;
         END LOOP;
         CLOSE get_prj_route_dtls_cur;
         -- End changes by rnahata for Bug 5758813
      END IF;

      -- Need to update proejct for
      IF c_visit_rec.PROJECT_ID IS NOT NULL THEN
        IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,L_DEBUG_KEY,'Visit Project ID = ' || c_visit_rec.PROJECT_ID);
          fnd_log.string(l_log_statement,L_DEBUG_KEY,'Before calling PA_PROJECT_PUB.UPDATE_PROJECT');
        END IF;

        PA_PROJECT_PUB.UPDATE_PROJECT
                   (p_api_version_number     => 1,
                    p_commit                 => l_commit,
                    p_init_msg_list          => l_init_msg_list,
                    p_msg_count              => l_msg_count,
                    p_msg_data               => l_msg_data,
                    p_return_status          => l_return_status,
                    p_workflow_started       => l_workflow_started,
                    p_pm_product_code        => G_PM_PRODUCT_CODE,
                    p_project_in             => l_project_rec,
                    p_project_out            => l_project_out,
                    p_key_members            => l_key_members,
                    p_class_categories       => l_class_categories,
                    p_tasks_in                => l_task_in,
                    p_tasks_out               => l_task_out
                   );

        IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,L_DEBUG_KEY,'After calling PA_PROJECT_PUB.UPDATE_PROJECT - l_return_status = '||l_return_status);
        END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,L_DEBUG_KEY,'Errors from PA_PROJECT_PUB.UPDATE_PROJECT - l_msg_count = '||l_msg_count);
          END IF;
          RAISE Fnd_Api.g_exc_error;
        END IF;

        -- If the Visit Organisation is chnaged after costing
        -- need to set pjm paramters for the new org if it doesnot exist.
        OPEN c_pjm_param(c_visit_rec.project_id, c_visit_rec.organization_id);
        FETCH c_pjm_param INTO l_dummy;
        IF c_pjm_param%NOTFOUND THEN -- need to create for new org

            OPEN c_cost_group(c_visit_rec.organization_id);
            FETCH c_cost_group INTO l_param_data.cost_group_id;
            CLOSE c_cost_group;

            l_param_data.project_id := c_visit_rec.project_id;
            l_param_data.organization_id := c_visit_rec.organization_id;
            -- l_param_data.cost_group_id := NVL(l_param_data.cost_group_id,1);
            l_param_data.wip_acct_class_code := NULL;
            l_param_data.eam_acct_class_code := NULL;
            l_param_data.ipv_expenditure_type := NULL;
            l_param_data.erv_expenditure_type := NULL;
            l_param_data.freight_expenditure_type := NULL;
            l_param_data.tax_expenditure_type := NULL;
            l_param_data.misc_expenditure_type := NULL;
            l_param_data.ppv_expenditure_type := NULL;
            l_param_data.dir_item_expenditure_type := 'Machine Usage';
            -- yazhou 06Oct2005 starts
            -- Bug fix #4658861
            -- l_param_data.start_date_active := c_visit_rec.start_date_time;
            -- l_param_data.end_date_active := c_visit_rec.close_date_time;
            l_param_data.start_date_active := NULL;
            l_param_data.end_date_active := NULL;
            -- yazhou 06Oct2005 ends

            PJM_PROJECT_PARAM_PUB.CREATE_PROJECT_PARAMETER(
              p_api_version => 1.0,
              p_init_msg_list => p_init_msg_list,
              p_commit => l_commit,
              x_return_status => l_return_status,
              x_msg_count => l_msg_count,
              x_msg_data => l_msg_data,
              p_param_data => l_param_data);

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               CLOSE c_pjm_param;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
            -- RROY
         END IF;
         CLOSE c_pjm_param;

         -- Merge process fro 11.5 10 bug fix on cmrdv10p env.
         -- Bug# 3594083 fix by shbhanda on 04/23
         -- To update all tasks without project task with project task id
         OPEN c_task_proj(c_visit_rec.PROJECT_ID);
         LOOP
             FETCH c_task_proj INTO c_task_proj_rec;
             EXIT WHEN c_task_proj%NOTFOUND;

             UPDATE AHL_VISIT_TASKS_B SET
             PROJECT_TASK_ID = c_task_proj_rec.task_id,
             OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
             --TCHIMIRA::BUG 9222622 ::15-DEC-2009::UPDATE WHO COLUMNS
             LAST_UPDATE_DATE      = SYSDATE,
             LAST_UPDATED_BY       = Fnd_Global.USER_ID,
             LAST_UPDATE_LOGIN     = Fnd_Global.LOGIN_ID
             /*B6436358 - sowsubra - Visit task number is of type number and task number in projects
             is of type char. Hence the invalid number error. And so added a to_char function to convert
             the visit task number to character*/
             WHERE VISIT_ID = p_visit_id AND TO_CHAR(VISIT_TASK_NUMBER) = c_task_proj_rec.task_number
             AND PROJECT_TASK_ID is NULL;
         END LOOP;
         CLOSE c_task_proj;
      END IF;
   ELSIF c_visit_rec.START_DATE_TIME IS NULL or c_visit_rec.START_DATE_TIME = Fnd_Api.G_MISS_DATE THEN
      x_return_status := Fnd_Api.g_ret_sts_error;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AHL', 'AHL_VWP_VISIT_ST_DT_MISSING');
         Fnd_Msg_Pub.ADD;
      END IF;
   END IF; -- check for visit's start date time
END IF; -- l_chk_project

---------------------------End of API Body---------------------------------------
--Standard check to count messages
l_msg_count := Fnd_Msg_Pub.count_msg;

IF l_msg_count > 0 THEN
   X_msg_count := l_msg_count;
   X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
   RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;

IF (l_log_procedure >= l_log_current_level) THEN
    fnd_log.string(l_log_procedure,L_DEBUG_KEY ||'.end','End of the procedure');
END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO Update_Project;
   FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO Update_Project;
   FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Update_Project;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Update_Project',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

END Update_Project;

--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Project
--
-- PURPOSE
--    To delete Project and its tasks if visit in VWP is deleted
--------------------------------------------------------------------
PROCEDURE Delete_Project(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type       IN  VARCHAR2  := Null,
   p_visit_id          IN  NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2  )
AS
  -- Define local Variables
   L_API_NAME    CONSTANT VARCHAR2(30)  := 'Delete_Project';
   L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
   L_API_VERSION CONSTANT NUMBER := 1.0;
   l_count                NUMBER;
   l_msg_count            NUMBER;
   l_created_project_id   NUMBER;
   i                      NUMBER;
   l_return_status        VARCHAR2(1);
   l_chk_project          VARCHAR2(1);
   l_del_proj_flag        VARCHAR2(1);
   l_valid_flag           VARCHAR2(1):= 'N';
   l_commit               VARCHAR2(1) := 'F';
   l_init_msg_list        VARCHAR2(1) := 'F';
   l_default              VARCHAR2(30);
   l_msg_data             VARCHAR2(2000);
   G_EXC_ERROR            EXCEPTION;

 -- Define local Cursors
    -- To find visit related information
   CURSOR c_visit (x_id IN NUMBER) IS
    SELECT * FROM AHL_VISITS_VL
    WHERE VISIT_ID = x_id;
   c_visit_rec c_visit%ROWTYPE;

   -- To find whether the visit project occurs in PJM_PROJECT_PARAMETERS table
    CURSOR c_Project(x_proj_id IN NUMBER) IS
       SELECT count(*) FROM PJM_PROJECT_PARAMETERS
         WHERE Project_ID = x_proj_id;
BEGIN

  SAVEPOINT Delete_project;

  IF (l_log_procedure >= l_log_current_level) THEN
    fnd_log.string(l_log_procedure,L_DEBUG_KEY ||'.begin','At the start of the procedure');
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF Fnd_Api.to_boolean(p_init_msg_list)THEN
     Fnd_Msg_Pub.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  -- Standard call to check for call compatibility.
  IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      L_API_NAME,G_PKG_NAME) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (l_log_statement >= l_log_current_level) THEN
    fnd_log.string(l_log_statement,L_DEBUG_KEY,'Visit Id=' || p_visit_id);
  END IF;

  OPEN c_visit (p_visit_id);
  FETCH c_visit INTO c_visit_rec;
  CLOSE c_visit;

  -- To check Project responsibilites
  -- Post 11.5.10
  -- RROY
  AHL_VWP_RULES_PVT.Check_Proj_Responsibility
   (x_check_project    => l_chk_project,
    x_return_status    => l_return_status);

  IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
    x_return_status := l_return_status;
    RAISE G_EXC_ERROR;
  END IF;

  IF l_chk_project = 'Y' THEN
    OPEN  c_Project(c_visit_rec.PROJECT_ID);
    FETCH c_Project INTO l_count;
    CLOSE c_Project;

    IF l_count > 0 THEN -- merge process for 11.5 10 bug# 3470801 fix on CMRDV10P
      Fnd_Message.SET_NAME('AHL','AHL_VWP_PROJ_PJM_PARA');
      Fnd_Message.SET_TOKEN('VISIT_NUMBER', c_visit_rec.Visit_Number);
      Fnd_Msg_Pub.ADD;
      RAISE Fnd_Api.G_EXC_ERROR;
    ELSE
      IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,L_DEBUG_KEY,'Before calling :  PA_PROJECT_PUB.CHECK_DELETE_PROJECT_OK');
      END IF;

      PA_PROJECT_PUB.CHECK_DELETE_PROJECT_OK
                ( p_api_version_number     => 1
                  , p_init_msg_list         =>  l_init_msg_list
                  , p_return_status         => l_return_status
                  , p_msg_count           => l_msg_count
                  , p_msg_data           => l_msg_data
                  , p_project_id       => c_visit_rec.PROJECT_ID
                  , p_pm_project_reference   =>  c_visit_rec.visit_number
                  , p_delete_project_ok_flag => l_del_proj_flag
                );

      IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,L_DEBUG_KEY,'After calling PA_PROJECT_PUB.CHECK_DELETE_PROJECT_OK - l_return_status = '||l_return_status);
      END IF;

      IF l_return_status <> 'S' THEN
        RAISE G_EXC_ERROR;
      END IF;

      IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,L_DEBUG_KEY,'l_del_proj_flag = '||l_del_proj_flag);
      END IF;

      IF l_del_proj_flag = 'Y' THEN
          IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,L_DEBUG_KEY,'Before calling PA_PROJECT_PUB.DELETE_PROJECT');
          END IF;

          PA_PROJECT_PUB.DELETE_PROJECT
                 ( p_api_version_number  =>  1
                 ,p_commit               =>  l_commit
                 ,p_init_msg_list        =>  l_init_msg_list
                 ,p_msg_count            =>  l_msg_count
                 ,p_msg_data             =>  l_msg_data
                 ,p_return_status        =>  l_return_status
                 ,p_pm_product_code      =>  G_PM_PRODUCT_CODE
                 ,p_pm_project_reference =>  c_visit_rec.visit_number
                 ,p_pa_project_id        =>  c_visit_rec.PROJECT_ID
                );

          IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,L_DEBUG_KEY,'After calling PA_PROJECT_PUB.DELETE_PROJECT - l_return_status = '||l_return_status);
          END IF;

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,L_DEBUG_KEY,'Errors from PA_PROJECT_PUB.DELETE_PROJECT API : '|| x_msg_count );
            END IF;
            RAISE Fnd_Api.g_exc_error;
          END IF;
      END IF;
    END IF;
  END IF;

---------------------------End of API Body---------------------------------------
  --Standard check to count messages
  l_msg_count := Fnd_Msg_Pub.count_msg;

  IF l_msg_count > 0 THEN
     X_msg_count := l_msg_count;
     X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (l_log_procedure >= l_log_current_level) THEN
    fnd_log.string(l_log_procedure,L_DEBUG_KEY ||'.end','End of the procedure');
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO Delete_Project;
   FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                             p_data  => x_msg_data,
                             p_encoded => fnd_api.g_false);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO Delete_Project;
   FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                             p_data  => x_msg_data,
                             p_encoded => fnd_api.g_false);

 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Delete_Project;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Delete_Project',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
END Delete_Project;

--****************************************************************--
--------------------------------------------------------------------
--              VWP INTEGRATION WITH PRODUCTION                   --
--------------------------------------------------------------------
--****************************************************************--

------------------------------------------------------------------
--  Procedure name    : Validate_MR_Route_Date
--  Type              : Private
--  Function          : Validate if the tasks associated to MR Route Id
--                      have an expired MR Id / Route Id.
--  Parameters  :
--
--  Validate_MR_Route_Date Parameters:
--       p_mr_route_id            IN     NUMBER     Required
--       p_visit_task_number      IN     NUMBER     Required
--       p_start_date_time        IN     DATE       Required
--       p_end_date_time          IN     DATE       Required
--
--  Version :
--      28 Sep, 2007                    RNAHATA  Initial Version - 1.0
--                                      Added for Bug 6448678
-------------------------------------------------------------------

PROCEDURE Validate_MR_Route_Date(
   p_mr_route_id       IN  NUMBER,
   p_visit_task_number IN  NUMBER,
   p_start_date_time   IN  DATE,
   p_end_date_time     IN  DATE
  )
AS
   -- Define local Variables
   L_API_NAME     CONSTANT VARCHAR2(30)  := 'Validate_MR_Route_Date';
   L_DEBUG_KEY    CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   -- To find MR related Information
   CURSOR c_mr_header (c_id IN NUMBER) IS
     SELECT mrh1.effective_from,mrh1.effective_to
     FROM AHL_MR_HEADERS_APP_V mrh1, AHL_MR_ROUTES mrr
     WHERE mrh1.mr_status_code = 'COMPLETE' AND
           trunc(mrh1.effective_from) <= trunc(sysdate) AND
           trunc(nvl(mrh1.effective_to,sysdate)) >= trunc(sysdate) AND
           mrr.mr_route_id = c_id  AND
           mrh1.mr_header_id = mrr.mr_header_id AND
           mrh1.version_number = (select max(version_number)
                                 from AHL_MR_HEADERS_APP_V mrh2
                                 where mrh2.title = mrh1.title
                                 and mrh2.mr_status_code = 'COMPLETE'
                                 and trunc(effective_from) <= trunc(sysdate) AND
                                 trunc(nvl(effective_to,sysdate)) >= trunc(sysdate));

   c_mr_header_rec c_mr_header%ROWTYPE;

   -- To find Route related Information
   CURSOR c_route (c_id IN NUMBER) IS
     SELECT ra.*
     FROM AHL_ROUTES_APP_V ra, AHL_MR_ROUTES mrr
     WHERE ra.route_id = mrr.route_id AND
           mrr.mr_route_id = c_id AND
           ra.revision_status_code = 'COMPLETE';

   c_route_rec c_route%ROWTYPE;

BEGIN

   -- Log API Entry Point
   IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.begin',
                      'At the start of PL SQL procedure.');
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY,
                      'MR Route Id = ' || p_mr_route_id || 'Visit Task Number = ' || p_visit_task_number ||
                      'Start Date = ' || p_start_date_time || 'End Date = ' || p_end_date_time);
    END IF;

   IF p_mr_route_id IS NOT NULL THEN
      OPEN c_route (p_mr_route_id);
      FETCH c_route INTO c_route_rec;

      IF c_route%FOUND THEN
         CLOSE c_route;

         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Checking Route Start and End Dates');
         END IF;

         IF TRUNC(c_route_rec.start_date_active) > p_start_date_time THEN

            Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_TSK_STDT_ROUT_STDT');
            Fnd_Message.Set_Token('TASK_NUMBER', p_visit_task_number);
            Fnd_Msg_Pub.ADD;

         END IF;

         IF TRUNC(c_route_rec.end_date_active) IS NOT NULL THEN
            IF TRUNC(c_route_rec.end_date_active) < p_end_date_time THEN

               Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_TSK_ENDT_ROUT_ENDT');
               Fnd_Message.Set_Token('TASK_NUMBER', p_visit_task_number);
               Fnd_Msg_Pub.ADD;

            END IF;
         END IF;

      ELSE  -- Else of c_route%FOUND check

         CLOSE c_route;

         Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_TSK_NO_ROUTE');
         Fnd_Message.Set_Token('TASK_NUMBER', p_visit_task_number);
         Fnd_Msg_Pub.ADD;

      END IF; -- End of c_route%FOUND check

     -- If the tasks associated to MR Route Id have an expired MR Id
     -- then it cannot be pushed into Production Planning.
     OPEN c_mr_header (p_mr_route_id);
     FETCH c_mr_header INTO c_mr_header_rec;

     IF c_mr_header%FOUND THEN
        CLOSE c_mr_header;

        IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Checking MR Start and End Dates');
        END IF;

        IF TRUNC(c_mr_header_rec.effective_from) > p_start_date_time THEN
           Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_VST_NO_TS_SD_LT_MR');
           Fnd_Message.Set_Token('TASK_NUMBER', p_visit_task_number);
           Fnd_Msg_Pub.ADD;

        END IF;
        IF TRUNC(c_mr_header_rec.effective_to) IS NOT NULL THEN
           IF TRUNC(c_mr_header_rec.effective_to) < p_end_date_time THEN

              Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_VST_NO_TS_ED_GT_MR');
              Fnd_Message.Set_Token('TASK_NUMBER', p_visit_task_number);
              Fnd_Msg_Pub.ADD;

           END IF;
        END IF;

     ELSE -- Else for c_mr_header%FOUND check
       CLOSE c_mr_header;

       Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_VST_NO_MR_ID');
       Fnd_Message.Set_Token('TASK_NUMBER', p_visit_task_number);
       Fnd_Msg_Pub.ADD;

      END IF; -- End of c_mr_header%FOUND check
   END IF; -- End of p_mr_route_id IS NOT NULL check

   ---------------------------End of API Body---------------------------------------
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure.');
   END IF;

END Validate_MR_Route_Date;

--------------------------------------------------------------------
-- PROCEDURE
--    Validate_Before_Production
--
-- PURPOSE
--    To validate Visit and all its Tasks before the push to production
--------------------------------------------------------------------
PROCEDURE Validate_Before_Production
  (
   p_api_version       IN         NUMBER,
   p_init_msg_list     IN         VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN         VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN         NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type       IN         VARCHAR2  := 'JSP',
   p_visit_id          IN         NUMBER,

   x_error_tbl         OUT NOCOPY Error_Tbl_Type,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
 )
IS
   L_API_VERSION  CONSTANT NUMBER := 1.0;
   L_API_NAME     CONSTANT VARCHAR2(30) := 'Validate_Before_Production';
   --part-chgER - sowsubra
   L_DEBUG_KEY    CONSTANT VARCHAR2(90) := 'ahl.plsql.'||G_PKG_NAME||'.'||L_API_NAME;
   l_dept_Tbl              Dept_Tbl_Type;
   l_error_tbl             Error_Tbl_Type;
   l_visit_end_time        DATE;
   -- l_flag               VARCHAR2(1):= 'N';
   l_return_status         VARCHAR2(1);
   l_chk_flag              VARCHAR2(1);
   l_check_flag            VARCHAR2(1);
   l_proj_task_flag        VARCHAR2(1);
   -- Post 11.5.10
   -- RROY
   l_hierarchy_flag        VARCHAR2(1);
   l_job_released_flag     VARCHAR2(1);
   l_task_invalid_flag     VARCHAR2(1);
   -- RROY
   l_default               VARCHAR2(30);
   l_temp                  VARCHAR2(2000);
   l_msg_data              VARCHAR2(2000);
   l_plan_end_hour         NUMBER;
   -- Post 11.5.10
   -- RROY
   l_start_from_hour       NUMBER;
   l_visit_task_id         NUMBER;
   -- RROY
   l_end_hour              NUMBER;
   l_visit_task_id         NUMBER;
   l_count                 NUMBER;
   l_msg_count             NUMBER :=0;
   l_data                  VARCHAR2(2000);
   l_count1                NUMBER;
   l_count2                NUMBER;
   i                       NUMBER:=0;
   j                       NUMBER:=0;
   x                       NUMBER:=0;
   l_dept_flag             VARCHAR2(1):= 'N';
   l_dept                  NUMBER;
   l_dummy_i               NUMBER;

   -- To find visit related information
   -- Added where condition for checking DELETED status in 11.5.10
   CURSOR c_visit (x_id IN NUMBER) IS
    SELECT * FROM AHL_VISITS_VL
    WHERE VISIT_ID = x_id
    AND NVL(STATUS_CODE,'X') <> 'DELETED';
   c_visit_rec c_visit%ROWTYPE;

   -- To find visit dept has any dept shifts
    CURSOR c_dept (x_id IN NUMBER) IS
    SELECT COUNT(*) FROM AHL_DEPARTMENT_SHIFTS
    WHERE DEPARTMENT_ID = x_id;

/* Begin Changes by Shkalyan */
     -- To find count for tasks for visit
     -- Added where condition for checking DELETED status in 11.5.10
   CURSOR c_task_count (x_id IN NUMBER) IS
    SELECT count(*) FROM AHL_VISIT_TASKS_VL
    WHERE VISIT_ID = x_id
    AND NVL(STATUS_CODE,'X') <> 'DELETED'
    AND (TASK_TYPE_CODE <> 'SUMMARY' OR
          (TASK_TYPE_CODE = 'SUMMARY' AND
            MR_ID IS NOT NULL));
/* End Changes by Shkalyan */

/* Begin Changes by Shkalyan */
    -- To find task related information
    -- Added where condition for checking DELETED status in 11.5.10
   CURSOR c_task (x_visit_id IN NUMBER) IS
    SELECT * FROM AHL_VISIT_TASKS_VL
    WHERE VISIT_ID = x_visit_id
         AND NVL(STATUS_CODE,'X') not in ('DELETED','RELEASED')
    AND (TASK_TYPE_CODE <> 'SUMMARY' OR
          (TASK_TYPE_CODE = 'SUMMARY' AND
            MR_ID IS NOT NULL));
/* End Changes by Shkalyan */
   c_task_rec c_task%ROWTYPE;

  -- VWP11.5.10 Enhancements
  -- To find whether any visit which is in a primaryplan has any simulation plans
   CURSOR c_simulation (x_id IN NUMBER) IS
    SELECT COUNT(*) FROM AHL_SIMULATION_PLANS_VL
    WHERE SIMULATION_PLAN_ID = x_id
    AND PRIMARY_PLAN_FLAG = 'Y';

-- AnRaj: Following two cursors have been changed due to  performnace issues
-- Bug Number 4919291
  -- To find MR header related information
 /*  CURSOR c_mr_header (x_id IN NUMBER) IS
      SELECT T1.* FROM AHL_MR_HEADERS_APP_V T1, AHL_MR_ROUTES_V T2
        WHERE T1.MR_HEADER_ID = T2.MR_HEADER_ID
        AND T2.MR_ROUTE_ID = x_id;
*/

-- yazhou 02-Jun-2006 starts
-- bug fix#5209826
/*
  CURSOR c_mr_header (x_id IN NUMBER) IS
    SELECT   T1.EFFECTIVE_FROM,T1.EFFECTIVE_TO
    FROM     AHL_MR_HEADERS_APP_V T1, AHL_MR_ROUTES_V T2
    WHERE    T1.MR_HEADER_ID = T2.MR_HEADER_ID
    AND      T2.MR_ROUTE_ID = x_id;
*/
  CURSOR c_mr_header (x_id IN NUMBER) IS
     SELECT T1.EFFECTIVE_FROM,T1.EFFECTIVE_TO
     FROM ahl_mr_headers_app_v T1, AHL_MR_ROUTES_V T2
     WHERE T1.mr_status_code = 'COMPLETE' AND
           trunc(T1.effective_from) <= trunc(sysdate) AND
           trunc(nvl(T1.effective_to,sysdate)) >= trunc(sysdate) AND
           T2.MR_ROUTE_ID = x_id  AND
           T1.MR_HEADER_ID = T2.MR_HEADER_ID AND
           T1.version_number = (select max(version_number)
                             from ahl_mr_headers_app_v mr1
                             where mr1.title = T1.title
                             and mr1.mr_status_code = 'COMPLETE'
                             and trunc(effective_from) <= trunc(sysdate) AND
                             trunc(nvl(effective_to,sysdate)) >= trunc(sysdate));

-- yazhou 02-Jun-2006 ends

   c_mr_header_rec c_mr_header%ROWTYPE;

  -- To find route related information
  /* CURSOR c_route (x_id IN NUMBER) IS
      SELECT T1.* FROM AHL_ROUTES_APP_V T1, AHL_MR_ROUTES_V T2
        WHERE T1.ROUTE_ID = T2.ROUTE_ID
        AND T2.MR_ROUTE_ID = x_id
        AND T1.REVISION_STATUS_CODE = 'COMPLETE';
  */
  CURSOR c_route (x_id IN NUMBER) IS
    SELECT   T1.START_DATE_ACTIVE,T1.END_DATE_ACTIVE
    FROM     AHL_ROUTES_APP_V T1, AHL_MR_ROUTES_V T2
    WHERE    T1.ROUTE_ID = T2.ROUTE_ID
    AND      T2.MR_ROUTE_ID = x_id
    AND      T1.REVISION_STATUS_CODE = 'COMPLETE';
   c_route_rec c_route%ROWTYPE;
  -- End of Fix for 4919291

  -- To find only those routes which are there in tasks table but not in route table for a visit
  -- Added where condition for checking DELETED status in 11.5.10
    CURSOR c_route_chk (x_id IN NUMBER) IS
     SELECT VT.MR_ROUTE_ID
     FROM AHL_VISIT_TASKS_B VT
     WHERE VT.VISIT_ID = x_id
           AND NVL(STATUS_CODE,'X') not in ('DELETED','RELEASED')
       AND VT.MR_Route_ID IS NOT NULL
       AND NOT EXISTS (
       SELECT 1
        FROM AHL_MR_ROUTES T1, AHL_ROUTES_APP_V T2, AHL_MR_HEADERS_APP_V B
        WHERE T1.MR_ROUTE_ID = VT.MR_ROUTE_ID
          AND T1.MR_HEADER_ID = B.MR_HEADER_ID
          AND T1.ROUTE_ID = T2.ROUTE_ID
          AND T2.REVISION_STATUS_CODE = 'COMPLETE');
    c_route_chk_rec c_route_chk%ROWTYPE;

 -- To find visit task id for the non-summary tasks which have no MR Routes
 -- Added where condition for checking DELETED status in 11.5.10
    CURSOR c_route_tsk (x_id IN NUMBER) IS
       SELECT VISIT_TASK_ID, VISIT_TASK_NUMBER FROM AHL_VISIT_TASKS_B
           WHERE VISIT_ID = x_id
                       AND NVL(STATUS_CODE,'X') not in ('DELETED','RELEASED')
           AND MR_Route_ID IS NULL
           AND TASK_TYPE_CODE <> 'SUMMARY';

/* commented out for bug fix 4081044
 yazhou 03-Jan-2005
 -- To find count for Item and MR Header ID
   CURSOR c_check (x_item_id IN NUMBER, x_mr_route_id IN NUMBER) IS
      SELECT count(*) FROM Ahl_MR_Items_V T1, AHL_MR_ROUTES_APP_V T2
         WHERE T1.Inventory_Item_ID = x_item_id
         AND T1.MR_HEADER_ID = T2.MR_HEADER_ID
         AND MR_ROUTE_ID = x_mr_route_id;
*/

 -- To find all departments from a visit's tasks table
 -- Added where condition for checking DELETED status in 11.5.10
   CURSOR c_dept_task (x_id IN NUMBER) IS
    SELECT DEPARTMENT_ID FROM AHL_VISIT_TASKS_B
      WHERE VISIT_ID = x_id
            AND NVL(STATUS_CODE,'X') not in ('DELETED','RELEASED')
    AND DEPARTMENT_ID IS NOT NULL;
    c_dept_task_rec c_dept_task%ROWTYPE;

 -- To find all departments from a visit's tasks table
 -- Added where condition for checking DELETED status in 11.5.10
   CURSOR c_dept_tsk (x_id IN NUMBER) IS
    SELECT DEPARTMENT_ID, VISIT_TASK_NUMBER FROM AHL_VISIT_TASKS_B
     WHERE VISIT_ID = x_id
          AND NVL(STATUS_CODE,'X') not in ('DELETED','RELEASED')
    AND DEPARTMENT_ID IS NOT NULL;
    c_dept_tsk_rec c_dept_tsk%ROWTYPE;

    /*sowsubra - part-chgER - 18 July, 2007 - start*/
   CURSOR c_get_inst_item (c_instance_id IN NUMBER) IS
    SELECT INVENTORY_ITEM_ID, INSTANCE_NUMBER FROM CSI_ITEM_INSTANCES
    WHERE  instance_id = c_instance_id;

   c_inst_item_rec    c_get_inst_item%ROWTYPE;
   /*sowsubra - part-chgER - end*/

 -- To find out if the item instances associated to a visit or task is still active
 -- CURSOR c_serial (p_serial_id IN NUMBER, p_item_id IN NUMBER, p_org_id IN NUMBER) IS
 -- part-chgER - changed the name of the cusror.
  CURSOR c_instance (c_instance_id IN NUMBER, c_item_id IN NUMBER, c_org_id IN NUMBER) IS
    SELECT count(*)FROM CSI_ITEM_INSTANCES
      WHERE Instance_Id  = c_instance_id
    AND Inventory_Item_Id = c_item_id
    AND Inv_Master_Organization_Id = c_org_id
    AND ACTIVE_START_DATE <= sysdate
    AND (ACTIVE_END_DATE >= sysdate OR ACTIVE_END_DATE IS NULL);

-- RROY

 -- bug fix 4077103 -yazhou
 -- To check the current status of the Unit
   CURSOR c_uc_status (p_instance_id IN NUMBER) IS
    SELECT name, AHL_UTIL_UC_PKG.GET_UC_STATUS_CODE(UNIT_CONFIG_HEADER_ID) uc_status
    FROM  ahl_unit_config_headers uc,
          csi_item_instances csis
    WHERE uc.csi_item_instance_id=csis.instance_id
    AND (uc.active_end_date IS NULL OR uc.active_end_date > SYSDATE)
    AND csis.instance_id = p_instance_id;

    c_uc_status_rec c_uc_status%ROWTYPE;

BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Validate_Before_Production;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Visit Id = ' || p_visit_id);
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_boolean(p_init_msg_list) THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   OPEN c_visit (p_visit_id);
   FETCH c_visit INTO c_visit_rec;
   CLOSE c_visit;

   -- To check if the unit is quarantined
   -- AnRaj added for R 12.0 ACL changes in VWP, Start
   check_unit_quarantined(p_visit_id,c_visit_rec.Item_Instance_Id);
   -- AnRaj added for R 12.0 ACL changes in VWP, End
   IF c_visit_rec.TEMPLATE_FLAG = 'N' THEN
   -- To check visit's start date is not null
      IF c_visit_rec.START_DATE_TIME IS NULL THEN
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Visit Start Date is null.');
         END IF;
         -- By shbhanda 05/21/04 for TC changes
         Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_VST_NO_ST_DATE');
         Fnd_Message.Set_Token('VISIT_NUMBER', c_visit_rec.VISIT_NUMBER);
         Fnd_Msg_Pub.ADD;
      END IF;

     -- To check visit's status is not null and it should be only planning or partially released
     IF c_visit_rec.STATUS_CODE IS NOT NULL THEN
        IF c_visit_rec.STATUS_CODE <> 'PLANNING' and c_visit_rec.STATUS_CODE <> 'PARTIALLY RELEASED' THEN
           IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                             'Visit Status Code is not Planning/Partially Released.');
           END IF;
           Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_VST_NOT_PLANNING'); -- **** IMPortant uPDATE FOR PARTIALLY RELEASED
           Fnd_Message.Set_Token('VISIT_NUMBER', c_visit_rec.VISIT_NUMBER);
           Fnd_Msg_Pub.ADD;
           /* l_temp := 'ERROR: Visit Number ' || c_visit_rec.VISIT_NUMBER || ' : Status Code is not Planning or Partially Released' ;
           l_error_tbl(j).Msg_Index := j;
           l_error_tbl(j).Msg_Data  := l_temp;
           j := j + 1;*/

           -- POst 11.5.10 Changes by Senthil.
        ELSIF TRUNC(c_visit_rec.start_date_time) < TRUNC(SYSDATE) AND c_visit_rec.STATUS_CODE <> 'PARTIALLY RELEASED'
        THEN
           IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                             'Visit Status Code is Planning and Visit Start Date is less than sysdate. ');
           END IF;
           Fnd_Message.SET_NAME('AHL','AHL_VWP_START_DATE_LT_SYS');
           Fnd_Message.Set_Token('VISIT_NUMBER', c_visit_rec.VISIT_NUMBER);
           Fnd_Msg_Pub.ADD;
           /* l_error_tbl(j).Msg_Index := j;
           l_error_tbl(j).Msg_Data  := REPLACE(FND_MESSAGE.GET_STRING(APPIN => 'AHL',
           NAMEIN => 'AHL_VWP_START_DATE_LT_SYS')
           ,'VISIT_NUMBER',c_visit_rec.VISIT_NUMBER);
           j := j + 1; */
        END IF;
     -- visit's status is null
     ELSE
        IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Visit Status Code is null.');
        END IF;
        Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_VST_NO_STATUS');
        Fnd_Message.Set_Token('VISIT_NUMBER', c_visit_rec.VISIT_NUMBER);
        Fnd_Msg_Pub.ADD;

        /*l_temp := 'ERROR: Visit Number ' || c_visit_rec.VISIT_NUMBER || ' : Status Code Missing' ;
        l_error_tbl(j).Msg_Index := j;
        l_error_tbl(j).Msg_Data  := l_temp;
        j := j + 1; */
     END IF;

     -- To check visit's organization is not null
     IF c_visit_rec.ORGANIZATION_ID IS NULL THEN
        IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Visit Organization is null.');
        END IF;

        Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_VST_NO_ORG');
        Fnd_Message.Set_Token('VISIT_NUMBER', c_visit_rec.VISIT_NUMBER);
        Fnd_Msg_Pub.ADD;

        /* l_temp := 'ERROR: Visit Number ' || c_visit_rec.VISIT_NUMBER || ' : Organization Missing' ;
        l_error_tbl(j).Msg_Index := j;
        l_error_tbl(j).Msg_Data  := l_temp;
        j := j + 1; */
     END IF;

     -- To check visit's department is not null
     IF c_visit_rec.DEPARTMENT_ID IS NULL THEN
        IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Visit Department is null.');
        END IF;

        Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_VST_NO_DEPT');
        Fnd_Message.Set_Token('VISIT_NUMBER', c_visit_rec.VISIT_NUMBER);
        Fnd_Msg_Pub.ADD;

        /* l_temp := 'ERROR: Visit Number ' || c_visit_rec.VISIT_NUMBER || ' : Department Missing';
        l_error_tbl(j).Msg_Index := j;
        l_error_tbl(j).Msg_Data  := l_temp;
        j := j + 1; */
     END IF;

     -- Start by shbhanda on 29-Jan-04
     -- To check visit's close date time i.e planned end date is not null
     IF c_visit_rec.CLOSE_DATE_TIME IS NULL THEN
        IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Visit Plan End Date is null.');
        END IF;

        Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_VST_NO_PLN_END_DT');
        Fnd_Message.Set_Token('VISIT_NUMBER', c_visit_rec.VISIT_NUMBER);
        Fnd_Msg_Pub.ADD;

        /* l_temp := 'ERROR: Visit Number ' || c_visit_rec.VISIT_NUMBER || ' : Planned end date missing' ;
        l_error_tbl(j).Msg_Index := j;
        l_error_tbl(j).Msg_Data  := l_temp;
        j := j + 1; */
     END IF;
     -- End by shbhanda on 29-Jan-04

     -- To check visit's simulation plan lies in primary plan
     IF c_visit_rec.SIMULATION_PLAN_ID IS NOT NULL THEN
        OPEN c_simulation (c_visit_rec.SIMULATION_PLAN_ID);
        FETCH c_simulation INTO l_count;
        CLOSE c_simulation;
        IF l_count = 0 THEN
           IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                             'Visit has 0 Simulations.');
           END IF;

           Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_VST_NO_PRIM_PLAN');
           Fnd_Message.Set_Token('VISIT_NUMBER', c_visit_rec.VISIT_NUMBER);
           Fnd_Msg_Pub.ADD;
        END IF;
     END IF;

     --sowsubra FP:Bug#5758829
     /*When the visit type code is not null, then validate the type code to see if
     the visit type is enabled and not end-dated.*/
     IF c_visit_rec.visit_type_code IS NOT NULL THEN
        IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Before calling AHL_VWP_RULES_PVT.CHECK_LOOKUP_NAME_OR_ID.');
        END IF;

        AHL_VWP_RULES_PVT.CHECK_LOOKUP_NAME_OR_ID (
             p_lookup_type  => 'AHL_PLANNING_VISIT_TYPE',
             p_lookup_code  => trim(c_visit_rec.visit_type_code),
             p_meaning      => NULL,
             p_check_id_flag => 'Y',
             x_lookup_code   => c_visit_rec.visit_type_code,
             x_return_status => l_return_status);

        IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'After calling AHL_VWP_RULES_PVT.CHECK_LOOKUP_NAME_OR_ID.');
        END IF;

        IF NVL(l_return_status, 'X') <> 'S' THEN
           Fnd_Message.SET_NAME('AHL','AHL_VWP_TYPE_CODE_NOT_EXISTS');
           Fnd_Msg_Pub.ADD;
           RAISE Fnd_Api.G_EXC_ERROR;
        END IF;
     END IF;

     /*sowsubra - part-chgER - 18 July, 2007- start*/
     -- only when unit is associated with the visit then check if the item-instance
     IF (c_visit_rec.item_instance_id IS NOT NULL) THEN
       OPEN c_get_inst_item(c_visit_rec.item_instance_id);
       FETCH c_get_inst_item INTO c_inst_item_rec;
       CLOSE c_get_inst_item;

       IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'Item Id from csi instances = ' || c_inst_item_rec.inventory_item_id);
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'Instance number from csi instances = ' || c_inst_item_rec.instance_number);
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'Visit Item Id = ' || c_visit_rec.Inventory_Item_Id);
       END IF;

       IF c_inst_item_rec.inventory_item_id = c_visit_rec.Inventory_Item_Id THEN
          /*sowsubra - part-chgER - end*/
          -- To check visit must be associated to an Active Item Instance.
          -- To find out if the item instances associated to the visit is still active
          IF c_visit_rec.Item_Instance_Id IS NOT NULL THEN
              OPEN c_instance (c_visit_rec.Item_Instance_Id, c_visit_rec.Inventory_Item_Id, c_visit_rec.Item_Organization_Id);
              FETCH c_instance INTO l_count;
              CLOSE c_instance;
              IF l_count = 0 THEN

                 Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_VST_INST_NO_ACTIVE');
                 Fnd_Message.Set_Token('VISIT_NUMBER', c_visit_rec.VISIT_NUMBER);
                 Fnd_Msg_Pub.ADD;
              END IF;
          END IF;
       ELSE
          -- SKPATHAK :: Bug 8312388 :: 07-MAY-2009
          -- Earlier the error AHL_VWP_VST_INST_ITM_CHNGD was thrown if
          -- c_inst_item_rec.inventory_item_id and c_visit_rec.Inventory_Item_Id were
          -- not the same. This check has now been removed.
          IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement, L_DEBUG_KEY,
                           'Visit Instance has undergone part number change.');
          END IF;
       END IF;
   END IF; --c_visit_rec.item_instance_id IS NOT NULL

   -- bug fix 4077103 -yazhou
   -- To check visit must be associated to an Active Unit.
   -- Also the unit must be in Complete or Incomplete status
   IF c_visit_rec.Item_Instance_Id IS NOT NULL THEN
       OPEN c_uc_status (c_visit_rec.Item_Instance_Id);
       FETCH c_uc_status INTO c_uc_status_rec;
       CLOSE c_uc_status;

         IF c_uc_status_rec.uc_status not in ('COMPLETE','INCOMPLETE') THEN

            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              c_uc_status_rec.name || ' UC status is invalid: '|| c_uc_status_rec.uc_status);
            END IF;

            Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_VST_INVALID_UC');
            Fnd_Message.Set_Token('VISIT_NUMBER', c_visit_rec.VISIT_NUMBER);
            Fnd_Message.Set_Token('UNIT_NAME', c_uc_status_rec.name);
            Fnd_Msg_Pub.ADD;
         END IF;
   END IF;

   -- To check tasks must be associated to Active Item Instances.
   -- To find out if the item instances associated to the tasks are still active

   OPEN c_task (p_visit_id);
   LOOP
      FETCH c_task INTO c_task_rec;
      EXIT WHEN c_task%NOTFOUND;

        /*commented out by sowsubra as a visit can be created without a unit, then the tasks
        present in the visit should be still validated.*/
        --IF c_visit_rec.Item_Instance_Id IS NOT NULL THEN

      /*sowsubra - part-chgER - 18 July, 2007 - start*/
      IF (c_task_rec.instance_id IS NOT NULL) THEN
         OPEN c_get_inst_item(c_task_rec.instance_id);
         FETCH c_get_inst_item INTO c_inst_item_rec;
         CLOSE c_get_inst_item;

         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Item Id from csi instances - ' || c_inst_item_rec.inventory_item_id);
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Visit Item Id - ' || c_task_rec.Inventory_Item_Id);
         END IF;

         IF c_inst_item_rec.inventory_item_id = c_task_rec.Inventory_Item_Id THEN
            IF c_task_rec.INSTANCE_ID IS NOT NULL THEN
               OPEN c_instance (c_task_rec.INSTANCE_ID, c_task_rec.Inventory_Item_Id, c_task_rec.Item_Organization_Id);
               FETCH c_instance INTO l_count;
               CLOSE c_instance;

               IF l_count = 0 THEN
                 Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_TSK_INST_NO_ACTIVE');
                 Fnd_Message.Set_Token('TASK_NUMBER', c_task_rec.VISIT_TASK_NUMBER);
                 Fnd_Msg_Pub.ADD;
               END IF;
            END IF;
         ELSE
            -- SKPATHAK :: Bug 8312388 :: 07-MAY-2009
            -- Earlier the error AHL_VWP_TSK_INST_ITM_CHNGD was thrown if
            -- c_inst_item_rec.inventory_item_id and c_task_rec.Inventory_Item_Id were
            -- not the same. This check has now been removed.
            IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement, L_DEBUG_KEY,
                             'Task Instance has undergone part number change.');
            END IF;
         END IF;
      END IF; -- c_task_rec.instance_id is not null
      /*sowsubra - part-chgER - end*/
   END LOOP;
   CLOSE c_task;
   --END IF; -- End for Check Instance Id presence

   -- NR-MR Changes - sowsubra - Begin comment
   /* The check for instance_in_config_tree for the visit instance is redundant since
     in instance_in_config_tree, the visit instance is compared against itself.*/
   /***

   -- To check visit must be associated to an Item Instance.
   -- To check all task's serial number are still active
   IF c_visit_rec.Item_Instance_Id IS NOT NULL THEN

       --BEGIN: jeli added for bug 3777720
       IF (AHL_VWP_RULES_PVT.instance_in_config_tree(p_visit_id, c_visit_rec.item_instance_id)= FND_API.G_RET_STS_ERROR) THEN
       --END: jeli added for bug 3777720
         Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_VST_INST_NO_FOUND');
         Fnd_Message.Set_Token('VISIT_NUMBER',c_visit_rec.VISIT_NUMBER);
         Fnd_Msg_Pub.ADD;
       END IF;
   END IF;

   IF c_visit_rec.Item_Instance_Id IS NOT NULL THEN

       OPEN c_task (p_visit_id);
       LOOP
       FETCH c_task INTO c_task_rec;
          EXIT WHEN c_task%NOTFOUND;
         IF c_task_rec.INSTANCE_ID IS NOT NULL THEN
--             IF l_check_flag = 'N' THEN
           --BEGIN: jeli added for bug 3777720
           IF (AHL_VWP_RULES_PVT.instance_in_config_tree(p_visit_id, c_task_rec.instance_id) = FND_API.G_RET_STS_ERROR) THEN
           --END: jeli added for bug 3777720
              Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_VST_INST_NO_FOUND');
              Fnd_Message.Set_Token('VISIT_NUMBER', c_visit_rec.VISIT_NUMBER);
              Fnd_Msg_Pub.ADD;
                  END IF;
              END IF;
           END LOOP;
           CLOSE c_task;

--   Removed for POst 11.5.10 Changes by Senthil.
--     ELSE
--         IF (l_log_statement >= l_log_current_level) THEN
--            fnd_log.string(l_log_statement,
--                          L_DEBUG_KEY,
--                          'Check Visit Serial Number');
--         END IF;
--         l_temp := 'ERROR: Visit Number ' || c_visit_rec.VISIT_NUMBER || ' : Serial Number Missing' ;
--         l_error_tbl(j).Msg_Index := j;
--         l_error_tbl(j).Msg_Data  := l_temp;
--              j := j + 1;

      END IF; -- End for Check Instance Id presence
      ***/
      -- NR-MR Changes - sowsubra - end comment

      -- To check visit must be associated to a Project ID
      -- Check for the proejct id presence in PJM_PROJECT_PARAMETER table
      -- Post 11.5.10
      -- RROY
      /*
      IF c_visit_rec.Project_Id IS NOT NULL THEN
          OPEN c_Project(c_visit_rec.Project_Id);
          FETCH c_Project INTO l_count;
          CLOSE c_Project;
          IF l_count = 0 THEN
              l_temp := 'ERROR: Visit Number ' || c_visit_rec.VISIT_NUMBER || ' :  This project should be included in PJM_PROJECT_PARAMETERS from PA' ;
              l_error_tbl(j).Msg_Index := j;
              l_error_tbl(j).Msg_Data  := l_temp;
              j := j + 1;
          END IF;
      ELSE
          l_temp := 'ERROR: Visit Number ' || c_visit_rec.VISIT_NUMBER || ' : No Project is associated to this Visit' ;
          l_error_tbl(j).Msg_Index := j;
          l_error_tbl(j).Msg_Data  := l_temp;
          j := j + 1;
      END IF;
      */
      -- Post 11.5.10
      -- RROY

   -- To check all routes for visit's tasks must exists
   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Initially, FLAG = ' || l_chk_flag);
   END IF;

   OPEN c_route_chk (p_visit_id);
   l_chk_flag := 'N';
   LOOP
       FETCH c_route_chk INTO c_route_chk_rec;
       EXIT WHEN c_route_chk%NOTFOUND;
       IF c_route_chk%FOUND THEN
         l_chk_flag := 'Y';
       END IF;
   END LOOP;
   CLOSE c_route_chk;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'After Route Check, FLAG = ' || l_chk_flag);
   END IF;

   -- To check visit's department should have dept shifts defined
   OPEN c_dept (c_visit_rec.department_id);
   FETCH c_dept INTO l_count;
   CLOSE c_dept;

   -- To find if the all visit tasks dept has department shifts defined
   OPEN c_dept_task (p_visit_id);
   i:=0;
   LOOP
       FETCH c_dept_task INTO c_dept_task_rec;
       EXIT WHEN c_dept_task%NOTFOUND;
       IF c_dept_task%FOUND THEN
          IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'task dept' || c_dept_task_rec.department_id);
          END IF;
          OPEN c_dept (c_dept_task_rec.department_id);
          FETCH c_dept INTO l_dept;
          l_dept_Tbl(i) := l_dept;
          IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'task dept count ' || l_dept);
          END IF;
          i := i + 1;
          CLOSE c_dept;
       END IF;
   END LOOP;
   CLOSE c_dept_task;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'task dept table count ' || l_dept_Tbl.COUNT);
   END IF;

   IF l_dept_Tbl.COUNT > 0 THEN
      l_dept_flag := 'N';
      x := l_dept_Tbl.FIRST;
      LOOP
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'task dept table values ' || l_dept_Tbl(x));
      END IF;
      IF l_dept_Tbl(x) = 0 THEN
         l_dept_flag := 'Y';
         EXIT WHEN l_dept_flag = 'Y';
      END IF;
         EXIT WHEN x = l_dept_Tbl.LAST ;
         x := l_dept_Tbl.NEXT(x);
      END LOOP;
   END IF;

      IF (c_visit_rec.START_DATE_TIME IS NOT NULL
          AND c_visit_rec.START_DATE_TIME <> Fnd_Api.g_miss_date)
          AND (c_visit_rec.DEPARTMENT_ID IS NOT NULL
          AND c_visit_rec.DEPARTMENT_ID <> Fnd_Api.g_miss_num)
          AND l_count > 0 AND l_chk_flag = 'N' AND l_dept_flag = 'N' THEN

         --The visit end date
         l_visit_end_time := AHL_VWP_TIMES_PVT.get_visit_end_time(p_visit_id);

         -- Start by shbhanda on Feb03,2004 for 11.5.10 release--
         -- If visit actual end date exceeds planned end date,
         -- then an error message will be displayed and the visit cannot be released.

         IF c_visit_rec.close_date_time IS NOT NULL THEN

            IF TRUNC(l_visit_end_time) > TRUNC(c_visit_rec.close_date_time) THEN
               IF (l_log_statement >= l_log_current_level) THEN
                  fnd_log.string(l_log_statement,
                                 L_DEBUG_KEY,
                                 'Check visit end time and plan end time');
               END IF;
               Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_VST_ACTDT_GT_PLNDT');
               Fnd_Message.Set_Token('VISIT_NUMBER', c_visit_rec.VISIT_NUMBER);
               Fnd_Msg_Pub.ADD;
               /* l_temp := 'ERROR: Visit Number ' || c_visit_rec.VISIT_NUMBER || ' : Actual end date exceeds planned end date.' ;
                l_error_tbl(j).Msg_Index := j;
                l_error_tbl(j).Msg_Data  := l_temp;
                j := j + 1; */

            ELSIF TRUNC(l_visit_end_time) = TRUNC(c_visit_rec.close_date_time) THEN

               l_plan_end_hour := TO_NUMBER(TO_CHAR(c_visit_rec.CLOSE_DATE_TIME , 'HH24'));
               l_end_hour := TO_NUMBER(TO_CHAR(l_visit_end_time , 'HH24'));

               IF l_end_hour > l_plan_end_hour THEN
                  IF (l_log_statement >= l_log_current_level) THEN
                     fnd_log.string(l_log_statement,
                                    L_DEBUG_KEY,
                                    'Check visit end hour and plan end hour');
                  END IF;
                  -- By shbhanda 08/04/04 for TC changes
                  Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_VST_ACTHR_GT_PLNHR');
                  Fnd_Message.Set_Token('VISIT_NUMBER', c_visit_rec.VISIT_NUMBER);
                  Fnd_Msg_Pub.ADD;
                 /* l_temp := 'ERROR: Visit Number ' || c_visit_rec.VISIT_NUMBER || ' : Actual end date hour exceeds planned end date hour.' ;
                  l_error_tbl(j).Msg_Index := j;
                  l_error_tbl(j).Msg_Data  := l_temp;
                  j := j + 1; */
               END IF;
            END IF;
         -- Post 11.5.10 Changes by Senthil.
         ELSE
            Fnd_Message.SET_NAME('AHL','AHL_VWP_PLN_END_DATE_NULL');
            Fnd_Message.Set_Token('VISIT_NUMBER',
                            c_visit_rec.VISIT_NUMBER);
            Fnd_Msg_Pub.ADD;

         END IF;
         -- End by shbhanda on Feb03,2004 for 11.5.10 release--

         -- To find any visit task if Tasks associated to a route/MR, must be associated to the item as set up in FMP
         OPEN c_task(p_visit_id);
         LOOP
         FETCH c_task INTO c_task_rec;
         EXIT WHEN c_task%NOTFOUND;

         IF c_task_rec.task_type_code IS NOT NULL THEN
            IF UPPER(c_task_rec.task_type_code) = 'PLANNED' THEN
               --- Changes made by VSUNDARA for Production - SR Integration
               IF c_task_rec.mr_route_id is null THEN

                  /* commented out for bug fix 4081044
                  yazhou 03-Jan-2005
                  OPEN c_check (c_task_rec.inventory_item_id, c_task_rec.mr_route_id);
                  FETCH c_check INTO l_count;
                  CLOSE c_check;
                   IF l_count = 0 THEN
                     Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_VST_NO_ITEM_MR_RT'); --***** change this
                     Fnd_Message.Set_Token('VISIT_NUMBER', c_visit_rec.VISIT_NUMBER);
                     Fnd_Msg_Pub.ADD;
                   END IF;
                   ELSE */
                  IF c_task_rec.SERVICE_REQUEST_ID is null OR c_task_rec.UNIT_EFFECTIVITY_ID is null THEN
                     Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_VST_NO_SR_UE'); --***** change this
                     Fnd_Message.Set_Token('VISIT_NUMBER', c_visit_rec.VISIT_NUMBER);
                     Fnd_Msg_Pub.ADD;
                  END IF; --Added by jeli on 07/26/04 when merging code otherwise it couldn't pass compilation
               END IF; --- End Changes made by VSUNDARA for Production - SR Integration
            END IF;
         END IF;

         IF UPPER(c_task_rec.task_type_code) = 'UNASSOCIATED' AND c_task_rec.DURATION IS NULL THEN

            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'Unassociated Task. Task Duration is null');
            END IF;
            Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_TSK_NO_DURATION');
            Fnd_Message.Set_Token('TASK_NUMBER', c_task_rec.VISIT_TASK_NUMBER);
            Fnd_Msg_Pub.ADD;
         END IF; -- End for c_task_rec.task_type_code check

         -- To find all visit tasks must be associated to an item and item instance.
         IF c_task_rec.instance_id IS NULL THEN
            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'Check Task Serial');
            END IF;
            Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_TSK_NO_SERIAL');
            Fnd_Message.Set_Token('TASK_NUMBER', c_task_rec.VISIT_TASK_NUMBER);
            Fnd_Msg_Pub.ADD;
         END IF;

         IF c_task_rec.inventory_item_id IS NULL THEN
            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'Task Inventory Item is null.');
            END IF;
            Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_TSK_NO_ITEM');
            Fnd_Message.Set_Token('TASK_NUMBER', c_task_rec.VISIT_TASK_NUMBER);
            Fnd_Msg_Pub.ADD;
         END IF;

      -- Begin changes by rnahata for Bug 6448678
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Before calling Validate_MR_Route_Date. l_msg_count = ' || l_msg_count);
      END IF;

      Validate_MR_Route_Date(
        p_mr_route_id       => c_task_rec.mr_route_id,
        p_visit_task_number => c_task_rec.visit_task_number,
        p_start_date_time   => sysdate,
        p_end_date_time     => sysdate);

      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'After calling Validate_MR_Route_Date for Task Id: ' ||
                        c_task_rec.visit_task_id || ' and l_msg_count = ' || l_msg_count);
      END IF;
      -- End changes by rnahata for Bug 6448678

      END LOOP; -- End of loop to check c_task cursor
      CLOSE c_task;

   ELSE

      IF l_count = 0 THEN
         Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_VST_NO_DEPT_SHIFT');
         Fnd_Message.Set_Token('VISIT_NUMBER', c_visit_rec.VISIT_NUMBER);
         Fnd_Msg_Pub.ADD;
      END IF;

      IF l_chk_flag = 'Y' THEN
         Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_VST_RT_EXISTS');
         Fnd_Message.Set_Token('VISIT_NUMBER', c_visit_rec.VISIT_NUMBER);
         Fnd_Msg_Pub.ADD;
      END IF;

      IF l_dept_flag = 'Y' THEN
         OPEN c_dept_tsk (p_visit_id);
         LOOP
            FETCH c_dept_tsk INTO c_dept_tsk_rec;
            EXIT WHEN c_dept_tsk%NOTFOUND;
            IF c_dept_tsk%FOUND THEN
               IF (l_log_statement >= l_log_current_level) THEN
                   fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Task Dept' || c_dept_tsk_rec.department_id);
               END IF;
               OPEN c_dept (c_dept_tsk_rec.department_id);
               FETCH c_dept INTO l_dept;
               IF l_dept = 0 THEN
                  IF (l_log_statement >= l_log_current_level) THEN
                     fnd_log.string(l_log_statement,
                                    L_DEBUG_KEY,
                                    'Task Dept Count ' || l_dept);
                  END IF;
                  Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_VST_NO_DEPT_SHIFT');
                  Fnd_Message.Set_Token('TASK_NUMBER', c_dept_tsk_rec.VISIT_TASK_NUMBER);
                  Fnd_Msg_Pub.ADD;
               END IF;
               CLOSE c_dept;
            END IF;
         END LOOP;
         CLOSE c_dept_tsk;
      END IF;
   END IF;

      IF c_task_rec.visit_task_id IS NULL AND c_visit_rec.STATUS_CODE = 'PLANNING' THEN

         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'No Task Found for the Visit');
         END IF;

         Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_VST_TASK_NULL');
         Fnd_Message.Set_Token('VISIT_NUMBER', c_visit_rec.VISIT_NUMBER);
         Fnd_Msg_Pub.ADD;

      END IF;
   END IF;

   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'After calling *count_msg* l_count = ' || l_msg_count);
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Start calling Fnd_Msg_Pub.GET');
   END IF;

   j := 1;

   FOR i IN 1..l_msg_count LOOP

        IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          '------------------------------------------------');
        END IF;

        FND_MSG_PUB.get (
           p_encoded        => FND_API.G_FALSE,
           p_data           => l_data,
           p_msg_index_out  => l_msg_count);
        IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Error Message : '||l_data);
        END IF;
        l_error_tbl(j).Msg_Index := j;
        l_error_tbl(j).Msg_Data  := l_data;
        j := j + 1;

   END LOOP;
   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'End calling Fnd_Msg_Pub.GET');
   END IF;

x_error_tbl :=  l_error_tbl;

 -------------------- finish --------------------------
  -- END of API body.
  -- Standard check of p_commit.

   IF Fnd_Api.To_Boolean (p_commit) THEN
      COMMIT WORK;
   END IF;

   Fnd_Msg_Pub.count_and_get(
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
  );

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;

EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Validate_Before_Production;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Validate_Before_Production;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN OTHERS THEN
      ROLLBACK TO Validate_Before_Production;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
    THEN
         Fnd_Msg_Pub.add_exc_msg (G_PKG_NAME, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
END Validate_Before_Production;

--------------------------------------------------------------------
-- PROCEDURE
--    Get_Task_Relationships
--
-- PURPOSE
-- To get all the Relationships for the Visit Task.
--------------------------------------------------------------------

PROCEDURE Get_Task_Relationships
( p_visit_id           IN            NUMBER,
  p_visit_number       IN            NUMBER,
  p_visit_task_id      IN            NUMBER,
  p_x_relationship_tbl IN OUT NOCOPY AHL_PRD_WORKORDER_PVT.prd_workorder_rel_tbl
) IS

CURSOR get_mwo_wip_entity_id(x_visit_id IN NUMBER) IS
 SELECT wip_entity_id
 FROM AHL_WORKORDERS
WHERE visit_id = x_visit_id
  AND VISIT_TASK_ID IS NULL
  AND MASTER_WORKORDER_FLAG = 'Y';

CURSOR get_task_dtls(c_visit_task_id IN NUMBER) IS
 SELECT visit_task_number, task_type_code, SERVICE_REQUEST_ID, MR_ID, originating_task_id
 FROM AHL_VISIT_TASKS_B
 WHERE visit_task_id = c_visit_task_id;

-- Get all the Parent Task Records For the Visit Task
CURSOR get_parent_task_dtls(c_visit_task_id NUMBER) IS
 SELECT PARENT.visit_task_number, PARENT.visit_task_id
 FROM AHL_VISIT_TASKS_B PARENT, AHL_VISIT_TASKS_B CHILD
 WHERE PARENT.visit_task_id = CHILD.originating_task_id
  AND CHILD.visit_task_id = c_visit_task_id;

CURSOR does_wo_exist_csr(c_visit_task_id NUMBER) IS
 SELECT 1 FROM AHL_WORKORDERS
 WHERE VISIT_TASK_ID = c_visit_task_id;

CURSOR get_wip_entity_id(c_visit_task_id NUMBER) IS
 SELECT wip_entity_id FROM AHL_WORKORDERS
 WHERE VISIT_TASK_ID = c_visit_task_id;

L_API_NAME     CONSTANT VARCHAR2(30)  := 'Get_Task_Relationships';
L_DEBUG_KEY    CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
rel_count               NUMBER;
l_task_wip_id           NUMBER := 0;
l_visit_task_no         NUMBER;
l_visit_task_type       VARCHAR2(30);
l_orig_task_id          NUMBER := 0;
l_parent_task_number    NUMBER;
l_parent_visit_task_id  NUMBER;
l_mwo_wip_entity_id     NUMBER;
l_parent_task_wip_id    NUMBER := 0;
l_sr_id                 NUMBER := 0;
l_mr_id                 NUMBER := 0;

BEGIN

 IF (l_log_procedure >= l_log_current_level) THEN
    fnd_log.string(l_log_procedure,
                   L_DEBUG_KEY ||'.begin',
                   'At the start of PL SQL procedure.');
    fnd_log.string(l_log_procedure,
                   L_DEBUG_KEY,
                   'Visit Id = ' || p_visit_id ||
                   ', Visit Number = ' || p_visit_number ||
                   ', Visit Task Id = ' || p_visit_task_id);
 END IF;

 rel_count := p_x_relationship_tbl.COUNT;

 -- Create relationship only if WO doesn't exist for p_task_id
 OPEN does_wo_exist_csr(p_visit_task_id);
 FETCH does_wo_exist_csr INTO l_task_wip_id;
 IF does_wo_exist_csr%FOUND THEN
    CLOSE does_wo_exist_csr;
    RETURN;
 END IF;
 CLOSE does_wo_exist_csr;

 OPEN get_task_dtls(p_visit_task_id);
 FETCH get_task_dtls into l_visit_task_no, l_visit_task_type, l_sr_id, l_mr_id, l_orig_task_id;
 CLOSE get_task_dtls;

 OPEN  get_parent_task_dtls(p_visit_task_id);
 FETCH get_parent_task_dtls INTO l_parent_task_number, l_parent_visit_task_id;
 CLOSE get_parent_task_dtls;

 OPEN get_mwo_wip_entity_id(p_visit_id);
 FETCH get_mwo_wip_entity_id INTO l_mwo_wip_entity_id;
 CLOSE get_mwo_wip_entity_id;

 OPEN get_wip_entity_id(l_parent_visit_task_id);
 FETCH get_wip_entity_id INTO l_parent_task_wip_id;
 CLOSE get_wip_entity_id;

 IF (l_log_statement >= l_log_current_level) THEN
    fnd_log.string(l_log_statement,
                   L_DEBUG_KEY,
                   'Total Relationships : ' || rel_count);
    fnd_log.string(l_log_statement,
                   L_DEBUG_KEY,
                   'Getting Parent Tasks for task : ' || l_visit_task_no);
 END IF;

 rel_count := rel_count + 1;
 p_x_relationship_tbl(rel_count).batch_id := p_visit_number;
 p_x_relationship_tbl(rel_count).dml_operation := 'C';
 p_x_relationship_tbl(rel_count).relationship_type := 1;
 p_x_relationship_tbl(rel_count).child_header_id := l_visit_task_no;

 IF (l_orig_task_id IS NOT NULL) THEN
       p_x_relationship_tbl(rel_count).parent_wip_entity_id := l_parent_task_wip_id;
       p_x_relationship_tbl(rel_count).parent_header_id := l_parent_task_number;
 ELSE
    -- If the Originating Task is null, make the the Visit's MWO as the parent of this task's WO
    p_x_relationship_tbl(rel_count).parent_wip_entity_id := l_mwo_wip_entity_id;
    p_x_relationship_tbl(rel_count).parent_header_id := 0;
 END IF;

 IF (l_log_statement >= l_log_current_level) THEN
    fnd_log.string(l_log_statement,
                   L_DEBUG_KEY,
                   'Total Relationships : ' || rel_count);
    fnd_log.string(l_log_statement,
                   L_DEBUG_KEY,
                   'All tasks obtained for task : ' || l_visit_task_no);
 END IF;

 IF (l_log_procedure >= l_log_current_level) THEN
    fnd_log.string(l_log_procedure,
                   L_DEBUG_KEY ||'.end',
                   'At the end of PL SQL procedure. p_x_relationship_tbl.COUNT = ' ||
                   p_x_relationship_tbl.COUNT);
 END IF;

END Get_Task_Relationships;

--------------------------------------------------------------------
-- PROCEDURE
--    Get_Visit_Relationships
--
-- PURPOSE
-- To get all the Relationships for the Visit. These include :
-- 1.A record for Each MR to MR / Visit Relationship.
-- 2.A record for Each Visit Task to MR Relationship.
-- 3.A record for Each Visit Task to Visit Relationship for Unassociated Tasks.
--------------------------------------------------------------------

PROCEDURE Get_Visit_Relationships
(
  p_visit_id           IN            NUMBER,
  p_visit_number       IN            NUMBER,
  p_x_relationship_tbl IN OUT NOCOPY AHL_PRD_WORKORDER_PVT.prd_workorder_rel_tbl
)
AS
  L_API_VERSION CONSTANT NUMBER        := 1.0;
  L_API_NAME    CONSTANT VARCHAR2(30)  := 'Get_Visit_Relationships';
  L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
  l_wip_entity_id        NUMBER;
  l_parent_wip_entity_id NUMBER;
  rel_count              NUMBER := 0;
  mr_count               NUMBER := 0;

/*-- Get all the Task Records corresponding to a MR.
CURSOR   get_mrs_for_visit(c_visit_id NUMBER)
IS
SELECT   visit_task_id,
         visit_task_number,
         NVL(originating_task_id, -1)
FROM     AHL_VISIT_TASKS_B
WHERE    visit_id = c_visit_id
AND      task_type_code='SUMMARY'
AND      mr_id IS NOT NULL
ORDER BY 3;*/

/* Changes made by VSUNDARA for SR INTEGRATION*/
-- Get all the Task Records corresponding to a MR.
CURSOR get_mrs_for_visit(c_visit_id NUMBER)
IS
 SELECT visit_task_id,
        visit_task_number,
        NVL(originating_task_id, -1)
 FROM AHL_VISIT_TASKS_B
 WHERE visit_id = c_visit_id
  AND task_type_code='SUMMARY'
  AND (mr_id IS NOT NULL OR unit_effectivity_id IS NOT NULL)
  AND NVL(STATUS_CODE, 'X') <> 'DELETED'
  -- SKPATHAK :: Bug 9444849 :: 19-MAR-2010
  -- This condition added during bug #4075702 fix is not needed
  -- since after opening this cursor we have a check if the visit task id fetched by this cursor already has a corresponding WO
  -- so only for tasks in planning we are building the relationships
  -- Also it is necessary to remove this condition to fix the bug 9444849, since the parent task can be implemented as well
  --AND NVL(STATUS_CODE, 'X') = 'PLANNING'  --Srini Bug #4075702
 ORDER BY 3;
/* End */

TYPE mr_task_rec_type IS RECORD
(
  visit_task_id        NUMBER,
  visit_task_number    NUMBER,
  originating_task_id  NUMBER
);

TYPE mr_task_tbl_type IS TABLE OF mr_task_rec_type INDEX BY BINARY_INTEGER;

l_mrs_for_visit  mr_task_tbl_type;

-- Get all the Tasks associated to a MR.
CURSOR get_tasks_for_mr(c_visit_id NUMBER, c_mr_task_id NUMBER)
IS
SELECT visit_task_number, visit_task_id
FROM   AHL_VISIT_TASKS_B
WHERE  visit_id = c_visit_id
AND    originating_task_id = c_mr_task_id
AND    task_type_code <> 'SUMMARY'
AND NVL(STATUS_CODE, 'X') = 'PLANNING'  --Srini Bug #4075702
AND NVL(STATUS_CODE, 'X') <> 'DELETED';

-- Get all the Unassociated Tasks.
CURSOR get_un_associated_tasks(c_visit_id NUMBER)
IS
SELECT visit_task_number, visit_task_id
FROM   AHL_VISIT_TASKS_B
WHERE  visit_id = c_visit_id
AND NVL(STATUS_CODE, 'X') = 'PLANNING'  --Srini Bug #4075702
AND    task_type_code='UNASSOCIATED';

-- yazhou 27-Jun-2006 starts
-- fix along with bug#5377347, should get the active job for the task only

CURSOR get_wo(c_visit_task_id NUMBER)
IS
SELECT wip_entity_id
FROM AHL_WORKORDERS
WHERE VISIT_TASK_ID = c_visit_task_id
      AND STATUS_CODE NOT IN ('22','7');

CURSOR get_parent_wo(c_visit_task_id NUMBER)
IS
SELECT wip_entity_id
FROM AHL_WORKORDERS
WHERE VISIT_TASK_ID = c_visit_task_id
      AND STATUS_CODE NOT IN ('22','7');
-- yazhou 27-Jun-2006 ends

CURSOR get_mwo(c_visit_id NUMBER)
IS
SELECT wip_entity_id
FROM AHL_WORKORDERS
WHERE visit_id = c_visit_id
AND VISIT_TASK_ID IS NULL
AND MASTER_WORKORDER_FLAG = 'Y'
AND STATUS_CODE NOT IN ('7', '22');

BEGIN

  IF (l_log_procedure >= l_log_current_level) THEN
   fnd_log.string(l_log_procedure,L_DEBUG_KEY||'.begin','At the start of PLSQL procedure');
  END IF;

  rel_count := p_x_relationship_tbl.COUNT;
  -- Get all the Task Records corresponding to a MR for the Visit.
  OPEN get_mrs_for_visit(p_visit_id);
  LOOP
     EXIT WHEN get_mrs_for_visit%NOTFOUND;
     mr_count := mr_count + 1;
     FETCH get_mrs_for_visit
     INTO  l_mrs_for_visit(mr_count).visit_task_id,
            l_mrs_for_visit(mr_count).visit_task_number,
            l_mrs_for_visit(mr_count).originating_task_id;
   END LOOP;
   CLOSE get_mrs_for_visit;

   IF (l_log_statement >= l_log_current_level) THEN
    fnd_log.string(l_log_statement,L_DEBUG_KEY,'Total MRs for Visit : '||l_mrs_for_visit.COUNT);
   END IF;

   IF (l_mrs_for_visit.COUNT > 0) THEN
      FOR i IN l_mrs_for_visit.FIRST..l_mrs_for_visit.LAST LOOP
          -- if the visit task already has a workorder then do not
          -- create a relationship for it
          OPEN get_wo(l_mrs_for_visit(i).visit_task_id);
          FETCH get_wo INTO l_wip_entity_id;
          IF get_wo%NOTFOUND THEN
             rel_count := rel_count + 1;
             p_x_relationship_tbl(rel_count).batch_id := p_visit_number;
             p_x_relationship_tbl(rel_count).child_header_id := l_mrs_for_visit(i).visit_task_number;
             p_x_relationship_tbl(rel_count).relationship_type := 1;
             p_x_relationship_tbl(rel_count).dml_operation := 'C';
             -- Loop to Find out Parent MRs
             IF (l_mrs_for_visit(i).originating_task_id <> -1) THEN
                FOR j IN l_mrs_for_visit.FIRST..l_mrs_for_visit.LAST LOOP
                    IF (l_mrs_for_visit(i).originating_task_id = l_mrs_for_visit(j).visit_task_id) THEN
                       p_x_relationship_tbl(rel_count).parent_header_id := l_mrs_for_visit(j).visit_task_number;
                       OPEN get_parent_wo(l_mrs_for_visit(j).visit_task_id);
                       FETCH get_parent_wo INTO l_parent_wip_entity_id;
                       IF get_parent_wo%FOUND THEN
                          p_x_relationship_tbl(rel_count).parent_wip_entity_id := l_parent_wip_entity_id;
                       END IF;
                       CLOSE get_parent_wo;
                      EXIT;
                    END IF;
                END LOOP;
             END IF;
             -- If no Parent MR is found set the parent as the Visit
             IF (p_x_relationship_tbl(rel_count).parent_header_id IS NULL) THEN
                p_x_relationship_tbl(rel_count).parent_header_id := 0;
                OPEN get_mwo(p_visit_id);
                FETCH get_mwo INTO l_parent_wip_entity_id;
                IF get_mwo%FOUND THEN
                   p_x_relationship_tbl(rel_count).parent_wip_entity_id := l_parent_wip_entity_id;
                END IF;
                CLOSE get_mwo;
             END IF;
          END IF;
          CLOSE get_wo;
      END LOOP;
   END IF;

   IF (l_log_statement >= l_log_current_level) THEN
    fnd_log.string(l_log_statement,L_DEBUG_KEY,'Getting Tasks for MRs');
   END IF;
   -- Get all the Tasks for a MR.
   IF (l_mrs_for_visit.COUNT > 0) THEN
     FOR i IN l_mrs_for_visit.FIRST..l_mrs_for_visit.LAST LOOP
       FOR mr_tasks_cursor IN get_tasks_for_mr(p_visit_id, l_mrs_for_visit(i).visit_task_id) LOOP
           OPEN get_wo(mr_tasks_cursor.visit_task_id);
           FETCH get_wo INTO l_wip_entity_id;
           IF get_wo%NOTFOUND THEN
              rel_count := rel_count + 1;
              p_x_relationship_tbl(rel_count).batch_id := p_visit_number;
              p_x_relationship_tbl(rel_count).parent_header_id := l_mrs_for_visit(i).visit_task_number;
              p_x_relationship_tbl(rel_count).child_header_id := mr_tasks_cursor.visit_task_number;
              p_x_relationship_tbl(rel_count).relationship_type := 1;
              p_x_relationship_tbl(rel_count).dml_operation := 'C';
              -- if this visit task is already in shop floor then get the wip_entity_id
              OPEN get_parent_wo(l_mrs_for_visit(i).visit_task_id);
              FETCH get_parent_wo INTO l_parent_wip_entity_id;
              IF get_parent_wo%FOUND THEN
                p_x_relationship_tbl(rel_count).parent_wip_entity_id := l_parent_wip_entity_id;
              END IF;
              CLOSE get_parent_wo;
          END IF;
          CLOSE get_wo;
       END LOOP;
     END LOOP;
   END IF;

   IF (l_log_statement >= l_log_current_level) THEN
    fnd_log.string(l_log_statement,L_DEBUG_KEY,'Getting Unassociated Tasks for Visit');
   END IF;

   -- Get all Un-associated Tasks for a Visit.
   OPEN get_mwo(p_visit_id);
   FETCH get_mwo INTO l_parent_wip_entity_id;
   IF get_mwo%NOTFOUND THEN
      l_parent_wip_entity_id := 0;
   END IF;
   CLOSE get_mwo;

   FOR tsk_cursor IN get_un_associated_tasks(p_visit_id) LOOP
       OPEN get_wo(tsk_cursor.visit_task_id);
       FETCH get_wo INTO l_wip_entity_id;
       IF get_wo%NOTFOUND THEN
          rel_count := rel_count + 1;
          p_x_relationship_tbl(rel_count).batch_id := p_visit_number;
          p_x_relationship_tbl(rel_count).parent_header_id := 0; -- Visit
          p_x_relationship_tbl(rel_count).child_header_id := tsk_cursor.visit_task_number;
          p_x_relationship_tbl(rel_count).relationship_type := 1;
          p_x_relationship_tbl(rel_count).dml_operation := 'C';
          p_x_relationship_tbl(rel_count).parent_wip_entity_id := l_parent_wip_entity_id;
       END IF;
       CLOSE get_wo;
   END LOOP;

   IF (l_log_procedure >= l_log_current_level) THEN
    fnd_log.string(l_log_procedure,L_DEBUG_KEY,'Total Relationships : ' || p_x_relationship_tbl.COUNT );
    fnd_log.string(l_log_procedure,L_DEBUG_KEY||'.end','At the end of PLSQL procedure');
   END IF;

END Get_Visit_Relationships;

--------------------------------------------------------------------
-- PROCEDURE
--    Get_Task_Dependencies
--
-- PURPOSE
-- To get all the Technical Dependencies for the Visit Task.
--------------------------------------------------------------------

PROCEDURE Get_Task_Dependencies
(
  p_visit_number       IN            NUMBER,
  p_visit_task_id      IN            NUMBER,
  p_visit_task_number  IN            NUMBER,
  p_x_relationship_tbl IN OUT NOCOPY AHL_PRD_WORKORDER_PVT.prd_workorder_rel_tbl
)
AS
   L_API_VERSION   CONSTANT NUMBER        := 1.0;
   L_API_NAME      CONSTANT VARCHAR2(30)  := 'Get_Task_Dependencies';
   L_DEBUG_KEY     CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

-- Get all the Task Dependencies.
CURSOR get_tech_dependencies(c_visit_task_id NUMBER)
IS
 SELECT PARENT.visit_task_number parent_task_number,
        CHILD.visit_task_number child_task_number
 FROM AHL_VISIT_TASKS_B PARENT,
      AHL_VISIT_TASKS_B CHILD,
      AHL_TASK_LINKS LINK
 WHERE PARENT.visit_task_id = LINK.parent_task_id
  AND CHILD.visit_task_id = LINK.visit_task_id
  AND NVL(PARENT.STATUS_CODE,'X') = 'PLANNING'
  AND NVL(CHILD.STATUS_CODE,'X') = 'PLANNING'
  AND (PARENT.visit_task_id = c_visit_task_id
       OR  CHILD.visit_task_id = c_visit_task_id);

l_visit_task_number NUMBER;
rel_count           NUMBER;
dup_found           BOOLEAN;

BEGIN

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                 L_DEBUG_KEY ||'.begin',
                 'At the start of PL SQL procedure.');
      fnd_log.string(l_log_procedure,
                 L_DEBUG_KEY,
                 'Visit Number = ' || p_visit_number ||
                 ', Visit Task Id = ' || p_visit_task_id ||
                 ', Visit Task Number = ' || p_visit_task_number);
   END IF;

   rel_count := p_x_relationship_tbl.COUNT;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Total dependencies = ' || rel_count);
   END IF;

   -- Get the Technical Dependencies between Visit Tasks for a Visit.
   FOR tsk_cursor IN get_tech_dependencies(p_visit_task_id) LOOP

       dup_found := FALSE;
       --Do not insert the row if it already exists in relationship table.
       FOR i IN p_x_relationship_tbl.FIRST..p_x_relationship_tbl.LAST LOOP
           IF (p_x_relationship_tbl(i).relationship_type = 2 AND
                p_x_relationship_tbl(i).parent_header_id = tsk_cursor.parent_task_number AND
                p_x_relationship_tbl(i).child_header_id = tsk_cursor.child_task_number) THEN
             dup_found := TRUE;
             EXIT;
           END IF;
       END LOOP;

       IF (dup_found = FALSE) THEN
          rel_count := rel_count + 1;
          p_x_relationship_tbl(rel_count).batch_id := p_visit_number;
          p_x_relationship_tbl(rel_count).parent_header_id := tsk_cursor.parent_task_number;
          p_x_relationship_tbl(rel_count).child_header_id := tsk_cursor.child_task_number;
          p_x_relationship_tbl(rel_count).relationship_type := 2;
          p_x_relationship_tbl(rel_count).dml_operation := 'C';
       END IF;

   END LOOP;

   IF (l_log_procedure >= l_log_current_level ) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY,
                     'Total dependencies for Visit Task ' || p_visit_task_number ||
                     'is: '|| rel_count);
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure.');
   END IF;

END Get_Task_Dependencies;

--------------------------------------------------------------------
-- PROCEDURE
--    Get_Visit_Dependencies
--
-- PURPOSE
-- To get all the Technical Dependencies for the Visit.
--------------------------------------------------------------------

PROCEDURE Get_Visit_Dependencies
(
  p_visit_id           IN            NUMBER,
  p_visit_number       IN            NUMBER,
  p_x_relationship_tbl IN OUT NOCOPY AHL_PRD_WORKORDER_PVT.prd_workorder_rel_tbl
)
AS
  L_API_VERSION  CONSTANT NUMBER        := 1.0;
  L_API_NAME     CONSTANT VARCHAR2(30)  := 'Get_Visit_Dependencies';
  L_DEBUG_KEY    CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
  rel_count               NUMBER;

-- Get all the Task Dependencies.
CURSOR get_tech_dependencies(c_visit_id NUMBER)
IS
SELECT PARENT.visit_task_number parent_task_number,
       CHILD.visit_task_number child_task_number
FROM   AHL_VISIT_TASKS_B PARENT,
       AHL_VISIT_TASKS_B CHILD,
       AHL_TASK_LINKS LINK
WHERE  PARENT.visit_task_id = LINK.parent_task_id
 AND    CHILD.visit_task_id = LINK.visit_task_id
 AND    NVL(PARENT.STATUS_CODE,'X') = 'PLANNING' --Srini Bug #4075702
 AND    PARENT.visit_id = c_visit_id
 AND    CHILD.visit_id = c_visit_id;

BEGIN

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure.');
   END IF;

   rel_count := p_x_relationship_tbl.COUNT;

   -- Get the Technical Dependencies between Visit Tasks for a Visit.
   FOR tsk_cursor IN get_tech_dependencies(p_visit_id) LOOP
     rel_count := rel_count + 1;
     p_x_relationship_tbl(rel_count).batch_id := p_visit_number;
     p_x_relationship_tbl(rel_count).parent_header_id := tsk_cursor.parent_task_number;
     p_x_relationship_tbl(rel_count).child_header_id := tsk_cursor.child_task_number;
     p_x_relationship_tbl(rel_count).relationship_type := 2;
     p_x_relationship_tbl(rel_count).dml_operation := 'C';
   END LOOP;

   IF (l_log_procedure >= l_log_current_level ) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY,
                     'Total Relationships : ' || p_x_relationship_tbl.COUNT);
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure.');
   END IF;

END Get_Visit_Dependencies;

/* End Changes by Shkalyan */

--------------------------------------------------------------------
-- PROCEDURE
--    Push_to_Production
--
-- PURPOSE
--    To push visit along with all its tasks to Production for create jobs
--------------------------------------------------------------------
PROCEDURE Push_to_Production
(   p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := Fnd_Api.g_false,
    p_commit            IN  VARCHAR2 := Fnd_Api.g_false,
    p_validation_level  IN  NUMBER   := Fnd_Api.g_valid_level_full,
    p_module_type       IN  VARCHAR2 := Null,
    p_visit_id          IN  NUMBER,
    p_release_flag      IN  VARCHAR2 := 'N', -- By shbhanda 05/21/04 for TC changes
    p_orig_visit_id     IN  NUMBER   := NULL, -- By yazhou  08/06/04 for TC changes
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
)
IS
   L_API_VERSION   CONSTANT NUMBER       := 1.0;
   L_API_NAME      CONSTANT VARCHAR2(30) := 'Push_to_Production';
   L_DEBUG_KEY     CONSTANT VARCHAR2(100):= 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
   l_prd_workorder_tbl  AHL_PRD_WORKORDER_PVT.PRD_WORKORDER_TBL;
   /* Begin Changes by Shkalyan */
   l_prd_workorder_rel_tbl  AHL_PRD_WORKORDER_PVT.PRD_WORKORDER_REL_TBL;
   l_firm_planned_flag    VARCHAR2(1) := FND_PROFILE.value('AHL_PRD_FIRM_PLANNED_FLAG');
   l_visit_wo_id          NUMBER;
   l_visit_wo_ovn         NUMBER;
   l_visit_wo_status      VARCHAR2(30);
   l_visit_wo_start_time  DATE;
   l_visit_wo_end_time    DATE;
   l_orig_visit_status    VARCHAR2(30);
   l_orig_task_status     VARCHAR2(30);
   l_workorder_id         NUMBER;
   l_workorder_ovn        NUMBER;
   l_workorder_status     VARCHAR2(30);
   /* End Changes by Shkalyan */
   l_return_status        VARCHAR2(1);
   l_msg_count            NUMBER;
   l_msg_data             VARCHAR2(2000);
   idx                    NUMBER;
   l_count                NUMBER;
   l_route_id             NUMBER;
   l_commit               VARCHAR2(1) := 'F';
   l_visit_end_time       DATE;
   l_temp_msg_count       NUMBER:=0; --rnahata
   l_init_msg_list        VARCHAR2(1) := 'F';

   -- To find visit related information
   CURSOR c_visit (x_id IN NUMBER) IS
    SELECT * FROM AHL_VISITS_VL
    WHERE VISIT_ID = x_id;

   c_visit_rec c_visit%ROWTYPE;
   c_orig_visit_rec c_visit%ROWTYPE;

   /* Begin Changes by VSUNDARA For SR Integration*/
   -- To find task related information
   CURSOR c_task (x_id IN NUMBER) IS
    SELECT * FROM AHL_VISIT_TASKS_VL
    WHERE VISIT_ID = x_id
     AND NVL(STATUS_CODE, 'X') = 'PLANNING'
     AND (TASK_TYPE_CODE <> 'SUMMARY' OR
           (TASK_TYPE_CODE = 'SUMMARY' AND
             (MR_ID IS NOT NULL OR UNIT_EFFECTIVITY_ID IS NOT NULL)));
   /* End */

   c_task_rec c_task%ROWTYPE;
   c_orig_task_rec c_task%ROWTYPE;

   /* Begin Changes by Shkalyan */
     -- To find count for tasks for visit
   CURSOR c_task_ct (x_id IN NUMBER) IS
    SELECT count(*) FROM AHL_VISIT_TASKS_VL
    WHERE VISIT_ID = x_id
     AND NVL(STATUS_CODE, 'X') = 'PLANNING'
     AND (TASK_TYPE_CODE <> 'SUMMARY' OR
           (TASK_TYPE_CODE = 'SUMMARY' AND
             MR_ID IS NOT NULL OR UNIT_EFFECTIVITY_ID IS NOT NULL));
   /* End Changes by Shkalyan */

   -- To find Route Id from MR Routes view
   CURSOR c_route (x_id IN NUMBER) IS
    SELECT Route_Id FROM AHL_MR_ROUTES_V
    WHERE MR_ROUTE_ID = x_id;

   /* Begin Changes by Shkalyan */
    -- To find job for task
   CURSOR c_job (x_id IN NUMBER) IS
    SELECT workorder_id, object_version_number, status_code
    FROM AHL_WORKORDERS
    WHERE VISIT_TASK_ID = x_id
     AND STATUS_CODE not in ('22','7'); --(22-Deleted, 7-Cancelled)

   --transit check visit change
   --yazhou start
   -- To find master workorder for Visit
   CURSOR c_visit_job (x_visit_id IN NUMBER) IS
    SELECT wo.workorder_id, wo.object_version_number, wo.status_code,
          WIP.SCHEDULED_START_DATE,
          WIP.SCHEDULED_COMPLETION_DATE
    FROM AHL_WORKORDERS WO,
         WIP_DISCRETE_JOBS WIP
    WHERE wo.VISIT_ID = x_visit_id
     AND   wo.VISIT_TASK_ID IS NULL
     AND   wo.MASTER_WORKORDER_FLAG = 'Y'
     AND   WIP.WIP_ENTITY_ID = WO.WIP_ENTITY_ID
     AND   wo.STATUS_CODE not in ('22','7'); --(22-Deleted, 7-Cancelled)

   CURSOR c_visit_wo_status (x_visit_id IN NUMBER) IS
    SELECT wo.status_code
    FROM AHL_WORKORDERS WO
    WHERE wo.VISIT_ID = x_visit_id
     AND   wo.VISIT_TASK_ID IS NULL
     AND   wo.MASTER_WORKORDER_FLAG = 'Y'
     AND   wo.STATUS_CODE not in ('22','7'); --(22-Deleted, 7-Cancelled)

   -- Get workorder status for the coresponding job in originating visit
   CURSOR c_wo_status (x_orig_visit_id IN NUMBER, x_visit_task_id IN NUMBER) IS
    SELECT wo.status_code
    FROM AHL_WORKORDERS WO,
         AHL_VISIT_TASKS_B t
    WHERE wo.VISIT_ID = x_orig_visit_id
     AND   wo.visit_task_id = t.visit_task_id
     AND   t.visit_task_number = (Select visit_task_number
                                  from ahl_visit_tasks_b
                                 where visit_task_id = x_visit_task_id)
     AND   wo.STATUS_CODE not in ('22','7'); --(22-Deleted, 7-Cancelled)
   -- yazhou end

  /* End Changes by Shkalyan */

   --Post11510. Added to get summary task start, end time
   CURSOR get_summary_task_times_csr(x_task_id IN NUMBER)IS
         SELECT min(start_date_time), max(end_date_time)
      --TCHIMIRA::19-FEB-2010::BUG 9384614
      -- Use the base table instead of the vl view
      FROM ahl_visit_tasks_b VST
         START WITH visit_task_id  = x_task_id
       -- anraj changed coz the nvl on the RHS is not required
         -- AND NVL(VST.status_code, 'Y') <> NVL ('DELETED', 'X')
       AND NVL(VST.status_code, 'Y') <> 'DELETED'
         CONNECT BY originating_task_id = PRIOR visit_task_id;

-- Added by Jerry on 08/13/2004 per Yan and Alex's request
-- Yan added the condition to filter out summary tasks on 08/31/2005
CURSOR get_independent_tasks(c_visit_id IN NUMBER) IS
  select t.visit_task_id
    from ahl_visit_tasks_b t,
         ahl_visits_b v
   where v.visit_id = c_visit_id
     and v.visit_id = t.visit_id
     and v.status_code = 'PARTIALLY RELEASED'
     and t.start_date_time < SYSDATE
     and t.status_code ='PLANNING'
     and t.task_type_code <>'SUMMARY'
     -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Adjust task times only if past task start date is null
     and t.past_task_start_date IS NULL
     and (not exists (select 1 from ahl_task_links l0
                      where l0.parent_task_id = t.visit_task_id
                         or l0.visit_task_id = t.visit_task_id)
          or t.visit_task_id in (select l1.parent_task_id from ahl_task_links l1
                                  where not exists (select l2.visit_task_id from ahl_task_links l2
                                                     where l2.visit_task_id = l1.parent_task_id)));
--Modified by Srini Nov08, 2004 to create master workorder not having an asset

-- anraj: Modified the cursor definition to exclude the tasks in status DELETED
CURSOR get_task_inst_dtls(c_visit_id IN NUMBER)
IS
  SELECT inventory_item_id,instance_id
  FROM ahl_visit_tasks_vl
  WHERE visit_id = c_visit_id
  AND NVL(status_code, 'Y') <> 'DELETED'
  AND ROWNUM = 1;
get_task_inst_rec  get_task_inst_dtls%ROWTYPE;

/* Added by rnahata for Bug 6447196 */
CURSOR c_get_vst_status_and_date (c_visit_id IN NUMBER) IS
 SELECT status_code, close_date_time
 FROM ahl_visits_b
 WHERE visit_id = c_visit_id;
get_vst_status_and_date_rec   c_get_vst_status_and_date%ROWTYPE;

/* Added by rnahata for Bug 5758813
   Fetches the route information for updating workorder
   description for tasks created from Routes */
CURSOR get_wo_dtls_for_mrtasks_cur (p_task_id IN NUMBER) IS
 --TCHIMIRA::Bug 9149770 ::09-FEB-2010
 --use substrb and lengthb instead of substr and length respectively
 SELECT ar.route_no||'.'||substrb(ar.title,1,(240 - (lengthb(ar.route_no) + 1))) workorder_description
 FROM ahl_routes_vl ar,ahl_visit_tasks_b avt, ahl_mr_routes mrr
 WHERE avt.visit_task_id = p_task_id
  AND nvl(avt.status_code,'Y') = 'PLANNING'
  AND avt.mr_route_id = mrr.mr_route_id
  AND mrr.route_id = ar.route_id;
  get_wo_dtls_for_mrtasks_rec    get_wo_dtls_for_mrtasks_cur%ROWTYPE;

BEGIN
   --------------------- initialize -----------------------

   SAVEPOINT Push_to_Production;
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Visit Id = ' || p_visit_id);
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_boolean(p_init_msg_list)
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   --  Initialize API return status to success
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Before calling AHL_VWP_TIMES_PVT.Calculate_Task_Times');
   END IF;

   -- Calculate Task Start/End time
   AHL_VWP_TIMES_PVT.CALCULATE_TASK_TIMES(
           p_api_version      => 1.0,
           p_init_msg_list    => Fnd_Api.G_FALSE,
           p_commit           => Fnd_Api.G_FALSE,
           p_validation_level => Fnd_Api.G_VALID_LEVEL_FULL,
           x_return_status    => l_return_status,
           x_msg_count        => l_msg_count,
           x_msg_data         => l_msg_data,
           p_visit_id         => p_visit_id);

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'After calling AHL_VWP_TIMES_PVT.Calculate_Task_Times. Return Status = ' || l_return_status);
   END IF;

   IF (l_return_status <> Fnd_Api.G_RET_STS_SUCCESS) THEN
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Errors from AHL_VWP_TIMES_PVT.Calculate_Task_Times. Message count: ' ||
                        l_msg_count || ', message data: ' || l_msg_data);
      END IF;
   END IF;

   /*rnahata - B6447196 - start*/
   /*c_visit_rec fetch has been moved after the project details are updated for the visit. Hence
   moved the cursor after integrate_to_projects*/
   OPEN c_get_vst_status_and_date (p_visit_id);
   FETCH c_get_vst_status_and_date INTO get_vst_status_and_date_rec;
   CLOSE c_get_vst_status_and_date;
   /*rnahata - B6447196 - end*/

   --Jerry updated on 08/13/2004 after discussion with Yan and Alex for adjusting task start date
   IF get_vst_status_and_date_rec.STATUS_CODE = 'PARTIALLY RELEASED' THEN
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Before calling AHL_VWP_TIMES_PVT.adjust_task_times');
      END IF;
      FOR l_get_independent_tasks IN get_independent_tasks(p_visit_id) LOOP
          AHL_VWP_TIMES_PVT.adjust_task_times(
                 p_api_version         => 1.0,
                 p_init_msg_list       => Fnd_Api.G_FALSE,
                 p_commit              => Fnd_Api.G_FALSE,
                 p_validation_level    => Fnd_Api.G_VALID_LEVEL_FULL,
                 x_return_status       => l_return_status,
                 x_msg_count           => l_msg_count,
                 x_msg_data            => l_msg_data,
                 p_task_id             => l_get_independent_tasks.visit_task_id,
                 p_reset_sysdate_flag  => FND_API.G_TRUE);
      END LOOP;

      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'After calling AHL_VWP_TIMES_PVT.adjust_task_times. Return Status = ' || l_return_status);
      END IF;

      IF (l_return_status <> Fnd_Api.G_RET_STS_SUCCESS) THEN
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Errors from AHL_VWP_TIMES_PVT.adjust_task_times. Message count: ' ||
                           l_msg_count || ', message data: ' || l_msg_data);
         END IF;
      END IF;

      l_visit_end_time := AHL_VWP_TIMES_PVT.get_visit_end_time(p_visit_id);
      IF l_visit_end_time > get_vst_status_and_date_rec.close_date_time THEN
         Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_VST_TSK_STDT_ADJU');
         Fnd_Message.Set_Token('VISIT_END_DATE', l_visit_end_time);
         Fnd_Msg_Pub.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   /*rnahata - B6447196 - start*/
   /*moved the call to integrate to projects after task times gets updated
   esp in case of visits that is partially implemented*/
   idx := idx + 1;
   --Call prrojects
   -- Post 11.5.10
   -- RROY

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Before calling INTEGRATE_TO_PROJECTS');
   END IF;

   AHL_VWP_PROJ_PROD_PVT.Integrate_to_Projects
              (p_api_version       => l_api_version,
               p_init_msg_list     => p_init_msg_list,
               p_commit            => l_commit,
               p_validation_level  => p_validation_level,
               p_module_type       => p_module_type,
               p_visit_id          => p_visit_id,
               x_return_status     => l_return_status,
               x_msg_count         => l_msg_count,
               x_msg_data          => x_msg_data);

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'After calling INTEGRATE_TO_PROJECTS. l_return_status '||l_return_status);
   END IF;

   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     -- Check Error Message stack.
     x_msg_count := FND_MSG_PUB.count_msg;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Post 11.5.10
   -- RROY
   OPEN c_visit (p_visit_id);
   FETCH c_visit INTO c_visit_rec;
   CLOSE c_visit;
   /*rnahata - B6447196 - end*/

   -- Begin changes by rnahata for Bug 6448678
   l_temp_msg_count := Fnd_Msg_Pub.count_msg;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
       L_DEBUG_KEY,
       'Before calling VALIDATE_MR_ROUTE_DATE. l_msg_count = ' || l_msg_count);
   END IF;

   OPEN c_task (p_visit_id);
   LOOP
       FETCH c_task INTO c_task_rec;
       EXIT WHEN c_task%NOTFOUND;
       Validate_MR_Route_Date
       (
          p_mr_route_id       => c_task_rec.mr_route_id,
          p_visit_task_number => c_task_rec.visit_task_number,
          p_start_date_time   => c_task_rec.start_date_time,
          p_end_date_time     => c_task_rec.end_date_time
      );

       IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
          L_DEBUG_KEY,
          'After calling VALIDATE_MR_ROUTE_DATE for task Id: ' ||
          c_task_rec.visit_task_id ||', l_msg_count = ' || l_msg_count);
       END IF;

   END LOOP;
   CLOSE c_task;

   l_msg_count := Fnd_Msg_Pub.count_msg;
   IF (l_msg_count <> l_temp_msg_count) THEN
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
         L_DEBUG_KEY,
         'Errors from VALIDATE_MR_ROUTE_DATE. Message count: ' || l_msg_count);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   -- End changes by rnahata for Bug 6448678

  -- transit check visit Change
  -- yazhou start
   IF  p_orig_visit_id IS NOT NULL THEN

      OPEN c_visit (p_orig_visit_id);
      FETCH c_visit INTO c_orig_visit_rec;
      CLOSE c_visit;

      OPEN c_visit_wo_status (p_orig_visit_id);
      FETCH c_visit_wo_status INTO l_orig_visit_status;
      CLOSE c_visit_wo_status;
   END IF;
   -- yazhou end

   -- Start for 11.5.10 release
   -- By shbhanda 05-Jun-03
   -- For creating/updating Master Workorder in production for the visit in VWP

   /* Begin Changes by Shkalyan */

   idx := 0;

   OPEN c_visit_job (p_visit_id);
   FETCH c_visit_job INTO l_visit_wo_id, l_visit_wo_ovn, l_visit_wo_status, l_visit_wo_start_time,l_visit_wo_end_time;
   CLOSE c_visit_job;
   --
   OPEN get_task_inst_dtls(p_visit_id);
   FETCH get_task_inst_dtls INTO get_task_inst_rec;
   CLOSE get_task_inst_dtls;
   --
   -- master workorder for visit already exists
   IF l_visit_wo_id IS NOT NULL THEN

      -- If visit dates changed then reschedule the jobs
      IF (l_visit_wo_start_time <> c_visit_rec.START_DATE_TIME
          OR l_visit_wo_end_time <> c_visit_rec.CLOSE_DATE_TIME) THEN

         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
             L_DEBUG_KEY,
             'Before calling AHL_PRD_WORKORDER_PVT.reschedule_visit_jobs');
         END IF;

         AHL_PRD_WORKORDER_PVT.reschedule_visit_jobs(
              P_API_VERSION                  => 1.0,
              x_return_status                => l_return_status,
              x_msg_count                    => l_msg_count,
              x_msg_data                     => l_msg_data,
              P_VISIT_ID                     => p_visit_id,
              p_x_scheduled_start_date       => c_visit_rec.START_DATE_TIME,
              p_x_scheduled_end_date         => c_visit_rec.CLOSE_DATE_TIME);

         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'After calling AHL_PRD_WORKORDER_PVT.reschedule_visit_jobs. Return Status = ' || l_return_status);
         END IF;

         IF (l_return_status <> Fnd_Api.G_RET_STS_SUCCESS) THEN
            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'Errors from AHL_PRD_WORKORDER_PVT.reschedule_visit_jobs. Message count: ' ||
                              l_msg_count || ', message data: ' || l_msg_data);
            END IF;
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSE
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

      END IF; --reschedule visit jobs

      -- If p_module_type is 'CST' then master workorder status should stay as DRAFT
      -- Update only workorder time

      -- Re-Query the OVN for the workorder again since its been updated by
      -- AHL_PRD_WORKORDER_PVT.RESCHEDULE_VISIT_JOBS API.
      -- Balaji added this fix as a part of BAE OVN bug fix for workorders.
      OPEN c_visit_job (p_visit_id);
      FETCH c_visit_job INTO l_visit_wo_id, l_visit_wo_ovn, l_visit_wo_status, l_visit_wo_start_time,l_visit_wo_end_time;
      CLOSE c_visit_job;

      IF p_module_type = 'CST' THEN
         idx := idx+1;
         l_prd_workorder_tbl(idx).DML_OPERATION := 'U';
         l_prd_workorder_tbl(idx).WORKORDER_ID := l_visit_wo_id;
         l_prd_workorder_tbl(idx).OBJECT_VERSION_NUMBER := l_visit_wo_ovn;
         l_prd_workorder_tbl(idx).SCHEDULED_START_DATE  := c_visit_rec.start_date_time;
         l_prd_workorder_tbl(idx).SCHEDULED_END_DATE    := c_visit_rec.close_date_time;
      END IF;

      -- If visit master workorder status is already RELEASED, the no change should be made

      IF p_module_type <> 'CST' AND l_visit_wo_status <> '3' THEN
         --TCHIMIRA::P2P CP ER 9151144::02-DEC-2009
         --Modified the if condition
         IF (p_release_flag = 'Y' OR p_release_flag = 'R')  THEN
            -- change status from UNRELEASED/DRAFT to RELEASED
            idx := idx+1;
            l_prd_workorder_tbl(idx).DML_OPERATION := 'U';
            l_prd_workorder_tbl(idx).WORKORDER_ID := l_visit_wo_id;
            l_prd_workorder_tbl(idx).OBJECT_VERSION_NUMBER := l_visit_wo_ovn;
            l_prd_workorder_tbl(idx).STATUS_CODE  := '3';   -- Released
            l_prd_workorder_tbl(idx).FIRM_PLANNED_FLAG     := 1; -- Firm
            -- l_prd_workorder_tbl(idx).VALIDATE_STRUCTURE := 'Y'; -- rroy - TC - validate entire structure
            l_prd_workorder_tbl(idx).SCHEDULED_START_DATE  := c_visit_rec.start_date_time;
            l_prd_workorder_tbl(idx).SCHEDULED_END_DATE    := c_visit_rec.close_date_time;
         ELSIF l_visit_wo_status = '17' THEN
            -- Master workorder was in Draft status
            -- Need to make it UNRELEASED now
            idx := idx+1;
            l_prd_workorder_tbl(idx).DML_OPERATION := 'U';
            l_prd_workorder_tbl(idx).WORKORDER_ID := l_visit_wo_id;
            l_prd_workorder_tbl(idx).OBJECT_VERSION_NUMBER := l_visit_wo_ovn;
            l_prd_workorder_tbl(idx).SCHEDULED_START_DATE  := c_visit_rec.start_date_time;
            l_prd_workorder_tbl(idx).SCHEDULED_END_DATE    := c_visit_rec.close_date_time;
            l_prd_workorder_tbl(idx).STATUS_CODE           := '1';   -- Unreleased
            l_prd_workorder_tbl(idx).FIRM_PLANNED_FLAG     := 1; -- Firm
         -- Added by jaramana on 20-OCT-2009 for Bug 9016332
         -- Also need to handle if the Master Work Order is in Unreleased status
         -- and user does P2P with Unreleased work orders
         ELSIF l_visit_wo_status = '1' THEN
            -- Master workorder is in Unreleased status and user wants to keep it that way
            idx := idx+1;
            l_prd_workorder_tbl(idx).DML_OPERATION         := 'U';
            l_prd_workorder_tbl(idx).WORKORDER_ID          := l_visit_wo_id;
            l_prd_workorder_tbl(idx).OBJECT_VERSION_NUMBER := l_visit_wo_ovn;
            l_prd_workorder_tbl(idx).SCHEDULED_START_DATE  := c_visit_rec.start_date_time;
            l_prd_workorder_tbl(idx).SCHEDULED_END_DATE    := c_visit_rec.close_date_time;
            l_prd_workorder_tbl(idx).STATUS_CODE           := '1';   -- Unreleased
            l_prd_workorder_tbl(idx).FIRM_PLANNED_FLAG     := 1; -- Firm
         -- End addition by jaramana on 20-OCT-2009 for Bug 9016332
         END IF;
      ELSIF p_module_type <> 'CST' THEN
         idx := idx+1;
         l_prd_workorder_tbl(idx).DML_OPERATION := 'U';
         l_prd_workorder_tbl(idx).WORKORDER_ID := l_visit_wo_id;
         l_prd_workorder_tbl(idx).OBJECT_VERSION_NUMBER := l_visit_wo_ovn;
         --l_prd_workorder_tbl(idx).STATUS_CODE  := '3';   -- Released
         --l_prd_workorder_tbl(idx).FIRM_PLANNED_FLAG     := 1; -- Firm
         --l_prd_workorder_tbl(idx).VALIDATE_STRUCTURE := 'Y'; -- rroy - TC - validate entire structure
         l_prd_workorder_tbl(idx).SCHEDULED_START_DATE  := c_visit_rec.start_date_time;
         l_prd_workorder_tbl(idx).SCHEDULED_END_DATE    := c_visit_rec.close_date_time;
      END IF;
      l_prd_workorder_tbl(idx).BATCH_ID := c_visit_rec.VISIT_NUMBER;
      l_prd_workorder_tbl(idx).HEADER_ID := 0; -- Visit

   ELSE  -- Visit Master Workorder doesn't exist

      idx := idx+1;

      l_prd_workorder_tbl(idx).DML_OPERATION := 'C';

      IF (p_module_type = 'CST') THEN
         l_prd_workorder_tbl(idx).STATUS_CODE           := '17';  -- draft

         -- sracha 27Jul05. Create Draft WO as firm to avoid scheduling by EAM.
         --l_prd_workorder_tbl(idx).FIRM_PLANNED_FLAG     := 2; -- Planned
         l_prd_workorder_tbl(idx).FIRM_PLANNED_FLAG     := 1; -- Firm

     ELSE
         IF p_orig_visit_id IS NOT NULL THEN
            -- Create master workorder in same status as that of the originating visit
            l_prd_workorder_tbl(idx).STATUS_CODE           := l_orig_visit_status;
         ELSE
            --TCHIMIRA::P2P CP ER 9151144::02-DEC-2009::Modified if condition
            IF (p_release_flag = 'Y' OR p_release_flag = 'R') THEN
               l_prd_workorder_tbl(idx).STATUS_CODE           := '3';  -- Released
            ELSE
               l_prd_workorder_tbl(idx).STATUS_CODE           := '1';  -- Unreleased
            END IF;
         END IF;

         l_prd_workorder_tbl(idx).FIRM_PLANNED_FLAG     := 1; -- Firm

     END IF;
     -- Post 11.5.10 Changes by senthil
     l_prd_workorder_tbl(idx).SCHEDULED_START_DATE  := c_visit_rec.start_date_time;
     -- Changed by Shbhanda on 30th Jan 04
     l_prd_workorder_tbl(idx).SCHEDULED_END_DATE  := c_visit_rec.close_date_time;

     l_prd_workorder_tbl(idx).MASTER_WORKORDER_FLAG := 'Y';
     l_prd_workorder_tbl(idx).BATCH_ID := c_visit_rec.VISIT_NUMBER;
     l_prd_workorder_tbl(idx).HEADER_ID := 0; -- Visit
     /* End Changes by Shkalyan */
     l_prd_workorder_tbl(idx).VISIT_ID              := p_visit_id;
     l_prd_workorder_tbl(idx).ORGANIZATION_ID       := c_visit_rec.organization_id;
     l_prd_workorder_tbl(idx).PROJECT_ID            := c_visit_rec.project_id;
     l_prd_workorder_tbl(idx).DEPARTMENT_ID         := c_visit_rec.department_id ;
     l_prd_workorder_tbl(idx).INVENTORY_ITEM_ID     := NVL(c_visit_rec.inventory_item_id,get_task_inst_rec.inventory_item_id);
     l_prd_workorder_tbl(idx).ITEM_INSTANCE_ID      := NVL(c_visit_rec.item_instance_id,get_task_inst_rec.instance_id);
     l_prd_workorder_tbl(idx).JOB_DESCRIPTION       := c_visit_rec.visit_name ;
  END IF; --visit master workorder exist

  -- Create Workorders for tasks that have no workorder in production
  -- Update workorder only if the previous status is DRAFT

  OPEN c_task_ct(p_visit_id);
  FETCH c_task_ct INTO l_count;
  CLOSE c_task_ct;

  IF (l_log_statement >= l_log_current_level) THEN
     fnd_log.string(l_log_statement,
                    L_DEBUG_KEY,
                    'Task Count' || l_count);
  END IF;

  IF l_count > 0 THEN
     OPEN c_task(p_visit_id);
     FETCH c_task INTO c_task_rec;
     WHILE c_task%FOUND LOOP

     /* Begin Changes by Shkalyan */
     IF p_orig_visit_id is not NULL THEN
        -- Check the workorder status for the coresponding task in originating visit

        l_orig_task_status := null;

        OPEN c_wo_status(p_orig_visit_id,c_task_rec.visit_task_id);
        FETCH c_wo_status INTO l_orig_task_status;
        CLOSE c_wo_status;
     END IF;

     IF p_orig_visit_id is NULL OR l_orig_task_status is not null THEN

        -- Merge process for 11.5.10 bug fix on CMRDV10P
        -- Fix for Bug 3549573
        l_workorder_id := NULL;
        l_workorder_ovn := NULL;
        l_workorder_status := NULL;

        -- To get the Workorder for Visit Task
        OPEN c_job(c_task_rec.visit_task_id);
        FETCH c_job INTO l_workorder_id, l_workorder_ovn, l_workorder_status;
        CLOSE c_job;

        -- if workorder exists for the task
        IF l_workorder_id IS NOT NULL THEN
           IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                             'Workorder Id for Task = ' || l_workorder_id);
              END IF;
               -- If p_module_type is 'CST' then workorder status should stay as DRAFT
               -- Update only workorder time

              IF p_module_type = 'CST' THEN
                   idx := idx+1;
                   l_prd_workorder_tbl(idx).DML_OPERATION := 'U';
                   l_prd_workorder_tbl(idx).WORKORDER_ID := l_workorder_id;
                   l_prd_workorder_tbl(idx).OBJECT_VERSION_NUMBER := l_workorder_ovn;

              --POST11510 cxcheng. If summary task, use the min,max for sub tasks
              IF (c_task_rec.task_type_code = 'SUMMARY') THEN
                 OPEN get_summary_task_times_csr(c_task_rec.visit_task_id);
                 FETCH get_summary_task_times_csr INTO l_prd_workorder_tbl(idx).SCHEDULED_START_DATE,
                                                    l_prd_workorder_tbl(idx).SCHEDULED_END_DATE;
                 CLOSE get_summary_task_times_csr;
              ELSE
                 l_prd_workorder_tbl(idx).SCHEDULED_START_DATE := c_task_rec.START_DATE_TIME;
                 l_prd_workorder_tbl(idx).SCHEDULED_END_DATE   := c_task_rec.END_DATE_TIME;
              END IF;

                  l_prd_workorder_tbl(idx).ITEM_INSTANCE_ID  := c_task_rec.instance_id ;                    l_prd_workorder_tbl(idx).BATCH_ID := c_visit_rec.visit_number;
            l_prd_workorder_tbl(idx).HEADER_ID := c_task_rec.visit_task_number;

              END IF;
              -- Only update task if previous status is DRAFT
              IF ( p_module_type <> 'CST' AND l_workorder_status = '17' ) THEN
                   idx := idx+1;
                   --TCHIMIRA::P2P CP ER 9151144::02-DEC-2009::Modified if condition
                   IF (p_release_flag = 'Y' OR p_release_flag = 'R') THEN
                      l_prd_workorder_tbl(idx).STATUS_CODE := '3';  -- Released
                   ELSE
                      l_prd_workorder_tbl(idx).STATUS_CODE := '1';  -- Unreleased
                   END IF;
                   l_prd_workorder_tbl(idx).DML_OPERATION := 'U';
		   l_prd_workorder_tbl(idx).WORKORDER_ID := l_workorder_id;
		   l_prd_workorder_tbl(idx).OBJECT_VERSION_NUMBER := l_workorder_ovn;
		   IF (	l_firm_planned_flag IS NOT NULL	AND
                        -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010
                        -- For task with past task dates, WOs are always firm irrespective of the profile value
                        c_task_rec.past_task_start_date IS NULL AND
			l_firm_planned_flag = '2' ) THEN
			l_prd_workorder_tbl(idx).FIRM_PLANNED_FLAG := 2; -- Planned
		   ELSE
			l_prd_workorder_tbl(idx).FIRM_PLANNED_FLAG := 1; -- Firm
		   END IF;
		  --POST11510 cxcheng. If summary task,	use the	min,max	for sub	tasks
		  IF (c_task_rec.task_type_code	= 'SUMMARY') THEN
		  OPEN get_summary_task_times_csr(c_task_rec.visit_task_id);
		  FETCH	get_summary_task_times_csr INTO	l_prd_workorder_tbl(idx).SCHEDULED_START_DATE,
                                                  l_prd_workorder_tbl(idx).SCHEDULED_END_DATE  ;
                  CLOSE get_summary_task_times_csr;
                  ELSE
                       l_prd_workorder_tbl(idx).SCHEDULED_START_DATE := c_task_rec.START_DATE_TIME;
                       l_prd_workorder_tbl(idx).SCHEDULED_END_DATE := c_task_rec.END_DATE_TIME;
                  END IF;

              /* Begin changes by rnahata for Bug 5758813 - For summary tasks (both manual and MR summary tasks)
              and unassociated tasks the task name is passed as the workorder description.
              And for the Route tasks, the route number concatenated with the route title is
              passed as workorder description.*/

              IF (c_task_rec.task_type_code IN ('SUMMARY','UNASSOCIATED')) THEN
                 l_prd_workorder_tbl(idx).JOB_DESCRIPTION   :=  c_task_rec.visit_task_name;
              ELSE
                 OPEN get_wo_dtls_for_mrtasks_cur(c_task_rec.visit_task_id);
                 FETCH get_wo_dtls_for_mrtasks_cur INTO get_wo_dtls_for_mrtasks_rec;
                 CLOSE get_wo_dtls_for_mrtasks_cur;
                 l_prd_workorder_tbl(idx).JOB_DESCRIPTION := get_wo_dtls_for_mrtasks_rec.workorder_description;
              END IF;
              l_prd_workorder_tbl(idx).ITEM_INSTANCE_ID := c_task_rec.instance_id ;                     l_prd_workorder_tbl(idx).BATCH_ID := c_visit_rec.visit_number;
              l_prd_workorder_tbl(idx).BATCH_ID := c_visit_rec.visit_number;
              l_prd_workorder_tbl(idx).HEADER_ID := c_task_rec.visit_task_number;
           END IF;
           /* End Changes by Shkalyan */

           --l_prd_workorder_tbl(idx).VISIT_ID          := p_visit_id;
           --l_prd_workorder_tbl(idx).ORGANIZATION_ID   := c_visit_rec.organization_id;
           --l_prd_workorder_tbl(idx).PROJECT_ID        := c_visit_rec.project_id;
           --l_prd_workorder_tbl(idx).INVENTORY_ITEM_ID := c_task_rec.inventory_item_id ;
           --l_prd_workorder_tbl(idx).ITEM_INSTANCE_ID  := c_task_rec.instance_id ;
           --l_prd_workorder_tbl(idx).VISIT_TASK_ID     := c_task_rec.visit_task_id ;
           --l_prd_workorder_tbl(idx).VISIT_TASK_NUMBER := c_task_rec.visit_task_number ;
           --l_prd_workorder_tbl(idx).PROJECT_TASK_ID   := c_task_rec.project_task_id ;
           --l_prd_workorder_tbl(idx).JOB_DESCRIPTION   := c_task_rec.visit_task_name ;

           ELSE  -- workorder doesn't exist
              idx := idx+1;
              l_prd_workorder_tbl(idx).DML_OPERATION     := 'C';
              IF (p_module_type = 'CST') THEN
                 l_prd_workorder_tbl(idx).STATUS_CODE           := '17';  -- Draft
                 -- sracha 27Jul05. Create Draft WO as firm to avoid scheduling by EAM.
                 --l_prd_workorder_tbl(idx).FIRM_PLANNED_FLAG     := 2; -- Planned
                 l_prd_workorder_tbl(idx).FIRM_PLANNED_FLAG     := 1; -- Firm

               ELSE
                  IF p_orig_visit_id IS NOT NULL THEN
                     -- Create master workorder in same status as that of the originating visit
                     l_prd_workorder_tbl(idx).STATUS_CODE     := l_orig_task_status;
                  ELSE
                     IF (p_release_flag = 'Y' OR p_release_flag = 'R') THEN
                        l_prd_workorder_tbl(idx).STATUS_CODE  := '3';  -- Released
                                                                                    ELSE
                        l_prd_workorder_tbl(idx).STATUS_CODE  := '1';  -- Unreleased
                     END IF;
                  END IF;

                  IF ( l_firm_planned_flag IS NOT NULL AND
                       -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010
                       -- For task with past task dates, WOs are always firm irrespective of the profile value
                       c_task_rec.past_task_start_date IS NULL AND
                       l_firm_planned_flag = '2' ) THEN
                      l_prd_workorder_tbl(idx).FIRM_PLANNED_FLAG     := 2; -- Planned
                  ELSE
                      l_prd_workorder_tbl(idx).FIRM_PLANNED_FLAG     := 1; -- Firm
                  END IF;

               /*
               Get_Task_Dependencies
               (
                 p_visit_number       => c_visit_rec.visit_number,
                 p_visit_task_id      => c_task_rec.visit_task_id,
                 p_visit_task_number  => c_task_rec.visit_task_number,
                 p_x_relationship_tbl => l_prd_workorder_rel_tbl
               );
               */
              END IF; -- 'CST'
              IF (c_task_rec.task_type_code = 'SUMMARY') THEN
                 l_prd_workorder_tbl(idx).MASTER_WORKORDER_FLAG := 'Y';
              ELSE
                 l_prd_workorder_tbl(idx).MASTER_WORKORDER_FLAG := 'N';
              END IF;

              l_prd_workorder_tbl(idx).BATCH_ID := c_visit_rec.visit_number;
              l_prd_workorder_tbl(idx).HEADER_ID := c_task_rec.visit_task_number;
              /* End Changes by Shkalyan */
              l_prd_workorder_tbl(idx).VISIT_ID          := p_visit_id;
              l_prd_workorder_tbl(idx).ORGANIZATION_ID   := c_visit_rec.organization_id;
              l_prd_workorder_tbl(idx).PROJECT_ID        := c_visit_rec.project_id;
              l_prd_workorder_tbl(idx).INVENTORY_ITEM_ID := c_task_rec.inventory_item_id ;
              l_prd_workorder_tbl(idx).ITEM_INSTANCE_ID  := c_task_rec.instance_id ;
              l_prd_workorder_tbl(idx).VISIT_TASK_ID     := c_task_rec.visit_task_id ;
              l_prd_workorder_tbl(idx).VISIT_TASK_NUMBER := c_task_rec.visit_task_number ;
              l_prd_workorder_tbl(idx).PROJECT_TASK_ID   := c_task_rec.project_task_id ;

              /*B5758813 - rnahata - For summary tasks (both manual and MR summary tasks)
              and unassociated tasks the task name is passed as the workorder description.
              And for the MR tasks, the route number concatenated with the route title is
              passed as workorder description.*/
              IF (c_task_rec.task_type_code IN ('SUMMARY','UNASSOCIATED')) THEN
                 l_prd_workorder_tbl(idx).JOB_DESCRIPTION   :=  c_task_rec.visit_task_name;
              ELSE
                 OPEN get_wo_dtls_for_mrtasks_cur(c_task_rec.visit_task_id);
                 FETCH get_wo_dtls_for_mrtasks_cur INTO get_wo_dtls_for_mrtasks_rec;
                 CLOSE get_wo_dtls_for_mrtasks_cur;
                 l_prd_workorder_tbl(idx).JOB_DESCRIPTION := get_wo_dtls_for_mrtasks_rec.workorder_description;
              END IF;

              IF c_task_rec.mr_route_id IS NOT NULL AND c_task_rec.mr_route_id <> FND_API.g_miss_num THEN
                 OPEN c_route (c_task_rec.mr_route_id);
                 FETCH c_route INTO l_route_id;
                 CLOSE c_route;
                 l_prd_workorder_tbl(idx).ROUTE_ID := l_route_id ;
              ELSE
                 l_prd_workorder_tbl(idx).ROUTE_ID := Null;
              END IF;

              IF c_task_rec.department_id IS NOT NULL
                 AND c_task_rec.department_id <> FND_API.g_miss_num THEN
                 l_prd_workorder_tbl(idx).DEPARTMENT_ID   := c_task_rec.department_id ;
              ELSE
                 l_prd_workorder_tbl(idx).DEPARTMENT_ID   := c_visit_rec.department_id ;
              END IF;

              --POST11510 cxcheng. If summary task, use the min,max for sub tasks
              IF (c_task_rec.task_type_code = 'SUMMARY') THEN
                 OPEN get_summary_task_times_csr(c_task_rec.visit_task_id);
                 FETCH get_summary_task_times_csr INTO l_prd_workorder_tbl(idx).SCHEDULED_START_DATE,
                                                       l_prd_workorder_tbl(idx).SCHEDULED_END_DATE  ;
                 CLOSE get_summary_task_times_csr;
              ELSE
                 l_prd_workorder_tbl(idx).SCHEDULED_START_DATE  := c_task_rec.START_DATE_TIME;
                 l_prd_workorder_tbl(idx).SCHEDULED_END_DATE    := c_task_rec.END_DATE_TIME;
              END IF;

           END IF;  -- workorder exist

        END IF;  -- p_orig_visit null or orig_task_status null

        FETCH c_task INTO c_task_rec;
        END LOOP;

        CLOSE c_task;

     END IF; -- l_count
     -- yazhou end

   IF l_prd_workorder_tbl.COUNT > 0  THEN

      /* Begin Changes by Shkalyan */
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Before calling GET_VISIT_RELATIONSHIPS.');
      END IF;
      -- yazhou starts
      -- IF l_visit_wo_id IS NULL THEN
      Get_Visit_Relationships
      (
        p_visit_id           => p_visit_id,
        p_visit_number       => c_visit_rec.visit_number,
        p_x_relationship_tbl => l_prd_workorder_rel_tbl
      );

      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'After calling GET_VISIT_RELATIONSHIPS.');
      END IF;
      --     END IF;
      -- yazhou ends

      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Before calling GET_VISIT_DEPENDENCIES.');
      END IF;

      IF (p_module_type <> 'CST') THEN
        Get_Visit_Dependencies
        (
          p_visit_id           => p_visit_id,
          p_visit_number       => c_visit_rec.visit_number,
          p_x_relationship_tbl => l_prd_workorder_rel_tbl
       );
      END IF;

      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'After calling GET_VISIT_DEPENDENCIES.');
      END IF;

      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Before calling AHL_PRD_WORKORDER_PVT.Process_Jobs. l_prd_workorder_tbl.COUNT = ' || l_prd_workorder_tbl.COUNT);
      END IF;

      AHL_PRD_WORKORDER_PVT.Process_Jobs
      (    p_api_version           => p_api_version,
           p_init_msg_list         => p_init_msg_list,
           p_commit                => FND_API.G_FALSE,
           p_validation_level      => p_validation_level,
           p_default               => FND_API.G_TRUE,
           p_module_type           => p_module_type,
           x_return_status         => l_return_status,
           x_msg_count             => x_msg_count,
           x_msg_data              => x_msg_data,
           p_x_prd_workorder_tbl   => l_prd_workorder_tbl,
           p_prd_workorder_rel_tbl => l_prd_workorder_rel_tbl
      );
      /* End Changes by Shkalyan */

      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'After calling AHL_PRD_WORKORDER_PVT.Process_Jobs. Return Status = ' || l_return_status);
      END IF;

      IF (l_return_status <> Fnd_Api.G_RET_STS_SUCCESS) THEN
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Errors from AHL_PRD_WORKORDER_PVT.Process_Jobs. Message count: ' ||
                           l_msg_count || ', message data: ' || l_msg_data);
         END IF;
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSE
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      -- Begin changes by rnahata for Bug 5758813
      /*The project start/end dates have to be updated with the workorder scheduled
      start/end dates.*/

      IF (l_log_statement >= l_log_current_level) THEN
         For i IN l_prd_workorder_tbl.FIRST..l_prd_workorder_tbl.LAST
         LOOP
           fnd_log.string(l_log_statement,
           L_DEBUG_KEY,
           'WorkOrder Id ('||i||'): '||l_prd_workorder_tbl(i).workorder_id);
         END LOOP;
      END IF;

      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Before calling Update_Project_Task_Times.');
      END IF;

      Update_Project_Task_Times(p_prd_workorder_tbl => l_prd_workorder_tbl,
                                 p_commit            =>'F',
                                 x_return_status     => l_return_status,
                                 x_msg_count         => l_msg_count,
                                 x_msg_data          => l_msg_data);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_msg_count := FND_MSG_PUB.count_msg;
         IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Errors from Update_Project_Task_Times. Message count: ' || x_msg_count);
         END IF;
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      ELSE
         IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Returned Success from Update_Project_Task_Times');
         END IF;
      END IF;
      -- End changes by rnahata for Bug 5758813
   END IF; -- To find if the visit has any tasks

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Update Visit -- Released');
   END IF;
--transit check visit change
-- yazhou start
   IF (p_module_type <> 'CST') THEN
      IF p_orig_visit_id is null THEN
        --------------------------------- R12 changes For Serial Number Reservations Start----------------------------------
        ----------------------------------AnRaj added on 15th June 2005-----------------------------------------------------
        -- When a visit is pushed to production, all the material reservations that were
        -- created will have to be transferred with the WIP details

        IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,L_DEBUG_KEY,'Before calling AHL_RSV_RESERVATIONS_PVT.TRANSFER_RESERVATION');
        END IF;

        AHL_RSV_RESERVATIONS_PVT.TRANSFER_RESERVATION
        (
            p_api_version   => l_api_version,
            p_init_msg_list => l_init_msg_list,
            x_return_status => l_return_status,
            p_module_type   => p_module_type,
            x_msg_count     => l_msg_count,
            x_msg_data      => l_msg_data,
            p_visit_id      => p_visit_id
        );

        IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,L_DEBUG_KEY,'After calling AHL_RSV_RESERVATIONS_PVT.TRANSFER_RESERVATION - l_return_status : '||l_return_status);
        END IF;

        -- handle the exceptions, if any
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                             ':Errors from AHL_RSV_RESERVATIONS_PVT.TRANSFER_RESERVATION API : ' || x_msg_count );
            END IF;
            RAISE Fnd_Api.g_exc_error;
        END IF;
        --------------------------------- R12 changes For Serial Number Reservations End----------------------------------

         UPDATE AHL_VISITS_B
         SET    STATUS_CODE = 'RELEASED',
                OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
                --TCHIMIRA::BUG 9222622 ::15-DEC-2009::UPDATE WHO COLUMNS
                LAST_UPDATE_DATE      = SYSDATE,
                LAST_UPDATED_BY       = Fnd_Global.USER_ID,
                LAST_UPDATE_LOGIN     = Fnd_Global.LOGIN_ID
         WHERE  VISIT_ID = p_visit_id;

      ELSE
         UPDATE AHL_VISITS_B
         SET    STATUS_CODE = c_orig_visit_rec.STATUS_CODE,
                OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
                --TCHIMIRA::BUG 9222622 ::15-DEC-2009::UPDATE WHO COLUMNS
                LAST_UPDATE_DATE      = SYSDATE,
                LAST_UPDATED_BY       = Fnd_Global.USER_ID,
                LAST_UPDATE_LOGIN     = Fnd_Global.LOGIN_ID
         WHERE  VISIT_ID = p_visit_id;
    END IF;

   END IF;

   IF ( p_module_type <> 'CST' ) THEN
     IF p_orig_visit_id is null THEN

         UPDATE AHL_VISIT_TASKS_B
         SET STATUS_CODE = 'RELEASED',
             OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
             --TCHIMIRA::BUG 9222622 ::15-DEC-2009::UPDATE WHO COLUMNS
             LAST_UPDATE_DATE      = SYSDATE,
             LAST_UPDATED_BY       = Fnd_Global.USER_ID,
             LAST_UPDATE_LOGIN     = Fnd_Global.LOGIN_ID
         WHERE VISIT_ID = p_visit_id
        AND STATUS_CODE = 'PLANNING';

    ELSE
       UPDATE AHL_VISIT_TASKS_B
       SET STATUS_CODE = 'RELEASED',
           OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
           --TCHIMIRA::BUG 9222622 ::15-DEC-2009::UPDATE WHO COLUMNS
           LAST_UPDATE_DATE      = SYSDATE,
           LAST_UPDATED_BY       = Fnd_Global.USER_ID,
           LAST_UPDATE_LOGIN     = Fnd_Global.LOGIN_ID
       WHERE VISIT_ID = p_visit_id
         AND STATUS_CODE = 'PLANNING'
         AND VISIT_TASK_NUMBER in (Select VISIT_TASK_NUMBER
                                   FROM ahl_visit_tasks_b
                                   where visit_id = p_orig_visit_id
                                   AND STATUS_CODE = 'RELEASED');
      END IF;
   END IF;
   -- yazhou end

   -- Start By Shbhanda 16th Feb 2004 --
   -- Earlier this code was in Release_Visit procedure
   -- was moved here as whenever the visit is pushed to production
   -- 'any_task_chg_flag' in Visit should always be 'N'
   -----------------------------------------------
   -- To call AHL_VWP_RULES_PVT.Update_Visit_Task_Flag to update any_task_chg_flag as 'N'
   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Before calling AHL_VWP_RULES_PVT.Update_Visit_Task_Flag.');
   END IF;

   IF c_visit_rec.any_task_chg_flag = 'Y' THEN
      AHL_VWP_RULES_PVT.Update_Visit_Task_Flag
          (p_visit_id      => p_visit_id,
           p_flag          => 'N',
           x_return_status => x_return_status);
   END IF;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'After calling AHL_VWP_RULES_PVT.Update_Visit_Task_Flag');
   END IF;
   -- End By Shbhanda 16th Feb 2004 -------------

  ---------------------------End of Body-------------------------------------
  -- END of API body.
  -- Standard check of p_commit.

   IF Fnd_Api.To_Boolean (p_commit) THEN
      COMMIT WORK;
   END IF;

   Fnd_Msg_Pub.count_and_get(
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
  );

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;

EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Push_to_Production;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Push_to_Production;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN OTHERS THEN
      ROLLBACK TO Push_to_Production;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
      THEN
         Fnd_Msg_Pub.add_exc_msg (G_PKG_NAME, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
END Push_to_Production;

-------------------------------------------------------------------
--  Procedure name    : Release_Visit
--  Type              : Private
--
--
--  Function          :To Validate before pushing visit and its tasks to production
--
--
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version      IN  NUMBER   Required
--      p_init_msg_list    IN  VARCHAR2 Default  FND_API.G_FALSE
--      p_commit           IN  VARCHAR2 Default  FND_API.G_FALSE
--      p_validation_level IN  NUMBER   Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status    OUT VARCHAR2 Required
--      x_msg_count        OUT NUMBER   Required
--      x_msg_data         OUT VARCHAR2 Required
--
--  Release visit Parameters:
--       p_visit_id             IN   NUMBER  Required
--
--  Version :
--    09/09/2003     SSURAPAN   Initial  Creation
-------------------------------------------------------------------
PROCEDURE Release_Visit (
    p_api_version      IN         NUMBER,
    p_init_msg_list    IN         VARCHAR2 := Fnd_Api.G_FALSE,
    p_commit           IN         VARCHAR2 := Fnd_Api.G_FALSE,
    p_validation_level IN         NUMBER   := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type      IN         VARCHAR2 := NULL,
    p_visit_id         IN         NUMBER,
    p_release_flag     IN         VARCHAR2 := 'N', -- By shbhanda 05/21/04 fro TC changes
    p_orig_visit_id    IN         NUMBER   := NULL, -- By yazhou   08/06/04 for TC changes
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2)
 IS
    --Standard local variables
    L_API_NAME         CONSTANT VARCHAR2(30)  := 'Release_Visit';
    L_API_VERSION      CONSTANT NUMBER        := 1.0;
    L_DEBUG_KEY        CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
    l_msg_data                  VARCHAR2(2000);
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_Error_Tbl_Type            Error_Tbl_Type;
    l_error_msg                 VARCHAR2(5000);
    l_error_count               NUMBER;
    l_commit                    VARCHAR2(1) := 'F';
    --Post 11.5.10
    -- RROY
    l_validate_error   CONSTANT VARCHAR2(1) := 'V';
    --l_projects_error CONSTANT VARCHAR2(1) := 'R';
    l_push_error       CONSTANT VARCHAR2(1) := 'P';
    -- RROY
    --TCHIMIRA::P2P CP ER 9151144::02-DEC-2009
    l_err_msg                   VARCHAR2(2000);
    l_msg_index_out             NUMBER;
    l_phase_code                VARCHAR2(1);

   --TCHIMIRA::P2P CP ER 9151144::09-DEC-2009
   --cursor to fetch phase code
   CURSOR c_conc_req_phase(x_id IN NUMBER) IS
    SELECT FCR.PHASE_CODE
    FROM FND_CONCURRENT_REQUESTS FCR, AHL_VISITS_B AVB
    WHERE FCR.REQUEST_ID = AVB.REQUEST_ID
    AND AVB.VISIT_ID = x_id;

   -- To find visit related information
   CURSOR c_visit (x_id IN NUMBER) IS
    SELECT * FROM AHL_VISITS_VL
    WHERE VISIT_ID = x_id
    -- TCHIMIRA :: Bug 8594339 :: 19-NOV-2009
    -- Lock the visit record
    FOR UPDATE OF OBJECT_VERSION_NUMBER;
   c_visit_rec c_visit%ROWTYPE;
  BEGIN

    IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,L_DEBUG_KEY||'.begin','At the start of the PLSQL procedure');
    END IF;

    -- Standard start of API savepoint
    SAVEPOINT Release_Visit_Pvt;



         -- Initialize message list if p_init_msg_list is set to TRUE
         IF FND_API.To_Boolean(p_init_msg_list) THEN
         FND_MSG_PUB.Initialize;
         END IF;

	 -- Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;

         -- Standard call to check for call compatibility.
         IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,G_PKG_NAME) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

    --

    IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,L_DEBUG_KEY,'Visit ID : '||p_visit_id);
    END IF;

    -- Check for Required Parameters
    IF(p_visit_id IS NULL OR p_visit_id = FND_API.G_MISS_NUM) THEN
        FND_MESSAGE.Set_Name(G_PM_PRODUCT_CODE,'AHL_VWP_CST_INPUT_MISS');
        FND_MSG_PUB.ADD;
        IF (l_log_unexpected >= l_log_current_level)THEN
            fnd_log.string
            (
                l_log_unexpected,
                'ahl.plsql.AHL_VWP_CST_WO_PVT.Release_Visit',
                'Visit id is mandatory but found null in input '
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    --TCHIMIRA::P2P CP ER 9151144::09-DEC-2009::BEGIN
    --Throws an error if the phase code is either pending or running
    IF(p_release_flag = 'Y' OR p_release_flag = 'N')THEN
            OPEN c_conc_req_phase(p_visit_id);
            FETCH c_conc_req_phase INTO l_phase_code;
            CLOSE c_conc_req_phase;

            IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,L_DEBUG_KEY,'l_phase_code : '||l_phase_code);
            END IF;

            IF(l_phase_code IN('R' , 'P')) THEN
              FND_MESSAGE.Set_Name(G_PM_PRODUCT_CODE,'AHL_VWP_CP_P2P_IN_PROGS');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
    END IF;
    --TCHIMIRA::P2P CP ER 9151144::09-DEC-2009::END

    -- TCHIMIRA :: Bug 8594339 :: 19-NOV-2009
    -- Lock the visit record
    OPEN c_visit(p_visit_id);
    FETCH c_visit INTO c_visit_rec;

    --TCHIMIRA::P2P CP ER 9151144::02-DEC-2009::Modified the if condition to check if the P2P is normal or background
     IF(p_release_flag = 'Y' OR p_release_flag = 'N')THEN
          IF (l_log_statement >= l_log_current_level)THEN
            fnd_log.string (l_log_statement,L_DEBUG_KEY, 'Before Calling Validate Before Production');
          END IF;

       --Valdate before push to production happens
       AHL_VWP_PROJ_PROD_PVT.Validate_Before_Production
              (p_api_version      => l_api_version,
               p_init_msg_list    => p_init_msg_list,
               p_commit           => l_commit,
               p_validation_level => p_validation_level,
               p_module_type      => p_module_type,
               p_visit_id         => p_visit_id,
               x_error_tbl        => l_error_tbl_type,
               x_return_status    => l_return_status,
               x_msg_count        => l_msg_count,
               x_msg_data         => l_msg_data);

       IF (l_log_statement >= l_log_current_level)THEN
          fnd_log.string (l_log_statement, L_DEBUG_KEY, 'After Calling Validate Before Production - l_return_status = '||l_return_status);
       END IF;
    END IF;
     -- Post 11.5.10
     -- RROY
     IF l_error_tbl_type.COUNT > 0 THEN
       l_return_status := l_validate_error;
       x_return_status := l_validate_error;
     ELSIF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      -- Check Error Message stack.
       x_msg_count := FND_MSG_PUB.count_msg;

       IF (l_log_statement >= l_log_current_level)THEN
          fnd_log.string ( l_log_statement, L_DEBUG_KEY,'Errors from Validate Before Production - '||x_msg_count);
       END IF;
       -- TCHIMIRA :: Bug 8594339 :: 19-NOV-2009
       CLOSE c_visit;
       RAISE Fnd_Api.g_exc_error;
     ELSE
          IF (l_log_statement >= l_log_current_level)THEN
          fnd_log.string(l_log_statement,L_DEBUG_KEY, 'Before Calling aggregate_material_requirements');
          END IF;

       -- AnRaj: Added as part of Material Requirement Aggrgation Enhancement, Bug#5303378
       -- Call aggregate_material_requirements for a visit
       -- If a visit task has more than one requirement for the same item, then this method will aggregate
       -- all those requirements into a single requirement
       Aggregate_Material_Reqrs
            (  p_api_version      => l_api_version,
               p_init_msg_list    => p_init_msg_list,
               p_commit           => l_commit,
               p_validation_level => p_validation_level,
               p_module_type      => p_module_type,
               p_visit_id         => p_visit_id,
               x_return_status    => l_return_status,
               x_msg_count        => l_msg_count,
               x_msg_data         => l_msg_data
            );
       IF (l_log_statement >= l_log_current_level)THEN
          fnd_log.string(l_log_statement,L_DEBUG_KEY, 'After Calling aggregate_material_requirements - l_return_status = '||l_return_status);
       END IF;

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_msg_count := FND_MSG_PUB.count_msg;
          IF (l_log_statement >= l_log_current_level)THEN
              fnd_log.string(   l_log_statement,L_DEBUG_KEY,'Errors from aggregate_material_requirements: ' || x_msg_count);
          END IF;
	  -- TCHIMIRA :: Bug 8594339 :: 19-NOV-2009
          CLOSE c_visit;
          RAISE Fnd_Api.g_exc_error;
       END IF;

       IF (l_log_statement >= l_log_current_level)THEN
         fnd_log.string(l_log_statement,L_DEBUG_KEY, 'Before calling Push_to_Production');
       END IF;

       --Call push to production with module type 'CST'
       AHL_VWP_PROJ_PROD_PVT.Push_to_Production
             (p_api_version      => l_api_version,
              p_init_msg_list    => p_init_msg_list,
              p_commit           => l_commit,
              p_validation_level => p_validation_level,
              p_module_type      => p_module_type, --'JSP', -- earlier 'CST'
              p_visit_id         => p_visit_id,
              p_release_flag     => p_release_flag,
              p_orig_visit_id    => p_orig_visit_id,
              x_return_status    => l_return_status,
              x_msg_count        => l_msg_count,
              x_msg_data         => l_msg_data);

       IF (l_log_statement >= l_log_current_level)THEN
         fnd_log.string(l_log_statement,L_DEBUG_KEY, 'After calling Push_to_Production - l_return_status = '||l_return_status);
       END IF;

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       -- Check Error Message stack.
         x_msg_count := FND_MSG_PUB.count_msg;
         IF (l_log_statement >= l_log_current_level)THEN
          fnd_log.string( l_log_statement,L_DEBUG_KEY, 'Errors from Push to Production: ' || x_msg_count );
         END IF;
	 -- TCHIMIRA :: Bug 8594339 :: 19-NOV-2009
         CLOSE c_visit;
         RAISE Fnd_Api.g_exc_error;
       END IF;

       IF (l_log_statement >= l_log_current_level)THEN
         fnd_log.string(l_log_statement,L_DEBUG_KEY, 'Before calling AHL_LTP_SIMUL_PLAN_PVT.delete_simul_visits');
       END IF;

       -- Delete simulated visits associated to this visit
       AHL_LTP_SIMUL_PLAN_PVT.delete_simul_visits
             (p_api_version        => l_api_version,
              p_init_msg_list      => p_init_msg_list,
              p_commit             => l_commit,
              p_validation_level   => p_validation_level,
              p_visit_id           => p_visit_id,
              x_return_status      => l_return_status,
              x_msg_count          => l_msg_count,
              x_msg_data           => l_msg_data);

       IF (l_log_statement >= l_log_current_level)THEN
         fnd_log.string(l_log_statement,L_DEBUG_KEY, 'After calling AHL_LTP_SIMUL_PLAN_PVT.delete_simul_visits - l_return_status : '||l_return_status);
       END IF;

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       -- Check Error Message stack.
         x_msg_count := FND_MSG_PUB.count_msg;
         IF (l_log_statement >= l_log_current_level)THEN
          fnd_log.string( l_log_statement,L_DEBUG_KEY,'Errors from delete_simul_visits: '||x_msg_count);
         END IF;
	 -- TCHIMIRA :: Bug 8594339 :: 19-NOV-2009
         CLOSE c_visit;
         RAISE Fnd_Api.g_exc_error;
       END IF;
     END IF;
     -- Post 11.5.10
     -- RROY
     -- TCHIMIRA :: Bug 8594339 :: 19-NOV-2009
     CLOSE c_visit;

     -- Standard check of p_commit
     IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
     END IF;

     IF (l_log_procedure >= l_log_current_level)THEN
        fnd_log.string ( l_log_procedure,L_DEBUG_KEY ||'.end','At the end of PLSQL procedure');
     END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO Release_Visit_Pvt;
   FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO Release_Visit_Pvt;
   FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Release_Visit_Pvt;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Release_Visit',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

END Release_Visit;

-------------------------------------------------------------------
--  Procedure name    : Release_Tasks
--  Type              : Private
--  Function          : Validate the tasks and then push tasks to production
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version      IN  NUMBER        Required
--      p_init_msg_list    IN  VARCHAR2      Default  FND_API.G_FALSE
--      p_commit           IN  VARCHAR2      Default  FND_API.G_FALSE
--      p_validation_level IN  NUMBER        Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status    OUT VARCHAR2      Required
--      x_msg_count        OUT NUMBER        Required
--      x_msg_data         OUT VARCHAR2      Required
--
--  Parameters:
--      p_visit_id         IN  NUMBER        Required
--      p_release_flag     IN  VARCHAR2      Default  'N'
--      p_tasks_tbl        IN  Task_Tbl_Type Required
--
--  Version :
--      30 November, 2007  RNAHATA  Initial Version - 1.0
-------------------------------------------------------------------
PROCEDURE Release_Tasks(
    p_api_version      IN         NUMBER,
    p_init_msg_list    IN         VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit           IN         VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level IN         NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type      IN         VARCHAR2  := Null,
    p_visit_id         IN         NUMBER,
    p_tasks_tbl        IN         Task_Tbl_Type,
    p_release_flag     IN         VARCHAR2  := 'N',
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2)
IS
    L_API_NAME           CONSTANT VARCHAR2(30)  := 'Release_Tasks';
    L_API_VERSION        CONSTANT NUMBER        := 1.0;
    L_DEBUG_KEY          CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
    l_msg_data                    VARCHAR2(2000);
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_Error_Tbl_Type              Error_Tbl_Type;
    l_tasks_tbl                   Task_Tbl_Type;
    l_validate_visit              NUMBER:= 0;
    l_temp_msg_count              NUMBER:=0; --rnahata

    -- chk if the visit is valid
    CURSOR c_validate_visit (x_id IN NUMBER) IS
     SELECT 1 FROM AHL_VISITS_B
     WHERE VISIT_ID = x_id;

    -- chk if the visit is in partially released or planning status
    CURSOR c_visit_info (x_id IN NUMBER) IS
     SELECT start_date_time,status_code FROM AHL_VISITS_B
     WHERE VISIT_ID = x_id
     AND NVL(STATUS_CODE,'X') IN ('PARTIALLY RELEASED', 'PLANNING');

    c_visit_info_rec    c_visit_info%ROWTYPE;

  BEGIN

    IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Visit Id = ' || p_visit_id ||
                     'p_tasks_tbl.COUNT = ' || p_tasks_tbl.COUNT);
    END IF;

    -- Standard start of API savepoint
    SAVEPOINT Release_Tasks_Pvt;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Check for required parameters
    IF (p_visit_id IS NOT NULL) THEN

       OPEN c_validate_visit(p_visit_id);
       FETCH c_validate_visit INTO l_validate_visit;
       CLOSE c_validate_visit;

       --Validate visit
       IF (nvl(l_validate_visit,0) = 0) THEN
          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
             FND_MESSAGE.Set_Name(G_PM_PRODUCT_CODE,'AHL_VWP_INVALID_VST');
             FND_MESSAGE.SET_TOKEN('VISIT_ID', p_visit_id);
             FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       --Check if the visit is in planning or partially released status
       OPEN c_visit_info(p_visit_id);
       FETCH c_visit_info INTO c_visit_info_rec;
       IF c_visit_info%NOTFOUND THEN
          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
             FND_MESSAGE.Set_Name(G_PM_PRODUCT_CODE,'AHL_VWP_VST_STATUS_INVALID');
             FND_MSG_PUB.ADD;
          END IF;
          CLOSE c_visit_info;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE c_visit_info;
    --If visit_id is null
    ELSE
       IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
          FND_MESSAGE.Set_Name(G_PM_PRODUCT_CODE,'AHL_VWP_VISIT_NULL');
          FND_MSG_PUB.ADD;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    --No tasks selected
    IF (p_tasks_tbl.COUNT = 0) THEN
       IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
          FND_MESSAGE.Set_Name(G_PM_PRODUCT_CODE,'AHL_VWP_NO_TASK_SEL');
          FND_MSG_PUB.ADD;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'Before calling VALIDATE_BEFORE_PRODUCTION');
    END IF;

    --Validate visit before pushing the tasks to production
    AHL_VWP_PROJ_PROD_PVT.Validate_Before_Production
              (p_api_version      => l_api_version,
               p_init_msg_list    => p_init_msg_list,
               p_commit           => 'F',
               p_validation_level => p_validation_level,
               p_module_type      => p_module_type,
               p_visit_id         => p_visit_id,
               x_error_tbl        => l_error_tbl_type,
               x_return_status    => l_return_status,
               x_msg_count        => l_msg_count,
               x_msg_data         => l_msg_data);

    IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'After calling VALIDATE_BEFORE_PRODUCTION, Return Status = ' ||
                      l_return_status);
    END IF;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_error_tbl_type.COUNT > 0) THEN
       -- Check Error Message stack.
       x_msg_count := FND_MSG_PUB.count_msg;
       IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'Errors from VALIDATE_BEFORE_PRODUCTION. Message count: ' || x_msg_count);
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSE
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

    IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'Before calling VALIDATE_TASKS_BEF_PRODUCTION. p_module_type = ' || p_module_type);
    END IF;

    --Validate tasks before push to production happens
    AHL_VWP_PROJ_PROD_PVT.Validate_tasks_bef_production(
              p_visit_id        => p_visit_id,
              p_tasks_tbl       => p_tasks_tbl,
              x_tasks_tbl       => l_tasks_tbl,
              x_return_status   => l_return_status,
              x_msg_count       => l_msg_count,
              x_msg_data        => l_msg_data);

    IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'After calling VALIDATE_TASKS_BEF_PRODUCTION. Records in l_tasks_tbl: ' ||
                      l_tasks_tbl.COUNT|| ', Return Status = ' || l_return_status);
    END IF;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       -- Check Error Message stack.
       x_msg_count := FND_MSG_PUB.count_msg;

       IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'Errors from VALIDATE_TASKS_BEF_PRODUCTION. Message count: ' || x_msg_count);
       END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSE
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;  -- l_return_status <> FND_API.G_RET_STS_SUCCESS

    IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,
                       L_DEBUG_KEY,
                       'Before calling AGGREGATE_TASK_MATERIAL_REQRS ');
    END IF;

    --Total the material requirements for a specific item at task level
    FOR i IN l_tasks_tbl.FIRST..l_tasks_tbl.LAST
    LOOP
       AHL_VWP_PROJ_PROD_PVT.Aggregate_Task_Material_Reqrs
           (  p_api_version      => p_api_version,
              p_init_msg_list    => p_init_msg_list,
              p_commit           => p_commit,
              p_validation_level => p_validation_level,
              p_module_type      => p_module_type,
              p_task_id          => l_tasks_tbl(i).visit_task_id,
              p_rel_tsk_flag     => 'Y',
              x_return_status    => l_return_status,
              x_msg_count        => l_msg_count,
              x_msg_data         => l_msg_data
           );

       IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'After calling AGGREGATE_TASK_MATERIAL_REQRS for Task Id: ' ||
                         l_tasks_tbl(i).visit_task_id || '. Return Status = '|| l_return_status);
       END IF;

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          x_msg_count := FND_MSG_PUB.count_msg;
          IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'Errors from AGGREGATE_TASK_MATERIAL_REQRS. Message count: ' || x_msg_count);
          END IF;
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       END IF;
    END LOOP;

    --for paritally implemented visits adjust the task times
    IF (c_visit_info_rec.start_date_time < SYSDATE and c_visit_info_rec.status_code = 'PARTIALLY RELEASED') THEN

      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Before calling ADJUST_TASK_TIMES ');
      END IF;

      FOR i IN l_tasks_tbl.FIRST..l_tasks_tbl.LAST
      LOOP
        -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Call adjust_task_times only if past task dates are null
	SELECT past_task_start_date INTO l_tasks_tbl(i).past_task_start_date FROM ahl_visit_tasks_b WHERE visit_task_id = l_tasks_tbl(i).visit_task_id;
        IF l_tasks_tbl(i).past_task_start_date IS NULL THEN
          AHL_VWP_TIMES_PVT.adjust_task_times
             (p_api_version        => l_api_version,
              p_init_msg_list      => p_init_msg_list,
              p_commit             => 'F',
              p_validation_level   => p_validation_level,
              p_task_id            => l_tasks_tbl(i).visit_task_id,
              p_reset_sysdate_flag => FND_API.G_TRUE,
              x_return_status      => l_return_status,
              x_msg_count          => l_msg_count,
              x_msg_data           => l_msg_data
           );
         END IF;

          IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'After calling ADJUST_TASK_TIMES for task Id ' ||
                            l_tasks_tbl(i).visit_task_id ||'. Return Status = '|| l_return_status);
          END IF;

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             x_msg_count := FND_MSG_PUB.count_msg;
             IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'Errors from ADJUST_TASK_TIMES. Message count: ' || x_msg_count);
             END IF;
             IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
          END IF;
        END LOOP;
    END IF; --partially released

    l_temp_msg_count := Fnd_Msg_Pub.count_msg;

    --Validate the MR/Route dates for all the tasks
    FOR i IN l_tasks_tbl.FIRST..l_tasks_tbl.LAST
    LOOP
        IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Before calling VALIDATE_MR_ROUTE_DATE. l_msg_count = ' || l_msg_count);
        END IF;

        Validate_MR_Route_Date
        (
           p_mr_route_id       => l_tasks_tbl(i).MR_Route_Id,
           p_visit_task_number => l_tasks_tbl(i).VISIT_TASK_NUMBER,
           p_start_date_time   => l_tasks_tbl(i).TASK_START_DATE,
           p_end_date_time     => l_tasks_tbl(i).TASK_END_DATE
        );

        IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,L_DEBUG_KEY,
           'After calling VALIDATE_MR_ROUTE_DATE for task Id: ' ||l_tasks_tbl(i).visit_task_id || ' and l_msg_count - ' || l_msg_count);
        END IF;
    END LOOP;

    l_msg_count := Fnd_Msg_Pub.count_msg;
    IF (l_msg_count <> l_temp_msg_count) THEN
       IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,L_DEBUG_KEY,
                         'Errors from VALIDATE_MR_ROUTE_DATE. Message count: ' || l_msg_count);
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'Before calling PUSH_TASKS_TO_PRODUCTION for visit id: ' ||p_visit_id);
    END IF;

    --push the selected tasks to production
    AHL_VWP_PROJ_PROD_PVT.Push_tasks_to_production
    ( p_api_version      => l_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_validation_level => p_validation_level,
      p_module_type      => p_module_type,
      p_visit_id         => p_visit_id,
      p_tasks_tbl        => l_tasks_tbl,
      p_release_flag     => p_release_flag,
      x_return_status    => l_return_status,
      x_msg_count        => l_msg_count,
      x_msg_data         => l_msg_data
    );

    IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'After calling PUSH_TASKS_TO_PRODUCTION. Return Status = '|| l_return_status);
    END IF;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       x_msg_count := FND_MSG_PUB.count_msg;
       IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'Errors from PUSH_TASKS_TO_PRODUCTION. Message count: ' || x_msg_count);
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

    IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'Before calling DELETE_SIMUL_VISITS for visit id: ' ||p_visit_id);
    END IF;

    -- Delete the simulated visits
     AHL_LTP_SIMUL_PLAN_PVT.delete_simul_visits
           (p_api_version      => l_api_version,
            p_init_msg_list    => p_init_msg_list,
            p_commit           => 'F',
            p_validation_level => p_validation_level,
            p_visit_id         => p_visit_id,
            x_return_status    => l_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data);

    IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'After calling DELETE_SIMUL_VISITS for visit id ' ||p_visit_id||'. Return Status = '|| l_return_status);
    END IF;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       x_msg_count := FND_MSG_PUB.count_msg;
       IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Errors from DELETE_SIMUL_TASKS. Message count: ' || x_msg_count);
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

    -- Standard check of p_commit
    IF FND_API.TO_BOOLEAN(p_commit) THEN
       COMMIT WORK;
    END IF;

    Fnd_Msg_Pub.count_and_get(
          p_encoded => Fnd_Api.g_false,
          p_count   => x_msg_count,
          p_data    => x_msg_data
    );

    IF (l_log_procedure >= l_log_current_level) THEN
        fnd_log.string(l_log_procedure,
                       L_DEBUG_KEY||'.end',
                       'At the end of PLSQL procedure. Return Status = ' || x_return_status);
    END IF;

  EXCEPTION
    WHEN  FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       ROLLBACK TO Release_Tasks_Pvt;
       FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
       ROLLBACK TO Release_Tasks_Pvt;
       Fnd_Msg_Pub.count_and_get (
             p_encoded => Fnd_Api.g_false,
             p_count   => x_msg_count,
             p_data    => x_msg_data);

    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ROLLBACK TO Release_Tasks_Pvt;
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                  p_procedure_name => 'Release_Tasks',
                                  p_error_text     => SUBSTR(SQLERRM,1,500));
       END IF;
       FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => fnd_api.g_false);

END Release_Tasks;

------------------------------------------------------------------
--  Procedure name : Validate_tasks_bef_production
--  Type           : Private
--  Function       : Validate the tasks before pushing the tasks to prodn.
--  Parameters     :
--
--  Standard OUT Parameters :
--      x_return_status OUT  VARCHAR2      Required
--      x_msg_count     OUT  NUMBER        Required
--      x_msg_data      OUT  VARCHAR2      Required
--
--  Validate_tasks_bef_production Parameters:
--       p_visit_id     IN   NUMBER        Required
--       p_tasks_tbl    IN   Task_Tbl_Type Required
--       x_tasks_tbl    OUT  Task_Tbl_Type Required
--
--  Version :
--      30 November, 2007  RNAHATA  Initial Version - 1.0
-------------------------------------------------------------------

PROCEDURE Validate_tasks_bef_production(
    p_visit_id      IN         NUMBER,
    p_tasks_tbl     IN         Task_Tbl_Type,
    x_tasks_tbl     OUT NOCOPY Task_Tbl_Type,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
) IS

--cursor to fetch the details of the tasks that have been pushe to production
CURSOR c_task_dtls(x_vst_task_id IN NUMBER) IS
SELECT  mr_id,visit_id,visit_task_id,status_code,task_type_code,nvl(originating_task_id,0) as originating_task_id,
        summary_task_flag, inventory_item_id,item_organization_id,visit_task_number,end_date_time
FROM  ahl_visit_tasks_b
WHERE visit_task_id = x_vst_task_id
AND   NVL(status_code,'X') in ('PLANNING')
order by visit_task_id;

c_tsk_dtls_rec  c_task_dtls%ROWTYPE;

--cursor to fetch the summary task id of the planned/unplanned task
CURSOR c_summary_tsk_dtl (x_originating_tsk_id IN NUMBER) IS
 SELECT mr_id,visit_id,visit_task_id,status_code,task_type_code,nvl(originating_task_id,0) as originating_task_id,
         summary_task_flag, inventory_item_id,item_organization_id,visit_task_number,end_date_time
 FROM ahl_visit_tasks_b
WHERE visit_task_id = x_originating_tsk_id
  AND   NVL(status_code,'X') in ('PLANNING')
  AND   task_type_code = 'SUMMARY';

c_summary_tsk_rec c_summary_tsk_dtl%ROWTYPE;

--cursor to fetch master work order for the visit
CURSOR c_fet_master_wo  (x_visit_id IN NUMBER) IS
 SELECT wo.workorder_id, wo.status_code, wip.scheduled_start_date,wip.scheduled_completion_date
 FROM ahl_visits_b v, ahl_workorders wo, wip_discrete_jobs wip
WHERE v.visit_id = x_visit_id
  AND NVL(v.status_code,'X') = 'PARTIALLY RELEASED'
  AND v.visit_id = wo.visit_id
  AND wo.visit_task_id IS NULL
  AND wo.master_workorder_flag = 'Y'
  AND wip.wip_entity_id = wo.wip_entity_id
  AND wo.STATUS_CODE not in ('22','7');

c_mst_wo_visit_rec  c_fet_master_wo%ROWTYPE;

-- Get all the Parent Task Dependencies.
CURSOR get_parent_task_dependencies (x_vst_task_id IN NUMBER) IS
 SELECT P.visit_task_number , P.visit_task_id
 FROM   ahl_visit_tasks_b P,
        ahl_task_links L
 WHERE  P.visit_task_id = L.parent_task_id
AND    L.visit_task_id = x_vst_task_id;

-- Get all the Child Task Dependencies.
CURSOR get_child_task_dependencies (x_vst_task_id IN NUMBER) IS
 SELECT C.visit_task_number ,C.visit_task_id
 FROM   ahl_visit_tasks_b C,
        ahl_task_links L
 WHERE  C.visit_task_id = L.visit_task_id
AND    L.parent_task_id = x_vst_task_id;

c_par_tech_dep_rec  get_parent_task_dependencies%ROWTYPE;
c_ch_tech_dep_rec   get_child_task_dependencies%ROWTYPE;

/*cursor to fetch all the child MR's/tasks for the summary MR to ensure all the dtl tasks are pushed to production*/
CURSOR c_dtl_task_sum (x_vst_task_id IN NUMBER) IS
select mr_id,visit_id,visit_task_id,status_code,task_type_code,nvl(originating_task_id,0) as originating_task_id,
        summary_task_flag, inventory_item_id,item_organization_id,visit_task_number,end_date_time
FROM ahl_visit_tasks_b
WHERE NVL(status_code,'X') in ('PLANNING')
START WITH visit_task_id = x_vst_task_id
CONNECT BY originating_task_id = PRIOR visit_task_id
order by visit_id,visit_task_id,mr_id;

c_dtl_task_sum_rec    c_dtl_task_sum%ROWTYPE;

j                      NUMBER := 0;
K                      NUMBER := 0;
m                      NUMBER := 0;
L_API_NAME    CONSTANT VARCHAR2(30)  := 'Validate_tasks_bef_production';
L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
lp_originating_task_id ahl_visit_tasks_vl.originating_task_id%TYPE;
curr_task              BOOLEAN := FALSE;
parent_task            BOOLEAN := FALSE;
parent_task_found_flag BOOLEAN := FALSE;
child_task             BOOLEAN := FALSE;

BEGIN
   IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.begin',
                      'At the start of PL SQL procedure. Visit Id = ' ||
                      p_visit_id || ', p_tasks_tbl.COUNT = ' || p_tasks_tbl.COUNT);
    END IF;

    -- Standard start of API savepoint
    SAVEPOINT Validate_tasks_bef_prodn_pvt;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --chk if the visit is released/partially released.
    OPEN c_fet_master_wo (p_visit_id);
    FETCH c_fet_master_wo INTO c_mst_wo_visit_rec;
    IF c_fet_master_wo%NOTFOUND THEN
       x_msg_count := FND_MSG_PUB.count_msg;
       IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Visit not released: ' || c_tsk_dtls_rec.visit_task_number);
       END IF;
    END IF;
    CLOSE c_fet_master_wo;

    FOR i IN p_tasks_tbl.FIRST..p_tasks_tbl.LAST
    LOOP
        OPEN c_task_dtls(p_tasks_tbl(i).visit_task_id);
        FETCH c_task_dtls INTO c_tsk_dtls_rec;
        IF c_task_dtls%NOTFOUND THEN
           x_msg_count := FND_MSG_PUB.count_msg;
           IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                             'Task is either not in planning status or Invalid - ' ||
                             p_tasks_tbl(i).visit_task_id);
           END IF;
           CLOSE c_task_dtls;
           FND_MESSAGE.Set_Name(G_PM_PRODUCT_CODE,'AHL_VWP_INVALID_TSK_ID');
           Fnd_Message.SET_TOKEN('TASK_ID', p_tasks_tbl(i).visit_task_id);
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE c_task_dtls;

        /* if the visit is partially released, then the planned end time for the wo should not be
        exceed the scheduled end time */
        IF (c_mst_wo_visit_rec.scheduled_completion_date IS NOT NULL) AND
            (c_tsk_dtls_rec.end_date_time > c_mst_wo_visit_rec.scheduled_completion_date) THEN
            x_msg_count := FND_MSG_PUB.count_msg;
            IF (l_log_statement >= l_log_current_level) THEN
                fnd_log.string(l_log_statement,
                               L_DEBUG_KEY,
                               'Planned end time of the task is exceeding the scheduled completion time of the master WO: ' ||
                               c_tsk_dtls_rec.visit_task_number);
            END IF;
            FND_MESSAGE.SET_NAME(G_PM_PRODUCT_CODE,'AHL_VWP_PET_EXCD_SCT');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

        parent_task_found_flag := FALSE;
        /*when the summary task is selected then all child tasks/child mr's for the summary tasks/MR will be pushed to prodn.
        Fetches only summary tasks of MR's and not the manually added summary tasks.*/

        IF (c_tsk_dtls_rec.task_type_code IN ('SUMMARY') AND c_tsk_dtls_rec.summary_task_flag = 'N') THEN

           IF (x_tasks_tbl.COUNT > 0) THEN
              FOR m IN x_tasks_tbl.FIRST..x_tasks_tbl.LAST
              LOOP
                IF x_tasks_tbl(m).visit_task_id = c_tsk_dtls_rec.visit_task_id THEN
                   parent_task_found_flag := TRUE;
                   EXIT;
                END IF;
              END LOOP;
           END IF;

           --inserts only if the summary task is not inserted already.
           IF NOT(parent_task_found_flag) THEN
              --this cursor fetches entire family tree of the selected MR with its children to be inserted.
              OPEN  c_dtl_task_sum(c_tsk_dtls_rec.visit_task_id);
              LOOP
                 FETCH c_dtl_task_sum INTO c_dtl_task_sum_rec;
                 EXIT WHEN c_dtl_task_sum%NOTFOUND;
                 --populating the output table with all the child parent MR's/tasks
                 j := j + 1;
                 x_tasks_tbl(j).visit_id             := c_dtl_task_sum_rec.visit_id;
                 x_tasks_tbl(j).visit_task_id        := c_dtl_task_sum_rec.visit_task_id;
                 x_tasks_tbl(j).inventory_item_id    := c_dtl_task_sum_rec.inventory_item_id;
                 x_tasks_tbl(j).item_organization_id := c_dtl_task_sum_rec.item_organization_id;
                 x_tasks_tbl(j).mr_id                := c_dtl_task_sum_rec.mr_id;
                 x_tasks_tbl(j).task_type_code       := c_dtl_task_sum_rec.task_type_code;
                 x_tasks_tbl(j).task_status_code     := c_dtl_task_sum_rec.status_code;
                 x_tasks_tbl(j).originating_task_id  := c_dtl_task_sum_rec.originating_task_id;
                 x_tasks_tbl(j).visit_task_number    := c_dtl_task_sum_rec.visit_task_number;
              END LOOP;
              CLOSE c_dtl_task_sum;
           END IF;
        END IF;

      /*for each planned/unplanned/summary task ensure that the parent MR/task is selected.If not then throw
      an error message to the user asking him to select the parent MR*/
      IF (c_tsk_dtls_rec.task_type_code IN ('PLANNED','UNPLANNED', 'SUMMARY')) AND (c_tsk_dtls_rec.originating_task_id <> 0) THEN

        --loop back to the parent MR to ensure that the child tasks/MR is also selected
        lp_originating_task_id := c_tsk_dtls_rec.originating_task_id;

        LOOP
          parent_task_found_flag := FALSE;

          --this cursor fetches the parent for each task
          OPEN c_summary_tsk_dtl(lp_originating_task_id);
          FETCH c_summary_tsk_dtl INTO c_summary_tsk_rec;
          CLOSE c_summary_tsk_dtl;

          --locate the summary task from the selected task list
          FOR k IN p_tasks_tbl.FIRST..p_tasks_tbl.LAST
          LOOP
            --chk if the summary task for the task is also selected
            IF p_tasks_tbl(k).visit_task_id = c_summary_tsk_rec.visit_task_id THEN
               parent_task_found_flag := TRUE;
               EXIT;
            END IF;
          END LOOP;

          IF NOT(parent_task_found_flag) THEN --if summary task is not selected then throw an error
                x_msg_count := FND_MSG_PUB.count_msg;
                IF (l_log_statement >= l_log_current_level) THEN
                   fnd_log.string(l_log_statement,
                                  L_DEBUG_KEY,
                                  'Select the summary task for the task: ' ||
                                  c_tsk_dtls_rec.visit_task_number);
                END IF;
                FND_MESSAGE.Set_Name(G_PM_PRODUCT_CODE,'AHL_VWP_SEL_SUM_TSK');
                Fnd_Message.SET_TOKEN('TASK_NUMBER', c_tsk_dtls_rec.visit_task_number);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
          END IF;

          lp_originating_task_id := c_summary_tsk_rec.originating_task_id;

          EXIT WHEN NVL(lp_originating_task_id,0) = 0;
        END LOOP;

      END IF; --planned/unplanned tasks

      IF ((c_tsk_dtls_rec.task_type_code = 'UNASSOCIATED') OR
          (c_tsk_dtls_rec.task_type_code = 'SUMMARY' AND c_tsk_dtls_rec.summary_task_flag = 'Y')) THEN
            j := j + 1;
            x_tasks_tbl(j).visit_id             := c_tsk_dtls_rec.visit_id;
            x_tasks_tbl(j).visit_task_id        := c_tsk_dtls_rec.visit_task_id;
            x_tasks_tbl(j).inventory_item_id    := c_tsk_dtls_rec.inventory_item_id;
            x_tasks_tbl(j).item_organization_id := c_tsk_dtls_rec.item_organization_id;
            x_tasks_tbl(j).mr_id                := c_tsk_dtls_rec.mr_id;
            x_tasks_tbl(j).task_type_code       := c_tsk_dtls_rec.task_type_code;
            x_tasks_tbl(j).task_status_code     := c_tsk_dtls_rec.status_code;
            x_tasks_tbl(j).originating_task_id  := c_tsk_dtls_rec.originating_task_id;
      END IF; --unassociated/summary

    END LOOP; --for all selected tasks

    -- chk for each task which has a technical dependency with other MR's or unassociated tasks
    FOR i IN x_tasks_tbl.FIRST..x_tasks_tbl.LAST
    LOOP
      parent_task := FALSE;
      child_task := FALSE;

      OPEN get_parent_task_dependencies (x_tasks_tbl(i).visit_task_id);
      LOOP
        FETCH get_parent_task_dependencies INTO c_par_tech_dep_rec;
        IF get_parent_task_dependencies%NOTFOUND THEN
          x_msg_count := FND_MSG_PUB.count_msg;
          IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'Parent Technical task dependency not found for the task - ' ||
                            x_tasks_tbl(i).visit_task_number);
          END IF;
          EXIT;
        ELSE --when parent dependency is found chk if the associated MR/unassociated tasks are also selected.
          FOR j IN x_tasks_tbl.FIRST..x_tasks_tbl.LAST
          LOOP
            IF (x_tasks_tbl(j).visit_task_id = c_par_tech_dep_rec.visit_task_id) THEN
               parent_task := TRUE;
               EXIT;
            END IF;
          END LOOP;

          IF NOT(parent_task) THEN --parent task not selected
            x_msg_count := FND_MSG_PUB.count_msg;
            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'Parent tasks on which the task ' ||
                              x_tasks_tbl(i).visit_task_number ||
                              ' is technically dependent has not been selected.'||
                              'Please select the technically dependent tasks too');
            END IF;
            CLOSE get_parent_task_dependencies;
            FND_MESSAGE.Set_Name(G_PM_PRODUCT_CODE,'AHL_VWP_SEL_TECH_DEP');
            Fnd_Message.SET_TOKEN('TASK_NUMBER', x_tasks_tbl(i).visit_task_number);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF; --parent task not selected
        END IF;
      END LOOP; --loop through the parent dependent records
      CLOSE get_parent_task_dependencies;

      OPEN get_child_task_dependencies (x_tasks_tbl(i).visit_task_id);
      LOOP --loop through the child dependent records
        FETCH get_child_task_dependencies INTO c_ch_tech_dep_rec;
        IF get_child_task_dependencies%NOTFOUND THEN
           x_msg_count := FND_MSG_PUB.count_msg;
           IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                             'Child Technical task dependency not found for the task - ' || x_tasks_tbl(i).visit_task_number);
           END IF;
           EXIT;
        ELSE --when child dependency is found chk if the associated MR/unassociated tasks are also selected.
           FOR j IN x_tasks_tbl.FIRST..x_tasks_tbl.LAST
           LOOP
             IF (x_tasks_tbl(j).visit_task_id = c_ch_tech_dep_rec.visit_task_id) THEN
                child_task := TRUE;
                EXIT;
             END IF;
           END LOOP;

           IF NOT(child_task) THEN
              x_msg_count := FND_MSG_PUB.count_msg;
              IF (l_log_statement >= l_log_current_level) THEN
                 fnd_log.string(l_log_statement,
                                L_DEBUG_KEY,
                                'Child tasks on which the task ' || x_tasks_tbl(i).visit_task_number || ' is technically dependent has not been selected.'||
                                'Please select the technically dependent tasks too');
              END IF;
              CLOSE get_child_task_dependencies;
              FND_MESSAGE.Set_Name(G_PM_PRODUCT_CODE,'AHL_VWP_SEL_TECH_DEP');
              Fnd_Message.SET_TOKEN('TASK_NUMBER', x_tasks_tbl(i).visit_task_number);
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
           END IF; --curr task not selected
        END IF;
      END LOOP; --loop through the child dependent records
      CLOSE get_child_task_dependencies;

    END LOOP;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. x_tasks_tbl.COUNT = ' || x_tasks_tbl.COUNT);
   END IF;

  EXCEPTION
  WHEN  FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    ROLLBACK TO Validate_tasks_bef_prodn_pvt;
    FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO Validate_tasks_bef_prodn_pvt;
    Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Validate_tasks_bef_prodn_pvt;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Validate_tasks_bef_production',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

END Validate_tasks_bef_production;

-------------------------------------------------------------------
--  Procedure name    : Push_tasks_to_production
--  Type              : Private
--  Function          : Push the selected tasks to production.
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version      IN  NUMBER        Required
--      p_init_msg_list    IN  VARCHAR2      Default  FND_API.G_FALSE
--      p_validation_level IN  NUMBER        Default  FND_API.G_VALID_LEVEL_FULL
--      p_module_type      IN  VARCHAR2      Default  Null
--
--  Standard OUT Parameters :
--      x_return_status    OUT VARCHAR2      Required
--      x_msg_count        OUT NUMBER        Required
--      x_msg_data         OUT VARCHAR2      Required
--
--  Push_tasks_to_production Parameters:
--       p_module_type     IN  VARCHAR2      Default = NULL
--       p_visit_id        IN  NUMBER        Required
--       p_tasks_tbl       IN  Task_Tbl_Type Required
--       p_release_flag    IN  VARCHAR2      Default = 'N'
--
--  Version :
--      30 November, 2007  RNAHATA  Initial Version - 1.0
-------------------------------------------------------------------

PROCEDURE Push_tasks_to_production(
    p_api_version      IN         NUMBER,
    p_init_msg_list    IN         VARCHAR2  := Fnd_Api.g_false,
    p_validation_level IN         NUMBER    := Fnd_Api.g_valid_level_full,
    p_module_type      IN         VARCHAR2  := Null,
    p_visit_id         IN         NUMBER,
    p_tasks_tbl        IN         Task_Tbl_Type,
    p_release_flag     IN         VARCHAR2  ,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2
) IS

--check if the visit master wo exists
CURSOR c_fet_master_wo  (x_visit_id IN NUMBER) IS
 SELECT 1 FROM ahl_workorders wo
 WHERE wo.visit_id = x_visit_id
  AND wo.visit_task_id IS NULL
  AND wo.master_workorder_flag = 'Y';

--fetch master work order for the visit
CURSOR c_visit_master_wo  (x_visit_id IN NUMBER) IS
 SELECT wo.workorder_id, wo.status_code, wip.scheduled_start_date,wip.scheduled_completion_date,wo.object_version_number
 FROM ahl_visits_b v, ahl_workorders wo, wip_discrete_jobs wip
 WHERE v.visit_id = x_visit_id
  AND v.visit_id = wo.visit_id
  AND wo.visit_task_id IS NULL
  AND wo.master_workorder_flag = 'Y'
  AND wip.wip_entity_id = wo.wip_entity_id
  AND wo.status_code not in ('22','7');

c_mst_wo_visit_rec  c_visit_master_wo%ROWTYPE;

--fetch visit details
CURSOR c_visit_dtl (x_visit_id IN NUMBER) IS
 SELECT * FROM ahl_visits_vl
 WHERE visit_id = x_visit_id;

c_visit_dtl_rec c_visit_dtl%ROWTYPE;

--fetch task details
CURSOR c_visit_task_dtl (x_visit_task_id IN NUMBER) IS
 SELECT * FROM ahl_visit_tasks_vl
 WHERE visit_task_id = x_visit_task_id;

c_visit_tsk_dtl_rec c_visit_task_dtl%ROWTYPE;

--check if the task wo exists
CURSOR c_fet_task_wo  (x_visit_id IN NUMBER, x_visit_task_id IN NUMBER) IS
SELECT 1 FROM ahl_workorders wo
WHERE wo.visit_id = x_visit_id
AND wo.visit_task_id = x_visit_task_id
AND wo.visit_task_id IS NOT NULL;

--fetch work order for the task
CURSOR c_task_wo  (x_visit_id IN NUMBER,x_visit_task_id IN NUMBER) IS
SELECT v.visit_task_id, wo.workorder_id, wo.status_code, wip.scheduled_start_date,wip.scheduled_completion_date,wo.object_version_number
FROM ahl_visit_tasks_b v, ahl_workorders wo, wip_discrete_jobs wip
WHERE v.visit_id = x_visit_id
AND v.visit_id = wo.visit_id
AND wo.visit_task_id IS NOT NULL
AND wo.visit_task_id = x_visit_task_id
AND wip.wip_entity_id = wo.wip_entity_id
AND wo.status_code not in ('22','7');

c_task_wo_rec c_task_wo%ROWTYPE;

--fetch summary task flag for the task
CURSOR c_fet_sum_task_flg (x_visit_id IN NUMBER, x_visit_task_id IN NUMBER) IS
SELECT summary_task_flag FROM ahl_visit_tasks_b
WHERE visit_task_id = x_visit_task_id;

--fetch all the tasks in the visit
CURSOR c_all_task_dtl (x_visit_id IN NUMBER) IS
SELECT count(visit_task_id) FROM ahl_visit_tasks_b
WHERE visit_id = x_visit_id
AND NVL(status_code,'X') IN ('PLANNING');

--get summary task start, end time
CURSOR get_summary_task_times_csr(x_task_id IN NUMBER)IS
SELECT min(start_date_time), max(end_date_time)
FROM ahl_visit_tasks_b  VST
START WITH visit_task_id  = x_task_id
AND NVL(VST.status_code, 'Y') <> 'DELETED'
    CONNECT BY originating_task_id = PRIOR visit_task_id;

--find Route Id from MR Routes view
CURSOR c_route (x_id IN NUMBER) IS
SELECT Route_Id FROM AHL_MR_ROUTES_V
WHERE MR_ROUTE_ID = x_id;

--check if the visit master wo exists
CURSOR c_fet_mas_wo_dtls  (x_visit_id IN NUMBER) IS
SELECT actual_start_date,actual_end_date
FROM ahl_workorders wo
WHERE wo.visit_id = x_visit_id
AND wo.visit_task_id IS NULL
AND wo.master_workorder_flag = 'Y';

c_fet_mas_wo_dtl_rec    c_fet_mas_wo_dtls%ROWTYPE;

--Inventory item id and instance id to be defaulted when
--the item and instance are not specified at the header level
CURSOR default_task_inst_dtls(c_task_id IN NUMBER) IS
SELECT inventory_item_id,instance_id
FROM ahl_visit_tasks_b
WHERE visit_task_id = c_task_id;

def_task_inst_rec  default_task_inst_dtls%ROWTYPE;

/*B5758813 - rnahata - fetches the route information for updating workorder
description for tasks created from Routes */
CURSOR get_wo_dtls_for_mrtasks_cur (p_task_id IN NUMBER) IS
--TCHIMIRA::Bug 9149770 ::09-FEB-2010
--use substrb and lengthb instead of substr and length respectively
SELECT ar.route_no||'.'||substrb(ar.title,1,(240 - (lengthb(ar.route_no) + 1))) workorder_description
FROM ahl_routes_vl ar,ahl_visit_tasks_b avt, ahl_mr_routes mrr
WHERE avt.visit_task_id = p_task_id
and nvl(avt.status_code,'Y') = 'PLANNING'
and avt.mr_route_id = mrr.mr_route_id
and mrr.route_id = ar.route_id;

get_wo_dtls_for_mrtasks_rec    get_wo_dtls_for_mrtasks_cur%ROWTYPE;

--get SR MWO details.
CURSOR c_get_sr_mwo_dtls(p_sr_task_id IN NUMBER) IS
SELECT WDJ.WIP_ENTITY_ID,
       AWO.WORKORDER_ID,
       AWO.OBJECT_VERSION_NUMBER,
       WDJ.SCHEDULED_START_DATE,
       WDJ.SCHEDULED_COMPLETION_DATE
FROM AHL_WORKORDERS AWO,
     WIP_DISCRETE_JOBS WDJ
WHERE WDJ.WIP_ENTITY_ID = AWO.WIP_ENTITY_ID
 AND AWO.VISIT_TASK_ID = p_sr_task_id
 AND AWO.MASTER_WORKORDER_FLAG = 'Y'
 AND AWO.STATUS_CODE <> 17;

l_sr_mwo_rec  c_get_sr_mwo_dtls%ROWTYPE;

--get SR task details
CURSOR c_get_sr_task_dtls(p_sr_task_id IN NUMBER) IS
 SELECT * FROM AHL_VISIT_TASKS_B vst
 WHERE vst.TASK_TYPE_CODE = 'SUMMARY'
  AND vst.MR_ID IS NULL
  AND vst.SERVICE_REQUEST_ID =
      (SELECT vst1.SERVICE_REQUEST_ID
       FROM ahl_visit_tasks_b vst1
       WHERE vst1.visit_task_id = p_sr_task_id);

--check if visit has planned tasks
CURSOR c_visit_has_planned_tasks(p_visit_id IN NUMBER) IS
 SELECT 1 FROM ahl_visit_tasks_b
 WHERE visit_id = p_visit_id
  AND status_code = 'PLANNING';

CURSOR c_visit_time_matches_MWO_time(p_visit_id IN NUMBER) IS
 SELECT 1
 FROM ahl_visits_b vst, ahl_workorders wo, wip_discrete_jobs wdj
 WHERE vst.visit_id = p_visit_id
  AND wo.visit_id = vst.visit_id
  AND wo.MASTER_WORKORDER_FLAG = 'Y'
  AND wo.visit_task_id IS NULL
  AND wdj.wip_entity_id = wo.wip_entity_id
  AND vst.start_date_time = wdj.scheduled_start_date
  AND vst.close_date_time = wdj.scheduled_completion_date;

l_temp_num1             NUMBER := NULL;
l_temp_num2             NUMBER := NULL;
l_sr_task_dtls_rec      c_get_sr_task_dtls%ROWTYPE;
l_wo_tbl_count          NUMBER  := 0;
l_sch_start_date        DATE;
l_sch_end_date          DATE;
i                       NUMBER := 0;
l_chk_mst_wo            NUMBER := 0;
l_chk_task_wo           NUMBER := 0;
L_API_NAME     CONSTANT VARCHAR2(30)  := 'Push_tasks_to_production';
L_API_VERSION  CONSTANT NUMBER        := 1.0;
L_DEBUG_KEY    CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
l_msg_data              VARCHAR2(2000);
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_prd_workorder_tbl     AHL_PRD_WORKORDER_PVT.PRD_WORKORDER_TBL;
idx                     NUMBER := 0;
l_prd_workorder_rel_tbl AHL_PRD_WORKORDER_PVT.prd_workorder_rel_tbl;
l_manual_summ_task_flag VARCHAR2(1) ;
l_task_cnt              NUMBER := 0;
l_firm_planned_flag     VARCHAR2(1) := FND_PROFILE.value('AHL_PRD_FIRM_PLANNED_FLAG');

BEGIN
    IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.begin',
                      'At the start of PL SQL procedure. Visit Id = ' ||
                      p_visit_id || ', p_tasks_tbl.COUNT = ' || p_tasks_tbl.COUNT);
    END IF;

    -- Standard start of API savepoint
    SAVEPOINT Push_tasks_to_prodn_pvt;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.Initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'Before calling INTEGRATE_TO_PROJECTS for Visit Id ' || p_visit_id);
    END IF;

    --create the project id for the visit.
    AHL_VWP_PROJ_PROD_PVT.Integrate_to_Projects
      (p_api_version       => l_api_version,
       p_init_msg_list     => p_init_msg_list,
       p_commit            => 'F',
       p_validation_level  => p_validation_level,
       p_module_type       => p_module_type,
       p_visit_id          => p_visit_id,
       x_return_status     => l_return_status,
       x_msg_count         => l_msg_count,
       x_msg_data          => x_msg_data);

    IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'After calling Integrate_to_Projects. l_return_status = ' || l_return_status);
    END IF;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Errors from Integrate_to_Projects. Message count: ' || x_msg_count);
      END IF;
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSE
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    --chk if master wo for the visit already exists
    OPEN c_fet_master_wo(p_visit_id);
    FETCH c_fet_master_wo INTO l_chk_mst_wo;
    CLOSE c_fet_master_wo;

    OPEN c_visit_master_wo(p_visit_id);
    FETCH c_visit_master_wo INTO c_mst_wo_visit_rec;
    CLOSE c_visit_master_wo;

    --fetch the visit details
    OPEN c_visit_dtl(p_visit_id);
    FETCH c_visit_dtl INTO c_visit_dtl_rec;
    CLOSE c_visit_dtl;

    --fetch the count of tasks in planning status.
    OPEN c_all_task_dtl (p_visit_id);
    FETCH c_all_task_dtl INTO l_task_cnt;
    CLOSE c_all_task_dtl;

    idx := idx+1;
    l_prd_workorder_tbl(idx).SCHEDULED_START_DATE := c_visit_dtl_rec.start_date_time;
    l_prd_workorder_tbl(idx).SCHEDULED_END_DATE   := c_visit_dtl_rec.close_date_time;
    l_prd_workorder_tbl(idx).BATCH_ID             := c_visit_dtl_rec.VISIT_NUMBER;
    l_prd_workorder_tbl(idx).HEADER_ID            := 0; -- Visit
    IF (nvl(l_chk_mst_wo,0) = 1) THEN --Visit master wo already exists
       l_prd_workorder_tbl(idx).DML_OPERATION         := 'U';
       l_prd_workorder_tbl(idx).WORKORDER_ID          := c_mst_wo_visit_rec.workorder_id;
       l_prd_workorder_tbl(idx).OBJECT_VERSION_NUMBER := c_mst_wo_visit_rec.object_version_number;
       IF (c_mst_wo_visit_rec.status_code <> 3) THEN
          IF (p_release_flag = 'Y') THEN
             -- change status from UNRELEASED/DRAFT to RELEASED
             l_prd_workorder_tbl(idx).STATUS_CODE       := '3'; -- Released
             -- Visit Master Work Order should ALWAYS be FIRM (not dependent on profile)
             l_prd_workorder_tbl(idx).FIRM_PLANNED_FLAG := 1;   -- Firm
          ELSIF  c_mst_wo_visit_rec.status_code = '17' THEN
             -- Master workorder was in Draft status, make it UNRELEASED now
             l_prd_workorder_tbl(idx).STATUS_CODE       := '1'; -- Unreleased
             -- Visit Master Work Order should ALWAYS be FIRM (not dependent on profile)
             l_prd_workorder_tbl(idx).FIRM_PLANNED_FLAG := 1;   -- Firm
          END IF;
       END IF; --master work order status is not 3
    ELSE -- visit master workorder does not exist, create a master wo
       l_prd_workorder_tbl(idx).DML_OPERATION := 'C';
       -- Visit Master Work Order should ALWAYS be FIRM (not dependent on profile)
       l_prd_workorder_tbl(idx).FIRM_PLANNED_FLAG     := 1; -- Firm
       l_prd_workorder_tbl(idx).MASTER_WORKORDER_FLAG := 'Y';
       l_prd_workorder_tbl(idx).VISIT_ID              := p_visit_id;
       l_prd_workorder_tbl(idx).ORGANIZATION_ID       := c_visit_dtl_rec.organization_id;
       l_prd_workorder_tbl(idx).PROJECT_ID            := c_visit_dtl_rec.project_id;
       l_prd_workorder_tbl(idx).DEPARTMENT_ID         := c_visit_dtl_rec.department_id ;
       IF p_release_flag = 'Y' THEN
         l_prd_workorder_tbl(idx).STATUS_CODE  := '3';  -- Released
       ELSE
         l_prd_workorder_tbl(idx).STATUS_CODE  := '1';  -- Unreleased
       END IF;
       IF (c_visit_dtl_rec.inventory_item_id IS NULL AND c_visit_dtl_rec.item_instance_id IS NULL) THEN
          /*When the unit is not specified at the visit level, fetch the first task's inventory_item_id
          and the instance_id from the list of user selected tasks.This inventory_item_id/instance_id
          will be used in the creation of master wo for the visit.*/
          OPEN default_task_inst_dtls(p_tasks_tbl(p_tasks_tbl.FIRST).visit_task_id);
          FETCH default_task_inst_dtls INTO def_task_inst_rec;
          CLOSE default_task_inst_dtls;
          l_prd_workorder_tbl(idx).INVENTORY_ITEM_ID := def_task_inst_rec.inventory_item_id;
          l_prd_workorder_tbl(idx).ITEM_INSTANCE_ID  := def_task_inst_rec.instance_id;
       ELSE
          l_prd_workorder_tbl(idx).INVENTORY_ITEM_ID := c_visit_dtl_rec.inventory_item_id;
          l_prd_workorder_tbl(idx).ITEM_INSTANCE_ID  := c_visit_dtl_rec.item_instance_id;
       END IF;
       l_prd_workorder_tbl(idx).JOB_DESCRIPTION      := c_visit_dtl_rec.visit_name ;
    END IF; --visit master workorder exists or not

    FOR i in p_tasks_tbl.FIRST..p_tasks_tbl.LAST LOOP --for all tasks

        OPEN c_fet_sum_task_flg(p_visit_id, p_tasks_tbl(i).visit_task_id);
        FETCH c_fet_sum_task_flg INTO l_manual_summ_task_flag;
        CLOSE c_fet_sum_task_flg;

        IF (l_manual_summ_task_flag = 'Y') THEN
           -- No work order will be created for manually created summary task
           -- Just update the task status to Released.
           UPDATE ahl_visit_tasks_b
           SET  status_code = 'RELEASED',
                --TCHIMIRA::BUG 9222622 ::15-DEC-2009::UPDATE OVN AND WHO COLUMNS
                OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
                LAST_UPDATE_DATE      = SYSDATE,
                LAST_UPDATED_BY       = Fnd_Global.USER_ID,
                LAST_UPDATE_LOGIN     = Fnd_Global.LOGIN_ID
           WHERE visit_task_id = p_tasks_tbl(i).visit_task_id;

        ELSE
           --check if the wo exists for the task
           OPEN c_fet_task_wo(p_visit_id, p_tasks_tbl(i).visit_task_id);
           FETCH c_fet_task_wo INTO l_chk_task_wo;
           CLOSE c_fet_task_wo;

           --fetch the task details
           OPEN c_visit_task_dtl(p_tasks_tbl(i).visit_task_id);
           FETCH c_visit_task_dtl INTO c_visit_tsk_dtl_rec;
           CLOSE c_visit_task_dtl;

           --fetch the workorder details for the task
           OPEN c_task_wo(p_visit_id , p_tasks_tbl(i).visit_task_id);
           FETCH c_task_wo INTO c_task_wo_rec;
           CLOSE c_task_wo;

           IF (nvl(l_chk_task_wo,0) = 1) THEN --task wo for the visit already exists
              IF (c_task_wo_rec.status_code = 17) THEN  -- Status is Draft
                 idx := idx+1;
                 l_prd_workorder_tbl(idx).dml_operation := 'U';
                 l_prd_workorder_tbl(idx).workorder_id := c_task_wo_rec.workorder_id;
                 l_prd_workorder_tbl(idx).object_version_number := c_task_wo_rec.object_version_number;
                 l_prd_workorder_tbl(idx).item_instance_id  := c_visit_tsk_dtl_rec.instance_id ;
                 l_prd_workorder_tbl(idx).BATCH_ID := c_visit_dtl_rec.visit_number;
                 l_prd_workorder_tbl(idx).HEADER_ID := c_visit_tsk_dtl_rec.visit_task_number;
                 IF (p_release_flag = 'Y') THEN
                    l_prd_workorder_tbl(idx).status_code := '3'; -- Released
                 ELSE
                    l_prd_workorder_tbl(idx).status_code := '1'; -- UnReleased
                 END IF;
                 IF (l_firm_planned_flag IS NOT NULL AND
                 -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010
                 -- For task with past task dates, WOs are always firm irrespective of the profile value
                 p_tasks_tbl(i).past_task_start_date IS NULL AND
                 l_firm_planned_flag = '2') THEN
                    l_prd_workorder_tbl(idx).FIRM_PLANNED_FLAG := 2; -- Planned
                 ELSE
                    l_prd_workorder_tbl(idx).FIRM_PLANNED_FLAG := 1; -- Firm
                 END IF;
                 -- If summary task, use the min,max of sub tasks
                 IF (c_visit_tsk_dtl_rec.task_type_code = 'SUMMARY') THEN
                    OPEN get_summary_task_times_csr(c_visit_tsk_dtl_rec.visit_task_id);
                    FETCH get_summary_task_times_csr
                          INTO l_prd_workorder_tbl(idx).SCHEDULED_START_DATE,
                               l_prd_workorder_tbl(idx).SCHEDULED_END_DATE;
                    CLOSE get_summary_task_times_csr;
                 ELSE
                    l_prd_workorder_tbl(idx).scheduled_start_date  := c_visit_tsk_dtl_rec.start_date_time;
                    l_prd_workorder_tbl(idx).scheduled_end_date    := c_visit_tsk_dtl_rec.end_date_time;
                 END IF;
               /*B5758813 - rnahata - For summary tasks (both manual and MR summary tasks)
               and unassociated tasks the task name is passed as the workorder description.
               And for the Route tasks, the route number concatenated with the route title is
               passed as workorder description.*/
                 IF (c_visit_tsk_dtl_rec.task_type_code IN ('SUMMARY','UNASSOCIATED')) THEN
                    l_prd_workorder_tbl(idx).JOB_DESCRIPTION   :=  c_visit_tsk_dtl_rec.visit_task_name;
                 ELSE
                    OPEN get_wo_dtls_for_mrtasks_cur(c_visit_tsk_dtl_rec.visit_task_id);
                    FETCH get_wo_dtls_for_mrtasks_cur INTO get_wo_dtls_for_mrtasks_rec;
                    CLOSE get_wo_dtls_for_mrtasks_cur;
                    l_prd_workorder_tbl(idx).JOB_DESCRIPTION := get_wo_dtls_for_mrtasks_rec.workorder_description;
                 END IF;
              END IF;  -- WO Status is Draft
           ELSE --work order does not exist for this task
              -- Create a new work order
              idx := idx+1;
              l_prd_workorder_tbl(idx).DML_OPERATION := 'C';
              IF p_release_flag = 'Y' THEN
                 l_prd_workorder_tbl(idx).STATUS_CODE := '3';  -- Released
              ELSE
                 l_prd_workorder_tbl(idx).STATUS_CODE := '1';  -- Unreleased
              END IF;
              IF (l_firm_planned_flag IS NOT NULL AND
              -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010
              -- For task with past task dates, WOs are always firm irrespective of the profile value
              p_tasks_tbl(i).past_task_start_date IS NULL AND
              l_firm_planned_flag = '2') THEN
                 l_prd_workorder_tbl(idx).FIRM_PLANNED_FLAG := 2; -- Planned
              ELSE
                 l_prd_workorder_tbl(idx).FIRM_PLANNED_FLAG := 1; -- Firm
              END IF;
              IF (c_visit_tsk_dtl_rec.task_type_code = 'SUMMARY') THEN
                 l_prd_workorder_tbl(idx).MASTER_WORKORDER_FLAG := 'Y';
              ELSE
                 l_prd_workorder_tbl(idx).MASTER_WORKORDER_FLAG := 'N';
              END IF;

              l_prd_workorder_tbl(idx).BATCH_ID          := c_visit_dtl_rec.visit_number;
              l_prd_workorder_tbl(idx).HEADER_ID         := c_visit_tsk_dtl_rec.visit_task_number;
              l_prd_workorder_tbl(idx).VISIT_ID          := p_visit_id;
              l_prd_workorder_tbl(idx).ORGANIZATION_ID   := c_visit_dtl_rec.organization_id;
              l_prd_workorder_tbl(idx).PROJECT_ID        := c_visit_dtl_rec.project_id;
              l_prd_workorder_tbl(idx).INVENTORY_ITEM_ID := c_visit_tsk_dtl_rec.inventory_item_id ;
              l_prd_workorder_tbl(idx).ITEM_INSTANCE_ID  := c_visit_tsk_dtl_rec.instance_id ;
              l_prd_workorder_tbl(idx).VISIT_TASK_ID     := c_visit_tsk_dtl_rec.visit_task_id ;
              l_prd_workorder_tbl(idx).VISIT_TASK_NUMBER := c_visit_tsk_dtl_rec.visit_task_number ;
              l_prd_workorder_tbl(idx).PROJECT_TASK_ID   := c_visit_tsk_dtl_rec.project_task_id ;

          /*B5758813 - rnahata - For summary tasks (both manual and MR summary tasks)
              and unassociated tasks, the task name is passed as the workorder description.
              And for the MR tasks, the route number concatenated with the route title is
              passed as workorder description.*/
              IF (c_visit_tsk_dtl_rec.task_type_code IN ('SUMMARY','UNASSOCIATED')) THEN
                 l_prd_workorder_tbl(idx).JOB_DESCRIPTION :=  c_visit_tsk_dtl_rec.visit_task_name;
              ELSE
                 OPEN get_wo_dtls_for_mrtasks_cur(c_visit_tsk_dtl_rec.visit_task_id);
                 FETCH get_wo_dtls_for_mrtasks_cur INTO get_wo_dtls_for_mrtasks_rec;
                 CLOSE get_wo_dtls_for_mrtasks_cur;
                 l_prd_workorder_tbl(idx).JOB_DESCRIPTION := get_wo_dtls_for_mrtasks_rec.workorder_description;
              END IF;

              IF c_visit_tsk_dtl_rec.mr_route_id IS NOT NULL AND c_visit_tsk_dtl_rec.mr_route_id <> FND_API.g_miss_num THEN
                 OPEN c_route (c_visit_tsk_dtl_rec.mr_route_id);
                 FETCH c_route INTO l_prd_workorder_tbl(idx).ROUTE_ID;
                 CLOSE c_route;
              ELSE
                 l_prd_workorder_tbl(idx).ROUTE_ID := Null;
              END IF;

              IF c_visit_tsk_dtl_rec.department_id IS NOT NULL AND c_visit_tsk_dtl_rec.department_id <> FND_API.g_miss_num THEN
                 l_prd_workorder_tbl(idx).DEPARTMENT_ID := c_visit_tsk_dtl_rec.department_id ;
              ELSE
                 l_prd_workorder_tbl(idx).DEPARTMENT_ID := c_visit_dtl_rec.department_id ;
              END IF;

              -- If summary task, use the min,max of sub tasks
              IF (c_visit_tsk_dtl_rec.task_type_code = 'SUMMARY') THEN
                 OPEN get_summary_task_times_csr(c_visit_tsk_dtl_rec.visit_task_id);
                 FETCH get_summary_task_times_csr INTO l_prd_workorder_tbl(idx).SCHEDULED_START_DATE,
                                                       l_prd_workorder_tbl(idx).SCHEDULED_END_DATE;
                 CLOSE get_summary_task_times_csr;
              ELSE
                 l_prd_workorder_tbl(idx).SCHEDULED_START_DATE  := c_visit_tsk_dtl_rec.START_DATE_TIME;
                 l_prd_workorder_tbl(idx).SCHEDULED_END_DATE    := c_visit_tsk_dtl_rec.END_DATE_TIME;
              END IF;
           END IF; --work order exists or not for this task

           IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                             'Before calling Get_Task_Relationships for task id: ' ||p_tasks_tbl(i).visit_task_id);
           END IF;

           AHL_VWP_PROJ_PROD_PVT.Get_Task_Relationships
                ( p_visit_id            => p_visit_id,
                  p_visit_number        => c_visit_dtl_rec.visit_number,
                  p_visit_task_id       => c_visit_tsk_dtl_rec.visit_task_id,
                  p_x_relationship_tbl  => l_prd_workorder_rel_tbl
                );

           IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                             'After calling Get_Task_Relationships');
           END IF;
        END IF;  -- Task is Manually Created Summary Task or not
     END LOOP;  -- For all tasks in p_tasks_tbl

     --first get the task relationships for the tasks, then collect the dependencies.
     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
            L_DEBUG_KEY,
            'Before calling Get_Task_Dependencies for tasks');
     END IF;

     FOR i IN p_tasks_tbl.FIRST..p_tasks_tbl.LAST LOOP
       AHL_VWP_PROJ_PROD_PVT.Get_Task_Dependencies
            (
              p_visit_number       => c_visit_dtl_rec.visit_number,
              p_visit_task_id      => p_tasks_tbl(i).visit_task_id,
              p_visit_task_number  => p_tasks_tbl(i).visit_task_number,
              p_x_relationship_tbl => l_prd_workorder_rel_tbl
            );

       IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'After calling Get_Task_Dependencies for task id: ' ||p_tasks_tbl(i).visit_task_id);
       END IF;
     END LOOP;  -- For all tasks in p_tasks_tbl

    -- SR master workorder dates need to be adjusted when new MRs are added.
    -- Scheduled start date and Scheduled end date of SR MWO will be derived as follows
    -- 1. Scheduled start date will be least of scheduled start date of all existing workorders
    -- and new workorders that will be added.
    -- 2. Scheduled end date will be greatest of scheduled start date of all existing workorders
    -- and new workorders that will be added.

    -- step 1. get sr summary tasks duration
    -- Note: Entire task table need be looped through. As in future
    -- requirement, we may need to accomodate cases were more than one
    -- Group task will be passed to this API.
    OPEN c_get_sr_task_dtls(p_tasks_tbl(p_tasks_tbl.FIRST).visit_task_id);
    FETCH c_get_sr_task_dtls INTO l_sr_task_dtls_rec;
    CLOSE c_get_sr_task_dtls;

    OPEN get_summary_task_times_csr(l_sr_task_dtls_rec.visit_task_id);
    FETCH get_summary_task_times_csr INTO l_sch_start_date, l_sch_end_date;
    CLOSE get_summary_task_times_csr;

    -- step 2. get sr mwo details including scheduled dates.
    OPEN c_get_sr_mwo_dtls(l_sr_task_dtls_rec.visit_task_id);
    FETCH c_get_sr_mwo_dtls INTO l_sr_mwo_rec;
    CLOSE c_get_sr_mwo_dtls;

    -- step 3. update sr mwo details with new scheduled dates.
    IF (l_sr_mwo_rec.wip_entity_id IS NOT NULL) THEN

       l_wo_tbl_count := l_prd_workorder_tbl.COUNT + 1;

       --l_prd_workorder_tbl(l_wo_tbl_count).wip_entity_id := l_sr_mwo_rec.wip_entity_id;
       l_prd_workorder_tbl(l_wo_tbl_count).object_version_number := l_sr_mwo_rec.object_version_number;
       l_prd_workorder_tbl(l_wo_tbl_count).workorder_id := l_sr_mwo_rec.workorder_id;
       l_prd_workorder_tbl(l_wo_tbl_count).dml_operation := 'U';

       l_prd_workorder_tbl(l_wo_tbl_count).scheduled_start_date := LEAST(l_sr_mwo_rec.scheduled_start_date,l_sch_start_date);
       l_prd_workorder_tbl(l_wo_tbl_count).scheduled_start_hr := TO_NUMBER(TO_CHAR(l_prd_workorder_tbl(l_wo_tbl_count).scheduled_start_date, 'HH24'));
       l_prd_workorder_tbl(l_wo_tbl_count).scheduled_start_mi := TO_NUMBER(TO_CHAR(l_prd_workorder_tbl(l_wo_tbl_count).scheduled_start_date, 'MI'));

       l_prd_workorder_tbl(l_wo_tbl_count).scheduled_end_date := GREATEST(l_sr_mwo_rec.scheduled_completion_date,l_sch_end_date);
       l_prd_workorder_tbl(l_wo_tbl_count).scheduled_end_hr := TO_NUMBER(TO_CHAR(l_prd_workorder_tbl(l_wo_tbl_count).scheduled_end_date, 'HH24'));
       l_prd_workorder_tbl(l_wo_tbl_count).scheduled_end_mi := TO_NUMBER(TO_CHAR(l_prd_workorder_tbl(l_wo_tbl_count).scheduled_end_date, 'MI'));

       l_prd_workorder_tbl(l_wo_tbl_count).batch_id := c_visit_dtl_rec.visit_number;
       l_prd_workorder_tbl(l_wo_tbl_count).header_id := l_sr_task_dtls_rec.visit_task_number;

       IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'SR MWO Dates before updating...');
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         '----------------------------------------------');
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'scheduled_start_time->'||TO_CHAR(l_sr_mwo_rec.scheduled_start_date,'DD-MON-YYYY HH24:MI:SS'));
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'scheduled_end_time->'||TO_CHAR(l_sr_mwo_rec.scheduled_completion_date,'DD-MON-YYYY HH24:MI:SS'));
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'SR MWO Dates after updating...');
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         '----------------------------------------------');
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'scheduled_start_time->'||TO_CHAR(l_prd_workorder_tbl(l_wo_tbl_count).scheduled_start_date,'DD-MON-YYYY HH24:MI:SS'));
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'scheduled_end_time->'||TO_CHAR(l_prd_workorder_tbl(l_wo_tbl_count).scheduled_end_date,'DD-MON-YYYY HH24:MI:SS'));
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'SR Task scheduled_start_time->'||TO_CHAR(l_sch_start_date,'DD-MON-YYYY HH24:MI:SS'));
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'SR Task scheduled_end_time->'||TO_CHAR(l_sch_end_date,'DD-MON-YYYY HH24:MI:SS'));
       END IF;  -- Statement Log Level
    END IF;  -- wip_entity_id IS NOT NULL

    IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'Before calling PROCESS_JOBS for visit_id: ' || p_visit_id);
    END IF;

    -- Call Production API to create work orders
    AHL_PRD_WORKORDER_PVT.Process_Jobs
          (p_api_version           => l_api_version ,
           p_init_msg_list         => p_init_msg_list,
           p_commit                => 'F',
           p_validation_level      => p_validation_level,
           p_default               => FND_API.G_TRUE,
           p_module_type           => p_module_type,
           x_return_status         => l_return_status,
           x_msg_count             => l_msg_count,
           x_msg_data              => l_msg_data,
           p_x_prd_workorder_tbl   => l_prd_workorder_tbl,
           p_prd_workorder_rel_tbl => l_prd_workorder_rel_tbl
         );

    IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'After calling PROCESS_JOBS for visit_id ' ||
                      p_visit_id||', l_return_status: '|| l_return_status);
    END IF;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       x_msg_count := FND_MSG_PUB.count_msg;
       IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'Errors from PROCESS_JOBS. Message count: ' || x_msg_count);
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSE
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;  -- Return Status is not Success

    IF (l_log_statement >= l_log_current_level) THEN
       For i IN l_prd_workorder_tbl.FIRST..l_prd_workorder_tbl.LAST LOOP
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'WorkOrder Id('||i||'): '||l_prd_workorder_tbl(i).workorder_id);
       END LOOP;
    END IF;

    /*B5758813 - rnahata - starts*/
    /*The project start/end dates have to be updated with the workorder scheduled
    start/end dates.*/
    IF (l_log_statement >= l_log_current_level) THEN
       fnd_log.string(l_log_statement,
                      L_DEBUG_KEY,
                      'Before calling Update_Project_Task_Times.');
    END IF;

    Update_Project_Task_Times(
          p_prd_workorder_tbl => l_prd_workorder_tbl,
          p_commit            =>'F',
          x_return_status     => l_return_status,
          x_msg_count         => l_msg_count,
          x_msg_data          => l_msg_data);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       x_msg_count := FND_MSG_PUB.count_msg;
       IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'Errors from Update_Project_Task_Times. Message count: ' || x_msg_count);
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSE
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    ELSE
       IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Returned Success from Update_Project_Task_Times');
       END IF;
    END IF;  -- Return Status is Success or not
    /*B5758813 - rnahata - ends*/

    FOR i IN p_tasks_tbl.FIRST..p_tasks_tbl.LAST LOOP
      UPDATE ahl_visit_tasks_b
      SET   status_code = 'RELEASED',
            --TCHIMIRA::BUG 9222622 ::15-DEC-2009::UPDATE OVN AND WHO COLUMNS
	    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
            LAST_UPDATE_DATE      = SYSDATE,
            LAST_UPDATED_BY       = Fnd_Global.USER_ID,
            LAST_UPDATE_LOGIN     = Fnd_Global.LOGIN_ID
      WHERE visit_task_id = p_tasks_tbl(i).visit_task_id;
    END LOOP;

    /*Check if the user had selected all the tasks otherwise
    update the visit as Partially released.*/
    OPEN c_visit_has_planned_tasks(p_visit_id);
    FETCH c_visit_has_planned_tasks into l_temp_num1;
    CLOSE c_visit_has_planned_tasks;

    OPEN c_visit_time_matches_MWO_time(p_visit_id);
    FETCH c_visit_time_matches_MWO_time INTO l_temp_num2;
    CLOSE c_visit_time_matches_MWO_time;

    IF l_temp_num1 IS NOT NULL OR l_temp_num2 is NULL THEN
       IF (l_log_statement >= l_log_current_level) THEN
          IF l_temp_num1 IS NOT NULL THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'Visit has some tasks in planning status. Setting Visit status to PARTIALLY RELEASED.');
          END IF;
          IF l_temp_num2 IS NULL THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'Visit times and Master Work order times do not match. Setting Visit status to PARTIALLY RELEASED.');
          END IF;
       END IF;

       UPDATE ahl_visits_b
       SET status_code = 'PARTIALLY RELEASED',
            --TCHIMIRA::BUG 9222622 ::15-DEC-2009::UPDATE OVN AND WHO COLUMNS
            OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
            LAST_UPDATE_DATE      = SYSDATE,
            LAST_UPDATED_BY       = Fnd_Global.USER_ID,
            LAST_UPDATE_LOGIN     = Fnd_Global.LOGIN_ID
       WHERE visit_id = p_visit_id;
    ELSE
       IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Setting Visit status to RELEASED.');
       END IF;

       UPDATE ahl_visits_b
       SET status_code = 'RELEASED',
           any_task_chg_flag ='N',
           --TCHIMIRA::BUG 9222622 ::15-DEC-2009::UPDATE OVN AND WHO COLUMNS
            OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
            LAST_UPDATE_DATE      = SYSDATE,
            LAST_UPDATED_BY       = Fnd_Global.USER_ID,
            LAST_UPDATE_LOGIN     = Fnd_Global.LOGIN_ID
       WHERE visit_id = p_visit_id;
    END IF;

    IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.end',
                      'At the end of PL SQL procedure. Return Status = ' || x_return_status);
    END IF;

EXCEPTION
  WHEN  FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    ROLLBACK TO Push_tasks_to_prodn_pvt;
    FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
    ROLLBACK TO Push_tasks_to_prodn_pvt;
    Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Push_tasks_to_prodn_pvt;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Push_tasks_to_production',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => fnd_api.g_false);

END Push_tasks_to_production;

-------------------------------------------------------------------
--  Procedure name      : check_unit_quarantined
--  Type                : Private
--  Function            : To check whether the Unit is quarantined
--  Parameters          : item_instance_id

-- AnRaj added for R 12.0 ACL changes in VWP
-- Bug number 4297066
----------------------------------------------------------------------
PROCEDURE check_unit_quarantined(
      p_visit_id           IN  NUMBER,
      item_instance_id     IN  NUMBER
      )
IS
   L_API_NAME  CONSTANT VARCHAR2(30) := 'check_unit_quarantined';
   L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
   l_unit_name          VARCHAR2(80);
   l_quarantined        VARCHAR2(1);
   l_task_number        NUMBER(15);
   l_instance_id        NUMBER;

   CURSOR c_get_tasknumbers (x_visit_id IN NUMBER) IS
    SELECT visit_task_number,instance_id
    FROM ahl_visit_tasks_vl
    WHERE visit_id = p_visit_id
     AND NVL(STATUS_CODE,'X') NOT IN ('DELETED','RELEASED')
     AND TASK_TYPE_CODE <> 'SUMMARY';
BEGIN

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,L_DEBUG_KEY||'.begin', 'At the start of PL SQL procedure');
      fnd_log.string(l_log_procedure,L_DEBUG_KEY,'p_visit_id : '|| p_visit_id || 'item_instance_id : '|| item_instance_id);
   END IF;

   IF item_instance_id IS NOT NULL THEN
   -- If the Visit header has an instance id, check for the corresponding Unit
      l_quarantined := ahl_util_uc_pkg.is_unit_quarantined(null,item_instance_id);
      IF l_quarantined = FND_API.G_TRUE THEN
         l_unit_name := ahl_util_uc_pkg.get_unit_name(item_instance_id);
         Fnd_Message.SET_NAME('AHL','AHL_VWP_VLD_HDR_UNIT_QRNT');
         -- The Unit for this Visit (UNIT_NAME-1) is quarantined.
         Fnd_Message.Set_Token('UNIT_NAME',l_unit_name);
         Fnd_Msg_Pub.ADD;

         IF (l_log_statement >= l_log_current_level)THEN
            fnd_log.string (l_log_statement,L_DEBUG_KEY,'Unit : '||l_unit_name || ' is quarantined, Error message added');
         END IF;
      END IF;  -- l_quarantined not true
   ELSE -- instance id is null
   -- If the visit does not have a unit at the header , then check for the units of all tasks
      OPEN c_get_tasknumbers (p_visit_id);
      LOOP
         FETCH c_get_tasknumbers INTO l_task_number,l_instance_id;
         EXIT WHEN c_get_tasknumbers%NOTFOUND;
         l_quarantined := ahl_util_uc_pkg.is_unit_quarantined(null,l_instance_id);
         IF l_quarantined = FND_API.G_TRUE THEN
            Fnd_Message.SET_NAME('AHL','AHL_VWP_VLD_TSK_UNIT_QRNT');
            -- The Unit for the Task (UNIT_NAME-1) is quarantined.
            Fnd_Message.Set_Token('TASK_NUMBER',l_task_number);
            Fnd_Msg_Pub.ADD;
            IF (l_log_statement >= l_log_current_level)THEN
               fnd_log.string(l_log_statement,L_DEBUG_KEY,'Unit for this task: '||l_task_number||' is quarantined');
            END IF;
         END IF;  -- l_quarantined not true
      END LOOP;   --  c_get_tasknumbers
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,L_DEBUG_KEY ||'.end','At the end of PL SQL procedure ');
   END IF;
END check_unit_quarantined;

-------------------------------------------------------------------
--  Procedure name    : Release_MR
--  Type              : Private
--
--
--  Function          :To release all MRs associated to a given UE and return
--                     workorder ID for the root task. Requested by MEL/CDL.
--                     If p_module_type is 'PROD' and Validate_Before_Production
--                     fails, then no exception will be thrown and calling API is
--                     responsible to check return status ('V') and read from error stack.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required ='V' if validation fails
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--      x_workorder_id                  OUT     NUMBER                 Required
--
--  Release visit Parameters:
--       p_visit_id                     IN   NUMBER  Required
--       p_unit_effectivity_id          IN   NUMBER  Required
--       p_release_flag                 IN   VARCHAR2 optional
--
--  Version :
--    07/21/2005     YAZHOU   Initial  Creation
-------------------------------------------------------------------
PROCEDURE Release_MR (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN            VARCHAR2  := NULL,
    p_visit_id               IN            NUMBER,
    p_unit_effectivity_id    IN            NUMBER,
    p_release_flag           IN            VARCHAR2  := 'N',
    -- SKPATHAK :: Bug 8343599 :: 14-APR-2009
    -- Added an optional parameter to prevent date recalculation
    p_recalculate_dates      IN            VARCHAR2  := 'Y',
    x_workorder_id              OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2)
IS
    --Standard local variables
    l_api_name       CONSTANT VARCHAR2(30)  := 'Release_MR';
    l_api_version    CONSTANT NUMBER        := 1.0;
    L_DEBUG_KEY      CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
    l_msg_data                VARCHAR2(2000);
    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER;
    l_Error_Tbl_Type          Error_Tbl_Type;
    l_error_msg               VARCHAR2(5000);
    l_error_count             NUMBER;
    l_commit                  VARCHAR2(1) := 'F';
    l_validate_error CONSTANT VARCHAR2(1) := 'V';
    l_MR_end_time             DATE;
    l_visit_end_time          DATE;

    -- To find visit related information
   CURSOR c_visit (x_id IN NUMBER) IS
    SELECT * FROM AHL_VISITS_VL
    WHERE VISIT_ID = x_id;
   c_visit_rec c_visit%ROWTYPE;

   CURSOR get_wo(c_visit_id NUMBER, c_unit_effectivity_id NUMBER) IS
   SELECT workorder_id
   FROM AHL_WORKORDERS
   WHERE VISIT_TASK_ID = (select visit_task_id from ahl_visit_tasks_b
                          where visit_id = c_visit_id
                          and unit_effectivity_id = c_unit_effectivity_id
                          AND NVL(status_code, 'Y') <> 'DELETED'
                          and originating_task_id is null)
     AND STATUS_CODE NOT IN ('7', '22');

   CURSOR c_get_wo_details(x_visit_id IN NUMBER)
   IS
   SELECT
        scheduled_start_date,
        SCHEDULED_COMPLETION_DATE
   FROM   wip_discrete_jobs
   WHERE wip_entity_id =
        (
         SELECT
         wip_entity_id
         FROM ahl_workorders
         WHERE
           master_workorder_flag = 'Y' AND
           visit_task_id IS null AND
           status_code not in (22,7) and
           visit_id=x_visit_id
          );
   c_get_wo_details_rec  c_get_wo_details%ROWTYPE;

  -- get end time of the root task for a given UE
   CURSOR get_summary_task_times_csr(x_visit_id IN NUMBER, x_unit_effectivity_id IN NUMBER)IS
      SELECT max(end_date_time)
      FROM ahl_visit_tasks_b VST
      where visit_id = x_visit_id
        AND NVL(VST.status_code, 'Y') <> 'DELETED'
      START WITH unit_effectivity_id = x_unit_effectivity_id
        and originating_task_id is null
      CONNECT BY originating_task_id = PRIOR visit_task_id;

-- Get all the parent tasks for a given UE that start in a past date
CURSOR get_independent_tasks(x_visit_id IN NUMBER, x_unit_effectivity_id IN NUMBER) IS
  select distinct t.visit_task_id
    from ahl_visit_tasks_b t,
         ahl_visits_b v
   where v.visit_id = x_visit_id
     and v.visit_id = t.visit_id
     and v.status_code = 'PARTIALLY RELEASED'
     and t.start_date_time < SYSDATE
     and t.status_code ='PLANNING'
     and t.task_type_code <>'SUMMARY'
     -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Adjust task times only if past task start date is null
     and t.past_task_start_date IS NULL
     and (not exists (select 1 from ahl_task_links l0
                      where l0.parent_task_id = t.visit_task_id
                         or l0.visit_task_id = t.visit_task_id )
          or t.visit_task_id in (select l1.parent_task_id from ahl_task_links l1
                                  where not exists (select l2.visit_task_id from ahl_task_links l2
                                                     where l2.visit_task_id = l1.parent_task_id)))
    /*NR-MR Changes - For SR's created from non-routines have the originating wo as their originating task, hence they are not null.*/
    START WITH t.unit_effectivity_id  = x_unit_effectivity_id
        AND (( t.originating_task_id is null AND 'SR' <> p_module_type)
    -- SKPATHAK :: Bug #9410052 :: 25-FEB-2010 :: Removed the condition "originating_task_id is not null"
            OR ( 'SR' = p_module_type
                 and t.service_request_id is not null))
    CONNECT BY t.originating_task_id = PRIOR visit_task_id;

BEGIN

    IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure, L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Visit Id = ' || p_visit_id ||
                     ', p_recalculate_dates = ' || p_recalculate_dates);
    END IF;

    -- Standard start of API savepoint
    SAVEPOINT Release_MR;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean( p_init_msg_list) THEN
       FND_MSG_PUB.Initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,L_DEBUG_KEY,'Request for Release_MR Visit ID : ' || p_visit_id);
      fnd_log.string(l_log_statement,L_DEBUG_KEY,'Request for Release_MR UE ID : ' || p_unit_effectivity_id);
      fnd_log.string(l_log_statement,L_DEBUG_KEY,'Request for Release_MR Release Flag : ' || p_release_flag);
    END IF;

    -- Check for Required Parameters
    IF(p_visit_id IS NULL OR p_visit_id = FND_API.G_MISS_NUM) THEN
       FND_MESSAGE.Set_Name(G_PM_PRODUCT_CODE,'AHL_VWP_CST_INPUT_MISS');
       FND_MSG_PUB.ADD;
       IF (l_log_unexpected >= l_log_current_level)THEN
           fnd_log.string(l_log_unexpected,L_DEBUG_KEY,'Visit id is mandatory but found null in input');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF(p_unit_effectivity_id IS NULL OR p_unit_effectivity_id = FND_API.G_MISS_NUM) THEN
       FND_MESSAGE.Set_Name(G_PM_PRODUCT_CODE,'AHL_VWP_UE_INPUT_MISS');
       FND_MSG_PUB.ADD;
       IF (l_log_unexpected >= l_log_current_level)THEN
           fnd_log.string(l_log_unexpected,L_DEBUG_KEY,'Unit Effectivity id is mandatory but found null in input ');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (l_log_statement >= l_log_current_level)THEN
        fnd_log.string(l_log_statement,L_DEBUG_KEY,'Before Calling Validate Before Production for visit Id: ' ||p_visit_id);
    END IF;

    --Valdate before push to production happens
    Validate_Before_Production
              (p_api_version       => l_api_version,
               p_init_msg_list     => p_init_msg_list,
               p_commit            => l_commit,
               p_validation_level  => p_validation_level,
               p_module_type       => p_module_type,
               p_visit_id          => p_visit_id,
               x_error_tbl         => l_error_tbl_type,
               x_return_status     => l_return_status,
               x_msg_count         => x_msg_count,
               x_msg_data          => x_msg_data);

    IF (l_log_statement >= l_log_current_level)THEN
      fnd_log.string(l_log_statement,L_DEBUG_KEY,'After Calling Validate Before Production - l_return_status : '|| l_return_status);
    END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       -- Check Error Message stack.
       x_msg_count := FND_MSG_PUB.count_msg;
       IF (l_log_statement >= l_log_current_level)THEN
        fnd_log.string(l_log_statement,L_DEBUG_KEY,'Errors from Validate Before Production' || x_msg_count);
       END IF;
       RAISE Fnd_Api.g_exc_error;
    END IF;

    IF l_error_tbl_type.COUNT > 0 THEN
      x_return_status := l_validate_error;
    ELSE
      OPEN c_visit (p_visit_id);
      FETCH c_visit INTO c_visit_rec;
      CLOSE c_visit;
      -- Adjust Task Start/End time if visit start date is a past date
      -- ER #4552764

      IF c_visit_rec.STATUS_CODE = 'PARTIALLY RELEASED' AND c_visit_rec.start_date_time < SYSDATE THEN
        -- SKPATHAK :: Bug 8343599 :: 14-APR-2009 :: Begin
        -- Recalculate the task times only if the user has not entered a start date for the NR
        -- If the user has entered a task start date, the callers should pass 'N'
        -- for the p_recalculate_dates parameter so that the original dates can be retained
        IF (NVL(p_recalculate_dates, 'Y') <> 'N') THEN
        FOR l_get_independent_tasks IN get_independent_tasks(c_visit_rec.visit_id,p_unit_effectivity_id)
        LOOP
          AHL_VWP_TIMES_PVT.adjust_task_times(
                               p_api_version           => 1.0,
                               p_init_msg_list         => Fnd_Api.G_FALSE,
                               p_commit                => Fnd_Api.G_FALSE,
                               p_validation_level      => Fnd_Api.G_VALID_LEVEL_FULL,
                               x_return_status         => l_return_status,
                               x_msg_count             => l_msg_count,
                               x_msg_data              => l_msg_data,
                               p_task_id               => l_get_independent_tasks.visit_task_id,
                               p_reset_sysdate_flag    => FND_API.G_TRUE);
        END LOOP;
        END IF;
        -- SKPATHAK :: Bug 8343599 :: 14-APR-2009 :: End
        l_visit_end_time := AHL_VWP_TIMES_PVT.get_visit_end_time(c_visit_rec.visit_id);
        IF l_visit_end_time > c_visit_rec.close_date_time THEN
          Fnd_Message.SET_NAME('AHL','AHL_VWP_PRD_VST_TSK_STDT_ADJU');
          Fnd_Message.Set_Token('VISIT_END_DATE', l_visit_end_time);
          Fnd_Msg_Pub.ADD;
          x_return_status := l_validate_error;
        END IF;
      END IF;
    END IF;

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      /* Check visit end date instead
           --The MR end date
           OPEN get_summary_task_times_csr(p_visit_id, p_unit_effectivity_id);
           FETCH get_summary_task_times_csr into l_MR_end_time;
           CLOSE get_summary_task_times_csr;
      */
     l_visit_end_time := AHL_VWP_TIMES_PVT.get_visit_end_time(c_visit_rec.visit_id);

     OPEN c_get_wo_details(c_visit_rec.visit_id);
     FETCH c_get_wo_details into c_get_wo_details_rec;
     -- Validate to check if derived visit end time now exceeds scheduled master work order completion time
     -- Note: since we are checking for derived visit end time here, if there are other task in planning
     -- status with end date exceeding visit master WO end date, then MR tasks cannot be created
     IF TRUNC(l_visit_end_time) > TRUNC(c_get_wo_details_rec.scheduled_completion_date) THEN
        x_return_status := l_validate_error;
        -- Error Message
        Fnd_Message.SET_NAME('AHL','AHL_VWP_DATE_EXCD_WO_DATE');
        Fnd_Message.Set_Token('VISIT_END_DATE', l_visit_end_time);
        FND_MSG_PUB.ADD;
     END IF;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      -- Per MEL/CDL requirement, if tasks are sucessfully created but fail to be pushed
      -- to production, then they will stay in 'PLANNING' status.
      IF p_module_type <>'PROD' THEN
        -- Check Error Message stack.
        x_msg_count := FND_MSG_PUB.count_msg;
        IF (l_log_statement >= l_log_current_level)THEN
          fnd_log.string(l_log_statement,L_DEBUG_KEY,'Errors from Validate Before Production'|| x_msg_count);
        END IF;
        RAISE Fnd_Api.g_exc_error;
      END IF;
    ELSE
      IF (l_log_statement >= l_log_current_level)THEN
         fnd_log.string(l_log_statement,L_DEBUG_KEY,'Before Calling Push_MR_to_Production for UE Id: ' ||p_unit_effectivity_id);
      END IF;

      Push_MR_to_Production
             (p_api_version        => l_api_version,
              p_init_msg_list      => p_init_msg_list,
              p_commit             => l_commit,
              p_validation_level   => p_validation_level,
              p_module_type        => p_module_type,
              p_visit_id           => p_visit_id,
              p_unit_effectivity_id => p_unit_effectivity_id,
              p_release_flag       => p_release_flag,
              x_return_status      => l_return_status,
              x_msg_count          => l_msg_count,
              x_msg_data           => l_msg_data);

      IF (l_log_statement >= l_log_current_level)THEN
         fnd_log.string(l_log_statement,L_DEBUG_KEY,'After Calling Push_MR_to_Production - l_return_status : ' ||l_return_status);
      END IF;

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       -- Check Error Message stack.
       x_msg_count := FND_MSG_PUB.count_msg;
       IF (l_log_statement >= l_log_current_level)THEN
        fnd_log.string(l_log_statement,L_DEBUG_KEY,'Errors from Push to Production: ' || x_msg_count);
       END IF;
       RAISE Fnd_Api.g_exc_error;
      END IF;

      /*Return root root workorder ID for the given UE*/
      OPEN get_wo(p_visit_id, p_unit_effectivity_id);
      FETCH get_wo INTO x_workorder_id;
      CLOSE get_wo;
    END IF;

    -- Standard check of p_commit
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
    END IF;

    Fnd_Msg_Pub.count_and_get(
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data);

    IF (l_log_procedure >= l_log_current_level)THEN
        fnd_log.string(l_log_procedure,L_DEBUG_KEY||'.end','At the end of PLSQL procedure');
    END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO Release_MR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO Release_MR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Release_MR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Release_MR',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

END Release_MR;

--------------------------------------------------------------------
-- PROCEDURE
--    Get_MR_Dependencies
--
-- PURPOSE
-- To get all the Technical Dependencies for the MR.
--------------------------------------------------------------------

PROCEDURE Get_MR_Dependencies
(
  p_visit_id             IN            NUMBER,
  p_visit_number         IN            NUMBER,
  p_unit_effectivity_id  IN            NUMBER,
  p_module_type          IN            VARCHAR2  := Null, /*NR-MR Changes - sowsubra*/
  p_x_relationship_tbl   IN OUT NOCOPY AHL_PRD_WORKORDER_PVT.prd_workorder_rel_tbl
)
AS

-- Get all the Task Dependencies for the given MR.
CURSOR get_tech_dependencies( c_visit_id NUMBER, c_unit_effectivity_id NUMBER )
IS
SELECT distinct PARENT.visit_task_number parent_task_number,
       CHILD.visit_task_number child_task_number
FROM   AHL_VISIT_TASKS_B PARENT,
       AHL_VISIT_TASKS_B CHILD,
       AHL_TASK_LINKS LINK
WHERE  PARENT.visit_task_id = LINK.parent_task_id
AND    CHILD.visit_task_id = LINK.visit_task_id
AND    NVL(PARENT.STATUS_CODE,'X') = 'PLANNING' --Srini Bug #4075702
AND    PARENT.visit_id = c_visit_id
AND    CHILD.visit_id = c_visit_id
AND PARENT.visit_task_id in (select visit_task_id from ahl_visit_tasks_b
                             where visit_id = c_visit_id
                              /*NR-MR Changes - For SR's created from non-routines have the originating wo as their originating task, hence they are not null.*/
                             START WITH unit_effectivity_id  = c_unit_effectivity_id
                                AND (( originating_task_id is null AND 'SR' <> p_module_type)
				-- SKPATHAK :: Bug #9410052 :: 25-FEB-2010
                                -- Removed the condition "originating_task_id is not null"
                                      OR ( 'SR' = p_module_type
                                            and service_request_id is not null))
                             CONNECT BY originating_task_id = PRIOR visit_task_id)
AND CHILD.visit_task_id in ( select visit_task_id from ahl_visit_tasks_b
                             where visit_id = c_visit_id
                             /*NR-MR Changes - For SR's created from non-routines have the originating wo as their originating task, hence they are not null.*/
                             START WITH unit_effectivity_id  = c_unit_effectivity_id
                                AND (( originating_task_id is null AND 'SR' <> p_module_type)
				-- SKPATHAK :: Bug #9410052 :: 25-FEB-2010
				-- Removed the condition "originating_task_id is not null"
                                      OR ( 'SR' = p_module_type
                                            and service_request_id is not null))
                             CONNECT BY originating_task_id = PRIOR visit_task_id);

l_api_name CONSTANT VARCHAR2(30):= 'Get_MR_Dependencies';
L_DEBUG_KEY    CONSTANT VARCHAR2(100):= 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
rel_count           NUMBER;

BEGIN

  IF (l_log_procedure >= l_log_current_level) THEN
    fnd_log.string(l_log_procedure,L_DEBUG_KEY||'.begin','At the start of the procedure');
  END IF;

  rel_count := p_x_relationship_tbl.COUNT;

  IF (l_log_statement >= l_log_current_level) THEN
    fnd_log.string(l_log_statement,L_DEBUG_KEY,'rel_count - '||rel_count);
  END IF;

  -- Get the Technical Dependencies between Visit Tasks for a Visit.
  FOR tsk_cursor IN get_tech_dependencies( p_visit_id , p_unit_effectivity_id) LOOP
    rel_count := rel_count + 1;
    p_x_relationship_tbl(rel_count).batch_id := p_visit_number;
    p_x_relationship_tbl(rel_count).parent_header_id := tsk_cursor.parent_task_number;
    p_x_relationship_tbl(rel_count).child_header_id := tsk_cursor.child_task_number;
    p_x_relationship_tbl(rel_count).relationship_type := 2;
    p_x_relationship_tbl(rel_count).dml_operation := 'C';
  END LOOP;

  IF (l_log_procedure >= l_log_current_level) THEN
    fnd_log.string(l_log_procedure,L_DEBUG_KEY,'Total Relationships : ' || p_x_relationship_tbl.COUNT);
    fnd_log.string(l_log_procedure,L_DEBUG_KEY||'.end','At the end of procedure');
  END IF;

END Get_MR_Dependencies;

--------------------------------------------------------------------
-- PROCEDURE
--    Get_MR_Relationships
--
-- PURPOSE
-- To get all the Relationships for the MR. These include :
-- 1.A record for Each MR to MR / Visit Relationship.
-- 2.A record for Each Visit Task to MR Relationship.
--------------------------------------------------------------------

PROCEDURE Get_MR_Relationships
(
  p_visit_id            IN            NUMBER,
  p_visit_number        IN            NUMBER,
  p_unit_effectivity_id IN            NUMBER,
  p_module_type         IN            VARCHAR2  := Null, /*NR-MR Changes - sowsubra*/
  p_x_relationship_tbl  IN OUT NOCOPY AHL_PRD_WORKORDER_PVT.prd_workorder_rel_tbl
)
AS
-- Get all the MR tasks associated to the given UE.
/*NR-MR Changes - sowsubra - modified the cursor to fetch the sr_id, mr_id and task type*/
CURSOR   get_mrs_for_UE( c_visit_id NUMBER , c_unit_effectivity_id NUMBER)
IS
SELECT   distinct visit_task_id,
         visit_task_number,
         task_type_code,
         service_request_id,
         mr_id,
         NVL(originating_task_id, -1)
FROM     AHL_VISIT_TASKS_B
WHERE    visit_id = c_visit_id
AND      task_type_code='SUMMARY'
-- SKPATHAK :: Bug 9444849 :: 19-MAR-2010
-- This condition is not needed, since after opening this cursor we have a check if the visit task id fetched by this cursor
-- already has a corresponding WO. So only for tasks in planning we are building the relationships
-- Also it is necessary to remove this condition to fix the bug 9444849, since the parent task can be implemented as well
-- AND NVL(STATUS_CODE, 'X') = 'PLANNING'
/*NR-MR Changes - For SR's created from non-routines have the originating wo as their originating task, hence they are not null.*/
START WITH unit_effectivity_id  = c_unit_effectivity_id
   AND (( originating_task_id is null AND 'SR' <> p_module_type)
   -- SKPATHAK :: Bug #9410052 :: 25-FEB-2010 :: Removed the condition "originating_task_id is not null"
        OR ( 'SR' = p_module_type
             and service_request_id is not null))
CONNECT BY originating_task_id = PRIOR visit_task_id
order by 2;

TYPE mr_task_rec_type IS RECORD
(
  visit_task_id        NUMBER,
  visit_task_number    NUMBER,
  /*NR-MR Changes - sowsubra - begin*/
  task_type_code       VARCHAR2(30),
  service_request_id   NUMBER,
  mr_id                NUMBER,
  /*NR-MR Changes - sowsubra - end*/
  originating_task_id  NUMBER
);

TYPE mr_task_tbl_type IS TABLE OF mr_task_rec_type INDEX BY BINARY_INTEGER;

l_mrs_for_UE  mr_task_tbl_type;

-- Get all the Tasks associated to a MR.
CURSOR get_tasks_for_mr( c_visit_id NUMBER, c_mr_task_id NUMBER )
IS
SELECT visit_task_number, visit_task_id
FROM   AHL_VISIT_TASKS_B
WHERE  visit_id = c_visit_id
AND    originating_task_id = c_mr_task_id
AND    task_type_code <> 'SUMMARY'
AND NVL(STATUS_CODE, 'X') = 'PLANNING';

CURSOR get_wo(c_visit_task_id NUMBER)
IS
SELECT wip_entity_id
FROM AHL_WORKORDERS
WHERE VISIT_TASK_ID = c_visit_task_id
AND STATUS_CODE NOT IN ('7', '22');

CURSOR get_parent_wo(c_visit_task_id NUMBER)
IS
SELECT wip_entity_id
FROM AHL_WORKORDERS
WHERE VISIT_TASK_ID = c_visit_task_id
AND STATUS_CODE NOT IN ('7', '22');

CURSOR get_mwo(c_visit_id NUMBER)
IS
SELECT wip_entity_id
FROM AHL_WORKORDERS
WHERE visit_id = c_visit_id
AND VISIT_TASK_ID IS NULL
AND MASTER_WORKORDER_FLAG = 'Y'
AND STATUS_CODE NOT IN ('7', '22');

l_api_name        CONSTANT    VARCHAR2(30):= 'Get_MR_Relationships';
L_DEBUG_KEY           CONSTANT   VARCHAR2(100):= 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

l_wip_entity_id      NUMBER;
l_parent_wip_entity_id      NUMBER;
/*NR-MR Changes - sowsubra - begin*/
l_parent_wo_id      NUMBER := 0;
/*NR-MR Changes - sowsubra - end*/

rel_count    NUMBER := 0;
mr_count     NUMBER := 0;

BEGIN

  IF (l_log_procedure >= l_log_current_level) THEN
    fnd_log.string(l_log_procedure,L_DEBUG_KEY||'.begin','At the start of the procedure');
  END IF;

  rel_count := p_x_relationship_tbl.COUNT;

  IF (l_log_statement >= l_log_current_level) THEN
    fnd_log.string(l_log_statement,L_DEBUG_KEY,'rel_count - '||rel_count);
  END IF;

  -- Get all the Task Records corresponding to a MR for the given UE.
  OPEN get_mrs_for_UE( p_visit_id, p_unit_effectivity_id );
  LOOP
    EXIT WHEN get_mrs_for_UE%NOTFOUND;
    mr_count := mr_count + 1;
    FETCH get_mrs_for_UE
    INTO  l_mrs_for_UE(mr_count).visit_task_id,
          l_mrs_for_UE(mr_count).visit_task_number,
          /*NR-MR Changes - sowsubra - begin*/
          l_mrs_for_UE(mr_count).task_type_code,
          l_mrs_for_UE(mr_count).service_request_id,
          l_mrs_for_UE(mr_count).mr_id,
          /*NR-MR Changes - sowsubra - end*/
          l_mrs_for_UE(mr_count).originating_task_id;
  END LOOP;
  CLOSE get_mrs_for_UE;

  IF (l_log_statement >= l_log_current_level) THEN
    fnd_log.string(l_log_statement,L_DEBUG_KEY,'Total MRs for Visit : ' || l_mrs_for_UE.COUNT);
  END IF;

  OPEN get_mwo(p_visit_id);
  FETCH get_mwo INTO l_parent_wip_entity_id;
  CLOSE get_mwo;

  IF ( l_mrs_for_UE.COUNT > 0 ) THEN
    FOR i IN l_mrs_for_UE.FIRST..l_mrs_for_UE.LAST LOOP
    -- if the visit task already has a workorder then do not
    -- create a relationship for it
    OPEN get_wo(l_mrs_for_UE(i).visit_task_id);
    FETCH get_wo INTO l_wip_entity_id;
    IF get_wo%NOTFOUND THEN
        rel_count := rel_count + 1;
        p_x_relationship_tbl(rel_count).batch_id := p_visit_number;
        p_x_relationship_tbl(rel_count).child_header_id := l_mrs_for_UE(i).visit_task_number;
        p_x_relationship_tbl(rel_count).relationship_type := 1;
        p_x_relationship_tbl(rel_count).dml_operation := 'C';

        -- Loop to Find out Parent MRs
        IF ( l_mrs_for_UE(i).originating_task_id <> -1 ) THEN
          /*NR-MR Changes - sowsubra - begin*/
          /*MWO created for the SR Summary task should be child of visit MWO only.
          Hence the parent of the SR Summary task created from production will be visit.*/
          IF (l_mrs_for_UE(i).service_request_id IS NOT NULL) AND (l_mrs_for_UE(i).mr_id IS NULL) AND (NVL(p_module_type, 'NOT_SR') = 'SR') THEN
            /*OPEN get_mwo(p_visit_id);
            FETCH get_mwo INTO l_parent_wip_entity_id;
            CLOSE get_mwo;*/
            p_x_relationship_tbl(rel_count).parent_wip_entity_id := l_parent_wip_entity_id;
            p_x_relationship_tbl(rel_count).parent_header_id := 0;
          ELSE
            /*NR-MR Changes - sowsubra - end*/
            FOR j IN l_mrs_for_UE.FIRST..l_mrs_for_UE.LAST LOOP
              IF ( l_mrs_for_UE(i).originating_task_id = l_mrs_for_UE(j).visit_task_id ) THEN
                p_x_relationship_tbl(rel_count).parent_header_id := l_mrs_for_UE(j).visit_task_number;
                OPEN get_parent_wo(l_mrs_for_UE(j).visit_task_id);
                FETCH get_parent_wo INTO l_parent_wo_id;
                IF get_parent_wo%FOUND THEN
                  p_x_relationship_tbl(rel_count).parent_wip_entity_id := l_parent_wo_id;
                END IF;
                CLOSE get_parent_wo;
                EXIT;
              END IF;
            END LOOP;
          END IF; /*NR-MR Changes - sowsubra*/
        END IF;

        -- If no Parent MR is found set the parent as the Visit
        IF ( p_x_relationship_tbl(rel_count).parent_header_id IS NULL ) THEN
          p_x_relationship_tbl(rel_count).parent_header_id := 0;
          /*OPEN get_mwo(p_visit_id);
          FETCH get_mwo INTO l_parent_wip_entity_id;
          IF get_mwo%FOUND THEN*/
          p_x_relationship_tbl(rel_count).parent_wip_entity_id := l_parent_wip_entity_id;
          /*END IF;
          CLOSE get_mwo;*/
        END IF;
    END IF;
    CLOSE get_wo;

    IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,L_DEBUG_KEY,'Total MRs for Visit : ' || l_mrs_for_UE.COUNT);
    END IF;
    END LOOP;
  END IF;

  IF (l_log_statement >= l_log_current_level) THEN
    fnd_log.string(l_log_statement,L_DEBUG_KEY,'Getting Tasks for MRs');
  END IF;
  -- Get all the Tasks for a MR.
  IF ( l_mrs_for_UE.COUNT > 0 ) THEN
    FOR i IN l_mrs_for_UE.FIRST..l_mrs_for_UE.LAST
    LOOP
      FOR mr_tasks_cursor IN get_tasks_for_mr( p_visit_id, l_mrs_for_UE(i).visit_task_id )
      LOOP
        OPEN get_wo(mr_tasks_cursor.visit_task_id);
        FETCH get_wo INTO l_wip_entity_id;
        IF get_wo%NOTFOUND THEN
           rel_count := rel_count + 1;
           p_x_relationship_tbl(rel_count).batch_id := p_visit_number;
           p_x_relationship_tbl(rel_count).parent_header_id := l_mrs_for_UE(i).visit_task_number;
           p_x_relationship_tbl(rel_count).child_header_id := mr_tasks_cursor.visit_task_number;
           p_x_relationship_tbl(rel_count).relationship_type := 1;
           p_x_relationship_tbl(rel_count).dml_operation := 'C';

           -- if this visit task is already in shop floor then get the wip_entity_id
           OPEN get_parent_wo(l_mrs_for_UE(i).visit_task_id);
           FETCH get_parent_wo INTO l_parent_wip_entity_id;
           IF get_parent_wo%FOUND THEN
               p_x_relationship_tbl(rel_count).parent_wip_entity_id := l_parent_wip_entity_id;
           END IF;
           CLOSE get_parent_wo;
        END IF;
        CLOSE get_wo;
      END LOOP;
    END LOOP;
  END IF;

  IF (l_log_procedure >= l_log_current_level) THEN
    fnd_log.string(l_log_procedure,L_DEBUG_KEY,'Total Relationships : ' || p_x_relationship_tbl.COUNT );
    fnd_log.string(l_log_procedure,L_DEBUG_KEY||'.end','At the end of the procedure');
  END IF;

END Get_MR_Relationships;

--------------------------------------------------------------------
-- PROCEDURE
--    Push_MR_to_Production
--
-- PURPOSE
--    To push MR along with all its tasks to Production
--------------------------------------------------------------------
PROCEDURE Push_MR_to_Production
(    p_api_version          IN  NUMBER,
     p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
     p_commit               IN  VARCHAR2  := Fnd_Api.g_false,
     p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
     p_module_type          IN  VARCHAR2  := Null,
     p_visit_id             IN  NUMBER,
     p_unit_effectivity_id  IN  NUMBER,
     p_release_flag         IN  VARCHAR2  := 'N',
     x_return_status        OUT NOCOPY VARCHAR2,
     x_msg_count            OUT NOCOPY NUMBER,
     x_msg_data             OUT NOCOPY VARCHAR2
)
IS
   L_API_VERSION  CONSTANT NUMBER := 1.0;
   L_API_NAME     CONSTANT VARCHAR2(30) := 'Push_MR_to_Production';
   L_DEBUG_KEY    CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
   l_prd_workorder_tbl     AHL_PRD_WORKORDER_PVT.PRD_WORKORDER_TBL;
   l_prd_workorder_rel_tbl AHL_PRD_WORKORDER_PVT.PRD_WORKORDER_REL_TBL;
   l_firm_planned_flag     VARCHAR2(1) := FND_PROFILE.value( 'AHL_PRD_FIRM_PLANNED_FLAG' );
   l_return_status         VARCHAR2(1);
   l_msg_count             NUMBER;
   l_msg_data              VARCHAR2(2000);
   l_init_msg_list         VARCHAR2(1) := 'F';
   l_commit                VARCHAR2(1) := 'F';
   idx                     NUMBER;
   l_count                 NUMBER;
   l_route_id              NUMBER;
   l_visit_end_time        DATE;
   l_dummy                 VARCHAR2(1);
   l_temp_msg_count       NUMBER:=0; -- Added by skpathak for bug #9445455 fix

   -- To find visit related information
   CURSOR c_visit (x_visit_id IN NUMBER) IS
    SELECT * FROM AHL_VISITS_VL
    WHERE VISIT_ID = x_visit_id;

   c_visit_rec c_visit%ROWTYPE;

   -- To get all the tasks for the given UE
   CURSOR c_task (x_visit_id IN NUMBER, x_unit_effectivity_id IN NUMBER) IS
-- SKPATHAK :: Bug 8340436 :: 23-MAR-2009
    -- Fetch distinct rows to avoid duplicates
    -- Select individual cols instead of *
    --SELECT * FROM AHL_VISIT_TASKS_VL
    SELECT distinct visit_task_id, originating_task_id, visit_id, unit_effectivity_id,
           status_code, service_request_id, project_task_id, visit_task_number,
           visit_task_name, description, object_version_number, task_type_code,
           inventory_item_id, instance_id, mr_route_id, department_id, start_date_time,
           end_date_time, past_task_start_date -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Fetch past date too
      FROM AHL_VISIT_TASKS_VL
      WHERE VISIT_ID = x_visit_id
    AND NVL( STATUS_CODE, 'X' ) = 'PLANNING'
    /*NR-MR Changes*/
    START WITH unit_effectivity_id  = x_unit_effectivity_id
        AND (( originating_task_id is null AND 'SR' <> p_module_type)
	-- SKPATHAK :: Bug #9410052 :: 25-FEB-2010 :: Removed the condition "originating_task_id is not null"
            OR ( 'SR' = p_module_type
                 and service_request_id is not null))
    CONNECT BY originating_task_id = PRIOR visit_task_id;

   c_task_rec c_task%ROWTYPE;

   -- To get the count of all the tasks for the given UE
   CURSOR c_task_ct (x_visit_id IN NUMBER, x_unit_effectivity_id IN NUMBER) IS
    -- SKPATHAK :: Bug 8340436 :: 23-MAR-2009
    -- Fetch distinct rows to avoid duplicates and select visit_task_id instead of *
    --SELECT count(*) FROM AHL_VISIT_TASKS_B
    SELECT count(distinct visit_task_id) FROM AHL_VISIT_TASKS_B
    WHERE VISIT_ID = x_visit_id
    AND NVL( STATUS_CODE, 'X' ) = 'PLANNING'
    /*NR-MR Changes*/
    START WITH unit_effectivity_id  = x_unit_effectivity_id
        AND (( originating_task_id is null AND 'SR' <> p_module_type)
	-- SKPATHAK :: Bug #9410052 :: 25-FEB-2010 :: Removed the condition "originating_task_id is not null"
            OR ( 'SR' = p_module_type
                 and service_request_id is not null))
    CONNECT BY originating_task_id = PRIOR visit_task_id;

   -- To find Route Id from MR Routes view
   CURSOR c_route (x_id IN NUMBER) IS
    SELECT Route_Id FROM AHL_MR_ROUTES_V
    WHERE MR_ROUTE_ID = x_id;

  --To get summary task start, end time
  CURSOR get_summary_task_times_csr(x_task_id IN NUMBER)IS
      SELECT min(start_date_time), max(end_date_time)
      --TCHIMIRA::19-FEB-2010::BUG 9384614
      -- Use the base table instead of the vl view
      FROM ahl_visit_tasks_b VST
      START WITH visit_task_id  = x_task_id
        AND NVL(VST.status_code, 'Y') <> 'DELETED'
      CONNECT BY originating_task_id = PRIOR visit_task_id;

  CURSOR c_visit_task_exists(x_visit_id IN NUMBER)
  IS
    SELECT 'x'
    FROM   ahl_visit_tasks_b
    WHERE  visit_id = x_visit_id
    AND  STATUS_CODE = 'PLANNING';


  CURSOR c_get_wo_details(x_visit_id IN NUMBER)
  IS
    SELECT
        scheduled_start_date,
        SCHEDULED_COMPLETION_DATE
    FROM   wip_discrete_jobs
    WHERE wip_entity_id =
        (
         SELECT
         wip_entity_id
         FROM ahl_workorders
         WHERE
           master_workorder_flag = 'Y' AND
           visit_task_id IS null AND
           status_code not in (22,7) and
           visit_id=x_visit_id
          );

   c_get_wo_details_rec  c_get_wo_details%ROWTYPE;
   l_curr_task_id   NUMBER := 0;

  -- SATHAPLI::Bug 5758813, 04-Jun-2008
  -- Cursor to get the required format for the workorder description, given a visit task.
  CURSOR get_wo_dtls_for_mrtasks_cur (c_visit_task_id IN NUMBER) IS
  --TCHIMIRA::Bug 9149770 ::09-FEB-2010
  --use substrb and lengthb instead of substr and length respectively
  SELECT ar.route_no||'.'||SUBSTRB(ar.title, 1, (240 - (LENGTHB(ar.route_no) + 1))) workorder_description
    FROM ahl_routes_vl ar, ahl_visit_tasks_b avt,
         ahl_mr_routes mrr
   WHERE avt.visit_task_id         = c_visit_task_id
     AND NVL(avt.status_code, 'X') = 'PLANNING'
     AND avt.mr_route_id           = mrr.mr_route_id
     AND mrr.route_id              = ar.route_id;

  l_get_wo_dtls_rec get_wo_dtls_for_mrtasks_cur%ROWTYPE;

BEGIN
   --------------------- initialize -----------------------

  SAVEPOINT Push_MR_to_Production;

  IF (l_log_procedure >= l_log_current_level) THEN
    fnd_log.string(l_log_procedure,L_DEBUG_KEY||'.begin','At the begin of the procedure');
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF Fnd_Api.to_boolean(p_init_msg_list) THEN
    Fnd_Msg_Pub.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  -- Standard call to check for call compatibility.
  IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                     p_api_version,
                                     l_api_name,G_PKG_NAME) THEN
    RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (l_log_statement >= l_log_current_level) THEN
    fnd_log.string(l_log_statement,L_DEBUG_KEY,'p_unit_effectivity_id : '||p_unit_effectivity_id||'Visit Id : ' || p_visit_id);
  END IF;

  -- SKPATHAK :: Bug 9445455 :: 08-MAR-2010 :: START
  l_temp_msg_count := Fnd_Msg_Pub.count_msg;

  IF (l_log_statement >= l_log_current_level) THEN
     fnd_log.string(l_log_statement,
      L_DEBUG_KEY,
      'Before calling VALIDATE_MR_ROUTE_DATE. l_msg_count = ' || l_msg_count);
  END IF;

  OPEN c_task(p_visit_id, p_unit_effectivity_id);
  LOOP
      FETCH c_task INTO c_task_rec;
      EXIT WHEN c_task%NOTFOUND;
      Validate_MR_Route_Date
      (
          p_mr_route_id       => c_task_rec.mr_route_id,
          p_visit_task_number => c_task_rec.visit_task_number,
          p_start_date_time   => c_task_rec.start_date_time,
          p_end_date_time     => c_task_rec.end_date_time
      );

      IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
          L_DEBUG_KEY,
          'After calling VALIDATE_MR_ROUTE_DATE for task Id: ' ||
          c_task_rec.visit_task_id ||', l_msg_count = ' || l_msg_count);
      END IF;

  END LOOP;
  CLOSE c_task;

  l_msg_count := Fnd_Msg_Pub.count_msg;
  IF (l_msg_count <> l_temp_msg_count) THEN
     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
         L_DEBUG_KEY,
         'Errors from VALIDATE_MR_ROUTE_DATE. Message count: ' || l_msg_count);
     END IF;
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- SKPATHAK :: Bug 9445455 :: 08-MAR-2010 :: END

  --Create project tasks for the given MR
  IF (l_log_statement >= l_log_current_level) THEN
    fnd_log.string(l_log_statement,L_DEBUG_KEY,'Before calling Add_MR_to_Projects');
  END IF;

  Add_MR_to_Project
        (p_api_version       => l_api_version,
         p_init_msg_list     => p_init_msg_list,
         p_commit            => l_commit,
         p_validation_level  => p_validation_level,
         p_module_type       => p_module_type,
         p_visit_id          => p_visit_id,
         p_unit_effectivity_id => p_unit_effectivity_id,
         x_return_status     => l_return_status,
         x_msg_count         => l_msg_count,
         x_msg_data          => x_msg_data);

  IF (l_log_statement >= l_log_current_level) THEN
    fnd_log.string(l_log_statement,L_DEBUG_KEY,'After calling Add_MR_to_Projects - l_return_status : '||l_return_status);
  END IF;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    -- Check Error Message stack.
    x_msg_count := FND_MSG_PUB.count_msg;
    RAISE Fnd_Api.g_exc_error;
  END IF;

  OPEN c_visit (p_visit_id);
  FETCH c_visit INTO c_visit_rec;
  CLOSE c_visit;

  -- Create Workorders for MR tasks
  OPEN c_task_ct(p_visit_id, p_unit_effectivity_id);
  FETCH c_task_ct INTO l_count;
  CLOSE c_task_ct;

  IF (l_log_statement >= l_log_current_level) THEN
    fnd_log.string(l_log_statement,L_DEBUG_KEY, 'Task Count: ' || l_count);
  END IF;

  IF l_count > 0 THEN
    idx := 0;
    OPEN c_task(p_visit_id, p_unit_effectivity_id);
    FETCH c_task INTO c_task_rec;
    WHILE c_task%FOUND LOOP
      IF (l_curr_task_id <> c_task_rec.visit_task_id) THEN
        idx := idx+1;
        l_prd_workorder_tbl(idx).DML_OPERATION     := 'C';
        IF p_release_flag = 'Y' THEN
          l_prd_workorder_tbl(idx).STATUS_CODE  := '3';  -- Released
        ELSE
          l_prd_workorder_tbl(idx).STATUS_CODE  := '1';  -- Unreleased
        END IF;

        IF ( l_firm_planned_flag IS NOT NULL AND
        -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010
        -- For task with past task dates, WOs are always firm irrespective of the profile value
	-- Also for the NRs which have user entered past dates, WOs should always be firm
	-- SKPATHAK :: 26-FEB-2010
        -- Reverted back the changes for making past dated NR WOs as firmed
        c_task_rec.past_task_start_date IS NULL AND
	l_firm_planned_flag = '2' ) THEN
          l_prd_workorder_tbl(idx).FIRM_PLANNED_FLAG     := 2; -- Planned
        ELSE
          l_prd_workorder_tbl(idx).FIRM_PLANNED_FLAG     := 1; -- Firm
        END IF;

        IF ( c_task_rec.task_type_code = 'SUMMARY' ) THEN
          l_prd_workorder_tbl(idx).MASTER_WORKORDER_FLAG := 'Y';
        ELSE
          l_prd_workorder_tbl(idx).MASTER_WORKORDER_FLAG := 'N';
        END IF;

        l_prd_workorder_tbl(idx).BATCH_ID := c_visit_rec.visit_number;
        l_prd_workorder_tbl(idx).HEADER_ID := c_task_rec.visit_task_number;
        l_prd_workorder_tbl(idx).VISIT_ID          := p_visit_id;
        l_prd_workorder_tbl(idx).ORGANIZATION_ID   := c_visit_rec.organization_id;
        l_prd_workorder_tbl(idx).PROJECT_ID        := c_visit_rec.project_id;
        l_prd_workorder_tbl(idx).INVENTORY_ITEM_ID := c_task_rec.inventory_item_id ;
        l_prd_workorder_tbl(idx).ITEM_INSTANCE_ID  := c_task_rec.instance_id ;
        l_prd_workorder_tbl(idx).VISIT_TASK_ID     := c_task_rec.visit_task_id ;
        l_prd_workorder_tbl(idx).VISIT_TASK_NUMBER := c_task_rec.visit_task_number ;
        l_prd_workorder_tbl(idx).PROJECT_TASK_ID   := c_task_rec.project_task_id ;

        -- SATHAPLI::Bug 5758813, 04-Jun-2008, fix start
        -- For planned (route) tasks, set the workorder description  with the required format.
        -- l_prd_workorder_tbl(idx).JOB_DESCRIPTION   := c_task_rec.visit_task_name ;
        IF (c_task_rec.task_type_code IN ('SUMMARY','UNASSOCIATED')) THEN
          l_prd_workorder_tbl(idx).JOB_DESCRIPTION := c_task_rec.visit_task_name;
        ELSE
          -- Fetch the required format for the workorder description.
          OPEN get_wo_dtls_for_mrtasks_cur(c_task_rec.visit_task_id);
          FETCH get_wo_dtls_for_mrtasks_cur INTO l_get_wo_dtls_rec;
          CLOSE get_wo_dtls_for_mrtasks_cur;
          l_prd_workorder_tbl(idx).JOB_DESCRIPTION := l_get_wo_dtls_rec.workorder_description;
        END IF;
        -- SATHAPLI::Bug 5758813, 04-Jun-2008, fix end

        IF c_task_rec.mr_route_id IS NOT NULL AND c_task_rec.mr_route_id <> FND_API.g_miss_num THEN
          OPEN c_route (c_task_rec.mr_route_id);
          FETCH c_route INTO l_route_id;
          CLOSE c_route;
          l_prd_workorder_tbl(idx).ROUTE_ID := l_route_id ;
        ELSE
          l_prd_workorder_tbl(idx).ROUTE_ID := Null;
        END IF;

        IF c_task_rec.department_id IS NOT NULL
        AND c_task_rec.department_id <> FND_API.g_miss_num THEN
          l_prd_workorder_tbl(idx).DEPARTMENT_ID   := c_task_rec.department_id ;
        ELSE
          l_prd_workorder_tbl(idx).DEPARTMENT_ID   := c_visit_rec.department_id ;
        END IF;

        --If summary task, use the min,max for sub tasks
        IF (c_task_rec.task_type_code = 'SUMMARY') THEN
          OPEN get_summary_task_times_csr(c_task_rec.visit_task_id);
          FETCH get_summary_task_times_csr INTO l_prd_workorder_tbl(idx).SCHEDULED_START_DATE,
                                                l_prd_workorder_tbl(idx).SCHEDULED_END_DATE  ;
          CLOSE get_summary_task_times_csr;
        ELSE
          l_prd_workorder_tbl(idx).SCHEDULED_START_DATE  := c_task_rec.START_DATE_TIME;
          l_prd_workorder_tbl(idx).SCHEDULED_END_DATE    := c_task_rec.END_DATE_TIME;
        END IF;
        /*NR-MR Changes*/
        l_curr_task_id := c_task_rec.visit_task_id;
      END IF;
      FETCH c_task INTO c_task_rec;
    END LOOP;
    CLOSE c_task;
  END IF; -- l_count

  IF l_prd_workorder_tbl.COUNT > 0  THEN
    IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,L_DEBUG_KEY,'Before Getting MR Relationships ');
    END IF;

    Get_MR_Relationships
       (
         p_visit_id         => p_visit_id,
         p_visit_number     => c_visit_rec.visit_number,
         p_unit_effectivity_id  =>p_unit_effectivity_id,
         p_module_type       => p_module_type, /*NR-MR Changes - sowsubra*/
         p_x_relationship_tbl => l_prd_workorder_rel_tbl
       );

    IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,L_DEBUG_KEY,'After Getting MR Relationships ');
      fnd_log.string(l_log_statement,L_DEBUG_KEY,'Before Getting MR Dependencies ');
    END IF;

    Get_MR_Dependencies
       (
         p_visit_id           => p_visit_id,
         p_visit_number       => c_visit_rec.visit_number,
         p_unit_effectivity_id  =>p_unit_effectivity_id,
         p_module_type       => p_module_type, /*NR-MR Changes - sowsubra*/
         p_x_relationship_tbl => l_prd_workorder_rel_tbl
       );

    IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,L_DEBUG_KEY,'After Getting MR Dependencies ');
      fnd_log.string(l_log_statement,L_DEBUG_KEY,'Before calling AHL_PRD_WORKORDER_PVT.Process_Jobs ');
    END IF;

    AHL_PRD_WORKORDER_PVT.Process_Jobs
     (
          p_api_version          => p_api_version,
          p_init_msg_list        => p_init_msg_list,
          p_commit               => FND_API.G_FALSE,
          p_validation_level     => p_validation_level,
          p_default              => FND_API.G_TRUE,
          p_module_type          => p_module_type,
          x_return_status        => l_return_status,
          x_msg_count            => x_msg_count,
          x_msg_data             => x_msg_data,
          p_x_prd_workorder_tbl  => l_prd_workorder_tbl,
          p_prd_workorder_rel_tbl=> l_prd_workorder_rel_tbl
     );

    IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,L_DEBUG_KEY,'After calling AHL_PRD_WORKORDER_PVT.Process_Jobs - l_return_status : '||l_return_status);
    END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,L_DEBUG_KEY,'Errors from process_jobs API : ' || x_msg_count );
      END IF;
      RAISE Fnd_Api.g_exc_error;
    END IF;

    -- SATHAPLI::Bug 5758813, 04-Jun-2008, fix start
    -- Update the project tasks' (corresponding to the visit tasks) start and end date with those of the workorders' created above.
    IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement, l_debug_key, 'Before calling Update_Project_Task_Times.');
    END IF;

    Update_Project_Task_Times(
      p_prd_workorder_tbl => l_prd_workorder_tbl,
      p_commit            => 'F',
      x_return_status     => l_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data
    );

    IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement, l_debug_key, 'After calling Update_Project_Task_Times. x_return_status => '||x_return_status);
    END IF;

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- SATHAPLI::Bug 5758813, 04-Jun-2008, fix end
  END IF; -- To find if the visit has any tasks

  -- Update the status of all the tasks for this given UE to RELEASED
  OPEN c_task(p_visit_id, p_unit_effectivity_id);
  FETCH c_task INTO c_task_rec;
  WHILE c_task%FOUND
  LOOP
      UPDATE AHL_VISIT_TASKS_B
      SET STATUS_CODE = 'RELEASED',
          OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
          --TCHIMIRA::BUG 9222622 ::15-DEC-2009::UPDATE WHO COLUMNS
          LAST_UPDATE_DATE      = SYSDATE,
          LAST_UPDATED_BY       = Fnd_Global.USER_ID,
          LAST_UPDATE_LOGIN     = Fnd_Global.LOGIN_ID
      WHERE VISIT_ID = p_visit_id
      AND VISIT_TASK_ID = c_task_rec.visit_task_id
      AND STATUS_CODE = 'PLANNING';

      FETCH c_task INTO c_task_rec;
  END LOOP;
  CLOSE c_task;

  -- Update visit status to RELEASED only if no other change of the visit
  -- needs to be pushed to production
  OPEN c_visit_task_exists(c_visit_rec.visit_id);
  FETCH c_visit_task_exists INTO l_dummy;

  OPEN c_get_wo_details(c_visit_rec.visit_id);
  FETCH c_get_wo_details into c_get_wo_details_rec;
  IF (c_visit_task_exists%NOTFOUND and
  c_visit_rec.start_date_time = c_get_wo_details_rec.scheduled_start_date and
  c_visit_rec.close_date_time = c_get_wo_details_rec.scheduled_completion_date) THEN
      UPDATE ahl_visits_b
      SET status_code = 'RELEASED',
          object_version_number = object_version_number + 1,
          --TCHIMIRA::BUG 9222622 ::15-DEC-2009::UPDATE WHO COLUMNS
          LAST_UPDATE_DATE      = SYSDATE,
          LAST_UPDATED_BY       = Fnd_Global.USER_ID,
          LAST_UPDATE_LOGIN     = Fnd_Global.LOGIN_ID
      WHERE visit_id = c_visit_rec.visit_id;

      IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,L_DEBUG_KEY,'Before AHL_VWP_RULES_PVT.Update_Visit_Task_Flag Call');
      END IF;

      IF c_visit_rec.any_task_chg_flag = 'Y' THEN
          AHL_VWP_RULES_PVT.Update_Visit_Task_Flag
                (p_visit_id      => c_visit_rec.visit_id,
                 p_flag          => 'N',
                 x_return_status => x_return_status);
      END IF;

      IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,L_DEBUG_KEY,'After AHL_VWP_RULES_PVT.Update_Visit_Task_Flag Call');
      END IF;
  END IF;
  ---------------------------End of Body-------------------------------------
  -- Standard check of p_commit.
  IF Fnd_Api.To_Boolean (p_commit) THEN
    COMMIT WORK;
  END IF;

  Fnd_Msg_Pub.count_and_get(
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

  IF (l_log_procedure >= l_log_current_level) THEN
    fnd_log.string(l_log_procedure,L_DEBUG_KEY||'.end','At the end of plsql procedure');
  END IF;

EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Push_MR_to_Production;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Push_MR_to_Production;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Push_MR_to_Production;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
    THEN
         Fnd_Msg_Pub.add_exc_msg (G_PKG_NAME, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Push_MR_to_Production;

--------------------------------------------------------------------
-- PROCEDURE
--    Add_MR_to_Project
--
-- PURPOSE
--    To add Project Task for all the tasks for a given MR
--    when SR tasks are created in prodution
--------------------------------------------------------------------
PROCEDURE Add_MR_to_Project(
   p_api_version         IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit              IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level    IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type         IN  VARCHAR2  := Null,
   p_visit_id            IN  NUMBER,
   p_unit_effectivity_id IN  NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2
  )
IS
   L_API_VERSION  CONSTANT NUMBER := 1.0;
   L_API_NAME     CONSTANT VARCHAR2(30)  := 'Add_MR_to_Project';
   L_DEBUG_KEY    CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
   G_EXC_ERROR             EXCEPTION;
   l_msg_count             NUMBER;
   l_task_id               NUMBER;
   l_pa_project_id_out     NUMBER;
   l_msg_index_out         NUMBER;
   l_return_status         VARCHAR2(1);
   l_chk_project           VARCHAR2(1);
   l_proj_ref_flag         VARCHAR2(1);
   l_project_tsk_flag      VARCHAR2(1);
   l_msg_data              VARCHAR2(2000);
   l_pa_project_number_out VARCHAR2(25);
   l_commit                VARCHAR2(1) := 'F';
   l_init_msg_list         VARCHAR2(1) := 'F';

    -- To find visit related information
   CURSOR c_visit (x_id IN NUMBER) IS
    SELECT * FROM AHL_VISITS_VL
    WHERE VISIT_ID = x_id;
   c_visit_rec c_visit%ROWTYPE;

   -- To get all the tasks for the given UE
   CURSOR c_task (x_visit_id IN NUMBER, x_unit_effectivity_id IN NUMBER) IS
   -- SKPATHAK :: Bug 8340436 :: 23-MAR-2009
    -- Fetch distinct rows to avoid duplicates
    -- Select individual cols instead of *
    --SELECT * FROM AHL_VISIT_TASKS_VL
    SELECT distinct visit_task_id, originating_task_id, visit_id, unit_effectivity_id,
           status_code, service_request_id, project_task_id, visit_task_number,
           visit_task_name, description, object_version_number, start_date_time,
           end_date_time
      FROM AHL_VISIT_TASKS_VL
    WHERE VISIT_ID = x_visit_id
    AND NVL( STATUS_CODE, 'X' ) = 'PLANNING'
    START WITH unit_effectivity_id  = x_unit_effectivity_id
        AND (( originating_task_id is null AND 'SR' <> p_module_type)
	-- SKPATHAK :: Bug #9410052 :: 25-FEB-2010 :: Removed the condition "originating_task_id is not null"
            OR ( 'SR' = p_module_type
                 and service_request_id is not null))
    CONNECT BY originating_task_id = PRIOR visit_task_id;

   c_task_rec c_task%ROWTYPE;
   l_curr_task_id   NUMBER := 0;

   -- SATHAPLI::Bug 5758813, 04-Jun-2008
   -- Cursor to get the required format used for the project task name and description, given a visit task.
   -- First part of the UNION is for the planned tasks (routes) attached to the NR.
   -- Second part is for the corresponding NR and MR summary tasks.
   CURSOR get_prj_task_dtls_cur (c_visit_task_id IN NUMBER) IS
   SELECT SUBSTR(NVL(ar.route_no, avt.visit_task_name), 1, 20) task_name,
          SUBSTR(NVL(ar.title, avt.visit_task_name), 1, 250) description
     FROM ahl_routes_vl ar, ahl_visit_tasks_vl avt,
          ahl_mr_routes mrr
    WHERE avt.visit_task_id         = c_visit_task_id
      AND NVL(avt.status_code, 'X') = 'PLANNING'
      AND avt.task_type_code        NOT IN ('SUMMARY', 'UNASSOCIATED')
      AND avt.mr_route_id           = mrr.mr_route_id (+)
      AND mrr.route_id              = ar.route_id (+)
   UNION ALL
   SELECT SUBSTR(NVL(amh.title, avt.visit_task_name), 1, 20) task_name,
          NVL(amh.title, avt.visit_task_name) description
     FROM ahl_mr_headers_v amh, ahl_visit_tasks_vl avt
    WHERE avt.visit_task_id         = c_visit_task_id
      AND NVL(avt.status_code, 'X') = 'PLANNING'
      AND avt.task_type_code        = 'SUMMARY'
      AND avt.summary_task_flag     = 'N'
      AND avt.mr_id                 = amh.mr_header_id (+);

   l_get_prj_task_dtls_cur_rec get_prj_task_dtls_cur%ROWTYPE;

BEGIN
   --------------------- initialize -----------------------
  SAVEPOINT Add_MR_to_Project;

  IF (l_log_procedure >= l_log_current_level) THEN
    fnd_log.string(l_log_procedure,L_DEBUG_KEY||'.begin','At the start of plsql procedure');
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF Fnd_Api.to_boolean(p_init_msg_list) THEN
    Fnd_Msg_Pub.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  -- Standard call to check for call compatibility.
  IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME) THEN
    RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (l_log_statement >= l_log_current_level) THEN
    fnd_log.string(l_log_statement,L_DEBUG_KEY,'Unit Effectivity ID = ' || p_unit_effectivity_id);
  END IF;

  ----------------------------------------- Start of Body ----------------------------------
  -- To check Project responsibilites

  -- Begin changes by jaramana on Mar 4, 2008 for bug 6788115 (FP of 6759574)
  -- As per update from ravichandran.velusamy in Projects team in the bug 6759574,
  -- the call to PA_INTERFACE_UTILS_PUB.Set_Global_Info may be removed.
  -- AHL_VWP_RULES_PVT.Check_Proj_Responsibility calls PA_INTERFACE_UTILS_PUB.Set_Global_Info
/***
  AHL_VWP_RULES_PVT.Check_Proj_Responsibility
           (x_check_project    => l_chk_project,
            x_return_status    => l_return_status);

  IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
    x_return_status := l_return_status;
    RAISE G_EXC_ERROR;
  END IF;

***/
  l_chk_project := 'Y';
  -- End changes by jaramana on Mar 4, 2008 for bug 6788115 (FP of 6759574)

  IF (l_log_statement >= l_log_current_level) THEN
    fnd_log.string(l_log_statement,L_DEBUG_KEY,'l_chk_project = ' || l_chk_project);
  END IF;

  IF l_chk_project = 'Y' THEN
    ----------------------------------------- Cursor ----------------------------------
    OPEN c_Visit(p_visit_id);
    FETCH c_visit INTO c_visit_rec;
    CLOSE c_Visit;

    OPEN c_task(p_visit_id, p_unit_effectivity_id);
    FETCH c_task INTO c_task_rec;
    WHILE c_task%FOUND
    LOOP
      IF ((c_task_rec.PROJECT_TASK_ID IS NULL)  AND (l_curr_task_id <> c_task_rec.visit_task_id))THEN
        IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,L_DEBUG_KEY, 'Inside Loop: c_task_rec.visit_task_number = ' || c_task_rec.visit_task_number ||
                ', c_task_rec.visit_task_id = ' || c_task_rec.visit_task_id ||
                ', c_task_rec.originating_task_id = ' || c_task_rec.originating_task_id ||
                ', c_task_rec.unit_effectivity_id = ' || c_task_rec.unit_effectivity_id ||
                ', c_task_rec.service_request_id = ' || c_task_rec.service_request_id);
        END IF;
        IF (l_log_statement >= l_log_current_level) THEN

          fnd_log.string(l_log_statement,L_DEBUG_KEY,'Before calling PA_PROJECT_PUB.Check_Unique_Task_Number');
        END IF;

        PA_PROJECT_PUB.Check_Unique_Task_Number
          ( p_api_version_number      => 1,
            p_init_msg_list           => l_init_msg_list,
            p_return_status           => l_return_status,
            p_msg_count               => l_msg_count,
            p_msg_data                => l_msg_data,
            p_project_id              => c_visit_rec.project_id,
            p_pm_project_reference    => c_visit_rec.visit_number,
            p_task_number             => c_task_rec.visit_task_number,
            p_unique_task_number_flag => l_project_tsk_flag
          ) ;

        IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,L_DEBUG_KEY,'After calling PA_PROJECT_PUB.Check_Unique_Task_Number - l_project_tsk_flag : '|| l_project_tsk_flag);
          fnd_log.string(l_log_statement,L_DEBUG_KEY,'Before calling PA_PROJECT_PUB.Check_Unique_Task_Reference');
        END IF;

        PA_PROJECT_PUB.Check_Unique_Task_Reference
         ( p_api_version_number      => 1,
           p_init_msg_list        => l_init_msg_list,
           p_return_status        => l_return_status,
           p_msg_count          => l_msg_count,
           p_msg_data          => l_msg_data,
           p_project_id             => c_visit_rec.project_id,
           p_pm_project_reference  => c_visit_rec.visit_number,
           p_pm_task_reference      => c_task_rec.visit_task_number,
           p_unique_task_ref_flag  => l_proj_ref_flag
         );

        IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,L_DEBUG_KEY,'After calling PA_PROJECT_PUB.Check_Unique_Task_Reference  - l_proj_ref_flag = ' || l_proj_ref_flag);
        END IF;

        IF l_project_tsk_flag = 'Y' AND l_proj_ref_flag = 'Y' THEN
          IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,L_DEBUG_KEY,'Before calling PA_PROJECT_PUB.ADD_TASK');
             fnd_log.string(l_log_statement,L_DEBUG_KEY,'c_visit_rec.PROJECT_ID=:' || c_visit_rec.PROJECT_ID);
             fnd_log.string(l_log_statement,L_DEBUG_KEY,'c_visit_rec.VISIT_NUMBER=:' || c_visit_rec.VISIT_NUMBER);
             fnd_log.string(l_log_statement,L_DEBUG_KEY,'c_task_rec.VISIT_TASK_NUMBER=:' || c_task_rec.VISIT_TASK_NUMBER);
             fnd_log.string(l_log_statement,L_DEBUG_KEY,'c_task_rec.VISIT_TASK_NAME=:' || c_task_rec.VISIT_TASK_NAME);
             fnd_log.string(l_log_statement,L_DEBUG_KEY,'c_task_rec.DESCRIPTION=:' || c_task_rec.DESCRIPTION);
          END IF;

          -- SATHAPLI::Bug 5758813, 04-Jun-2008 - Fetch the required format for the project task's name and description.
          OPEN get_prj_task_dtls_cur(c_task_rec.visit_task_id);
          FETCH get_prj_task_dtls_cur INTO l_get_prj_task_dtls_cur_rec;
          CLOSE get_prj_task_dtls_cur;

          PA_PROJECT_PUB.ADD_TASK
               (p_api_version_number      => 1
               ,p_commit                  => l_commit
               ,p_init_msg_list           => l_init_msg_list
               ,p_msg_count               => l_msg_count
               ,p_msg_data                => l_msg_data
               ,p_return_status           => l_return_status
               ,p_pm_product_code         => G_PM_PRODUCT_CODE
               -- yazhou 26Sept2005 starts
               -- ER#4618348
               -- ,p_pm_project_reference => c_task_rec.VISIT_NUMBER
               -- yazhou 26Sept2005 ends
               ,p_pa_project_id           => c_visit_rec.PROJECT_ID
               ,p_pm_task_reference       => c_task_rec.VISIT_TASK_NUMBER
               ,p_pa_task_number          => c_task_rec.VISIT_TASK_NUMBER
               -- SATHAPLI::Bug 5758813, 04-Jun-2008 - fix start
               -- Set the task name and description with the required format. Set the task start and end date too.
               -- ,p_task_name               => SUBSTR( c_task_rec.VISIT_TASK_NAME , 1,15)
               -- ,p_task_description        => c_task_rec.DESCRIPTION
               ,p_task_name               => l_get_prj_task_dtls_cur_rec.task_name
               ,p_task_description        => l_get_prj_task_dtls_cur_rec.description
               ,p_task_start_date         => trunc(c_task_rec.start_date_time)
               ,p_task_completion_date    => trunc(c_task_rec.end_date_time)
               -- SATHAPLI::Bug 5758813, 04-Jun-2008 - fix end
               ,p_pa_project_id_out       => l_pa_project_id_out
               ,p_pa_project_number_out   => l_pa_project_number_out
               ,p_task_id                 => l_task_id
                );

          IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,L_DEBUG_KEY,'After calling PA_PROJECT_PUB.ADD_TASK -  l_return_status : '||l_return_status);
          END IF;

          IF (l_return_status <> 'S') THEN
            IF (fnd_msg_pub.count_msg > 0 ) THEN
              FOR i IN 1..fnd_msg_pub.count_msg
              LOOP
                fnd_msg_pub.get(p_msg_index => i,
                                p_encoded   => 'F',
                                p_data      => l_msg_data,
                                p_msg_index_out => l_msg_index_out);
                IF (l_log_statement >= l_log_current_level) THEN
                  fnd_log.string(l_log_statement,L_DEBUG_KEY,': Error' ||l_msg_data);
                END IF;
              END LOOP;
            ELSE
              IF (l_log_statement >= l_log_current_level) THEN
                fnd_log.string(l_log_statement,L_DEBUG_KEY,': Another Error ='||l_msg_data);
              END IF;
            END IF;
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
          END IF;

          IF l_return_status = 'S' THEN
            /*NR-MR Changes - added this to ensure that duplicates are not passed*/
            l_curr_task_id := c_task_rec.visit_task_id;
            UPDATE AHL_VISIT_TASKS_B SET PROJECT_TASK_ID = l_task_id,
                   OBJECT_VERSION_NUMBER = c_task_rec.object_version_number + 1,
                   --TCHIMIRA::BUG 9222622 ::15-DEC-2009::UPDATE WHO COLUMNS
                   LAST_UPDATE_DATE      = SYSDATE,
                   LAST_UPDATED_BY       = Fnd_Global.USER_ID,
                   LAST_UPDATE_LOGIN     = Fnd_Global.LOGIN_ID
            WHERE VISIT_TASK_ID = c_task_rec.visit_task_id;
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string(l_log_statement,L_DEBUG_KEY,'Updated AHL_VISIT_TASKS_B: c_task_rec.visit_task_number = ' || c_task_rec.visit_task_number ||
                    ', c_task_rec.visit_task_id = ' || c_task_rec.visit_task_id ||
                    ', c_task_rec.originating_task_id = ' || c_task_rec.originating_task_id ||
                        ', c_task_rec.unit_effectivity_id = ' || c_task_rec.unit_effectivity_id ||
                    ', c_task_rec.service_request_id = ' || c_task_rec.service_request_id);
            END IF;

          END IF;
        ELSIF l_project_tsk_flag = 'N' AND l_proj_ref_flag = 'Y' THEN
          x_return_status := Fnd_Api.g_ret_sts_error;
          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
             Fnd_Message.set_name ('AHL', 'AHL_VWP_PROJ_TSK_REF_NOT_UNIQ');
             Fnd_Msg_Pub.ADD;
          END IF;
        ELSIF l_project_tsk_flag = 'Y' AND l_proj_ref_flag = 'N' THEN
          x_return_status := Fnd_Api.g_ret_sts_error;
          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
            Fnd_Message.set_name ('AHL', 'AHL_VWP_PROJ_TSK_NUM_NOT_UNIQ');
            Fnd_Msg_Pub.ADD;
          END IF;
        ELSE
          x_return_status := Fnd_Api.g_ret_sts_error;
          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
            Fnd_Message.set_name ('AHL', 'AHL_VWP_PROJ_TASK_NOT_UNIQUE');
            Fnd_Msg_Pub.ADD;
          END IF;
        END IF;
      END IF;  -- project_task_id is null
      FETCH c_task INTO c_task_rec;
    END LOOP;
    CLOSE c_task;
  END IF; -- l_chk_project
  ---------------------------End of Body-------------------------------------
  -- Standard check of p_commit.

  IF Fnd_Api.To_Boolean ( p_commit ) THEN
     COMMIT WORK;
  END IF;

  Fnd_Msg_Pub.count_and_get(
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

  IF (l_log_procedure >= l_log_current_level) THEN
    fnd_log.string(l_log_procedure,L_DEBUG_KEY||'.end','At the end of plsql procedure');
  END IF;

EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Add_MR_to_Project;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Add_MR_to_Project;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Add_MR_to_Project;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
    THEN
         Fnd_Msg_Pub.add_exc_msg (G_PKG_NAME, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Add_MR_to_Project;

-- AnRaj: Added as part of Material Requirement Aggrgation Enhancement, Bug#5303378
-- Call aggregate_material_requirements for a visit
-- If a visit task has more than one requirement for the same item, then this method will aggregate
-- all those requirements into a single requirement
PROCEDURE Aggregate_Material_Reqrs
          (p_api_version      IN         NUMBER,
           p_init_msg_list    IN         VARCHAR2,
           p_commit           IN         VARCHAR2,
           p_validation_level IN         NUMBER,
           p_module_type      IN         VARCHAR2,
           p_visit_id         IN         NUMBER,
           x_return_status    OUT NOCOPY VARCHAR2,
           x_msg_count        OUT NOCOPY NUMBER,
           x_msg_data         OUT NOCOPY VARCHAR2
          )
IS
   -- get all tasks in planning status for a visit
   CURSOR   get_visit_tasks_cur(c_visit_id NUMBER) IS
    SELECT visit_task_id
    FROM ahl_visit_tasks_b
    WHERE visit_id = c_visit_id
     AND NVL(status_code,'X') = 'PLANNING';

   -- Declare local variables
   l_api_version  CONSTANT NUMBER        := 1.0;
   l_api_name     CONSTANT VARCHAR2(30)  := 'Aggregate_Material_Reqrs';
   L_DEBUG_KEY    CONSTANT VARCHAR2(100) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;
   l_init_msg_list         VARCHAR2(1)   := 'F';
   l_return_status         VARCHAR2(1);
   l_msg_count             NUMBER;
   l_msg_data              VARCHAR2(2000);
   l_visit_task_id         NUMBER;
   l_reservation_id        NUMBER;
   l_scheduled_matrial_id  NUMBER;
   l_previous_item         NUMBER := NULL;

BEGIN
   -- Standard start of API savepoint
   SAVEPOINT AGGREGATE_MATERIAL_REQRS;

   -- Initialize return status to success before any code logic/validation
   x_return_status:= FND_API.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version, p_api_version, l_api_name, G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list = FND_API.G_TRUE
   IF FND_API.TO_BOOLEAN(p_init_msg_list)
   THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY,
                     'At the start of PL SQL procedure. Visit Id = ' || p_visit_id);
   END IF;

   OPEN get_visit_tasks_cur(p_visit_id);
   LOOP
      FETCH get_visit_tasks_cur INTO l_visit_task_id;
      EXIT WHEN get_visit_tasks_cur%NOTFOUND;
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Before calling AGGREGATE_TASK_MATERIAL_REQRS for Visit Task Id: ' || l_visit_task_id);
      END IF;

      AHL_VWP_PROJ_PROD_PVT.Aggregate_Task_Material_Reqrs
        (p_api_version      => p_api_version,
         p_init_msg_list    => p_init_msg_list,
         p_commit           => p_commit,
         p_validation_level => p_validation_level,
         p_module_type      => p_module_type,
         p_task_id          => l_visit_task_id,
         p_rel_tsk_flag     => 'N',
         x_return_status    => l_return_status,
         x_msg_count        => l_msg_count,
         x_msg_data         => l_msg_data
        );

      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'After calling AGGREGATE_TASK_MATERIAL_REQRS for Visit Task Id: ' ||
                        l_visit_task_id || '. Return Status = '|| l_return_status);
      END IF;

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_msg_count := FND_MSG_PUB.count_msg;
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Errors from AGGREGATE_TASK_MATERIAL_REQRS. Message count: ' || x_msg_count);
         END IF;
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

   END LOOP;
   CLOSE get_visit_tasks_cur;
END Aggregate_Material_Reqrs;

-------------------------------------------------------------------
--  Procedure name : Aggregate_Task_Material_Reqrs
--  Type           : Private
--  Function       : Find the total requirment of a specific
--                   item at the task level
--  Parameters     :
--
--  Standard OUT Parameters :
--      x_return_status OUT  VARCHAR2 Required
--      x_msg_count     OUT  NUMBER   Required
--      x_msg_data      OUT  VARCHAR2 Required
--
--  Aggregate_Task_Material_Reqrs Parameters:
--      p_task_id       IN   NUMBER   Required
--
--  Version :
--      30 November, 2007  RNAHATA  Initial Version - 1.0
-------------------------------------------------------------------
PROCEDURE Aggregate_Task_Material_Reqrs
    (p_api_version      IN         NUMBER,
     p_init_msg_list    IN         VARCHAR2,
     p_commit           IN         VARCHAR2,
     p_validation_level IN         NUMBER,
     p_module_type      IN         VARCHAR2,
     p_task_id          IN         NUMBER,
     p_rel_tsk_flag     IN         VARCHAR2 := 'Y',
     x_return_status    OUT NOCOPY VARCHAR2,
     x_msg_count        OUT NOCOPY NUMBER,
     x_msg_data         OUT NOCOPY VARCHAR2
    )
IS
   -- Cursor to get the duplicate material requirements
   CURSOR get_material_reqrs_cur(c_visit_task_id NUMBER) IS
    SELECT UNIQUE asmt1.scheduled_material_id,
           asmt1.visit_id,
           asmt1.visit_task_id,
           asmt1.inventory_item_id,
           asmt1.requested_quantity,
           asmt1.scheduled_quantity,
           asmt1.rt_oper_material_id,
           asmt1.item_group_id
    FROM ahl_schedule_materials asmt1,
         ahl_Schedule_materials asmt2
    WHERE asmt1.visit_id = asmt2.visit_id
     AND asmt1.visit_task_id = asmt2.visit_task_id
     AND asmt1.inventory_item_id = asmt2.inventory_item_id
     AND NVL(asmt1.operation_code,'X') = NVL(asmt2.operation_code,'X')
     AND asmt1.scheduled_material_id <> asmt2.scheduled_material_id
     AND NVL(asmt1.status,'X') = 'ACTIVE'
     AND NVL(asmt2.status,'X') = 'ACTIVE'
     AND asmt1.visit_task_id = c_visit_task_id
    ORDER BY asmt1.inventory_item_id;
   l_material_reqrs_rec       get_material_reqrs_cur%ROWTYPE;

   CURSOR check_reservation_exist (c_scheduled_material_id IN NUMBER) IS
    SELECT reservation_id
    FROM mtl_reservations
    WHERE demand_source_line_detail = c_scheduled_material_id
     AND external_source_code = 'AHL';

   -- Declare local variables
   L_API_NAME    CONSTANT VARCHAR2(30)  := 'Aggregate_Task_Material_Reqrs';
   l_api_version CONSTANT NUMBER        := 1.0;
   L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
   l_init_msg_list        VARCHAR2(1)   := 'F';
   l_reservation_id       NUMBER;
   l_scheduled_matrial_id NUMBER;
   l_previous_item        NUMBER := NULL;

BEGIN
   -- Initialize return status to success before any code logic/validation
   x_return_status:= FND_API.G_RET_STS_SUCCESS;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Visit Task Id = ' || p_task_id);
   END IF;

   -- Standard call to check for call compatibility
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version, p_api_version, l_api_name, G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list = FND_API.G_TRUE
   IF FND_API.TO_BOOLEAN(p_init_msg_list)
   THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

   -- initialize the counter
   l_previous_item := NULL;

   -- For each task in status planning, get details if there mutiple requirements for the same item
   OPEN  get_material_reqrs_cur(p_task_id);
   LOOP
       FETCH get_material_reqrs_cur INTO l_material_reqrs_rec;
       EXIT  WHEN get_material_reqrs_cur%NOTFOUND;

       IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'Fetching Material Requirements for task.');
       END IF;

       IF l_previous_item IS NULL THEN
       -- if the first duplicate occurance for a task
          l_scheduled_matrial_id := l_material_reqrs_rec.scheduled_material_id;
          IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'First Requirement Id: ' || l_scheduled_matrial_id);
          END IF;
       ELSIF l_previous_item = l_material_reqrs_rec.inventory_item_id THEN
       -- merge the records
          IF p_rel_tsk_flag = 'Y' THEN
             OPEN  check_reservation_exist(l_material_reqrs_rec.scheduled_material_id);
             FETCH check_reservation_exist INTO l_reservation_id;
             IF check_reservation_exist%FOUND THEN

                IF (l_log_statement >= l_log_current_level) THEN
                   fnd_log.string(l_log_statement,
                                  L_DEBUG_KEY,
                                  'Before calling AHL_RSV_RESERVATIONS_PVT.TRNSFR_RSRV_FOR_MATRL_REQR');
                   fnd_log.string(l_log_statement,
                                  L_DEBUG_KEY,
                                  'l_material_reqrs_rec.scheduled_material_id->' || l_material_reqrs_rec.scheduled_material_id);
                   fnd_log.string(l_log_statement,
                                  L_DEBUG_KEY,'l_scheduled_matrial_id->' || l_scheduled_matrial_id);
                END IF;

                -- Call Transfer reservations
                AHL_RSV_RESERVATIONS_PVT.TRNSFR_RSRV_FOR_MATRL_REQR
                  (p_api_version     => l_api_version,
                   p_init_msg_list   => l_init_msg_list,
                   p_module_type     => p_module_type,
                   x_msg_count       => x_msg_count,
                   x_msg_data        => x_msg_data,
                   x_return_status   => x_return_status,
                   p_visit_task_id   => p_task_id,
                   p_from_mat_req_id => l_material_reqrs_rec.scheduled_material_id,
                   p_to_mat_req_id   => l_scheduled_matrial_id
                  );

                IF (l_log_statement >= l_log_current_level) THEN
                   fnd_log.string(l_log_statement,
                                  L_DEBUG_KEY,
                                  'After calling AHL_RSV_RESERVATIONS_PVT.TRNSFR_RSRV_FOR_MATRL_REQR. Return Status = '||
                                  x_return_status);
                END IF;

                IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                   x_msg_count := FND_MSG_PUB.count_msg;
                   IF (l_log_statement >= l_log_current_level) THEN
                      fnd_log.string(l_log_statement,
                                     L_DEBUG_KEY,
                                     'Errors from AHL_RSV_RESERVATIONS_PVT.TRNSFR_RSRV_FOR_MATRL_REQR. Message count: ' || x_msg_count);
                   END IF;
                   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                      RAISE FND_API.G_EXC_ERROR;
                   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
                END IF;
             END IF;
          END IF;

          IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'Updating ahl_schedule_materials with new Material Requirements');
          END IF;

          -- Add the requirements into the first record
          UPDATE ahl_schedule_materials
          SET scheduled_quantity = NVL(scheduled_quantity,0) + NVL(l_material_reqrs_rec.scheduled_quantity,0),
              item_group_id = NVL(item_group_id,l_material_reqrs_rec.item_group_id),
              requested_quantity = NVL(requested_quantity,0) +  NVL(l_material_reqrs_rec.requested_quantity,0)
          WHERE scheduled_material_id = l_scheduled_matrial_id;

          IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'Deleting the old material requirements from table ahl_schedule_materials ');
          END IF;

          -- Mark the current row as deleted
          UPDATE ahl_Schedule_materials
          SET status = 'DELETED',requested_quantity = 0
          WHERE scheduled_material_id = l_material_reqrs_rec.scheduled_material_id;

       ELSE -- New duplicate inventory item id as material req
          l_scheduled_matrial_id := l_material_reqrs_rec.scheduled_material_id;
          IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'New Duplicate Inventory Item Id. Requirement Id: ' || l_scheduled_matrial_id ||
                            ', Item Id: ' || l_material_reqrs_rec.inventory_item_id);
          END IF;
       END IF; -- not the same item
       -- make the current item the previous item, before reading the next record
       l_previous_item := l_material_reqrs_rec.inventory_item_id;
   END LOOP;
   CLOSE get_material_reqrs_cur;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status =' || x_return_status);
   END IF;

END Aggregate_Task_Material_Reqrs;

-------------------------------------------------------------------
--  Procedure name    : Update_Project_Task_Times
--  Type              : Private
--  Function          : Update the project task start/end dates
--                      with the workorder schedule start/end dates
--  Parameters :
--  Standard IN Parameters :
--      p_commit                  IN      VARCHAR2 Fnd_Api.G_FALSE
--
--  Update_Project_Task_Times Parameters
--      p_prd_workorder_tbl       IN      AHL_PRD_WORKORDER_PVT.PRD_WORKORDER_TBL Required
--
--  Standard OUT Parameters :
--      x_return_status           OUT     VARCHAR2     Required
--      x_msg_count               OUT     NUMBER       Required
--      x_msg_data                OUT     VARCHAR2     Required
--
--  Version :
--      04 January, 2007          Bug#5758813 SOWSUBRA  Initial Version - 1.0
-------------------------------------------------------------------
PROCEDURE Update_Project_Task_Times
(   p_prd_workorder_tbl IN AHL_PRD_WORKORDER_PVT.PRD_WORKORDER_TBL,
    p_commit            IN VARCHAR2  := Fnd_Api.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
)
AS

l_task_in_tbl      PA_PROJECT_PUB.TASK_IN_TBL_TYPE;
task_index         NUMBER;
idx                NUMBER;
l_project_rec      PA_PROJECT_PUB.PROJECT_IN_REC_TYPE;
L_API_NAME         CONSTANT VARCHAR2(30) := 'Update_Project_Task_Times';
L_DEBUG_KEY        CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
l_msg_count        NUMBER;
l_msg_data         VARCHAR2(2000);
l_return_status    VARCHAR2(1);
l_task_out         PA_PROJECT_PUB.TASK_OUT_TBL_TYPE;
l_workflow_started VARCHAR2(1);
l_key_members      PA_PROJECT_PUB.PROJECT_ROLE_TBL_TYPE;
l_class_categories PA_PROJECT_PUB.CLASS_CATEGORY_TBL_TYPE;
l_project_out      PA_PROJECT_PUB.PROJECT_OUT_REC_TYPE;


--fetches the schedule start and completion date of workorder
CURSOR get_wo_schedule_dates_cur(p_wo_id IN NUMBER) IS
 SELECT WDJ.SCHEDULED_START_DATE, WDJ.SCHEDULED_COMPLETION_DATE
 FROM WIP_DISCRETE_JOBS WDJ, AHL_WORKORDERS WO
 WHERE WDJ.WIP_ENTITY_ID = WO.WIP_ENTITY_ID AND
       WO.WORKORDER_ID   = p_wo_id;
get_wo_schedule_dates_rec  get_wo_schedule_dates_cur%ROWTYPE;

--fetches project task id, the task start and end date of visit task
CURSOR get_task_dates_cur(p_wo_id IN NUMBER) IS
 SELECT AVT.PROJECT_TASK_ID, AVT.START_DATE_TIME, AVT.END_DATE_TIME,
        PAT.DESCRIPTION  -- Pass the old description back again
 FROM AHL_VISIT_TASKS_B AVT, AHL_WORKORDERS WO,
      PA_TASKS PAT
 WHERE WO.VISIT_TASK_ID = AVT.VISIT_TASK_ID AND
       WO.WORKORDER_ID  = p_wo_id AND
       PAT.TASK_ID (+) = AVT.PROJECT_TASK_ID;
get_task_dates_rec  get_task_dates_cur%ROWTYPE;

--fetch the project id, visit start date and visit end date
CURSOR get_visit_details_cur (p_wo_id IN NUMBER) IS
 SELECT av.visit_id, av.project_id, av.start_date_time, av.close_date_time
 FROM ahl_workorders wo, ahl_visits_b av
 WHERE WO.WORKORDER_ID  = p_wo_id
  AND wo.visit_id = av.visit_id;
  -- Changed by jaramana on 11-NOV-2009 for bug 9109020
  --AND wo.visit_task_id IS NULL
  --AND wo.master_workorder_flag = 'Y';
visit_details_rec get_visit_details_cur%ROWTYPE;

BEGIN
   -- Initialize return status to success before any code logic/validation
   x_return_status:= FND_API.G_RET_STS_SUCCESS;

   IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.begin',
                      'At the start of PL SQL procedure. p_prd_workorder_tbl.COUNT = ' || p_prd_workorder_tbl.COUNT);
    END IF;
   --for each workorder get the schduled start/end time
   IF p_prd_workorder_tbl.count > 0 THEN
      task_index := 1;
      FOR idx IN p_prd_workorder_tbl.FIRST..p_prd_workorder_tbl.LAST
      LOOP
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Workorder Id(' || idx || '): ' || p_prd_workorder_tbl(idx).workorder_id);
         END IF;

         OPEN get_wo_schedule_dates_cur(p_prd_workorder_tbl(idx).workorder_id);
         FETCH get_wo_schedule_dates_cur INTO get_wo_schedule_dates_rec;
         CLOSE get_wo_schedule_dates_cur;

         OPEN get_task_dates_cur(p_prd_workorder_tbl(idx).workorder_id);
         FETCH get_task_dates_cur INTO get_task_dates_rec;
         CLOSE get_task_dates_cur;

         --update the task start and end dates with workorder scheduled start/end dates.
         IF ((get_wo_schedule_dates_rec.scheduled_start_date <> get_task_dates_rec.start_date_time) OR
             (get_wo_schedule_dates_rec.scheduled_completion_date <> get_task_dates_rec.end_date_time)) THEN
            l_task_in_tbl(task_index).pa_task_id           := get_task_dates_rec.project_task_id;
            --Fix for the Bug 7009212; rnahata truncated the task times
            l_task_in_tbl(task_index).task_start_date      := trunc(get_wo_schedule_dates_rec.scheduled_start_date);
            l_task_in_tbl(task_index).task_completion_date := trunc(get_wo_schedule_dates_rec.scheduled_completion_date);
            --rnahata End
            -- jaramana Jan 5, 2005: Due to some reason, the task's Description does not get retained
            -- but gets corrupted if not passed (or left default at PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
            l_task_in_tbl(task_index).TASK_DESCRIPTION     := get_task_dates_rec.description;

            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'task_index = ' || task_index);
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'pa_task_id = '|| l_task_in_tbl(task_index).pa_task_id);
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'task_start_date = ' || l_task_in_tbl(task_index).task_start_date);
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'task_completion_date = ' || l_task_in_tbl(task_index).task_completion_date);
            END IF;
            task_index := task_index + 1;
         END IF;  -- Dates are not same
      END LOOP;
   END IF;  -- p_prd_workorder_tbl.count > 0

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'l_task_in_tbl.count = ' || l_task_in_tbl.count);
   END IF;
   --update the project header also with the visit start/end times.
   IF l_task_in_tbl.count > 0 THEN
      OPEN get_visit_details_cur(p_prd_workorder_tbl(p_prd_workorder_tbl.FIRST).workorder_id);
      FETCH get_visit_details_cur INTO visit_details_rec;
      CLOSE get_visit_details_cur;

      l_project_rec.PA_PROJECT_ID        := visit_details_rec.project_id;
      --Fix for the Bug 7009212; rnahata truncated the task times
      l_project_rec.START_DATE           := trunc(visit_details_rec.start_date_time);
      l_project_rec.COMPLETION_DATE      := trunc(visit_details_rec.close_date_time);
      l_project_rec.SCHEDULED_START_DATE := trunc(visit_details_rec.start_date_time);
      --rnahata End
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Before calling PA_PROJECT_PUB.update_project');
      END IF;

      --Now call update_project api to update the values in projects table
      PA_PROJECT_PUB.UPDATE_PROJECT(
            p_api_version_number => 1,
            p_commit             => p_commit,
            p_msg_count          => l_msg_count,
            p_msg_data           => l_msg_data,
            p_return_status      => l_return_status,
            p_workflow_started   => l_workflow_started,
            p_pm_product_code    => G_PM_PRODUCT_CODE,
            p_project_in         => l_project_rec,
            p_project_out        => l_project_out,
            p_key_members        => l_key_members,
            p_class_categories   => l_class_categories,
            p_tasks_in           => l_task_in_tbl,
            p_tasks_out          => l_task_out);

      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'After calling PA_PROJECT_PUB.update_project. Return Status = ' || l_return_status);
      END IF;

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Errors from PA_PROJECT_PUB.update_project. Message count: ' ||
                          l_msg_count || ', message data: ' || l_msg_data);
         END IF;
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;  -- Return Status is not success
   END IF;  -- l_task_in_tbl.count > 0

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;

END Update_Project_Task_Times;

-- SATHAPLI, 05-Jun-2008 - Cursory analysis shows that this API Create_Job_Tasks is not in use anymore.
-- Retaining the API code in the end of the package for any future references.
--------------------------------------------------------------------
-- PROCEDURE
--    Create_Job_Tasks
--
-- PURPOSE
--
--
--------------------------------------------------------------------
PROCEDURE Create_Job_Tasks(
   p_api_version      IN            NUMBER    :=1.0,
   p_init_msg_list    IN            VARCHAR2  := Fnd_Api.g_false,
   p_commit           IN            VARCHAR2  := Fnd_Api.g_false,
   p_validation_level IN            NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type      IN            VARCHAR2  := Null,
   p_x_task_Tbl       IN OUT NOCOPY Task_Tbl_Type,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2
 )
IS
   L_API_VERSION  CONSTANT NUMBER := 1.0;
   L_API_NAME     CONSTANT VARCHAR2(30) := 'Create_Job_Tasks';
   L_DEBUG_KEY    CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
   l_msg_count             NUMBER;
   l_route_id              NUMBER;
   l_job_ct                NUMBER;
   i                       NUMBER;
   j                       NUMBER;
   z                       NUMBER;
   idx                     NUMBER;
   z_return_status         VARCHAR2(1);
   l_return_status         VARCHAR2(1);
   y_return_status         VARCHAR2(1);
   l_flag                  VARCHAR2(1);
   l_status_flag           VARCHAR2(1);
   l_msg_data              VARCHAR2(2000);
   l_prd_workorder_tbl     AHL_PRD_WORKORDER_PVT.PRD_WORKORDER_TBL;
   /* Begin Changes by Shkalyan */
   l_prd_workorder_rel_tbl AHL_PRD_WORKORDER_PVT.PRD_WORKORDER_REL_TBL;
   l_firm_planned_flag     VARCHAR2(1) := FND_PROFILE.value('AHL_PRD_FIRM_PLANNED_FLAG');
   l_visit_wo_id           NUMBER;
   l_visit_wo_ovn          NUMBER;
   /* End Changes by Shkalyan */
   l_visit_end_time        DATE;
--
   -- To find count for tasks for visit
   CURSOR c_route (x_id IN NUMBER) IS
    SELECT Route_Id FROM AHL_MR_ROUTES_V
    WHERE MR_ROUTE_ID = x_id;

   -- To find visit related information
   CURSOR c_visit (x_id IN NUMBER) IS
    SELECT * FROM AHL_VISITS_VL
    WHERE VISIT_ID = x_id;
   c_visit_rec c_visit%ROWTYPE;

   -- To find task related information
   CURSOR c_task (x_id IN NUMBER) IS
    SELECT * FROM AHL_VISIT_TASKS_VL
    WHERE VISIT_TASK_ID = x_id ;
   c_task_rec c_task%ROWTYPE;

   -- To find count for jobs tasks
   CURSOR c_job (x_id IN NUMBER) IS
    SELECT count(*) FROM AHL_WORKORDERS
    WHERE VISIT_TASK_ID = x_id
    AND STATUS_CODE not in ('22','7');

   CURSOR c_chk_job (x_id IN NUMBER) IS
    SELECT * FROM AHL_WORKORDERS
    WHERE VISIT_TASK_ID = x_id
    AND STATUS_CODE not in ('22','7');
   c_chk_job_rec c_chk_job%ROWTYPE;

   -- To find job for Visit
   CURSOR c_visit_job (x_id IN NUMBER) IS
    SELECT workorder_id, object_version_number
    FROM AHL_WORKORDERS
    WHERE VISIT_ID = x_id
     AND VISIT_TASK_ID IS NULL
     AND MASTER_WORKORDER_FLAG = 'Y'
     AND STATUS_CODE not in ('22','7');

   --Post11510. Added to get summary task start, end time
   CURSOR get_summary_task_times_csr(p_task_id IN NUMBER)IS
    SELECT min(start_date_time), max(end_date_time)
      --TCHIMIRA::19-FEB-2010::BUG 9384614
      -- Use the base table instead of the vl view
      FROM ahl_visit_tasks_b VST
    START WITH visit_task_id = p_task_id
    AND NVL(VST.status_code, 'Y') <> NVL ('DELETED', 'X')
    CONNECT BY originating_task_id = PRIOR visit_task_id;

-- post 11.5.10
-- yazhou Jul-20-2005 start
  CURSOR c_visit_task_exists(x_visit_id IN NUMBER)
  IS
    SELECT 'x'
    FROM   ahl_visit_tasks_b
    WHERE  visit_id = x_visit_id
    AND  STATUS_CODE = 'PLANNING';

   CURSOR c_get_wo_details(x_visit_id IN NUMBER)
    IS
    SELECT scheduled_start_date,
           SCHEDULED_COMPLETION_DATE
    FROM wip_discrete_jobs
    WHERE wip_entity_id =
          (
           SELECT
           wip_entity_id
           FROM ahl_workorders
           WHERE
             master_workorder_flag = 'Y' AND
             visit_task_id IS null AND
             status_code not in (22,7) and
             visit_id=x_visit_id
          );
      c_get_wo_details_rec  c_get_wo_details%ROWTYPE;

   l_dummy VARCHAR2(1);
-- yazhou Jul-20-2005 end
BEGIN
   --------------------- initialize -----------------------
  SAVEPOINT Create_Job_Tasks;

  IF (l_log_procedure >= l_log_current_level) THEN
    fnd_log.string(l_log_procedure,L_DEBUG_KEY||'.begin','At the start of the PLSQL procedure');
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF Fnd_Api.to_boolean(p_init_msg_list) THEN
     Fnd_Msg_Pub.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  -- Standard call to check for call compatibility.
  IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --------------------------- Start of Body -------------------------------------
  IF (l_log_statement >= l_log_current_level) THEN
    fnd_log.string(l_log_statement,L_DEBUG_KEY,'Task table count = '||p_x_task_Tbl.COUNT);
  END IF;

  IF (p_x_task_Tbl.COUNT > 0) THEN
      i := p_x_task_Tbl.FIRST;

      IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,L_DEBUG_KEY,'Visit Id= ' || p_x_task_Tbl(i).visit_id);
        fnd_log.string(l_log_statement,L_DEBUG_KEY,'Task table value of Index i=' || i);
      END IF;

      WHILE i IS NOT NULL LOOP
        p_x_task_Tbl(i).operation_flag := 'C';

        OPEN c_visit (p_x_task_Tbl(i).visit_id);
        FETCH c_visit INTO c_visit_rec;
        CLOSE c_visit;

        --IF c_task_rec.department_id IS NULL THEN
        IF c_visit_rec.department_id IS NOT NULL THEN
          p_x_task_Tbl(i).department_id  := c_visit_rec.department_id ;
        ELSE
          p_x_task_Tbl(i).department_id  := NULL ;
        END IF;
        --END IF;

        IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,L_DEBUG_KEY,'Before calling AHL_VWP_TASKS_PVT.Create_Task');
        END IF;

        -- Call create Visit Task API
        AHL_VWP_TASKS_PVT.Create_Task (
          p_api_version      => p_api_version,
          p_init_msg_list    => Fnd_Api.g_false,
          p_validation_level => p_validation_level,
          p_module_type      => 'SR', --p_module_type,
          p_x_task_rec       => p_x_task_Tbl(i),
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

        IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,L_DEBUG_KEY,'After calling AHL_VWP_TASKS_PVT.Create_Task - x_return_status = '|| x_return_status);
        END IF;
        EXIT WHEN x_return_status <> 'S';
        i:= p_x_task_Tbl.NEXT(i);
      END LOOP;
  END IF;

  IF x_return_status <> 'S' THEN
    RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (p_x_task_Tbl.COUNT > 0) THEN
    i := p_x_task_Tbl.FIRST;
    -- yazhou 15Aug2005 starts
    -- Bug# 4552764 fix
    OPEN c_visit (p_x_task_Tbl(i).visit_id);
    FETCH c_visit INTO c_visit_rec;
    CLOSE c_visit;

    IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,L_DEBUG_KEY,'Before calling AHL_VWP_TIMES_PVT.adjust_task_times');
    END IF;

    IF c_visit_rec.start_date_time < SYSDATE THEN
      WHILE i IS NOT NULL
      LOOP
          AHL_VWP_TIMES_PVT.adjust_task_times(
                  p_api_version        => 1.0,
                  p_init_msg_list      => Fnd_Api.G_FALSE,
                  p_commit             => Fnd_Api.G_FALSE,
                  p_validation_level   => Fnd_Api.G_VALID_LEVEL_FULL,
                  x_return_status      => l_return_status,
                  x_msg_count          => l_msg_count,
                  x_msg_data           => l_msg_data,
                  p_task_id            => p_x_task_Tbl(i).visit_task_id,
                  p_reset_sysdate_flag => FND_API.G_TRUE);

          i:= p_x_task_Tbl.NEXT(i);
       END LOOP;
     END IF;
     --The visit end date
     l_visit_end_time := AHL_VWP_TIMES_PVT.get_visit_end_time(c_visit_rec.visit_id);

     IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,L_DEBUG_KEY,'After calling AHL_VWP_TIMES_PVT.adjust_task_times - l_visit_end_time = '||l_visit_end_time);
     END IF;
     -- yazhou 15Aug2005 ends
  END IF;

  -- yazhou 06Oct2005 starts
  -- bug fix #4658861
  OPEN c_get_wo_details(c_visit_rec.visit_id);
  FETCH c_get_wo_details into c_get_wo_details_rec;
  CLOSE c_get_wo_details;
  -- yazhou 06Oct2005 ends
  -- Post 11.5.10
  -- RROY

  -- Yazhou Note: since we are checking for derived visit end time here, if there are other task in planning
  -- status with end date exceeding visit planned end date, then non-routine cannot be created
  IF TRUNC(l_visit_end_time) > TRUNC(c_visit_rec.close_date_time) THEN
    --yazhou Jul-20-2005 start
    -- Set visit status to partially released
    -- UPDATE AHL_VISITS_B SET STATUS_CODE = 'PARTIALLY RELEASED',
    -- OBJECT_VERSION_NUMBER = c_visit_rec.object_version_number + 1
    -- WHERE VISIT_ID = c_visit_rec.visit_id;
    --yazhou Jul-20-2005 end

    -- yazhou Sep-15-2005 starts
    -- bug fix 4613220
    IF (p_x_task_Tbl.COUNT > 0) THEN
      i := p_x_task_Tbl.FIRST;
    END IF;
    -- Error Message
    FND_MESSAGE.Set_Name('AHL','AHL_VWP_CRT_JOB_ERR');
    Fnd_Message.Set_Token('TASK_NUMBER', p_x_task_tbl(i).visit_task_number);
    Fnd_Message.Set_Token('END_DATE', TRUNC(l_visit_end_time));
    -- yazhou Sep-15-2005 ends
    FND_MSG_PUB.ADD;
    -- yazhou 06Oct2005 starts
    -- bug fix #4658861
    -- Note: since we are checking for derived end time here, if there are other task in planning
    -- status with end date exceeding visit master WO end date, then non-routine cannot be created

  ELSIF TRUNC(l_visit_end_time) > TRUNC(c_get_wo_details_rec.scheduled_completion_date) THEN
    -- Error Message
    Fnd_Message.SET_NAME('AHL','AHL_VWP_DATE_EXCD_WO_DATE');
    Fnd_Message.Set_Token('VISIT_END_DATE', l_visit_end_time);
    FND_MSG_PUB.ADD;
    -- yazhou 06Oct2005 ends
  ELSE
    -- Start for 11.5.10 release
    -- By shbhanda 05-Jun-03
    -- For creating/updating Master Workorder in production for the visit in VWP
    idx := 1;
    /* Begin Changes by Shkalyan */
    l_prd_workorder_tbl(idx).MASTER_WORKORDER_FLAG := 'Y';
    l_prd_workorder_tbl(idx).BATCH_ID := c_visit_rec.visit_number;
    l_prd_workorder_tbl(idx).HEADER_ID := 0; -- Visit

    OPEN c_visit_job (c_visit_rec.visit_id);
    FETCH c_visit_job INTO l_visit_wo_id, l_visit_wo_ovn;
    CLOSE c_visit_job;

    IF l_visit_wo_id IS NOT NULL THEN
      l_prd_workorder_tbl(idx).DML_OPERATION := 'U';
      l_prd_workorder_tbl(idx).WORKORDER_ID := l_visit_wo_id;
      l_prd_workorder_tbl(idx).OBJECT_VERSION_NUMBER := l_visit_wo_ovn;
    ELSE
      l_prd_workorder_tbl(idx).DML_OPERATION := 'C';
      l_prd_workorder_tbl(idx).STATUS_CODE           := '1';
      l_prd_workorder_tbl(idx).FIRM_PLANNED_FLAG     := 1; -- Firm
    END IF;
    /* End Changes by Shkalyan */

    l_prd_workorder_tbl(idx).VISIT_ID              := c_visit_rec.visit_id;
    l_prd_workorder_tbl(idx).ORGANIZATION_ID       := c_visit_rec.organization_id;
    l_prd_workorder_tbl(idx).PROJECT_ID            := c_visit_rec.project_id;
    l_prd_workorder_tbl(idx).DEPARTMENT_ID         := c_visit_rec.department_id ;
    l_prd_workorder_tbl(idx).INVENTORY_ITEM_ID     := c_visit_rec.inventory_item_id ;
    l_prd_workorder_tbl(idx).ITEM_INSTANCE_ID      := c_visit_rec.item_instance_id ;
    l_prd_workorder_tbl(idx).SCHEDULED_START_DATE  := c_visit_rec.start_date_time;
    --l_prd_workorder_tbl(idx).SCHEDULED_END_DATE  := l_visit_end_time;
    -- Changed by Shbhanda on 30th Jan 04
    l_prd_workorder_tbl(idx).SCHEDULED_END_DATE    := c_visit_rec.close_date_time;
    l_prd_workorder_tbl(idx).JOB_DESCRIPTION       := c_visit_rec.visit_name ;

    idx := idx + 1;

    IF (p_x_task_Tbl.COUNT > 0) THEN
      i := p_x_task_Tbl.FIRST;
      j := 0;

      WHILE i IS NOT NULL LOOP
        -- Call create WIP Job API
        OPEN c_job(p_x_task_Tbl(i).visit_task_id);
        FETCH c_job INTO l_job_ct;
        CLOSE c_job;

        IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,L_DEBUG_KEY,'For job count = ' || l_job_ct);
        END IF;

        IF l_job_ct > 0 THEN
          i := i + 1;
        ELSE
          OPEN c_task(p_x_task_Tbl(i).visit_task_id);
          FETCH c_task INTO c_task_rec;
          CLOSE c_task;

          /* Begin Changes by Shkalyan */
          -- Form the Workorder Relationship Parenting to the Visit
          l_prd_workorder_rel_tbl(idx-1).DML_OPERATION := 'C';
          l_prd_workorder_rel_tbl(idx-1).PARENT_HEADER_ID := 0; -- Visit
          l_prd_workorder_rel_tbl(idx-1).CHILD_HEADER_ID := c_task_rec.visit_task_number;
          l_prd_workorder_rel_tbl(idx-1).BATCH_ID := c_visit_rec.visit_number;
          l_prd_workorder_rel_tbl(idx-1).RELATIONSHIP_TYPE := 1;

          -- Form the Workorder Record
          l_prd_workorder_tbl(idx).DML_OPERATION     := 'C';
          l_prd_workorder_tbl(idx).MASTER_WORKORDER_FLAG := 'N';
          l_prd_workorder_tbl(idx).BATCH_ID := c_visit_rec.visit_number;
          l_prd_workorder_tbl(idx).HEADER_ID := c_task_rec.visit_task_number;
          /* End Changes by Shkalyan */

          l_prd_workorder_tbl(idx).VISIT_ID          := c_visit_rec.visit_id;
          l_prd_workorder_tbl(idx).ORGANIZATION_ID   := c_visit_rec.organization_id;
          l_prd_workorder_tbl(idx).PROJECT_ID        := c_visit_rec.project_id;
          l_prd_workorder_tbl(idx).STATUS_CODE       := '1';
          l_prd_workorder_tbl(idx).INVENTORY_ITEM_ID := c_task_rec.inventory_item_id ;
          l_prd_workorder_tbl(idx).ITEM_INSTANCE_ID  := c_task_rec.instance_id ;
          l_prd_workorder_tbl(idx).VISIT_TASK_ID     := c_task_rec.visit_task_id ;
          l_prd_workorder_tbl(idx).VISIT_TASK_NUMBER := c_task_rec.visit_task_number ;
          l_prd_workorder_tbl(idx).PROJECT_TASK_ID   := c_task_rec.project_task_id ;
          l_prd_workorder_tbl(idx).JOB_DESCRIPTION   := c_task_rec.visit_task_name ;

          IF c_task_rec.department_id IS NOT NULL AND c_task_rec.department_id <> FND_API.g_miss_num THEN
            l_prd_workorder_tbl(idx).DEPARTMENT_ID   := c_task_rec.department_id ;
          ELSE
            l_prd_workorder_tbl(idx).DEPARTMENT_ID   := c_visit_rec.department_id ;
          END IF;

          IF c_task_rec.mr_route_id IS NOT NULL AND c_task_rec.mr_route_id <> FND_API.g_miss_num THEN
            OPEN c_route (c_task_rec.mr_route_id);
            FETCH c_route INTO l_route_id;
            CLOSE c_route;
            l_prd_workorder_tbl(idx).ROUTE_ID := l_route_id ;
          ELSE
            l_prd_workorder_tbl(idx).ROUTE_ID := Null;
          END IF;

          --POST11510 cxcheng. If summary task, use the min,max for sub tasks
          IF (c_task_rec.task_type_code = 'SUMMARY') THEN
            OPEN get_summary_task_times_csr(c_task_rec.visit_task_id);
            FETCH get_summary_task_times_csr INTO l_prd_workorder_tbl(idx).SCHEDULED_START_DATE,
                                                  l_prd_workorder_tbl(idx).SCHEDULED_END_DATE  ;
            CLOSE get_summary_task_times_csr;
          ELSE
            l_prd_workorder_tbl(idx).SCHEDULED_START_DATE  := c_task_rec.start_date_time;
            l_prd_workorder_tbl(idx).SCHEDULED_END_DATE    := c_task_rec.end_date_time;
          END IF;

          /* Begin Changes by Shkalyan */
          IF (l_firm_planned_flag IS NOT NULL AND
          -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010
          -- For task with past task dates, WOs are always firm irrespective of the profile value
          c_task_rec.past_task_start_date IS NULL AND
          l_firm_planned_flag = '2') THEN
            l_prd_workorder_tbl(idx).FIRM_PLANNED_FLAG     := 2; -- Planned
          ELSE
            l_prd_workorder_tbl(idx).FIRM_PLANNED_FLAG     := 1; -- Firm
          END IF;
          /* End Changes by Shkalyan */
          idx := idx + 1;
          i := p_x_task_Tbl.NEXT(i);
        END IF;
      END LOOP;
    END IF;

    IF l_prd_workorder_tbl.COUNT > 0  THEN
      IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,L_DEBUG_KEY,'Before calling AHL_PRD_WORKORDER_PVT.Process_Jobs');
      END IF;

      /* Begin Changes by Shkalyan */
      AHL_PRD_WORKORDER_PVT.Process_Jobs
                 (p_api_version           => p_api_version,
                  p_init_msg_list         => p_init_msg_list,
                  p_commit                => Fnd_Api.g_false,
                  p_validation_level      => p_validation_level,
                  p_default               => FND_API.G_TRUE,
                  p_module_type           => p_module_type,
                  x_return_status         => x_return_status,
                  x_msg_count             => x_msg_count,
                  x_msg_data              => x_msg_data,
                  p_x_prd_workorder_tbl   => l_prd_workorder_tbl,
                  p_prd_workorder_rel_tbl => l_prd_workorder_rel_tbl
                  );
      /* End Changes by Shkalyan */
      IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,L_DEBUG_KEY,'After calling AHL_PRD_WORKORDER_PVT.Process_Jobs - x_return_status = '||x_return_status);
      END IF;

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
    END IF; -- To find if the visit has any tasks

    IF (p_x_task_Tbl.COUNT > 0) THEN
        i := p_x_task_Tbl.FIRST;
         WHILE i IS NOT NULL LOOP
            OPEN c_chk_job(p_x_task_Tbl(i).visit_task_id);
            FETCH c_chk_job INTO c_chk_job_rec;
            CLOSE c_chk_job;

            p_x_task_Tbl(i).workorder_id  := c_chk_job_rec.workorder_id;

            --yazhou Jul-18-2005 start
            -- Fix for bug # 4078095
            UPDATE AHL_VISIT_TASKS_B
            SET STATUS_CODE = 'RELEASED',
                OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
            WHERE VISIT_TASK_ID = p_x_task_Tbl(i).visit_task_id
            AND STATUS_CODE = 'PLANNING';
            --yazhou Jul-18-2005 end
            i := p_x_task_Tbl.NEXT(i);
         END LOOP;
    END IF;

    IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,L_DEBUG_KEY,'Updated visit to Released..');
    END IF;
    --yazhou Jul-20-2005 start

    OPEN c_visit_task_exists(c_visit_rec.visit_id);
    FETCH c_visit_task_exists INTO l_dummy;

    OPEN c_get_wo_details(c_visit_rec.visit_id);
    FETCH c_get_wo_details into c_get_wo_details_rec;
    IF (c_visit_task_exists%NOTFOUND and
        c_visit_rec.start_date_time = c_get_wo_details_rec.scheduled_start_date and
        c_visit_rec.close_date_time = c_get_wo_details_rec.scheduled_completion_date) THEN
          UPDATE ahl_visits_b
          SET status_code = 'RELEASED',
              object_version_number = object_version_number + 1
          WHERE visit_id = c_visit_rec.visit_id;

          IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,L_DEBUG_KEY,'Before updating the task flag');
          END IF;

          IF c_visit_rec.any_task_chg_flag = 'Y' THEN
             AHL_VWP_RULES_PVT.Update_Visit_Task_Flag
                         (p_visit_id      => c_visit_rec.visit_id,
                          p_flag          => 'N',
                          x_return_status => x_return_status);
          END IF;
      END IF;
      CLOSE c_visit_task_exists;
      CLOSE c_get_wo_details;
  END IF;
  -- yazhou Jul-20-2005 end
  -- RROY
  ---------------------------End of Body-------------------------------------
  -- END of API body.
  -- Standard check of p_commit.

  IF Fnd_Api.To_Boolean (p_commit) THEN
     COMMIT WORK;
  END IF;

  Fnd_Msg_Pub.count_and_get(
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data);

  IF (l_log_procedure >= l_log_current_level) THEN
    fnd_log.string(l_log_procedure,L_DEBUG_KEY||'.end','At the end of the PLSQL procedure');
  END IF;

EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Create_Job_Tasks;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Job_Tasks;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Job_Tasks;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
    THEN
         Fnd_Msg_Pub.add_exc_msg (G_PKG_NAME, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
END Create_Job_Tasks;

END AHL_VWP_PROJ_PROD_PVT;

/
