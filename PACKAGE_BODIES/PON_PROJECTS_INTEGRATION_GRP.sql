--------------------------------------------------------
--  DDL for Package Body PON_PROJECTS_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_PROJECTS_INTEGRATION_GRP" AS
--$Header: PONGPRJB.pls 120.0 2005/11/08 14:51 smhanda noship $

-- module name for logging message
g_module_prefix CONSTANT VARCHAR2(40) := 'pon.plsql.PON_PROJECTS_INTEGRATION_GRP.';

-- Read the profile option that enables/disables the debug log
g_fnd_debug CONSTANT VARCHAR2(1) :=
  NVL (FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');


--checks if passed in project_id being used in any negotiation
--This API is called by Oracle Projects before deleting any project in Oracle Projects
PROCEDURE CHECK_DELETE_PROJECT_OK(
                    p_api_version                 IN          NUMBER,
                    p_init_msg_list               IN          VARCHAR2,
                    p_project_id                  IN         NUMBER,
                    x_return_status               OUT NOCOPY  VARCHAR2,
                    x_msg_count                   OUT NOCOPY  NUMBER,
                    x_msg_data                    OUT NOCOPY  VARCHAR2
                    ) IS
    -- Remember to change the l_api_version for change in the API
    --
    l_api_version    CONSTANT  NUMBER := 1.0;


    --
    -- define local variables
    --
    l_api_name       CONSTANT  VARCHAR2(30) := 'CHECK_DELETE_PROJECT_OK';
    l_delete_ok      varchar2(1);

BEGIN
      IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'100: Start' ||l_api_name);
                      END IF;
       End if;


        --
        -- Standard call to check for call compatibility
        --
        IF NOT FND_API.COMPATIBLE_API_CALL ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             'PON_PROJECTS_INTEGRATION_GRP' )
        THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        --
        -- Initialize message list if p_init_msg_list is set to TRUE
        -- We initialize the list by default. User should pass proper
        -- value to p_init_msg_list in case this initialization is not
        -- wanted
        --
        IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
           FND_MSG_PUB.INITIALIZE;
        END IF;

        --
        --  Initialize API to return the status as success initially
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_delete_ok   := 'Y';

        -- The below query looks for project_id reference at aution header, line
        -- and payment level
        SELECT 'N'
          INTO l_delete_ok
          FROM dual
        WHERE EXISTS
                (SELECT '1'
                   FROM pon_auction_headers_all
                  WHERE project_id = p_project_id
                )  OR
              EXISTS
                (SELECT '1'
                   FROM pon_auction_item_prices_all
                  WHERE project_id = p_project_id
                ) OR
              EXISTS
                (SELECT '1'
                   FROM pon_auc_payments_shipments
                  WHERE project_id = p_project_id
                );


        -- if control reaches here , that means passed in project_id was found in
        -- some table and should not be deleted
        IF ( l_delete_ok = 'N')
        THEN
             x_return_status := FND_API.G_RET_STS_ERROR;

             -- add message in queue
             FND_MESSAGE.set_name('PON', 'PON_PROJECT_USED_NO_DELETE');
             FND_MSG_PUB.Add;
             x_msg_data := 'PON_PROJECT_USED_NO_DELETE';

             IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'300: The Project Id refrenced in Sourcing');
                      END IF;
            End IF;
        END IF;
        IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_STATEMENT,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'400: End' ||l_api_name);
                      END IF;
        End IF;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_SUCCESS;
          IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                        FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                      MODULE   =>g_module_prefix||l_api_name,
                      MESSAGE  =>'450:Exception when no data found ');
                      END IF;
          END IF;


       WHEN FND_API.G_EXC_ERROR then
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get
              (p_count  =>      x_msg_count,
               p_data   =>      x_msg_data );


         IF g_fnd_debug = 'Y' then
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
              FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                           MODULE   =>g_module_prefix||l_api_name,
                           MESSAGE  =>'470: expected error ');
              FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                           MODULE   =>g_module_prefix||l_api_name,
                           MESSAGE  =>'470:errors '||FND_MSG_PUB.Get(p_msg_index=>nvl(x_msg_count,1),p_encoded =>'F' ));
                           END IF;
            END IF;


       WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
            FND_MSG_PUB.Add_Exc_Msg
        	   (p_pkg_name       => 'PON_PROJECTS_INTEGRATION_GRP',
		        p_procedure_name  => l_api_name);
          END IF;

          FND_MSG_PUB.Count_And_Get
                  (p_count  =>      x_msg_count,
                   p_data   =>      x_msg_data );


           IF g_fnd_debug = 'Y' then
                      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                          FND_LOG.string(LOG_LEVEL=>FND_LOG.LEVEL_EXCEPTION,
                                         MODULE   =>g_module_prefix||l_api_name,
                                         MESSAGE  =>'500:Exception UnExpected error '||sqlcode||':'||sqlerrm);
                      END IF;
           END IF;

 END CHECK_DELETE_PROJECT_OK;

END PON_PROJECTS_INTEGRATION_GRP;

/
