--------------------------------------------------------
--  DDL for Package Body PA_PURGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PURGE_PUB" AS
-- $Header: PAXPURGB.pls 120.5.12010000.2 2010/01/29 06:48:07 amehrotr ship $
Invalid_Arg_Exc_Pjr EXCEPTION;

--
--  PROCEDURE
--             START_PROCESS
--  PURPOSE
--	       This API is called from the executable of the concurrent program :
--	       ADM: Purge Obsolete Projects Data
--	       Based on the Purge Type Value selected in the Concurrent Program ,
--	       It calls respective APIs to do the purging.
--
--  Parameter Name	In/Out	Data Type	Null?	Default Value	Description
--  -------------       ------  ----------      ------  -------------   ---------------------------------
--  P_PURGE_TYPE	IN	VARCHAR2	NOT NULL     	      Indicates the purge option.
--  Valid values are:	ALL	DAILY_FCST_INFO	PROJECTS_WORKFLOWS	REPORTING_EXCEPTIONS
--                      PURGE_ORG_AUTHORITY     PURGE_PJI_DEBUG
--
--  P_DEBUG_MODE	IN	VARCHAR2	NOT NULL 'N'	      Indicates the debug option.
--  Valid values are:	'Y'	'N'
--
--  P_COMMIT_SIZE	IN	NUMBER		NOT NULL  10000	      Indicates the commit size.
--  ERRBUF		OUT	VARCHAR2	N/A	  N/A	      Indicates the error buffer to the concurrent program.
--  RETCODE		OUT	VARCHAR2	N/A	  N/A         Indicates the return code to the concurrent program.

--  HISTORY
--  avaithia            01-March-2006            Created
--

PROCEDURE START_PROCESS
(
errbuf          OUT     NOCOPY  VARCHAR2                        ,
retcode         OUT     NOCOPY  VARCHAR2                        ,
p_purge_type    IN              VARCHAR2                        ,
p_debug_mode    IN              VARCHAR2        DEFAULT 'N'     ,
p_commit_size   IN              NUMBER          DEFAULT  10000
)
IS
        l_request_id                    NUMBER;
        l_debug_level3                  NUMBER := 3;
        l_msg_count                     NUMBER := 0;
        l_msg_data                      VARCHAR2(2000);
        l_data                          VARCHAR2(2000);
        l_msg_index_out                 NUMBER;
        l_return_status                 VARCHAR2(2000);
        l_local_error_flag              VARCHAR2(1):='N'; -- 5201806
BEGIN
        l_request_id  := FND_GLOBAL.CONC_REQUEST_ID;

	-- Save Point doesnt make sense here
	-- As the APIs which this API calls ,have intermediate commits
	-- in them . So,this save point would be lost anyway.

	errbuf := NULL ;
	retcode := 0;
	l_return_status := FND_API.G_RET_STS_SUCCESS;
	pa_debug.set_err_stack('PA_PURGE_PUB.START_PROCESS');
	FND_MSG_PUB.initialize;

	pa_debug.set_process('PLSQL','LOG',p_debug_mode);

	IF p_debug_mode = 'Y' THEN
     		pa_debug.set_curr_function( p_function   => 'START_PROCESS', p_debug_mode => p_debug_mode );
     		pa_debug.g_err_stage:= 'Entering START_PROCESS - Request Id : ' || l_request_id;
     		pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
		pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
		pa_debug.g_err_stage:= 'Purge Type is ' || p_purge_type ;
		pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
                pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
		pa_debug.g_err_stage:= 'Commit Size is ' || p_commit_size ;
                pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
                pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
	END IF;

	IF p_purge_type IS NULL THEN
		IF p_debug_mode = 'Y' THEN
			pa_debug.g_err_stage:= 'Mandatory parameter to this API : Purge Type is NULL';
			pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
		END IF;

		l_return_status := FND_API.G_RET_STS_ERROR;
		PA_UTILS.ADD_MESSAGE
                        (p_app_short_name => 'PA',
                         p_msg_name       => 'PA_INV_PARAM_PASSED');
		RAISE Invalid_Arg_Exc_Pjr;
	END IF;


        IF p_purge_type in ('ALL', 'DAILY_FCST_INFO') THEN
		IF p_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Before Calling PA_PURGE_PUB.PURGE_FORECAST_ITEMS';
                        pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
                END IF;

                PA_PURGE_PUB.PURGE_FORECAST_ITEMS
                (
                        p_debug_mode => p_debug_mode ,
                        p_commit_size => p_commit_size ,
                        p_request_id  => l_request_id ,
                        x_return_status => l_return_status,
                        x_msg_count => l_msg_count,
                        x_msg_data => l_msg_data
                );

                IF p_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'PA_PURGE_PUB.PURGE_FORECAST_ITEMS returned status ' || l_return_status;
                        pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
                        pa_debug.g_err_stage:= 'PA_PURGE_PUB.PURGE_FORECAST_ITEMS returned l_msg_count as '||l_msg_count;
                        pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
                        pa_debug.g_err_stage:= 'PA_PURGE_PUB.PURGE_FORECAST_ITEMS returned l_msg_data as ' || substrb(l_msg_data,1,240);
                        pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
                END IF;

                IF  l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        l_local_error_flag := 'Y'; -- 5201806
                END IF ;
        END IF; -- 5171235

	IF p_purge_type in ('ALL','PROJECTS_WORKFLOWS') THEN -- 5171235
                IF p_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Before Calling PA_PURGE_PUB.PURGE_PROJ_WORKFLOW';
                        pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
                END IF;

                PA_PURGE_PUB.PURGE_PROJ_WORKFLOW
                (
                        p_debug_mode => p_debug_mode ,
                        p_commit_size => p_commit_size ,
                        p_request_id  => l_request_id ,
                        x_return_status => l_return_status,
                        x_msg_count => l_msg_count,
                        x_msg_data => l_msg_data
                );

                IF p_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'PA_PURGE_PUB.PURGE_PROJ_WORKFLOW returned status ' || l_return_status;
                        pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
                        pa_debug.g_err_stage:= 'PA_PURGE_PUB.PURGE_PROJ_WORKFLOW returned l_msg_count as '||l_msg_count;
                        pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
                        pa_debug.g_err_stage:= 'PA_PURGE_PUB.PURGE_PROJ_WORKFLOW returned l_msg_data as ' || substrb(l_msg_data,1,240);
                        pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
                END IF;

                IF  l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        l_local_error_flag := 'Y'; -- 5201806
                END IF ;
	END IF; -- 5171235

 	IF p_purge_type in ('ALL', 'REPORTING_EXCEPTIONS') THEN -- 5171235

                IF p_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Before Calling PA_PURGE_PUB.PURGE_REPORTING_EXCEPTIONS';
                        pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
                END IF;


                PA_PURGE_PUB.PURGE_REPORTING_EXCEPTIONS
                (
                        p_debug_mode => p_debug_mode ,
                        p_commit_size => p_commit_size ,
                        p_request_id  => l_request_id ,
                        x_return_status => l_return_status,
                        x_msg_count => l_msg_count,
                        x_msg_data => l_msg_data
                );

                IF p_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'PA_PURGE_PUB.PURGE_REPORTING_EXCEPTIONS returned status ' || l_return_status;
                        pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
                        pa_debug.g_err_stage:= 'PA_PURGE_PUB.PURGE_REPORTING_EXCEPTIONS returned l_msg_count as '||l_msg_count;
                        pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
                        pa_debug.g_err_stage:= 'PA_PURGE_PUB.PURGE_REPORTING_EXCEPTIONS returned l_msg_data as ' || substrb(l_msg_data,1,240);
                        pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
                END IF;

                IF  l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        l_local_error_flag := 'Y'; -- 5201806
		END IF ;

	END IF;

	IF p_purge_type in ('ALL', 'ORG_AUTH') THEN

                IF p_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Before Calling PA_PURGE_PUB.PURGE_ORG_AUTHORITY';
                        pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
                END IF;


                PA_PURGE_PUB.PURGE_ORG_AUTHORITY
                (
                        p_debug_mode => p_debug_mode ,
                        p_commit_size => p_commit_size ,
                        p_request_id  => l_request_id ,
                        x_return_status => l_return_status,
                        x_msg_count => l_msg_count,
                        x_msg_data => l_msg_data
                );

                IF p_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'PA_PURGE_PUB.PURGE_ORG_AUTHORITY returned status ' || l_return_status;
                        pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
                        pa_debug.g_err_stage:= 'PA_PURGE_PUB.PURGE_ORG_AUTHORITY returned l_msg_count as '||l_msg_count;
                        pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
                        pa_debug.g_err_stage:= 'PA_PURGE_PUB.PURGE_ORG_AUTHORITY returned l_msg_data as ' || substrb(l_msg_data,1,240);
                        pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
                END IF;

                IF  l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        l_local_error_flag := 'Y';
		END IF ;
	END IF;

	IF p_purge_type in ('ALL', 'PJI_DEBUG') THEN

                IF p_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Before Calling PA_PURGE_PUB.PURGE_PJI_DEBUG';
                        pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
                END IF;


                PA_PURGE_PUB.PURGE_PJI_DEBUG
                (
                        p_debug_mode => p_debug_mode ,
                        p_commit_size => p_commit_size ,
                        p_request_id  => l_request_id ,
                        x_return_status => l_return_status,
                        x_msg_count => l_msg_count,
                        x_msg_data => l_msg_data
                );

                IF p_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'PA_PURGE_PUB.PURGE_PJI_DEBUG returned status ' || l_return_status;
                        pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
                        pa_debug.g_err_stage:= 'PA_PURGE_PUB.PURGE_PJI_DEBUG returned l_msg_count as '||l_msg_count;
                        pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
                        pa_debug.g_err_stage:= 'PA_PURGE_PUB.PURGE_PJI_DEBUG returned l_msg_data as ' || substrb(l_msg_data,1,240);
                        pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
                END IF;

                IF  l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        l_local_error_flag := 'Y';
		END IF ;
	END IF;

        PA_PURGE_PUB.PRINT_OUTPUT_REPORT
        (
                 p_request_id => l_request_id
                ,x_return_status => l_return_status
                ,x_msg_count => l_msg_count
                ,x_msg_data => l_msg_data
        );

        IF  l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                --RAISE FND_API.G_EXC_ERROR; -- 5201806
                l_local_error_flag := 'Y'; -- 5201806
        END IF;

        COMMIT;

        IF  l_local_error_flag = 'Y' THEN  -- 5201806
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF p_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'Successfully Exiting START_PROCESS ';
                pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
                pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);

                pa_debug.reset_err_stack;
                pa_debug.reset_curr_function;
        END IF;

EXCEPTION
        WHEN Invalid_Arg_Exc_Pjr THEN
                l_return_status := FND_API.G_RET_STS_ERROR;
                l_msg_count := FND_MSG_PUB.count_msg;
                retcode     := '-1';

                IF p_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Inside Invalid Argument exception of START_PROCESS API';
                        pa_debug.write_file('START_PROCESS : '||  pa_debug.g_err_stage);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
                END IF;

                -- 5201806 : Commented not needed
                --IF l_msg_count >= 1 THEN
                --        PA_INTERFACE_UTILS_PUB.get_messages
                --              (p_encoded        => FND_API.G_TRUE, -- 5201806 : It should have been FALSE
                --              p_msg_index      => 1,
                --              p_msg_count      => l_msg_count,
                --              p_msg_data       => l_msg_data,
                --              p_data           => l_data,
                --              p_msg_index_out  => l_msg_index_out);
                --
                --        errbuf := l_data;
                -- END IF;

                FOR i in 1..FND_MSG_PUB.count_msg LOOP -- 5201806
                        PA_INTERFACE_UTILS_PUB.get_messages
                                (p_encoded        => FND_API.G_FALSE,
                                p_msg_index      => 1,
                                p_msg_count      => l_msg_count,
                                p_msg_data       => l_msg_data,
                                p_data           => l_data,
                                p_msg_index_out  => l_msg_index_out);

                        pa_debug.write_file('Error : ' ||i||': '|| l_data);
                        IF i = FND_MSG_PUB.count_msg THEN
                            errbuf := l_data;
                        END IF;
                END LOOP;

                IF p_debug_mode = 'Y' THEN
                        pa_debug.write_file('START_PROCESS :' || l_data);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',l_data,l_debug_level3);
                        pa_debug.reset_err_stack;
                        pa_debug.reset_curr_function;
                END IF ;
                -- No raise as per FD

        WHEN FND_API.G_EXC_ERROR THEN
                l_return_status := FND_API.G_RET_STS_ERROR;
                l_msg_count := FND_MSG_PUB.count_msg;
                retcode     := '-1';

                IF p_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Inside Expected Error block of START_PROCESS API';
                        pa_debug.write_file('START_PROCESS : '||  pa_debug.g_err_stage);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
                END IF;

                -- 5201806 : Commented not needed
                --IF l_msg_count >= 1 THEN
                --        PA_INTERFACE_UTILS_PUB.get_messages
                --              (p_encoded        => FND_API.G_TRUE, -- 5201806 : It should have been FALSE
                --              p_msg_index      => 1,
                --              p_msg_count      => l_msg_count,
                --              p_msg_data       => l_msg_data,
                --              p_data           => l_data,
                --              p_msg_index_out  => l_msg_index_out);
                --
                --        errbuf := l_data;
                -- END IF;

                FOR i in 1..FND_MSG_PUB.count_msg LOOP -- 5201806
                        PA_INTERFACE_UTILS_PUB.get_messages
                                (p_encoded        => FND_API.G_FALSE,
                                p_msg_index      => 1,
                                p_msg_count      => l_msg_count,
                                p_msg_data       => l_msg_data,
                                p_data           => l_data,
                                p_msg_index_out  => l_msg_index_out);

                        pa_debug.write_file('Error : ' ||i||': '|| l_data);
                        IF i = FND_MSG_PUB.count_msg THEN
                            errbuf := l_data;
                        END IF;
                END LOOP;


                IF p_debug_mode = 'Y' THEN
                        pa_debug.write_file('START_PROCESS :' || l_data);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',l_data,l_debug_level3);
                        pa_debug.reset_err_stack;
                        pa_debug.reset_curr_function;
                END IF ;
                -- No raise as per FD

        WHEN OTHERS THEN
                l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                retcode         := '-1';
                errbuf          := SUBSTRB(SQLERRM,1,240);

                FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_PURGE_PUB'
                        ,p_procedure_name  => 'START_PROCESS'
                        ,p_error_text      => errbuf);

                FOR i in 1..FND_MSG_PUB.count_msg LOOP -- 5201806
                        PA_INTERFACE_UTILS_PUB.get_messages
                                (p_encoded        => FND_API.G_FALSE,
                                p_msg_index      => 1,
                                p_msg_count      => l_msg_count,
                                p_msg_data       => l_msg_data,
                                p_data           => l_data,
                                p_msg_index_out  => l_msg_index_out);

                        pa_debug.write_file('Error : ' ||i||': '|| l_data);
                        IF i = FND_MSG_PUB.count_msg THEN
                            errbuf := l_data;
                        END IF;
                END LOOP;


                IF p_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:='Unexpected Error'||errbuf;
                        pa_debug.write_file('START_PROCESS :' || pa_debug.g_err_stage);
                        pa_debug.write('PA_PURGE_PUB.START_PROCESS',pa_debug.g_err_stage,l_debug_level3);
                        pa_debug.reset_err_stack;
                        pa_debug.reset_curr_function;
                END IF;

                RAISE;

END START_PROCESS;

--
--  PROCEDURE
--		PURGE_FORECAST_ITEMS
--  PURPOSE
--             This API purges unused forecast item data from the 3 tables pa_forecast_items ,pa_forecast_item_details
--	       and pa_fi_amount_details
--
--  Parameter Name      In/Out  Data Type       Null?   Default Value   Description
--  -------------       ------  ----------      ------  -------------   ---------------------------------
--  P_DEBUG_MODE        IN      VARCHAR2        NOT NULL 'N'          Indicates the debug option.
--  P_COMMIT_SIZE       IN      NUMBER          NOT NULL  10000       Indicates the commit size.
--  P_REQUEST_ID 	IN      NUMBER          NOT NULL              Indicates the concurrent request id.
--  X_RETURN_STATUS	OUT	VARCHAR2	N/A	  N/A	      Indicates the return status of the API.
--  Valid values are:	'S' for Success	'E' for Error	'U' for Unexpected Error
--
--  X_MSG_COUNT		OUT	NUMBER		N/A	  N/A	      Indicates the number of error messages
--								      in the message stack.
--  X_MSG_DATA          OUT     VARCHAR2        N/A       N/A         Indicates the error message text
--								      if only one error exists.

--  HISTORY
--  avaithia            01-March-2006            Created
--

PROCEDURE PURGE_FORECAST_ITEMS
(
p_debug_mode    IN              VARCHAR2        DEFAULT  'N'    ,
p_commit_size   IN              NUMBER          DEFAULT  10000  ,
p_request_id    IN              NUMBER                          ,
x_return_status OUT     NOCOPY  VARCHAR2                        ,
x_msg_count 	OUT     NOCOPY  NUMBER                          ,
x_msg_data 	OUT     NOCOPY  VARCHAR2
)
IS

        l_fi_tbl                        SYSTEM.PA_NUM_TBL_TYPE          := SYSTEM.PA_NUM_TBL_TYPE();
        l_fi_type_tbl                   SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
        l_rows1                         NUMBER                          :=0;
        l_rows2                         NUMBER                          :=0;
        l_rows3                         NUMBER                          :=0;
        l_debug_level3              	NUMBER                          := 3;
        l_msg_data      	        VARCHAR2(2000);
        l_data 				VARCHAR2(2000);
        l_msg_count			NUMBER;
        l_msg_index_out			NUMBER;
        i				NUMBER;
        rowexists  			INTEGER;
        sql_command 			VARCHAR2(4000);
        source_cursor 			INTEGER;
        l_rows_returned			NUMBER;
        l_check_pji_summarized_flag	VARCHAR2(1)                     := 'N';
        l_util_summarized_Code_flag	VARCHAR2(1)                     := 'N';
        l_local_error_flag              VARCHAR2(1)                     :='N'; -- 5201806


        CURSOR c_get_forecast_item_ids IS
        SELECT forecast_item_id, forecast_item_type
        FROM pa_forecast_items
        WHERE delete_flag='Y';

        -- Commented because of GSCC Error File.Sql.47
        -- CURSOR c_table_exists(l_table_name IN VARCHAR2) IS
        -- SELECT 'Y'
        -- FROM dba_objects
        -- WHERE object_name= l_table_name AND  OBJECT_TYPE = 'TABLE';
BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS ;
        x_msg_count := 0;
        x_msg_data := NULL;

        IF p_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function( p_function   => 'PURGE_FORECAST_ITEMS',
                                            p_debug_mode => p_debug_mode);
                pa_debug.g_err_stage:= 'Inside PURGE_FORECAST_ITEMS API' ;
                pa_debug.write('PA_PURGE_PUB',pa_debug.g_err_stage,l_debug_level3);
        END IF;

	sql_command := 'SELECT 1 from dual where exists(SELECT NAME FROM PJI_SYSTEM_PARAMETERS)' ;

        BEGIN

                source_cursor := dbms_sql.open_cursor;
                dbms_sql.parse(source_cursor,sql_command,dbms_sql.native);
                rowexists := dbms_sql.execute(source_cursor);

                -- Bug 5201806 : Start
                l_rows_returned := DBMS_SQL.FETCH_ROWS(source_cursor);
                IF nvl(l_rows_returned,0) > 0 THEN
                        rowexists := 1 ; -- Assigning 1 to indicate that rowexists
                ELSE
                        rowexists := 0 ; -- No rows returned by cursor
                END IF;
                -- Bug 5201806 : End

                dbms_sql.close_cursor(source_cursor);
	EXCEPTION

	        WHEN OTHERS THEN
	                IF dbms_sql.is_open(source_cursor) THEN
                                dbms_sql.close_cursor(source_cursor);
                        END IF;
	                rowexists := 0;
        END;

        -- Commented below line for Bug 5175803
        -- IF l_exists = 'Y' AND rowexists > 0  THEN

        IF rowexists > 0  THEN -- Added for Bug 5175803
                l_check_pji_summarized_flag := 'Y' ;
        ELSE -- IF table doesnt exist or no data in this table ,then check only this flag
                l_util_summarized_Code_flag := 'Y';
        END IF;

        OPEN c_get_forecast_item_ids;
        LOOP
                l_fi_tbl.delete; -- 5201806
                l_fi_type_tbl.delete; -- 5201806
	        FETCH c_get_forecast_item_ids BULK COLLECT INTO l_fi_tbl,l_fi_type_tbl LIMIT p_commit_size ;
	        EXIT WHEN l_fi_tbl.COUNT <= 0 ;

                -- Forecast Item Details Delete
                BEGIN
                        -- If forecast_item_type is 'R' , no need to check for any other flag.
                        -- We can delete all the children and parent records.
                        FORALL i IN l_fi_tbl.FIRST..l_fi_tbl.LAST
                                DELETE FROM pa_forecast_item_details
                                WHERE forecast_item_id = l_fi_tbl(i)
                                AND l_fi_type_tbl(i)='R';

                        l_rows2 := l_rows2 + nvl(sql%rowcount,0); -- 5201806 : Using nvl in %rowcount
                        COMMIT;


                        -- IF forecast_item_type is not 'R' and pji_summarized_flag is checked.
                        IF l_check_pji_summarized_flag = 'Y' THEN
                                FORALL i IN l_fi_tbl.FIRST..l_fi_tbl.LAST
                                        DELETE FROM pa_forecast_item_details
                                        WHERE forecast_item_id = l_fi_tbl(i)
                                        AND l_fi_type_tbl(i) <> 'R'
                                        AND PJI_SUMMARIZED_FLAG in ('X','E');

                                l_rows2 := l_rows2 + nvl(sql%rowcount,0);
                                COMMIT;

                                -- Delete all child records with ALL (NULL or Y) .Otherwise, ALL N values
                                -- Performance fix 5201806
                                -- Included a direct join between the inner and outer queries

                                FORALL i IN l_fi_tbl.FIRST..l_fi_tbl.LAST
                                        DELETE FROM pa_forecast_item_details a
                                        WHERE a.forecast_item_id = l_fi_tbl(i)
                                        AND l_fi_type_tbl(i) <> 'R'
                                        AND ( 'Y' = ALL(SELECT nvl(b.PJI_SUMMARIZED_FLAG,'Y') -- All records are NULL or Y
                                                FROM pa_forecast_item_details b
                                                WHERE b.forecast_item_id = a.forecast_item_id)
                                        OR 'N' = ALL (SELECT nvl(c.PJI_SUMMARIZED_FLAG,'XYZ') -- Otherwise,All records should be N
                                                FROM pa_forecast_item_details c
                                                WHERE c.forecast_item_id = a.forecast_item_id)
                                        ) ;

                                l_rows2 := l_rows2 + nvl(sql%rowcount,0);
                                COMMIT;
                        END IF; -- End if pji_summarized_flag is being checked.


                        -- IF forecast_item_type is not 'R' and util_summarized_code is checked.
	                IF l_util_summarized_Code_flag = 'Y' THEN

		                -- delete all child records with UTIL_SUMMARIZED_CODE as 'X' and 'E'
                                FORALL i IN l_fi_tbl.FIRST..l_fi_tbl.LAST
                                        DELETE FROM pa_forecast_item_details
                                        WHERE forecast_item_id = l_fi_tbl(i)
                                        AND l_fi_type_tbl(i) <> 'R'
                                        AND UTIL_SUMMARIZED_CODE in ('X','E');

           	                l_rows2 := l_rows2 + nvl(sql%rowcount,0);
		                COMMIT;

                                -- Delete all child records with ALL (NULL or Y) .Otherwise, ALL N values
                                -- Performance fix 5201806
                                -- Included a direct join between the inner and outer queries

                                FORALL i IN l_fi_tbl.FIRST..l_fi_tbl.LAST
                                        DELETE FROM pa_forecast_item_details a
                                        where a.forecast_item_id = l_fi_tbl(i)
                                        and l_fi_type_tbl(i) <> 'R'
			                and ( 'Y' = ALL(SELECT nvl(b.UTIL_SUMMARIZED_CODE,'Y')
                                    	        FROM pa_forecast_item_details b
                                    	        WHERE b.forecast_item_id = a.forecast_item_id)
                                        OR 'N' = ALL (SELECT nvl(c.UTIL_SUMMARIZED_CODE,'XYZ')
                                  	        FROM pa_forecast_item_details c
                                  	        WHERE c.forecast_item_id = a.forecast_item_id)
                                        ) ;

                                l_rows2 := l_rows2 + nvl(sql%rowcount,0);
		                COMMIT;
	                END IF; -- End if util_summarized_code is being checked.

	                -- commit;  -- 5201806 : Now commit is happening after each delete

                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                NULL ; -- Do nothing
                        WHEN OTHERS THEN
                                --  RAISE;
	                        -- Dont raise ,Just increment the Number of Rows Deleted Counter for the number of rows
	                        -- successfully deleted so far.
                                l_rows2 := l_rows2 + nvl(sql%rowcount,0);
                                l_local_error_flag := 'Y'; -- 5201806 : Populate the error in stack
	                        Fnd_Msg_Pub.add_exc_msg
                                        ( p_pkg_name        => 'PA_PURGE_PUB'
                                        , p_procedure_name  => 'PURGE_FORECAST_ITEMS'
                                        , p_error_text      => SUBSTRB(SQLERRM,1,240));
                                EXIT; -- 5201806 : exit the loop after discussion with Anders.
                END;

                -- FI Amount Details Delete
                BEGIN
	                -- 5175803 Performance fix: Included a direct join between the inner and outer queries
                        -- 5201806 : Added l_fi_type_tbl join too. R type records are deleted from pa_forecast_item_details
                        -- without any conditions. So no need to check for their exostence.
	                FORALL i IN l_fi_tbl.FIRST..l_fi_tbl.LAST
		                DELETE FROM pa_fi_amount_details fi
		                WHERE fi.forecast_item_id = l_fi_tbl(i)
		                AND( (l_fi_type_tbl(i) = 'R')
		                OR (l_fi_type_tbl(i) <> 'R'
		                AND NOT EXISTS( SELECT 'Y' from pa_forecast_item_details dtl
                                    WHERE dtl.forecast_item_id = fi.forecast_item_id)))
				    ;

                        l_rows3 := l_rows3 + nvl(sql%rowcount,0);
	                COMMIT;

                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                NULL ; -- Do nothing
                        WHEN OTHERS THEN
                                -- RAISE;
                                -- Dont raise ,Just increment the Number of Rows Deleted Counter for the number of rows
                                -- successfully deleted so far.
	                        l_rows3 := l_rows3 + nvl(sql%rowcount,0);
                                l_local_error_flag := 'Y'; -- 5201806 : Populate the error in stack
	                        Fnd_Msg_Pub.add_exc_msg
                                        ( p_pkg_name        => 'PA_PURGE_PUB'
                                        , p_procedure_name  => 'PURGE_FORECAST_ITEMS'
                                        , p_error_text      => SUBSTRB(SQLERRM,1,240));
                                EXIT; -- 5201806 : exit the loop after discussion with Anders.
                END;

                -- Forecast Items Delete
                BEGIN

                        -- 5175803 Performance fix
                        -- Included a direct join between the inner and outer queries
                        -- 5201806 : Added l_fi_type_tbl join too. R type records are deleted from pa_forecast_item_details
                        -- without any conditions. So no need to check for their exostence.
                        FORALL i IN l_fi_tbl.FIRST..l_fi_tbl.LAST
                                DELETE FROM pa_forecast_items fi
                                WHERE fi.forecast_item_id = l_fi_tbl(i)
		                AND( (forecast_item_type = 'R')
		                OR (forecast_item_type <> 'R'
		                AND NOT EXISTS( SELECT 'Y' from pa_forecast_item_details dtl
                                WHERE dtl.forecast_item_id = fi.forecast_item_id)))
				;

                        l_rows1 := l_rows1 + nvl(sql%rowcount,0);
                        COMMIT;

                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                NULL ; -- Do nothing
                        WHEN OTHERS THEN
                                -- RAISE;
                                -- Dont raise ,Just increment the Number of Rows Deleted Counter for the number of rows
                                -- successfully deleted so far.
	                        l_rows1 := l_rows1 + nvl(sql%rowcount,0);
                                l_local_error_flag := 'Y'; -- 5201806 : Populate the error in stack
	                        Fnd_Msg_Pub.add_exc_msg
                                        ( p_pkg_name        => 'PA_PURGE_PUB'
                                        , p_procedure_name  => 'PURGE_FORECAST_ITEMS'
                                        , p_error_text      => SUBSTRB(SQLERRM,1,240));
                                EXIT; -- 5201806 : exit the loop after discussion with Anders.
                END;
        END LOOP;
        CLOSE c_get_forecast_item_ids;

        IF p_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'No. of rows deleted from pa_forecast_items - ' || l_rows1 ;
                pa_debug.write('PA_PURGE_PUB',pa_debug.g_err_stage,l_debug_level3);
                pa_debug.g_err_stage:= 'No. of rows deleted from pa_forecast_item_details - ' || l_rows2;
                pa_debug.write('PA_PURGE_PUB',pa_debug.g_err_stage,l_debug_level3);
                pa_debug.g_err_stage:= 'No. of rows deleted from pa_fi_amount_details - ' ||l_rows3;
                pa_debug.write('PA_PURGE_PUB',pa_debug.g_err_stage,l_debug_level3);
        END IF;

        -- Write this info into log table
        PA_PURGE_PUB.INSERT_PURGE_LOG
        (
                p_request_id => p_request_id ,
                p_table_name => 'PA_FORECAST_ITEMS' ,
                p_rows_deleted => l_rows1 ,
                x_return_status => x_return_status ,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	        --RAISE FND_API.G_EXC_ERROR;
                l_local_error_flag := 'Y'; -- 5201806
        END IF;


        PA_PURGE_PUB.INSERT_PURGE_LOG
        (
                p_request_id => p_request_id ,
                p_table_name => 'PA_FORECAST_ITEM_DETAILS',
                p_rows_deleted => l_rows2,
                x_return_status => x_return_status ,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	        --RAISE FND_API.G_EXC_ERROR;
                l_local_error_flag := 'Y'; -- 5201806
        END IF;

        PA_PURGE_PUB.INSERT_PURGE_LOG
        (
                p_request_id => p_request_id ,
                p_table_name => 'PA_FI_AMOUNT_DETAILS',
                p_rows_deleted => l_rows3,
                x_return_status => x_return_status ,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	        --RAISE FND_API.G_EXC_ERROR;
                l_local_error_flag := 'Y'; -- 5201806
        END IF;

        IF l_local_error_flag = 'Y' THEN -- 5201806
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF p_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'Successfully inserted Log details pertaining to PA_FI_AMOUNT_DETAILS';
                pa_debug.write('PA_PURGE_PUB',pa_debug.g_err_stage,l_debug_level3);
                pa_debug.g_err_stage:= 'Exiting PURGE_FORECAST_ITEMS';
                pa_debug.write('PA_PURGE_PUB','PA_PURGE_PUB.PURGE_FORECAST_ITEMS :' || pa_debug.g_err_stage,l_debug_level3);
                pa_debug.reset_curr_function;
        END IF;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := Fnd_Api.G_RET_STS_ERROR;
                x_msg_count := Fnd_Msg_Pub.count_msg; -- 5201806 Changed to x_msg_count

                IF c_get_forecast_item_ids%ISOPEN THEN
                        CLOSE c_get_forecast_item_ids;
                END IF;

--                5201806 : Commented not needed...
--                IF l_msg_count >= 1 AND x_msg_data IS NULL
--                THEN
--                        Pa_Interface_Utils_Pub.get_messages
--                        ( p_encoded        => Fnd_Api.G_TRUE
--                        , p_msg_index      => 1
--                        , p_msg_count      => l_msg_count
--                        , p_msg_data       => l_msg_data
--                        , p_data           => l_data
--                        , p_msg_index_out  => l_msg_index_out);
--                        x_msg_data := l_data;
--                        x_msg_count := l_msg_count;
--                ELSE
--                        x_msg_count := l_msg_count;
--                END IF;

                IF p_debug_mode = 'Y' THEN
                        Pa_Debug.reset_curr_function;
                END IF;
        WHEN OTHERS THEN
                x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
                x_msg_count     := 1;
                x_msg_data      := SUBSTRB(SQLERRM,1,240);

                IF c_get_forecast_item_ids%ISOPEN THEN
                        CLOSE c_get_forecast_item_ids;
                END IF;

                Fnd_Msg_Pub.add_exc_msg
                        ( p_pkg_name        => 'PA_PURGE_PUB'
                        , p_procedure_name  => 'PURGE_FORECAST_ITEMS'
                        , p_error_text      => x_msg_data);

                x_msg_count := FND_MSG_PUB.count_msg; --5201806

                IF p_debug_mode = 'Y' THEN
                        Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
                        Pa_Debug.WRITE('PA_PURGE_PUB',Pa_Debug.g_err_stage, 5);
                        Pa_Debug.reset_curr_function;
                END IF;
                -- RAISE; 5201806 Do not raise in internal APIs
END PURGE_FORECAST_ITEMS ;

--
--  PROCEDURE
--              PURGE_PROJ_WORKFLOW
--  PURPOSE
--             This API purges unused denormalized workflow data from 3 tables pa_wf_processes , pa_wf_process_details
--		and pa_wf_ntf_performers
--
--
--  Parameter Name      In/Out  Data Type       Null?   Default Value   Description
--  -------------       ------  ----------      ------  -------------   ---------------------------------
--  P_DEBUG_MODE        IN      VARCHAR2        NOT NULL 'N'          Indicates the debug option.
--  P_COMMIT_SIZE       IN      NUMBER          NOT NULL  10000       Indicates the commit size.
--  P_REQUEST_ID        IN      NUMBER          NOT NULL              Indicates the concurrent request id.
--  X_RETURN_STATUS     OUT     VARCHAR2        N/A       N/A         Indicates the return status of the API.
--  Valid values are:   'S' for Success 'E' for Error   'U' for Unexpected Error
--
--  X_MSG_COUNT         OUT     NUMBER          N/A       N/A         Indicates the number of error messages
--                                                                    in the message stack.
--  X_MSG_DATA          OUT     VARCHAR2        N/A       N/A         Indicates the error message text
--                                                                    if only one error exists.

--  HISTORY
--  avaithia            01-March-2006            Created
--

PROCEDURE PURGE_PROJ_WORKFLOW
(
p_debug_mode    IN              VARCHAR2        DEFAULT  'N'    ,
p_commit_size   IN              NUMBER          DEFAULT  10000  ,
p_request_id    IN              NUMBER                          ,
x_return_status OUT     NOCOPY  VARCHAR2                        ,
x_msg_count     OUT     NOCOPY  NUMBER                          ,
x_msg_data      OUT     NOCOPY  VARCHAR2
)
IS
        l_wf_item_type_tbl      SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE ();
        l_wf_item_key_tbl       SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE ();
        l_wf_type_code_tbl      SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE ();
        l_debug_level3 		NUMBER                          := 3;
        i			NUMBER;
        l_rows1			NUMBER                          := 0;
        l_rows2                 NUMBER                          := 0;
        l_rows3                 NUMBER                          := 0;
        l_msg_data              VARCHAR2(2000);
        l_data                  VARCHAR2(2000);
        l_msg_count             NUMBER;
        l_msg_index_out         NUMBER;
        l_local_error_flag      VARCHAR2(1)                     :='N'; -- 5201806

        CURSOR c_purge_wf_details IS
        SELECT a.item_type, a.item_key, a.wf_type_code
        FROM pa_wf_processes a
        WHERE
        a.item_type in ('PACANDID','PACOPR','PARADVWF','PARAPTEM','PARFIGEN','PAROVCNT','PAWFGPF','PAYPRJNT','PARMATRX','PAXWFHRU')
        AND a.item_key NOT IN
                (SELECT wi.item_key
                FROM wf_items wi
                WHERE wi.item_type IN ('PACANDID','PACOPR','PARADVWF','PARAPTEM','PARFIGEN','PAROVCNT','PAWFGPF','PAYPRJNT','PARMATRX','PAXWFHRU')
        );

BEGIN
        x_return_status := FND_API.G_RET_STS_SUCCESS ;
        x_msg_count := 0;
        x_msg_data := NULL;

        IF p_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function( p_function   => 'PURGE_PROJ_WORKFLOW', p_debug_mode => p_debug_mode);
                pa_debug.g_err_stage:= 'Inside PURGE_PROJ_WORKFLOW API' ;
                pa_debug.write('PA_PURGE_PUB',pa_debug.g_err_stage,l_debug_level3);
        END IF;

        OPEN c_purge_wf_details ;
        LOOP
                l_wf_item_type_tbl.delete; -- 5201806
                l_wf_item_key_tbl.delete; -- 5201806
                l_wf_type_code_tbl.delete; -- 5201806

                FETCH c_purge_wf_details BULK COLLECT INTO l_wf_item_type_tbl,l_wf_item_key_tbl,l_wf_type_code_tbl LIMIT p_commit_size;
	        EXIT WHEN l_wf_item_type_tbl.COUNT <= 0;

                -- Delete pa_wf_ntf_performers
                BEGIN

                        FORALL i IN l_wf_item_type_tbl.FIRST..l_wf_item_type_tbl.LAST
                                DELETE FROM PA_WF_NTF_PERFORMERS
                                WHERE item_key = l_wf_item_key_tbl(i)
                                AND item_type = l_wf_item_type_tbl(i)
                                AND wf_type_code = l_wf_type_code_tbl(i);

                        l_rows3 := l_rows3 + nvl(sql%rowcount,0);
                        COMMIT;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                NULL ; -- Do nothing
                        WHEN OTHERS THEN
                                -- RAISE;
                                -- Dont raise ,Just increment the Number of Rows Deleted Counter for the number of rows
                                -- successfully deleted so far.
	                        l_rows3 := l_rows3 + nvl(sql%rowcount,0);
                                l_local_error_flag := 'Y'; -- 5201806 : Populate the error in stack
	                        Fnd_Msg_Pub.add_exc_msg
                                        ( p_pkg_name        => 'PA_PURGE_PUB'
                                        , p_procedure_name  => 'PURGE_PROJ_WORKFLOW'
                                        , p_error_text      => SUBSTRB(SQLERRM,1,240));
                                EXIT; -- 5201806 : exit the loop after discussion with Anders.
                END;

                -- Delete pa_wf_process_details
	        BEGIN

                        FORALL i IN l_wf_item_type_tbl.FIRST..l_wf_item_type_tbl.LAST
                                DELETE FROM pa_wf_process_details
                                WHERE item_key=l_wf_item_key_tbl(i)
	                        AND item_type = l_wf_item_type_tbl(i)
	                        AND wf_type_code = l_wf_type_code_tbl(i) ;

                        l_rows2 := l_rows2 + nvl(sql%rowcount,0);
                        COMMIT;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                NULL ; -- Do nothing
                        WHEN OTHERS THEN
                                -- RAISE;
                                -- Dont raise ,Just increment the Number of Rows Deleted Counter for the number of rows
                                -- successfully deleted so far.
	                        l_rows2 := l_rows2 + nvl(sql%rowcount,0);
                                l_local_error_flag := 'Y'; -- 5201806 : Populate the error in stack
	                        Fnd_Msg_Pub.add_exc_msg
                                        ( p_pkg_name        => 'PA_PURGE_PUB'
                                        , p_procedure_name  => 'PURGE_PROJ_WORKFLOW'
                                        , p_error_text      => SUBSTRB(SQLERRM,1,240));
                                EXIT; -- 5201806 : exit the loop after discussion with Anders.
                END;

                -- Delete pa_wf_processes
                BEGIN
                        FORALL i IN l_wf_item_type_tbl.FIRST..l_wf_item_type_tbl.LAST
                                DELETE FROM pa_wf_processes
                                WHERE item_key=l_wf_item_key_tbl(i)
                                AND item_type = l_wf_item_type_tbl(i)
		                AND wf_type_code = l_wf_type_code_tbl(i);

                        l_rows1 := l_rows1 + nvl(sql%rowcount,0);
                        COMMIT;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                NULL ; -- Do nothing
                        WHEN OTHERS THEN
                                -- RAISE;
                                -- Dont raise ,Just increment the Number of Rows Deleted Counter for the number of rows
                                -- successfully deleted so far.
	                        l_rows1 := l_rows1 + nvl(sql%rowcount,0);
                                l_local_error_flag := 'Y'; -- 5201806 : Populate the error in stack
	                        Fnd_Msg_Pub.add_exc_msg
                                        ( p_pkg_name        => 'PA_PURGE_PUB'
                                        , p_procedure_name  => 'PURGE_PROJ_WORKFLOW'
                                        , p_error_text      => SUBSTRB(SQLERRM,1,240));
                                EXIT; -- 5201806 : exit the loop after discussion with Anders.
                END;
        END LOOP;
        CLOSE c_purge_wf_details;

        IF p_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'No. of rows deleted from pa_wf_processes ' || l_rows1 ;
                pa_debug.write('PA_PURGE_PUB',pa_debug.g_err_stage,l_debug_level3);
                pa_debug.g_err_stage:= 'No. of rows deleted from pa_wf_process_details ' || l_rows2 ;
                pa_debug.write('PA_PURGE_PUB',pa_debug.g_err_stage,l_debug_level3);
                pa_debug.g_err_stage:= 'No. of rows deleted from pa_wf_ntf_performers ' || l_rows3 ;
                pa_debug.write('PA_PURGE_PUB',pa_debug.g_err_stage,l_debug_level3);
        END IF;


        PA_PURGE_PUB.INSERT_PURGE_LOG
        (
                p_request_id => p_request_id ,
                p_table_name => 'PA_WF_PROCESSES' ,
                p_rows_deleted => l_rows1 ,
                x_return_status => x_return_status ,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        --RAISE FND_API.G_EXC_ERROR;
                        l_local_error_flag := 'Y'; -- 5201806
        END IF;


        PA_PURGE_PUB.INSERT_PURGE_LOG
        (
                p_request_id => p_request_id ,
                p_table_name => 'PA_WF_PROCESS_DETAILS',
                p_rows_deleted => l_rows2,
                x_return_status => x_return_status ,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        --RAISE FND_API.G_EXC_ERROR;
                        l_local_error_flag := 'Y'; -- 5201806
        END IF;

        PA_PURGE_PUB.INSERT_PURGE_LOG
        (
                p_request_id => p_request_id ,
                p_table_name => 'PA_WF_NTF_PERFORMERS',
                p_rows_deleted => l_rows3,
                x_return_status => x_return_status ,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        --RAISE FND_API.G_EXC_ERROR;
                        l_local_error_flag := 'Y'; -- 5201806
        END IF;

        IF l_local_error_flag = 'Y' THEN -- 5201806
                RAISE FND_API.G_EXC_ERROR;
        END IF;


        IF p_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'Successfully inserted Log details pertaining to PA_WF_NTF_PERFORMERS';
                pa_debug.write('PA_PURGE_PUB',pa_debug.g_err_stage,l_debug_level3);
                pa_debug.g_err_stage:= 'Exiting PURGE_PROJ_WORKFLOW';
                pa_debug.write('PA_PURGE_PUB','PA_PURGE_PUB.PURGE_PROJ_WORKFLOW :' || pa_debug.g_err_stage,l_debug_level3);
                pa_debug.reset_curr_function;
        END IF;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := Fnd_Api.G_RET_STS_ERROR;
                x_msg_count := Fnd_Msg_Pub.count_msg; -- 5201806 Changed to x_msg_count

                IF c_purge_wf_details%ISOPEN THEN
                        Close c_purge_wf_details;
                END IF;

--                5201806 : Commented not needed...
--                IF l_msg_count >= 1 AND x_msg_data IS NULL
--                THEN
--                        Pa_Interface_Utils_Pub.get_messages
--                        ( p_encoded        => Fnd_Api.G_TRUE
--                        , p_msg_index      => 1
--                        , p_msg_count      => l_msg_count
--                        , p_msg_data       => l_msg_data
--                        , p_data           => l_data
--                        , p_msg_index_out  => l_msg_index_out);
--                        x_msg_data := l_data;
--                        x_msg_count := l_msg_count;
--                ELSE
--                        x_msg_count := l_msg_count;
--                END IF;

                IF p_debug_mode = 'Y' THEN
                        Pa_Debug.reset_curr_function;
                END IF;

        WHEN OTHERS THEN
                x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
                x_msg_count     := 1;
                x_msg_data      := SUBSTRB(SQLERRM,1,240);

                IF c_purge_wf_details%ISOPEN THEN
                        Close c_purge_wf_details;
                END IF;

                Fnd_Msg_Pub.add_exc_msg
                ( p_pkg_name        => 'PA_PURGE_PUB'
                , p_procedure_name  => 'PURGE_PROJ_WORKFLOW'
                , p_error_text      => x_msg_data);

                x_msg_count := FND_MSG_PUB.count_msg;--5201806

                IF p_debug_mode = 'Y' THEN
                        Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
                        Pa_Debug.WRITE('PA_PURGE_PUB',Pa_Debug.g_err_stage, 5);
                        Pa_Debug.reset_curr_function;
                END IF;
                -- RAISE; 5201806 Do not raise in internal APIs
END PURGE_PROJ_WORKFLOW;

--
--  PROCEDURE
--              PURGE_REPORTING_EXCEPTIONS
--  PURPOSE
--		This API will purge unused reporting exception data from pa_reporting_exceptions
--
--  Parameter Name      In/Out  Data Type       Null?   Default Value   Description
--  -------------       ------  ----------      ------  -------------   ---------------------------------
--  P_DEBUG_MODE        IN      VARCHAR2        NOT NULL 'N'          Indicates the debug option.
--  P_COMMIT_SIZE       IN      NUMBER          NOT NULL  10000       Indicates the commit size.
--  P_REQUEST_ID        IN      NUMBER          NOT NULL              Indicates the concurrent request id.
--  X_RETURN_STATUS     OUT     VARCHAR2        N/A       N/A         Indicates the return status of the API.
--  Valid values are:   'S' for Success 'E' for Error   'U' for Unexpected Error
--
--  X_MSG_COUNT         OUT     NUMBER          N/A       N/A         Indicates the number of error messages
--                                                                    in the message stack.
--  X_MSG_DATA          OUT     VARCHAR2        N/A       N/A         Indicates the error message text
--                                                                    if only one error exists.

--  HISTORY
--  avaithia            01-March-2006            Created
--

PROCEDURE PURGE_REPORTING_EXCEPTIONS
(
p_debug_mode    IN              VARCHAR2        default  'N'    ,
p_commit_size   IN              NUMBER          default  10000  ,
p_request_id    IN              NUMBER                          ,
x_return_status OUT     NOCOPY  VARCHAR2                        ,
x_msg_count     OUT     NOCOPY  NUMBER                          ,
x_msg_data      OUT     NOCOPY  VARCHAR2
)
IS
        l_request_id_tbl        SYSTEM.PA_NUM_TBL_TYPE  := SYSTEM.PA_NUM_TBL_TYPE ();
        l_debug_level3	        NUMBER                  :=3;
        l_rows1                 NUMBER                  :=0;
        l_msg_data              VARCHAR2(2000);
        l_data                  VARCHAR2(2000);
        l_msg_count             NUMBER;
        l_msg_index_out         NUMBER;
        i                       NUMBER;
        l_local_error_flag      VARCHAR2(1)                     :='N'; -- 5201806

        CURSOR c_get_request_id IS
        SELECT request_id
        FROM pa_reporting_exceptions
        WHERE request_id not in
                (SELECT request_id
                FROM fnd_concurrent_requests)
        AND nvl(request_id,0) > 0;

        --Technically if the pa_reporting_exceptions.request_id does not exist in fnd_concurrent_requests.request_id,
        --then the record is eligible to be purged.  Note - the code must exclude request_id < 0 as the
        --mass assignment flows populate this table using request_id = -1.

BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS ;
        x_msg_count := 0;
        x_msg_data := NULL;

        IF p_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function( p_function   => 'PURGE_REPORTING_EXCEPTIONS', p_debug_mode => p_debug_mode);
                pa_debug.g_err_stage:= 'Entering PURGE_REPORTING_EXCEPTIONS API';
                Pa_Debug.WRITE('PA_PURGE_PUB',pa_debug.g_err_stage,l_debug_level3);
        END IF;

        OPEN c_get_request_id;
        LOOP
                l_request_id_tbl.delete; -- 5201806
	        FETCH c_get_request_id BULK COLLECT INTO l_request_id_tbl LIMIT p_commit_size ;
	        EXIT WHEN l_request_id_tbl.COUNT <= 0 ;

	        BEGIN
		        FORALL i IN l_request_id_tbl.FIRST..l_request_id_tbl.LAST
			        DELETE FROM pa_reporting_exceptions
                                WHERE request_id = l_request_id_tbl (i);

		        l_rows1 :=l_rows1+nvl(sql%rowcount,0);
		        COMMIT;
	        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                NULL ; -- Do nothing
                        WHEN OTHERS THEN
                                -- RAISE;
                                -- Dont raise ,Just increment the Number of Rows Deleted Counter for the number of rows
                                -- successfully deleted so far.
	                        l_rows1 :=l_rows1+nvl(sql%rowcount,0);
                                l_local_error_flag := 'Y'; -- 5201806 : Populate the error in stack
	                        Fnd_Msg_Pub.add_exc_msg
                                        ( p_pkg_name        => 'PA_PURGE_PUB'
                                        , p_procedure_name  => 'PURGE_REPORTING_EXCEPTIONS'
                                        , p_error_text      => SUBSTRB(SQLERRM,1,240));
                                EXIT; -- 5201806 : exit the loop after discussion with Anders.
                END;
        END LOOP;
        CLOSE c_get_request_id;

        IF p_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'No. of rows deleted from pa_reporting_exceptions ' || l_rows1 ;
                pa_debug.write('PA_PURGE_PUB',pa_debug.g_err_stage,l_debug_level3);
        END IF;


        PA_PURGE_PUB.INSERT_PURGE_LOG
        (
                p_request_id => p_request_id ,
                p_table_name => 'PA_REPORTING_EXCEPTIONS' ,
                p_rows_deleted => l_rows1 ,
                x_return_status => x_return_status ,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        --RAISE FND_API.G_EXC_ERROR;
                        l_local_error_flag := 'Y'; -- 5201806
        END IF;

        IF l_local_error_flag = 'Y' THEN -- 5201806
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF p_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'Successfully inserted Log details pertaining to pa_reporting_exceptions';
                pa_debug.write('PA_PURGE_PUB',pa_debug.g_err_stage,l_debug_level3);
                pa_debug.g_err_stage:= 'Exiting PURGE_REPORTING_EXCEPTIONS';
                pa_debug.write('PA_PURGE_PUB',pa_debug.g_err_stage,l_debug_level3);
                Pa_Debug.reset_curr_function;
        END IF;
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := Fnd_Api.G_RET_STS_ERROR;
                x_msg_count := Fnd_Msg_Pub.count_msg;  -- 5201806 Changed to x_msg_count

                IF c_get_request_id%ISOPEN THEN
                        CLOSE c_get_request_id;
                END IF;

--                5201806 : Commented not needed...
--                IF l_msg_count >= 1 AND x_msg_data IS NULL
--                THEN
--                        Pa_Interface_Utils_Pub.get_messages
--                        ( p_encoded        => Fnd_Api.G_TRUE
--                        , p_msg_index      => 1
--                        , p_msg_count      => l_msg_count
--                        , p_msg_data       => l_msg_data
--                        , p_data           => l_data
--                        , p_msg_index_out  => l_msg_index_out);
--
--                        x_msg_data := l_data;
--                        x_msg_count := l_msg_count;
--                ELSE
--                        x_msg_count := l_msg_count;
--                END IF;

                IF p_debug_mode = 'Y' THEN
                        Pa_Debug.reset_curr_function;
                END IF;
        WHEN OTHERS THEN
                x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
                x_msg_count     := 1;
                x_msg_data      := SUBSTRB(SQLERRM,1,240);

                IF c_get_request_id%ISOPEN THEN
                        CLOSE c_get_request_id;
                END IF;

                Fnd_Msg_Pub.add_exc_msg
                ( p_pkg_name        => 'PA_PURGE_PUB'
                , p_procedure_name  => 'PURGE_REPORTING_EXCEPTIONS'
                , p_error_text      => x_msg_data);

                x_msg_count := FND_MSG_PUB.count_msg; --5201806

                IF p_debug_mode = 'Y' THEN
                        Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
                        Pa_Debug.WRITE('PA_PURGE_PUB',Pa_Debug.g_err_stage, 5);
                        Pa_Debug.reset_curr_function;
                END IF;
                -- RAISE; 5201806 Do not raise in internal APIs
END PURGE_REPORTING_EXCEPTIONS;

--
--  PROCEDURE
--              PURGE_ORG_AUTHORITY
--  PURPOSE
--             This API purges organization authority records of all terminated employees or contingent
--             workers whose termination date is earlier than system date
--
--
--  Parameter Name      In/Out  Data Type       Null?   Default Value   Description
--  -------------       ------  ----------      ------  -------------   ---------------------------------
--  P_DEBUG_MODE        IN      VARCHAR2        NOT NULL 'N'          Indicates the debug option.
--  P_COMMIT_SIZE       IN      NUMBER          NOT NULL  10000       Indicates the commit size.
--  P_REQUEST_ID        IN      NUMBER          NOT NULL              Indicates the concurrent request id.
--  X_RETURN_STATUS     OUT     VARCHAR2        N/A       N/A         Indicates the return status of the API.
--  Valid values are:   'S' for Success 'E' for Error   'U' for Unexpected Error
--
--  X_MSG_COUNT         OUT     NUMBER          N/A       N/A         Indicates the number of error messages
--                                                                    in the message stack.
--  X_MSG_DATA          OUT     VARCHAR2        N/A       N/A         Indicates the error message text
--                                                                    if only one error exists.

--  HISTORY
--  bifernan            16-October-2007            Created
--  bifernan            05-February-2007           Bug 6749278: Performance changes.
--                                                 Added code to log number of grants deleted.
--

PROCEDURE PURGE_ORG_AUTHORITY
(
p_debug_mode    IN              VARCHAR2        DEFAULT  'N'    ,
p_commit_size   IN              NUMBER          DEFAULT  10000  ,
p_request_id    IN              NUMBER                          ,
x_return_status OUT     NOCOPY  VARCHAR2                        ,
x_msg_count     OUT     NOCOPY  NUMBER                          ,
x_msg_data      OUT     NOCOPY  VARCHAR2
)
IS

	l_person_id		per_all_people_f.person_id%TYPE;
	l_orginzation_id	NUMBER;
	l_menu_name		fnd_menus.menu_name%TYPE;
	l_debug_level3 		NUMBER		:= 3;
	i			NUMBER;
	l_local_error_flag	VARCHAR2(1)	:='N';
	l_grants_deleted	NUMBER		:= 0;
	l_return_status		VARCHAR2(30);

	CURSOR c_purge_org_authority IS
	SELECT DISTINCT per.person_id,
		   (to_number(fg.instance_pk1_value)) organization_id,
		   fm.menu_name
	       FROM    fnd_grants fg,
		   fnd_objects fo,
		   fnd_menus fm,
		   per_all_people_f per,
		   wf_roles wfr
	       WHERE    per.person_id IN ( SELECT person_id
				      FROM      per_periods_of_service ppos
				      WHERE    ppos.person_id = per.person_id
							  AND      ppos.actual_termination_date is not null
				      AND      NOT EXISTS (SELECT 1
					       FROM   per_periods_of_service
					       WHERE  person_id = ppos.person_id
					       AND actual_termination_date IS NULL )
				      GROUP BY person_id
				      HAVING   MAX(actual_termination_date) < SYSDATE
				      UNION
				      SELECT   person_id
				      FROM     per_periods_of_placement ppop
				      WHERE    ppop.person_id = per.person_id
							  AND      ppop.actual_termination_date is not null
				      AND      NOT EXISTS (SELECT 1
					       FROM   per_periods_of_placement
					       WHERE  person_id = ppop.person_id
					       AND actual_termination_date IS NULL )
				      GROUP BY person_id
				      HAVING   MAX(actual_termination_date) < SYSDATE )
	       AND fg.object_id = fo.object_id
	       AND fo.obj_name = 'ORGANIZATION'
	       AND fg.instance_type = 'INSTANCE'
	       AND fg.instance_pk1_value is not null
	       AND fg.grantee_key = wfr.NAME
	       AND fg.grantee_type = 'USER'
	       AND fg.instance_set_id is null
	       AND wfr.orig_system = 'HZ_PARTY'
	       AND per.party_id = wfr.orig_system_id
	       AND fg.menu_id = fm.menu_id
	       AND (TRUNC(SYSDATE) BETWEEN per.effective_start_date AND per.effective_end_date)
	       AND fm.menu_name IN ('PA_PRM_RES_AUTH', 'PA_PRM_PROJ_AUTH', 'PA_PRM_RES_PRMRY_CONTACT', 'PA_PRM_UTL_AUTH');

BEGIN
        x_return_status := FND_API.G_RET_STS_SUCCESS ;
        x_msg_count := 0;
        x_msg_data := NULL;

        IF p_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function( p_function   => 'PURGE_ORG_AUTHORITY', p_debug_mode => p_debug_mode);
                pa_debug.g_err_stage:= 'Inside PURGE_ORG_AUTHORITY API' ;
                pa_debug.write('PA_PURGE_PUB',pa_debug.g_err_stage,l_debug_level3);
        END IF;

        OPEN c_purge_org_authority;
        LOOP
		l_person_id := -1;
		l_orginzation_id := -1;

		FETCH c_purge_org_authority INTO l_person_id, l_orginzation_id, l_menu_name;
	        EXIT WHEN c_purge_org_authority%NOTFOUND;

		BEGIN
			-- Delete Resource authority
			IF l_menu_name = 'PA_PRM_RES_AUTH' THEN
				pa_resource_utils.delete_grant( p_person_id => l_person_id
								,p_org_id    => l_orginzation_id
								,p_role_name => 'PA_PRM_RES_AUTH'
								,x_return_status => l_return_status);
			-- Delete project authority
			ELSIF l_menu_name = 'PA_PRM_PROJ_AUTH' THEN
				pa_resource_utils.delete_grant( p_person_id => l_person_id
								,p_org_id    => l_orginzation_id
								,p_role_name => 'PA_PRM_PROJ_AUTH'
								,x_return_status => l_return_status);
			-- Delete primary contact
			ELSIF l_menu_name = 'PA_PRM_RES_PRMRY_CONTACT' THEN
				pa_resource_utils.delete_grant( p_person_id => l_person_id
								,p_org_id    => l_orginzation_id
								,p_role_name => 'PA_PRM_RES_PRMRY_CONTACT'
								,x_return_status => l_return_status);
			-- Delete utilization authority
			ELSIF l_menu_name = 'PA_PRM_UTL_AUTH' THEN
				pa_resource_utils.delete_grant( p_person_id => l_person_id
								,p_org_id    => l_orginzation_id
								,p_role_name => 'PA_PRM_UTL_AUTH'
								,x_return_status => l_return_status);
			END IF;

			IF (l_return_status IS NULL OR l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
				l_grants_deleted := l_grants_deleted + 1;
			END IF;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				NULL ; -- Do nothing
			WHEN OTHERS THEN
				l_local_error_flag := 'Y';
				Fnd_Msg_Pub.add_exc_msg
                                        ( p_pkg_name        => 'PA_PURGE_PUB'
                                        , p_procedure_name  => 'PURGE_ORG_AUTHORITY'
                                        , p_error_text      => SUBSTRB(SQLERRM,1,240));
				EXIT;
		END;

	END LOOP;
        CLOSE c_purge_org_authority;

	IF p_debug_mode = 'Y' THEN
		pa_debug.g_err_stage:= 'No. of grants deleted ' || l_grants_deleted;
		pa_debug.write('PA_PURGE_PUB',pa_debug.g_err_stage,l_debug_level3);
	END IF;

	PA_PURGE_PUB.INSERT_PURGE_LOG
	(
		p_request_id => p_request_id ,
		p_table_name => 'FND_GRANTS' ,
		p_rows_deleted => l_grants_deleted ,
		x_return_status => x_return_status ,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data
	);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			l_local_error_flag := 'Y';
	END IF;

	IF l_local_error_flag = 'Y' THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF p_debug_mode = 'Y' THEN
		pa_debug.g_err_stage:= 'Successfully inserted Log details pertaining to PURGE_ORG_AUTHORITY';
		pa_debug.write('PA_PURGE_PUB',pa_debug.g_err_stage,l_debug_level3);
		pa_debug.g_err_stage:= 'Exiting PURGE_ORG_AUTHORITY';
		pa_debug.write('PA_PURGE_PUB',pa_debug.g_err_stage,l_debug_level3);
		Pa_Debug.reset_curr_function;
	END IF;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN

	        x_return_status := Fnd_Api.G_RET_STS_ERROR;
                x_msg_count := Fnd_Msg_Pub.count_msg;

                IF c_purge_org_authority%ISOPEN THEN
                        CLOSE c_purge_org_authority;
                END IF;

		IF p_debug_mode = 'Y' THEN
                        Pa_Debug.reset_curr_function;
                END IF;

        WHEN OTHERS THEN

                x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
                x_msg_count     := 1;
                x_msg_data      := SUBSTRB(SQLERRM,1,240);

                IF c_purge_org_authority%ISOPEN THEN
                        CLOSE c_purge_org_authority;
                END IF;

                Fnd_Msg_Pub.add_exc_msg
                ( p_pkg_name        => 'PA_PURGE_PUB'
                , p_procedure_name  => 'PURGE_ORG_AUTHORITY'
                , p_error_text      => x_msg_data);

                x_msg_count := FND_MSG_PUB.count_msg;

                IF p_debug_mode = 'Y' THEN
                        Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
                        Pa_Debug.WRITE('PA_PURGE_PUB',Pa_Debug.g_err_stage, 5);
                        Pa_Debug.reset_curr_function;
                END IF;

END PURGE_ORG_AUTHORITY;

--
--  PROCEDURE
--              PURGE_PJI_DEBUG
--  PURPOSE
--             This API purges the tables used by project performance summarization model to store
--             debug information.
--
--  Parameter Name      In/Out  Data Type       Null?   Default Value   Description
--  -------------       ------  ----------      ------  -------------   ---------------------------------
--  P_DEBUG_MODE        IN      VARCHAR2        NOT NULL 'N'          Indicates the debug option.
--  P_COMMIT_SIZE       IN      NUMBER          NOT NULL  10000       Indicates the commit size.
--  P_REQUEST_ID        IN      NUMBER          NOT NULL              Indicates the concurrent request id.
--  X_RETURN_STATUS     OUT     VARCHAR2        N/A       N/A         Indicates the return status of the API.
--  Valid values are:   'S' for Success 'E' for Error   'U' for Unexpected Error
--
--  X_MSG_COUNT         OUT     NUMBER          N/A       N/A         Indicates the number of error messages
--                                                                    in the message stack.
--  X_MSG_DATA          OUT     VARCHAR2        N/A       N/A         Indicates the error message text
--                                                                    if only one error exists.

--  HISTORY
--  bifernan            16-October-2007            Created
--  bifernan            01-January-2008            Prefixed PJI tables with schema name for truncate statement
--  bifernan            11-January-2008            Removed references to hard coded schemas names (GSCC)
--                                                 Replaced truncate statement with batch delete
--

PROCEDURE PURGE_PJI_DEBUG
(
p_debug_mode    IN              VARCHAR2        DEFAULT  'N'    ,
p_commit_size   IN              NUMBER          DEFAULT  10000  ,
p_request_id    IN              NUMBER                          ,
x_return_status OUT     NOCOPY  VARCHAR2                        ,
x_msg_count     OUT     NOCOPY  NUMBER                          ,
x_msg_data      OUT     NOCOPY  VARCHAR2
)
IS
        l_debug_level3	        NUMBER                  :=3;
        l_rows1                 NUMBER                  :=0;
	l_rows2                 NUMBER                  :=0;
	l_rows3                 NUMBER                  :=0;
        l_msg_data              VARCHAR2(2000);
        l_data                  VARCHAR2(2000);
        l_msg_count             NUMBER;
        l_msg_index_out         NUMBER;
        i                       NUMBER;
        l_local_error_flag      VARCHAR2(1)             :='N';

BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS ;
        x_msg_count := 0;
        x_msg_data := NULL;

        IF p_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function( p_function   => 'PURGE_PJI_DEBUG', p_debug_mode => p_debug_mode);
                pa_debug.g_err_stage:= 'Entering PURGE_PJI_DEBUG API';
                Pa_Debug.WRITE('PA_PURGE_PUB',pa_debug.g_err_stage,l_debug_level3);
        END IF;

	-- PJI_FM_EXTR_PLAN_LINES_DEBUG
	BEGIN
		LOOP
			DELETE FROM PJI_FM_EXTR_PLAN_LINES_DEBUG WHERE ROWNUM <= p_commit_size;
			EXIT WHEN sql%rowcount < p_commit_size;

			l_rows1 := l_rows1 + nvl(sql%rowcount,0);
			COMMIT; -- Clear rollback segment
		END LOOP;

		l_rows1 := l_rows1 + nvl(sql%rowcount,0);
		COMMIT;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL ; -- Do nothing
		WHEN OTHERS THEN
		        l_rows1 := l_rows1 + nvl(sql%rowcount,0);
			l_local_error_flag := 'Y';
			Fnd_Msg_Pub.add_exc_msg
				( p_pkg_name        => 'PA_PURGE_PUB'
				, p_procedure_name  => 'PURGE_PJI_DEBUG'
				, p_error_text      => SUBSTRB(SQLERRM,1,240));
	END;

	-- PJI_FM_XBS_ACCUM_TMP1_DEBUG
	BEGIN
		LOOP
			DELETE FROM PJI_FM_XBS_ACCUM_TMP1_DEBUG WHERE ROWNUM <= p_commit_size;
			EXIT WHEN sql%rowcount < p_commit_size;

			l_rows2 := l_rows2 + nvl(sql%rowcount,0);
			COMMIT; -- Clear rollback segment
		END LOOP;

		l_rows2 := l_rows2 + nvl(sql%rowcount,0);
		COMMIT;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL ; -- Do nothing
		WHEN OTHERS THEN
		        l_rows2 := l_rows2 + nvl(sql%rowcount,0);
			l_local_error_flag := 'Y';
			Fnd_Msg_Pub.add_exc_msg
				( p_pkg_name        => 'PA_PURGE_PUB'
				, p_procedure_name  => 'PURGE_PJI_DEBUG'
				, p_error_text      => SUBSTRB(SQLERRM,1,240));
	END;

	-- PJI_SYSTEM_DEBUG_MSG
	BEGIN
		LOOP
			DELETE FROM PJI_SYSTEM_DEBUG_MSG WHERE ROWNUM <= p_commit_size;
			EXIT WHEN sql%rowcount < p_commit_size;

			l_rows3 := l_rows3 + nvl(sql%rowcount,0);
			COMMIT; -- Clear rollback segment
		END LOOP;

		l_rows3 := l_rows3 + nvl(sql%rowcount,0);
		COMMIT;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL ; -- Do nothing
		WHEN OTHERS THEN
		        l_rows3 := l_rows3 + nvl(sql%rowcount,0);
			l_local_error_flag := 'Y';
			Fnd_Msg_Pub.add_exc_msg
				( p_pkg_name        => 'PA_PURGE_PUB'
				, p_procedure_name  => 'PURGE_PJI_DEBUG'
				, p_error_text      => SUBSTRB(SQLERRM,1,240));
	END;

	IF p_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'No. of rows deleted from PJI_FM_EXTR_PLAN_LINES_DEBUG ' || l_rows1 ;
                pa_debug.write('PA_PURGE_PUB',pa_debug.g_err_stage,l_debug_level3);
                pa_debug.g_err_stage:= 'No. of rows deleted from PJI_FM_XBS_ACCUM_TMP1_DEBUG ' || l_rows2 ;
                pa_debug.write('PA_PURGE_PUB',pa_debug.g_err_stage,l_debug_level3);
                pa_debug.g_err_stage:= 'No. of rows deleted from PJI_SYSTEM_DEBUG_MSG ' || l_rows3 ;
                pa_debug.write('PA_PURGE_PUB',pa_debug.g_err_stage,l_debug_level3);
        END IF;

	PA_PURGE_PUB.INSERT_PURGE_LOG
        (
                p_request_id => p_request_id ,
                p_table_name => 'PJI_FM_EXTR_PLAN_LINES_DEBUG' ,
                p_rows_deleted => l_rows1 ,
                x_return_status => x_return_status ,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		l_local_error_flag := 'Y';
        END IF;

        PA_PURGE_PUB.INSERT_PURGE_LOG
        (
                p_request_id => p_request_id ,
                p_table_name => 'PJI_FM_XBS_ACCUM_TMP1_DEBUG',
                p_rows_deleted => l_rows2,
                x_return_status => x_return_status ,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		l_local_error_flag := 'Y';
        END IF;

        PA_PURGE_PUB.INSERT_PURGE_LOG
        (
                p_request_id => p_request_id ,
                p_table_name => 'PJI_SYSTEM_DEBUG_MSG',
                p_rows_deleted => l_rows3,
                x_return_status => x_return_status ,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		l_local_error_flag := 'Y';
        END IF;

        IF l_local_error_flag = 'Y' THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;


        IF p_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'Successfully inserted Log details pertaining to PURGE_PJI_DEBUG';
                pa_debug.write('PA_PURGE_PUB',pa_debug.g_err_stage,l_debug_level3);
                pa_debug.g_err_stage:= 'Exiting PURGE_PJI_DEBUG';
                pa_debug.write('PA_PURGE_PUB','PA_PURGE_PUB.PURGE_PJI_DEBUG :' || pa_debug.g_err_stage,l_debug_level3);
                pa_debug.reset_curr_function;
        END IF;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := Fnd_Api.G_RET_STS_ERROR;
                x_msg_count := Fnd_Msg_Pub.count_msg;

                IF p_debug_mode = 'Y' THEN
                        Pa_Debug.reset_curr_function;
                END IF;

        WHEN OTHERS THEN
                x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
                x_msg_count     := 1;
                x_msg_data      := SUBSTRB(SQLERRM,1,240);

                Fnd_Msg_Pub.add_exc_msg
                ( p_pkg_name        => 'PA_PURGE_PUB'
                , p_procedure_name  => 'PURGE_PJI_DEBUG'
                , p_error_text      => x_msg_data);

                x_msg_count := FND_MSG_PUB.count_msg;

                IF p_debug_mode = 'Y' THEN
                        Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
                        Pa_Debug.WRITE('PA_PURGE_PUB',Pa_Debug.g_err_stage, 5);
                        Pa_Debug.reset_curr_function;
                END IF;

END PURGE_PJI_DEBUG;

--
--  PROCEDURE
--              PRINT_OUTPUT_REPORT
--  PURPOSE
--		This API will print the output report to concurrent log file.
--  Parameter Name      In/Out  Data Type       Null?   Default Value   Description
--  -------------       ------  ----------      ------  -------------   ---------------------------------
--  P_REQUEST_ID        IN      NUMBER          NOT NULL              Indicates the concurrent request id.
--  X_RETURN_STATUS     OUT     VARCHAR2        N/A       N/A         Indicates the return status of the API.
--  Valid values are:   'S' for Success 'E' for Error   'U' for Unexpected Error
--
--  X_MSG_COUNT         OUT     NUMBER          N/A       N/A         Indicates the number of error messages
--                                                                    in the message stack.
--  X_MSG_DATA          OUT     VARCHAR2        N/A       N/A         Indicates the error message text
--                                                                    if only one error exists.

--  HISTORY
--  avaithia            01-March-2006            Created
--

PROCEDURE PRINT_OUTPUT_REPORT
(
p_request_id            IN              NUMBER          ,
x_return_status         OUT     NOCOPY  VARCHAR2        ,
x_msg_count             OUT     NOCOPY  NUMBER          ,
x_msg_data              OUT     NOCOPY  VARCHAR2
)
IS

        CURSOR c_purge_details IS
        SELECT table_name, num_recs_purged
        FROM PA_PURGE_PRJ_DETAILS
        WHERE purge_batch_id = p_request_id
        AND project_id = 0
        ORDER BY table_name ;

        l_table_name_tbl        SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
        l_rows_deleted_tbl      SYSTEM.PA_NUM_TBL_TYPE          := SYSTEM.PA_NUM_TBL_TYPE();
        l_debug_mode            VARCHAR2(1); -- 5201806

BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS ;
        x_msg_count := 0;
        x_msg_data := NULL;
        l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N'); -- 5201806

        pa_debug.set_process('PLSQL','LOG','Y');
        pa_debug.set_curr_function( p_function   => 'PRINT_OUTPUT_REPORT', p_debug_mode => 'Y');

        pa_debug.g_err_stage:= '---------------------------------------------------';
        pa_debug.write_file(pa_debug.g_err_stage);

        pa_debug.g_err_stage:= 'Purge Process Report : ADM: Purge Projects Obsolete Data ';
        pa_debug.write_file(pa_debug.g_err_stage);

        pa_debug.g_err_stage:= '+---------------------------------------------------+';
        pa_debug.write_file(pa_debug.g_err_stage);

        pa_debug.g_err_stage:= 'Current system time is ' || sysdate ;
        pa_debug.write_file(pa_debug.g_err_stage);

        pa_debug.g_err_stage:= '+---------------------------------------------------+';
        pa_debug.write_file(pa_debug.g_err_stage);

        OPEN c_purge_details;
        FETCH c_purge_details BULK COLLECT INTO l_table_name_tbl,l_rows_deleted_tbl;
        CLOSE c_purge_details;

        IF nvl(l_table_name_tbl.LAST,0) > 0 THEN
                FOR i IN l_table_name_tbl.FIRST..l_table_name_tbl.LAST LOOP
                        pa_debug.g_err_stage:= 'Purged '|| l_rows_deleted_tbl(i) ||' entries from ' || l_table_name_tbl(i) ;
                        pa_debug.write_file(pa_debug.g_err_stage);
                        pa_debug.g_err_stage:= '                     ';
                        pa_debug.write_file(pa_debug.g_err_stage);
                END LOOP ;
        END IF;

        Pa_Debug.reset_curr_function;

EXCEPTION
        WHEN OTHERS THEN
                x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
                x_msg_count     := 1;
                x_msg_data      := SUBSTRB(SQLERRM,1,240);

                IF c_purge_details%ISOPEN THEN
                        CLOSE c_purge_details ;
                END IF;

                Fnd_Msg_Pub.add_exc_msg
                           ( p_pkg_name        => 'PA_PURGE_PUB'
                            , p_procedure_name  => 'PRINT_OUTPUT_REPORT'
                            , p_error_text      => x_msg_data);

                x_msg_count := FND_MSG_PUB.count_msg; --5201806

                IF l_debug_mode = 'Y' THEN  -- 5201806
                        Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
                        Pa_Debug.WRITE('PA_PURGE_PUB',Pa_Debug.g_err_stage, 5);
                        Pa_Debug.reset_curr_function;
                END IF;
                -- RAISE; 5201806 Do not raise in internal APIs
END PRINT_OUTPUT_REPORT;

--
--  PROCEDURE
--		INSERT_PURGE_LOG
--  PURPOSE
--		This API will populate the log table for deleted table information.
--
--  Parameter Name      In/Out  Data Type       Null?   Default Value   Description
--  -------------       ------  ----------      ------  -------------   ---------------------------------
--  P_REQUEST_ID        IN      NUMBER          NOT NULL              Indicates the concurrent request id.
--  P_TABLE_NAME        IN      VARCHAR2	NOT NULL              Indicates the table name deleted.
--  P_ROWS_DELETED      IN      NUMBER          NOT NULL              Indicates  the number of rows deleted.
--  X_RETURN_STATUS     OUT     VARCHAR2        N/A       N/A         Indicates the return status of the API.
--  Valid values are:   'S' for Success 'E' for Error   'U' for Unexpected Error
--
--  X_MSG_COUNT         OUT     NUMBER          N/A       N/A         Indicates the number of error messages
--                                                                    in the message stack.
--  X_MSG_DATA          OUT     VARCHAR2        N/A       N/A         Indicates the error message text
--                                                                    if only one error exists.

--  HISTORY
--  avaithia            01-March-2006            Created
--

PROCEDURE INSERT_PURGE_LOG
(
p_request_id    IN              NUMBER          ,
p_table_name    IN              VARCHAR2        ,
p_rows_deleted  IN              NUMBER          ,
x_return_status OUT     NOCOPY  VARCHAR2        ,
x_msg_count     OUT     NOCOPY  NUMBER          ,
x_msg_data      OUT     NOCOPY  VARCHAR2
)
IS
        l_debug_mode                    VARCHAR2(1);
        l_debug_level3                  NUMBER  := 3;
BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS ;
        x_msg_count := 0;
        x_msg_data := NULL;

        l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

        IF l_debug_mode = 'Y' THEN
                pa_debug.set_curr_function( p_function   => 'INSERT_PURGE_LOG', p_debug_mode => 'Y');
                Pa_Debug.WRITE('PA_PURGE_PUB','Before inserting into PA_PURGE_PRJ_DETAILS',l_debug_level3);
        END IF;

        INSERT INTO PA_PURGE_PRJ_DETAILS
        (
         PURGE_BATCH_ID
        ,PROJECT_ID
        ,TABLE_NAME
        ,NUM_RECS_PURGED
        ,CREATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_LOGIN
        ,CREATION_DATE
        ,PROGRAM_APPLICATION_ID
        ,PROGRAM_ID
        ,PROGRAM_UPDATE_DATE
        )
        VALUES
        (
         p_request_id
        ,0
        ,p_table_name
        ,p_rows_deleted
        ,fnd_global.user_id
        ,sysdate
        ,fnd_global.user_id
        ,fnd_global.login_id
        ,sysdate
        ,fnd_global.prog_appl_id
        ,fnd_global.conc_program_id
        ,sysdate
        );

        IF l_debug_mode = 'Y' THEN
                Pa_Debug.g_err_stage:='Successfully Inserted Purge Log';
                Pa_Debug.WRITE('PA_PURGE_PUB',Pa_Debug.g_err_stage,l_debug_level3);
                pa_debug.reset_curr_function;
        END IF;

EXCEPTION
        WHEN OTHERS THEN
                x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
                x_msg_count     := 1;
                x_msg_data      := SUBSTRB(SQLERRM,1,240);

                Fnd_Msg_Pub.add_exc_msg
                           ( p_pkg_name        => 'PA_PURGE_PUB'
                            , p_procedure_name  => 'INSERT_PURGE_LOG'
                            , p_error_text      => x_msg_data);

                x_msg_count := FND_MSG_PUB.count_msg; --5201806

                IF l_debug_mode = 'Y' THEN
                        Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
                        Pa_Debug.WRITE('PA_PURGE_PUB',Pa_Debug.g_err_stage, 5);
                        Pa_Debug.reset_curr_function;
                END IF;
                -- RAISE; 5201806 Do not raise in internal APIs
END INSERT_PURGE_LOG;

END PA_PURGE_PUB;

/
