--------------------------------------------------------
--  DDL for Package Body AHL_LTP_REQST_MATRL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_LTP_REQST_MATRL_PUB" AS
/* $Header: AHLPRMTB.pls 115.14 2003/12/17 00:36:59 ssurapan noship $ */
--
G_PKG_NAME  VARCHAR2(30)  := 'AHL_LTP_REQST_MATRL_PUB';
G_DEBUG     VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;
--
-- PACKAGE
--    AHL_LTP_REQST_MATRL_PUB
--
-- PURPOSE
--     This Public API is used to schedule and unschedule materials requests
--     using Material Requirement Interface
--
-- NOTES
--
--
-- HISTORY
-- 23-Apr-2002    ssurapan      Created.
--
-- Start of Comments --
--  Procedure name    : Update_Planned_Materials
--  Type        : Private
--  Function    : This procedure Updates Planned materials information associated to scheduled
--                visit, which are defined at Route Operation and Disposition level
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   In      VARCHAR2     Default  NULL
--         This will be null.
--  Standard out Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Update_Planned_Materials Parameters :
--       p_planned_materials_tbl          IN   Planned_Materials_Tbl,Required
--
--
PROCEDURE Update_Planned_Materials (
   p_api_version             IN    NUMBER,
   p_init_msg_list           IN    VARCHAR2  := FND_API.g_false,
   p_commit                  IN    VARCHAR2  := FND_API.g_false,
   p_validation_level        IN    NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN    VARCHAR2  := 'JSP',
   p_planned_Materials_tbl   IN    Planned_Materials_Tbl,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2)

  IS


    --Standard local variables
    l_api_name	    CONSTANT	VARCHAR2(30)	:= 'Update_Planned_Materials';
    l_api_version	CONSTANT	NUMBER		    := 1.0;
    l_msg_data             VARCHAR2(2000);
    l_return_status        VARCHAR2(1);
    l_msg_count             NUMBER;
    --
    l_commit     VARCHAR2(10)  := FND_API.g_false;
	l_planned_materials_tbl   planned_materials_tbl := p_planned_materials_tbl;
 BEGIN

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_LTP_REQST_MATRL_PUB.Update_Planned_Materials',
			'At the start of PLSQL procedure'
		);
     END IF;
     -- Standard start of API savepoint
     SAVEPOINT Update_Planned_Materials;
      -- Initialize message list if p_init_msg_list is set to TRUE
     IF FND_API.To_Boolean( p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
     END IF;
     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     --
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Request for Update Material Number of Records : '|| l_planned_materials_tbl.COUNT
		);

     END IF;

     IF l_planned_materials_tbl.COUNT > 0 THEN
       --
     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string
		  (
		   fnd_log.level_procedure,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
    	        'Before calling ahl ltp reqst matrl pvt.Update Planned Materials'
   		  );

     END IF;

       AHL_LTP_REQST_MATRL_PVT.Update_Planned_Materials (
                 p_api_version            => l_api_version,
                 p_init_msg_list          => p_init_msg_list,
                 p_commit                 => l_commit,
                 p_validation_level       => p_validation_level,
                 p_planned_materials_tbl  => p_planned_materials_tbl,
                 x_return_status          => l_return_status,
                 x_msg_count              => l_msg_count,
                 x_msg_data               => l_msg_data);
     END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string
		 (
		  fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
	        'After calling ahl ltp reqst matrl pvt.Update Planned Materials, Return Status : '|| l_return_status
		);
    END IF;
    -- Check Error Message stack.
     IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_count := FND_MSG_PUB.count_msg;
	      IF l_msg_count > 0 THEN
	        RAISE FND_API.G_EXC_ERROR;
	      END IF;
       END IF;

     -- Standard check of p_commit
     IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
     END IF;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_LTP_REQST_MATRL_PUB.Update Planned Materials.end',
			'At the end of PLSQL procedure'
		);
     END IF;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO Update_Planned_Materials;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO Update_Planned_Materials;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Update_Planned_Materials;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Update_Planned_Materials',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

  END Update_Planned_Materials;

END AHL_LTP_REQST_MATRL_PUB;

/
