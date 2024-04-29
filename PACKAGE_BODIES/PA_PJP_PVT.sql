--------------------------------------------------------
--  DDL for Package Body PA_PJP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PJP_PVT" as
 /* $Header: PARPJPVB.pls 120.0 2005/05/29 18:43:26 appldev noship $ */

 G_PKG_NAME    CONSTANT VARCHAR2(200) := 'PA_PJP_PVT';
 G_APP_NAME    CONSTANT VARCHAR2(3)   :=  'FPA';
 G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PVT';
 L_API_NAME    CONSTANT VARCHAR2(35)  := 'PJP';


PROCEDURE Submit_Project_Aw
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2,
    p_commit                IN              VARCHAR2,
    p_project_id            IN              NUMBER,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
) IS

BEGIN

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.String(
          FND_LOG.LEVEL_PROCEDURE,
             'fpa.sql.PA_PJP_PVT.Submit_Project_Aw',
             'Entering');
    END IF;

    x_return_status := 'E';

    EXECUTE IMMEDIATE
    'BEGIN Fpa_Process_Pvt.Submit_Project_Aw(:1, :2, :3, :4, :5, :6, :7); END;'
    USING P_API_VERSION,
          P_INIT_MSG_LIST,
          P_COMMIT,
          P_PROJECT_ID,
          OUT X_RETURN_STATUS,
          OUT X_MSG_COUNT,
          OUT X_MSG_DATA;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.String(
          FND_LOG.LEVEL_PROCEDURE,
             'fpa.sql.PA_PJP_PVT.Submit_Project_Aw',
             'Returning');
    END IF;


EXCEPTION

    WHEN OTHERS then
        IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 FND_LOG.String
                 ( FND_LOG.LEVEL_ERROR,
                 'fpa.sql.FPA_PJP_PVT.Submit_Project_Aw',
                 'WHEN OTHERS '||SQLERRM);
        END IF;

END Submit_Project_Aw;



 FUNCTION proj_scorecard_link_enabled
 (   p_function_name    IN  VARCHAR2,
     p_project_id       IN  NUMBER)
  RETURN VARCHAR2 IS

  l_sql_stat    VARCHAR2(2000);
  l_return_flag VARCHAR2(1) := 'F';

  BEGIN

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.String(
          FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.PA_PJP_PVT.proj_scorecard_link_enabled.Begin',
          'Entering');
    END IF;

    L_SQL_STAT := 'BEGIN :1 := Fpa_Process_Pvt.proj_scorecard_link_enabled(:2, :3); END;';
    EXECUTE IMMEDIATE
    l_sql_stat
    USING OUT L_RETURN_FLAG, IN P_FUNCTION_NAME, IN P_PROJECT_ID;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.String(
          FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.PA_PJP_PVT.proj_scorecard_link_enabled.Begin',
          'Returning l_return_flag '||l_return_flag);
    END IF;

    RETURN l_RETURN_FLAG;

  EXCEPTION

     WHEN OTHERS then
        IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 FND_LOG.String
                 ( FND_LOG.LEVEL_ERROR,
                 'fpa.sql.FPA_PJP_PVT.proj_scorecard_link_enabled',
                 'WHEN OTHERS '||SQLERRM);
        END IF;

      RETURN l_return_flag;

END proj_scorecard_link_enabled;


END PA_PJP_PVT;

/
