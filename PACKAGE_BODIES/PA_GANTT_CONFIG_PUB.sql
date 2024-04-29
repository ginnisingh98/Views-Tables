--------------------------------------------------------
--  DDL for Package Body PA_GANTT_CONFIG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_GANTT_CONFIG_PUB" AS
/* $Header: PAGCGCPB.pls 120.1 2005/08/19 16:32:45 mwasowic noship $ */

g_module_name      VARCHAR2(100) := 'pa.plsql.PA_GANTT_CONFIG_PUB';
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

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'CREATE_GANTT_CONFIG',
                                      p_debug_mode => l_debug_mode );
     END IF;

     -- Check for business rules violations

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating input parameters';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'p_gantt_view_id = '|| p_gantt_view_id;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
             pa_debug.g_err_stage:= 'p_gantt_config_usage = '|| p_gantt_config_usage;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
             pa_debug.g_err_stage:= 'p_name = '|| p_name;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
             pa_debug.g_err_stage:= 'p_filter_code = '|| p_filter_code;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
             pa_debug.g_err_stage:= 'p_time_scale_code = '|| p_time_scale_code;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
             pa_debug.g_err_stage:= 'p_number_of_displayed_rows = '|| p_number_of_displayed_rows;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
             pa_debug.g_err_stage:= 'p_expand_collapse_flag = '|| p_expand_collapse_flag;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
             pa_debug.g_err_stage:= 'p_show_additional_col_flag = '|| p_show_additional_col_flag;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
             pa_debug.g_err_stage:= 'p_focus_enabled_flag = '|| p_focus_enabled_flag;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
             pa_debug.g_err_stage:= 'p_show_header_ui_flag = '|| p_show_header_ui_flag;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);

     END IF;

     IF (p_gantt_view_id IS NULL) OR
        (p_gantt_config_usage IS NULL) OR
        (p_name IS NULL) OR
        (p_filter_code IS NULL) OR
        (p_time_scale_code IS NULL) OR
        (p_number_of_displayed_rows IS NULL) OR
        (p_expand_collapse_flag IS NULL) OR
        (p_show_additional_col_flag IS NULL) OR
        (p_focus_enabled_flag IS NULL) OR
        (p_show_header_ui_flag IS NULL)
     THEN
          PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                  p_msg_name     => 'PA_INV_PARAM_PASSED');
          RAISE Invalid_Arg_Exc_GC;

     END IF;

     /* Give a call to pa_gantt_config_pvt.create_gantt_config */
     PA_GANTT_CONFIG_PVT.CREATE_GANTT_CONFIG (
             P_COMMIT                    => P_COMMIT
            ,P_CALLING_MODULE            => P_CALLING_MODULE
            ,P_GANTT_VIEW_ID             => P_GANTT_VIEW_ID
            ,P_GANTT_CONFIG_USAGE        => P_GANTT_CONFIG_USAGE
            ,P_FILTER_CODE               => P_FILTER_CODE
            ,P_TIME_SCALE_CODE           => P_TIME_SCALE_CODE
            ,P_EXPAND_COLLAPSE_FLAG      => P_EXPAND_COLLAPSE_FLAG
            ,P_NUMBER_OF_DISPLAYED_ROWS  => P_NUMBER_OF_DISPLAYED_ROWS
            ,P_SHOW_ADDITIONAL_COL_FLAG  => P_SHOW_ADDITIONAL_COL_FLAG
            ,P_FOCUS_ENABLED_FLAG        => P_FOCUS_ENABLED_FLAG
            ,P_SHOW_HEADER_UI_FLAG       => P_SHOW_HEADER_UI_FLAG
            ,P_NAME                      => P_NAME
            ,P_DESCRIPTION               => P_DESCRIPTION
            ,PX_GANTT_CONFIG_ID          => PX_GANTT_CONFIG_ID
            ,X_RETURN_STATUS             => X_RETURN_STATUS
            ,X_MSG_COUNT                 => X_MSG_COUNT
            ,X_MSG_DATA                  => X_MSG_DATA
     );

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := 'Error in creating gantt config ';
             pa_debug.write(g_module_name,pa_debug.g_err_stage,l_debug_level4);
          END IF;
          Raise Invalid_Arg_Exc_GC;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'gantt config id : ' || px_gantt_config_id;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
     END IF;

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

     RETURN;

WHEN others THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_GANTT_CONFIG_PUB'
                    ,p_procedure_name  => 'CREATE_GANTT_CONFIG'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                              l_debug_level5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END CREATE_GANTT_CONFIG;


procedure UPDATE_GANTT_CONFIG (
  P_COMMIT                    in VARCHAR2,
  P_CALLING_MODULE            in VARCHAR2,
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

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'UPDATE_GANTT_CONFIG',
                                      p_debug_mode => l_debug_mode );
     END IF;

     -- Check for business rules violations
     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating input parameters';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'p_gantt_view_id = '|| p_gantt_view_id;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
             pa_debug.g_err_stage:= 'p_gantt_config_usage = '|| p_gantt_config_usage;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
             pa_debug.g_err_stage:= 'p_name = '|| p_name;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
             pa_debug.g_err_stage:= 'p_filter_code = '|| p_filter_code;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
             pa_debug.g_err_stage:= 'p_time_scale_code = '|| p_time_scale_code;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
             pa_debug.g_err_stage:= 'p_number_of_displayed_rows = '|| p_number_of_displayed_rows;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
             pa_debug.g_err_stage:= 'p_expand_collapse_flag = '|| p_expand_collapse_flag;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
             pa_debug.g_err_stage:= 'p_show_additional_col_flag = '|| p_show_additional_col_flag;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
             pa_debug.g_err_stage:= 'p_focus_enabled_flag = '|| p_focus_enabled_flag;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
             pa_debug.g_err_stage:= 'p_show_header_ui_flag = '|| p_show_header_ui_flag;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
     END IF;

     IF (p_gantt_view_id IS NULL) OR
        (p_gantt_config_usage IS NULL) OR
        (p_name IS NULL) OR
        (p_filter_code IS NULL) OR
        (p_time_scale_code IS NULL) OR
        (p_number_of_displayed_rows IS NULL) OR
        (p_expand_collapse_flag IS NULL) OR
        (p_show_additional_col_flag IS NULL) OR
        (p_focus_enabled_flag IS NULL) OR
        (p_show_header_ui_flag IS NULL)
     THEN
          PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                  p_msg_name     => 'PA_INV_PARAM_PASSED');
          RAISE Invalid_Arg_Exc_GC;

     END IF;


     PA_GANTT_CONFIG_PVT.UPDATE_GANTT_CONFIG (
             P_COMMIT                     =>   P_COMMIT
            ,P_CALLING_MODULE             =>   P_CALLING_MODULE
            ,P_GANTT_CONFIG_ID            =>   P_GANTT_CONFIG_ID
            ,P_GANTT_VIEW_ID              =>   P_GANTT_VIEW_ID
            ,P_GANTT_CONFIG_USAGE         =>   P_GANTT_CONFIG_USAGE
            ,P_FILTER_CODE                =>   P_FILTER_CODE
            ,P_TIME_SCALE_CODE            =>   P_TIME_SCALE_CODE
            ,P_EXPAND_COLLAPSE_FLAG       =>   P_EXPAND_COLLAPSE_FLAG
            ,P_NUMBER_OF_DISPLAYED_ROWS   =>   P_NUMBER_OF_DISPLAYED_ROWS
            ,P_SHOW_ADDITIONAL_COL_FLAG   =>   P_SHOW_ADDITIONAL_COL_FLAG
            ,P_FOCUS_ENABLED_FLAG         =>   P_FOCUS_ENABLED_FLAG
            ,P_SHOW_HEADER_UI_FLAG        =>   P_SHOW_HEADER_UI_FLAG
            ,P_RECORD_VERSION_NUMBER      =>   P_RECORD_VERSION_NUMBER
            ,P_NAME                       =>   P_NAME
            ,P_DESCRIPTION                =>   P_DESCRIPTION
            ,X_RETURN_STATUS              =>   X_RETURN_STATUS
            ,X_MSG_COUNT                  =>   X_MSG_COUNT
            ,X_MSG_DATA                   =>   X_MSG_DATA
          );
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := 'Error in updating gantt config ';
             pa_debug.write(g_module_name,pa_debug.g_err_stage,l_debug_level4);
          END IF;
          Raise Invalid_Arg_Exc_GC;
     END IF;

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

     RETURN;

WHEN others THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_GANTT_CONFIG_PUB'
                    ,p_procedure_name  => 'UPDATE_GANTT_CONFIG'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                              l_debug_level5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END UPDATE_GANTT_CONFIG;


procedure DELETE_GANTT_CONFIG (
  P_COMMIT                    in VARCHAR2 := 'N',
  P_CALLING_MODULE            in VARCHAR2 := 'SELF_SERVICE',
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

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'DELETE_GANTT_CONFIG',
                                      p_debug_mode => l_debug_mode );
     END IF;

     -- Check for business rules violations
     IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'P_GANTT_CONFIG_ID = '|| P_GANTT_CONFIG_ID;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
             pa_debug.g_err_stage:= 'P_RECORD_VERSION_NUMBER = '|| P_RECORD_VERSION_NUMBER;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
     END IF;

     IF (P_GANTT_CONFIG_ID IS NULL) OR
        (P_RECORD_VERSION_NUMBER IS NULL)
     THEN
          PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                  p_msg_name     => 'PA_INV_PARAM_PASSED');
          RAISE Invalid_Arg_Exc_GC;
     END IF;

     PA_GANTT_CONFIG_PVT.DELETE_GANTT_CONFIG (
             P_COMMIT                  => P_COMMIT
            ,P_CALLING_MODULE          => P_CALLING_MODULE
            ,P_GANTT_CONFIG_ID         => P_GANTT_CONFIG_ID
            ,P_RECORD_VERSION_NUMBER   => P_RECORD_VERSION_NUMBER
            ,X_RETURN_STATUS           => X_RETURN_STATUS
            ,X_MSG_COUNT               => X_MSG_COUNT
            ,X_MSG_DATA                => X_MSG_DATA
          );

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := 'Error in deleting gantt config ';
             pa_debug.write(g_module_name,pa_debug.g_err_stage,l_debug_level4);
          END IF;
          Raise Invalid_Arg_Exc_GC;
     END IF;

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

     RETURN;

WHEN others THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_GANTT_CONFIG_PUB'
                    ,p_procedure_name  => 'DELETE_GANTT_CONFIG'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                              l_debug_level5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END DELETE_GANTT_CONFIG;

END PA_GANTT_CONFIG_PUB;

/
