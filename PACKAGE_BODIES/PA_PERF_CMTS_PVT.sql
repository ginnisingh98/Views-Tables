--------------------------------------------------------
--  DDL for Package Body PA_PERF_CMTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PERF_CMTS_PVT" AS
/* $Header: PAPECTVB.pls 120.1 2005/08/19 16:38:16 mwasowic noship $ */

g_module_name   VARCHAR2(100) := 'pa.plsql.pa_perf_cmts_pvt';

/*==================================================================
  PROCEDURE
      create_comment
  PURPOSE
      This procedure inserts a row into the pa_perf_cmts table.
 ==================================================================*/


    PROCEDURE create_comment(
			     p_api_version           IN NUMBER :=  1.0,
			     p_init_msg_list         IN VARCHAR2 := fnd_api.g_true,
			     p_commit                IN VARCHAR2 := FND_API.g_false,
			     p_validate_only         IN VARCHAR2 := FND_API.g_true,
			     p_max_msg_count         IN NUMBER := FND_API.g_miss_num,
			     P_transaction_id        IN NUMBER,
			     P_COMMENT_TEXT          IN VARCHAR2,
			     p_commented_by          IN NUMBER,
			     P_comment_date          IN DATE,
			     x_comment_id            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
			     X_RETURN_STATUS         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			     X_MSG_COUNT             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
			     X_MSG_DATA              OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

l_msg_count               NUMBER := 0;
l_data                    VARCHAR2(2000);
l_msg_data                VARCHAR2(2000);
l_msg_index_out           NUMBER;
l_debug_mode              VARCHAR2(1);
l_rowid                   VARCHAR2(255);
l_debug_level2            CONSTANT NUMBER := 2;
l_debug_level3            CONSTANT NUMBER := 3;
l_debug_level4            CONSTANT NUMBER := 4;
l_debug_level5            CONSTANT NUMBER := 5;

BEGIN

     -- Initialize the Error Stack
     PA_DEBUG.init_err_stack('PA_PERF_CMTS_PVT.create_comment');
     x_msg_count := 0;
     x_msg_data  := NULL;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'PA_PERF_CMTS_PVT.create_comment',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Entered PA_PERF_CMTS_PVT.create_comment';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     SELECT pa_perf_comments_s1.NEXTVAL
       INTO x_comment_id
       FROM dual;



     PA_PERF_CMTS_PKG.insert_row(
        X_ROWID => l_rowid,
        x_comment_id => x_comment_id,
        X_perf_txn_id => P_transaction_id,
        X_comment_text => P_comment_text,
	X_commented_by => P_commented_by,
        X_comment_date => P_comment_date,
	X_CREATION_DATE => NULL,
        X_CREATED_BY => NULL,
        X_LAST_UPDATE_DATE => NULL,
        X_LAST_UPDATED_BY => NULL,
        X_LAST_UPDATE_LOGIN => NULL
     );

     -- Check for business rules violations

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting PA_PERF_CMTS_PVT.create_comment';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
          pa_debug.reset_curr_function;
     END IF;

     -- Reset the Error Stack
     PA_DEBUG.reset_err_stack;


EXCEPTION
   WHEN others THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;

      FND_MSG_PUB.add_exc_msg(
       p_pkg_name        => 'PA_PERF_CMTS_PVT'
      ,p_procedure_name  => 'CREATE_COMMENT'
      ,p_error_text      => x_msg_data);

      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error: '||x_msg_data;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                              l_debug_level5);
          pa_debug.reset_curr_function;
      END IF;
      RAISE;
END create_comment;


END PA_PERF_CMTS_PVT;


/
