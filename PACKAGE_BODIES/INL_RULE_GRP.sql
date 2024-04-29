--------------------------------------------------------
--  DDL for Package Body INL_RULE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INL_RULE_GRP" AS
/* $Header: INLGRULB.pls 120.0.12010000.3 2013/09/09 16:44:48 acferrei noship $ */
-- API name   : Check_Condition
-- Type       : Group
-- Function   : Returns Y or N indicating whether the processing of an imported
--              LCM shipment should be automatically submitted or not
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version IN NUMBER,
--              p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE
--              p_commit  IN VARCHAR2 := FND_API.G_FALSE
--              p_ship_header_id IN NUMBER
--              p_rule_package_name IN VARCHAR2
--
-- OUT          x_return_status OUT NOCOPY VARCHAR2
--              x_msg_count OUT NOCOPY NUMBER
--              x_msg_data OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
FUNCTION Check_Condition(p_api_version IN NUMBER,
                         p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
                         p_commit IN VARCHAR2 := FND_API.G_FALSE,
                         p_ship_header_id IN NUMBER,
                         p_rule_package_name IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

    l_api_name  CONSTANT VARCHAR2(30) := 'Check_Condition';
    l_api_version CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_debug_info VARCHAR2(2000);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);

    l_sql_dist VARCHAR2(2000);
    l_check_condition VARCHAR2(1) := 'Y';
    l_condition_call VARCHAR2(200);
    l_exec_code VARCHAR2(200);

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(p_module_name => g_module_name,
                                  p_procedure_name => l_api_name) ;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(p_current_version_number => l_api_version,
                                       p_caller_version_number => p_api_version,
                                       p_api_name => l_api_name,
                                       p_pkg_name => g_pkg_name ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_Variable(p_module_name => g_module_name,
                                 p_procedure_name => l_api_name,
                                 p_var_name => 'p_ship_header_id',
                                 p_var_value => p_ship_header_id);

    IF p_rule_package_name IS NOT NULL THEN

        l_debug_info := 'Call code: ' || p_rule_package_name;
        INL_LOGGING_PVT.Log_Statement(p_module_name => g_module_name,
                                      p_procedure_name => l_api_name,
                                      p_debug_info => l_debug_info);

        l_debug_info := 'Execute custom code';
        INL_LOGGING_PVT.Log_Statement(p_module_name => g_module_name,
                                      p_procedure_name => l_api_name,
                                      p_debug_info => l_debug_info);

        l_condition_call := p_rule_package_name || '.Get_Value(' || p_ship_header_id || ')';
        --REPLACE(p_custom_condition_call, ':p_ship_header_id', p_ship_header_id);

        --l_exec_code  := 'BEGIN :l_custom_code_out := ' || l_condition_call || '; END;';
        l_exec_code  := 'BEGIN :l_rule_code_out := ' || l_condition_call || '; END;';

        INL_LOGGING_PVT.Log_Variable (p_module_name => g_module_name,
                                  p_procedure_name => l_api_name,
                                  p_var_name => 'l_exec_code',
                                  p_var_value => l_exec_code);

        EXECUTE IMMEDIATE l_exec_code USING OUT l_check_condition;

    END IF;

    INL_LOGGING_PVT.Log_Variable(p_module_name => g_module_name,
                                 p_procedure_name => l_api_name,
                                 p_var_name => 'l_check_condition',
                                 p_var_value => l_check_condition);

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                              p_count => x_msg_count,
                              p_data => x_msg_data);

    -- Standard End of Procedure/Function Logging
    INL_LOGGING_PVT.Log_EndProc(p_module_name => g_module_name,
                                p_procedure_name => l_api_name);

    RETURN l_check_condition;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError(p_module_name => g_module_name,
                                       p_procedure_name => l_api_name);
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError(p_module_name => g_module_name,
                                         p_procedure_name => l_api_name);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count => x_msg_count,
                                  p_data => x_msg_data);
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError(p_module_name => g_module_name,
                                         p_procedure_name => l_api_name);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(
            p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(p_pkg_name => g_pkg_name,
                                    p_procedure_name => l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data);
END Check_Condition;
END INL_RULE_GRP;

/
