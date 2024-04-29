--------------------------------------------------------
--  DDL for Package Body PA_GANTT_CONFIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_GANTT_CONFIG_PVT" AS
/* $Header: PAGCGCVB.pls 120.1 2005/08/19 16:33:01 mwasowic noship $ */

g_module_name      VARCHAR2(100) := 'pa.plsql.PA_GANTT_CONFIG_PVT';
Invalid_Arg_Exc_GC Exception;


procedure CREATE_GANTT_CONFIG (
  P_COMMIT                    in VARCHAR2,
  P_CALLING_MODULE            in VARCHAR2,
  P_GANTT_VIEW_ID             in PA_GANTT_CONFIG_B.gantt_view_id%TYPE,
  P_GANTT_CONFIG_USAGE        in PA_GANTT_CONFIG_B.gantt_config_usage%TYPE,
  P_FILTER_CODE               in PA_GANTT_CONFIG_B.filter_code%TYPE,
  P_TIME_SCALE_CODE           in PA_GANTT_CONFIG_B.time_scale_code%TYPE,
  P_EXPAND_COLLAPSE_FLAG      in PA_GANTT_CONFIG_B.expand_collapse_flag%TYPE,
  P_NUMBER_OF_DISPLAYED_ROWS  in PA_GANTT_CONFIG_B.number_of_displayed_rows%TYPE,
  P_SHOW_ADDITIONAL_COL_FLAG  in PA_GANTT_CONFIG_B.show_additional_col_flag%TYPE,
  P_FOCUS_ENABLED_FLAG        in PA_GANTT_CONFIG_B.focus_enabled_flag%TYPE,
  P_SHOW_HEADER_UI_FLAG       in PA_GANTT_CONFIG_B.show_header_ui_flag%TYPE,
  P_NAME                      in PA_GANTT_CONFIG_TL.name%TYPE,
  P_DESCRIPTION               in PA_GANTT_CONFIG_TL.description%TYPE,
  PX_GANTT_CONFIG_ID          in OUT NOCOPY PA_GANTT_CONFIG_B.gantt_config_id%TYPE, --File.Sql.39 bug 4440895
  X_RETURN_STATUS             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_MSG_COUNT                 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_MSG_DATA                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;

l_rowid                         ROWID;

BEGIN
     IF p_commit = 'Y' THEN
          savepoint create_gantt_config;
     END IF;

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'CREATE_GANTT_CONFIG',
                                      p_debug_mode => l_debug_mode );
     END IF;

     PA_GANTT_CONFIG_PKG.INSERT_ROW (
           X_ROWID                         =>  l_rowid
          ,X_GANTT_CONFIG_ID               =>  PX_GANTT_CONFIG_ID
          ,X_GANTT_VIEW_ID                 =>  P_GANTT_VIEW_ID
          ,X_GANTT_CONFIG_USAGE            =>  P_GANTT_CONFIG_USAGE
          ,X_FILTER_CODE                   =>  P_FILTER_CODE
          ,X_TIME_SCALE_CODE               =>  P_TIME_SCALE_CODE
          ,X_EXPAND_COLLAPSE_FLAG          =>  P_EXPAND_COLLAPSE_FLAG
          ,X_NUMBER_OF_DISPLAYED_ROWS      =>  P_NUMBER_OF_DISPLAYED_ROWS
          ,X_SHOW_ADDITIONAL_COL_FLAG      =>  P_SHOW_ADDITIONAL_COL_FLAG
          ,X_FOCUS_ENABLED_FLAG            =>  P_FOCUS_ENABLED_FLAG
          ,X_SHOW_HEADER_UI_FLAG           =>  P_SHOW_HEADER_UI_FLAG
          ,X_RECORD_VERSION_NUMBER         =>  1
          ,X_ATTRIBUTE_CATEGORY            =>  NULL
          ,X_ATTRIBUTE1                    =>  NULL
          ,X_ATTRIBUTE2                    =>  NULL
          ,X_ATTRIBUTE3                    =>  NULL
          ,X_ATTRIBUTE4                    =>  NULL
          ,X_ATTRIBUTE5                    =>  NULL
          ,X_ATTRIBUTE6                    =>  NULL
          ,X_ATTRIBUTE7                    =>  NULL
          ,X_ATTRIBUTE8                    =>  NULL
          ,X_ATTRIBUTE9                    =>  NULL
          ,X_ATTRIBUTE10                   =>  NULL
          ,X_ATTRIBUTE11                   =>  NULL
          ,X_ATTRIBUTE12                   =>  NULL
          ,X_ATTRIBUTE13                   =>  NULL
          ,X_ATTRIBUTE14                   =>  NULL
          ,X_ATTRIBUTE15                   =>  NULL
          ,X_NAME                          =>  P_NAME
          ,X_DESCRIPTION                   =>  P_DESCRIPTION
          ,X_CREATION_DATE                 =>  sysdate
          ,X_CREATED_BY                    =>  fnd_global.user_id
          ,X_LAST_UPDATE_DATE              =>  sysdate
          ,X_LAST_UPDATED_BY               =>  fnd_global.user_id
          ,X_LAST_UPDATE_LOGIN             =>  fnd_global.login_id
     );


     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting CREATE_GANTT_CONFIG';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
          pa_debug.reset_curr_function;
     END IF;
EXCEPTION

WHEN Invalid_Arg_Exc_GC THEN

     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count = 1 and x_msg_data IS NULL THEN
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
     IF l_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;
     END IF;

     IF p_commit = 'Y' THEN
          rollback to create_gantt_config;
     END IF;

     RETURN;

WHEN others THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_GANTT_CONFIG_PVT'
                    ,p_procedure_name  => 'CREATE_GANTT_CONFIG'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                              l_debug_level5);
          pa_debug.reset_curr_function;
     END IF;

     IF p_commit = 'Y' THEN
          rollback to create_gantt_config;
     END IF;

     RAISE;
END CREATE_GANTT_CONFIG;


procedure UPDATE_GANTT_CONFIG (
  P_COMMIT                    in VARCHAR2 ,
  P_CALLING_MODULE            in VARCHAR2 ,
  P_GANTT_CONFIG_ID           in PA_GANTT_CONFIG_B.gantt_config_id%TYPE,
  P_GANTT_VIEW_ID             in PA_GANTT_CONFIG_B.gantt_view_id%TYPE,
  P_GANTT_CONFIG_USAGE        in PA_GANTT_CONFIG_B.gantt_config_usage%TYPE,
  P_FILTER_CODE               in PA_GANTT_CONFIG_B.filter_code%TYPE,
  P_TIME_SCALE_CODE           in PA_GANTT_CONFIG_B.time_scale_code%TYPE,
  P_EXPAND_COLLAPSE_FLAG      in PA_GANTT_CONFIG_B.expand_collapse_flag%TYPE,
  P_NUMBER_OF_DISPLAYED_ROWS  in PA_GANTT_CONFIG_B.number_of_displayed_rows%TYPE,
  P_SHOW_ADDITIONAL_COL_FLAG  in PA_GANTT_CONFIG_B.show_additional_col_flag%TYPE,
  P_FOCUS_ENABLED_FLAG        in PA_GANTT_CONFIG_B.focus_enabled_flag%TYPE,
  P_SHOW_HEADER_UI_FLAG       in PA_GANTT_CONFIG_B.show_header_ui_flag%TYPE,
  P_RECORD_VERSION_NUMBER     in PA_GANTT_CONFIG_B.RECORD_VERSION_NUMBER%TYPE,
  P_NAME                      in PA_GANTT_CONFIG_TL.name%TYPE,
  P_DESCRIPTION               in PA_GANTT_CONFIG_TL.description%TYPE,
  X_RETURN_STATUS             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_MSG_COUNT                 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_MSG_DATA                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;

CURSOR cur_gantt_config_rvn(c_gantt_config_id pa_gantt_config_b.gantt_config_id%TYPE)
is
   select record_version_number
   from pa_gantt_config_b
   where gantt_config_id = c_gantt_config_id;

l_gantt_config_rvn  pa_gantt_config_b.record_version_number%TYPE;

BEGIN
     IF p_commit = 'Y' THEN
          savepoint update_gantt_config;
     END IF;

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'UPDATE_GANTT_CONFIG',
                                      p_debug_mode => l_debug_mode );
     END IF;

     open  cur_gantt_config_rvn(p_gantt_config_id);
     fetch cur_gantt_config_rvn into l_gantt_config_rvn;

     IF cur_gantt_config_rvn%NOTFOUND OR p_record_version_number <> l_gantt_config_rvn THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_XC_RECORD_CHANGED');
          close cur_gantt_config_rvn;
          RAISE Invalid_Arg_Exc_GC;
     END IF;

     close cur_gantt_config_rvn;

     PA_GANTT_CONFIG_PKG.UPDATE_ROW (
           X_GANTT_CONFIG_ID                 => P_GANTT_CONFIG_ID
          ,X_GANTT_VIEW_ID                   => P_GANTT_VIEW_ID
          ,X_GANTT_CONFIG_USAGE              => P_GANTT_CONFIG_USAGE
          ,X_FILTER_CODE                     => P_FILTER_CODE
          ,X_TIME_SCALE_CODE                 => P_TIME_SCALE_CODE
          ,X_EXPAND_COLLAPSE_FLAG            => P_EXPAND_COLLAPSE_FLAG
          ,X_NUMBER_OF_DISPLAYED_ROWS        => P_NUMBER_OF_DISPLAYED_ROWS
          ,X_SHOW_ADDITIONAL_COL_FLAG        => P_SHOW_ADDITIONAL_COL_FLAG
          ,X_FOCUS_ENABLED_FLAG              => P_FOCUS_ENABLED_FLAG
          ,X_SHOW_HEADER_UI_FLAG             => P_SHOW_HEADER_UI_FLAG
          ,X_RECORD_VERSION_NUMBER           => P_RECORD_VERSION_NUMBER
          ,X_ATTRIBUTE_CATEGORY              => NULL
          ,X_ATTRIBUTE1                      => NULL
          ,X_ATTRIBUTE2                      => NULL
          ,X_ATTRIBUTE3                      => NULL
          ,X_ATTRIBUTE4                      => NULL
          ,X_ATTRIBUTE5                      => NULL
          ,X_ATTRIBUTE6                      => NULL
          ,X_ATTRIBUTE7                      => NULL
          ,X_ATTRIBUTE8                      => NULL
          ,X_ATTRIBUTE9                      => NULL
          ,X_ATTRIBUTE10                     => NULL
          ,X_ATTRIBUTE11                     => NULL
          ,X_ATTRIBUTE12                     => NULL
          ,X_ATTRIBUTE13                     => NULL
          ,X_ATTRIBUTE14                     => NULL
          ,X_ATTRIBUTE15                     => NULL
          ,X_NAME                            => P_NAME
          ,X_DESCRIPTION                     => P_DESCRIPTION
          ,X_LAST_UPDATE_DATE                => sysdate
          ,X_LAST_UPDATED_BY                 => fnd_global.user_id
          ,X_LAST_UPDATE_LOGIN               => fnd_global.login_id
     );


     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting UPDATE_GANTT_CONFIG';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
          pa_debug.reset_curr_function;
     END IF;
EXCEPTION

WHEN Invalid_Arg_Exc_GC THEN

     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count = 1 and x_msg_data IS NULL THEN
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
     IF l_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;
     END IF;

     IF p_commit = 'Y' THEN
          rollback to update_gantt_config;
     END IF;

     RETURN;

WHEN others THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_GANTT_CONFIG_PVT'
                    ,p_procedure_name  => 'UPDATE_GANTT_CONFIG'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                              l_debug_level5);
          pa_debug.reset_curr_function;
     END IF;

     IF p_commit = 'Y' THEN
          rollback to update_gantt_config;
     END IF;

     RAISE;
END UPDATE_GANTT_CONFIG;


procedure DELETE_GANTT_CONFIG (
  P_COMMIT                    in VARCHAR2 ,
  P_CALLING_MODULE            in VARCHAR2 ,
  P_GANTT_CONFIG_ID           in PA_GANTT_CONFIG_B.gantt_config_id%TYPE,
  P_RECORD_VERSION_NUMBER     in PA_GANTT_CONFIG_B.RECORD_VERSION_NUMBER%TYPE,
  X_RETURN_STATUS             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_MSG_COUNT                 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_MSG_DATA                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;

CURSOR cur_gantt_config_rvn(c_gantt_config_id pa_gantt_config_b.gantt_config_id%TYPE)
is
   select record_version_number
   from pa_gantt_config_b
   where gantt_config_id = c_gantt_config_id;

l_gantt_config_rvn  pa_gantt_config_b.record_version_number%TYPE;

BEGIN
     IF p_commit = 'Y' THEN
          savepoint delete_gantt_config;
     END IF;

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'DELETE_GANTT_CONFIG',
                                      p_debug_mode => l_debug_mode );
     END IF;

     open  cur_gantt_config_rvn(p_gantt_config_id);
     fetch cur_gantt_config_rvn into l_gantt_config_rvn;

     IF cur_gantt_config_rvn%NOTFOUND OR p_record_version_number <> l_gantt_config_rvn THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_XC_RECORD_CHANGED');
          close cur_gantt_config_rvn;
          RAISE Invalid_Arg_Exc_GC;
     END IF;

     close cur_gantt_config_rvn;

     PA_GANTT_CONFIG_PKG.DELETE_ROW(
          X_GANTT_CONFIG_ID   =>   p_gantt_config_id
     );

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting DELETE_GANTT_CONFIG';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
          pa_debug.reset_curr_function;
     END IF;
EXCEPTION

WHEN Invalid_Arg_Exc_GC THEN

     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count = 1 and x_msg_data IS NULL THEN
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
     IF l_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;
     END IF;

     IF p_commit = 'Y' THEN
          rollback to delete_gantt_config;
     END IF;

     RETURN;

WHEN others THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_GANTT_CONFIG_PVT'
                    ,p_procedure_name  => 'DELETE_GANTT_CONFIG'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                              l_debug_level5);
          pa_debug.reset_curr_function;
     END IF;

     IF p_commit = 'Y' THEN
          rollback to delete_gantt_config;
     END IF;

     RAISE;
END DELETE_GANTT_CONFIG;

END PA_GANTT_CONFIG_PVT;

/
