--------------------------------------------------------
--  DDL for Package Body INL_LOGGING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INL_LOGGING_PVT" AS
/* $Header: INLVLOGB.pls 120.4.12010000.3 2010/02/26 14:01:40 aicosta ship $ */

-- Utility name   : Log_Concurrent
-- Type       : Private
-- Function   :  Private procedure to write the same content that goes to FND
--               LOG into the Concurrent Log when executing LCM concurrent programs.
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_module_name    IN VARCHAR2
--              p_procedure_name IN VARCHAR2
--              p_debug_info     IN VARCHAR2
--              p_call_api_name  IN VARCHAR2
--              p_var_name       IN VARCHAR2
--              p_var_value      IN VARCHAR2
--              p_debug_type     IN NUMBER [1 - Log_BeginProc,
--                                              Log_Statement,
--                                              Log_Event,
--                                              Log_Exception,
--                                              Log_ExpecError,
--                                              Log_UnexpecError,
--                                              Log_EndProc.
--                                          2 - Log_Variable
--                                          3 - Log_APICallIn
--                                          4 - Log_APICallOut]
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Log_Concurrent(p_module_name IN VARCHAR2,
                         p_procedure_name IN VARCHAR2,
                         p_debug_info IN VARCHAR2,
                         p_call_api_name IN VARCHAR2,
                         p_var_name IN VARCHAR2,
                         p_var_value IN VARCHAR2,
                         p_debug_type IN NUMBER)

IS
    l_cp_flag number := 0;
    l_timestamp varchar2(256);
BEGIN
    l_cp_flag :=  NVL(fnd_profile.value('CONC_REQUEST_ID'), 0);
    IF ( l_cp_flag > 0 ) THEN
        l_timestamp := '[' || to_char(sysdate,'DD-MON-YY HH24:MI:SS') || '] ';
        IF(p_debug_type = 1) THEN
            FND_FILE.put_line(FND_FILE.LOG, l_timestamp || p_module_name|| p_procedure_name ||' >> '|| p_debug_info); --Bug#9415151
        ELSIF(p_debug_type = 2) THEN
            FND_FILE.put_line(FND_FILE.LOG, l_timestamp || p_module_name || p_procedure_name||' >> '|| p_var_name||': ' ||p_var_value); --Bug#9415151
        ELSIF(p_debug_type = 3) THEN
            FND_FILE.put_line(FND_FILE.LOG, l_timestamp || p_module_name || p_procedure_name||' >> [Log_APICallIn] - [' || p_call_api_name || '] >> '|| p_var_name||': ' ||p_var_value); --Bug#9415151
        ELSIF(p_debug_type = 4) THEN
            FND_FILE.put_line(FND_FILE.LOG, l_timestamp || p_module_name || p_procedure_name||' >> [Log_APICallOut] - [' || p_call_api_name || '] >> '|| p_var_name||': ' ||p_var_value);--Bug#9415151
        END IF;
    END IF;
END Log_Concurrent;

-- API name   : Log_Statement
-- Type       : Private
-- Function   :  Level 1: Low-level progress reporting Log for Statements
--               Examples: "Obtaining connection from pool", "Got request parameter", "Set cookie with name, value"
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_module_name IN VARCHAR2
--              p_procedure_name IN VARCHAR2
--              p_debug_info IN VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Log_Statement (p_module_name IN VARCHAR2,
                         p_procedure_name IN VARCHAR2,
                         p_debug_info IN VARCHAR2)
IS
BEGIN
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL AND LENGTH(p_debug_info)>0) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,p_module_name||' '||p_procedure_name,p_debug_info);
    -- Write on concurrent log
    Log_Concurrent(p_module_name => p_module_name,
                   p_procedure_name => p_procedure_name,
                   p_debug_info => p_debug_info,
                   p_call_api_name => NULL,
                   p_var_name => NULL,
                   p_var_value => NULL,
                   p_debug_type => 1);
  END IF;
END Log_Statement;

-- API name   : Log_Variable
-- Type       : Private
-- Function   : Level 1: Low-level progress reporting
--              Log for variable values
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_module_name IN VARCHAR2
--              p_procedure_name IN VARCHAR2
--              p_var_name IN VARCHAR2
--              p_var_value IN VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Log_Variable (p_module_name IN VARCHAR2,
                        p_procedure_name IN VARCHAR2,
                        p_var_name IN VARCHAR2,
                        p_var_value IN VARCHAR2)
IS
  l_debug_info VARCHAR2(200);
BEGIN
  l_debug_info := p_var_name||': ' ||p_var_value;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,p_module_name||' '||p_procedure_name,l_debug_info);
    -- Write on concurrent log
    Log_Concurrent(p_module_name => p_module_name,
                   p_procedure_name => p_procedure_name,
                   p_debug_info => NULL,
                   p_call_api_name => NULL,
                   p_var_name => p_var_name,
                   p_var_value => p_var_value,
                   p_debug_type => 2);
  END IF;
END Log_Variable;

-- API name   : Log_BeginProc
-- Type       : Private
-- Function   : Level 2: API level progress reporting
--              Log for Beginning of Procedure/Function
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_module_name IN VARCHAR2
--              p_procedure_name IN VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Log_BeginProc (p_module_name IN VARCHAR2,
                         p_procedure_name IN VARCHAR2)
IS
BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,p_module_name||' '||p_procedure_name,'BEGIN(+)');
        -- Write on concurrent log
        Log_Concurrent(p_module_name => p_module_name,
                       p_procedure_name => p_procedure_name,
                       p_debug_info => 'BEGIN(+)',
                       p_call_api_name => NULL,
                       p_var_name => NULL,
                       p_var_value => NULL,
                       p_debug_type => 1);
    END IF;
END Log_BeginProc;

-- API name   : Log_EndProc
-- Type       : Private
-- Function   : Level 2: API level progress reporting
--              Log for End of Procedure/Function
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_module_name IN VARCHAR2
--              p_procedure_name IN VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Log_EndProc (p_module_name IN VARCHAR2,
                       p_procedure_name IN VARCHAR2)
IS
BEGIN
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,p_module_name||' '||p_procedure_name,'END(-)');
     -- Write on concurrent log
     Log_Concurrent(p_module_name => p_module_name,
                    p_procedure_name => p_procedure_name,
                    p_debug_info => 'END(-)',
                    p_call_api_name => NULL,
                    p_var_name => NULL,
                    p_var_value => NULL,
                    p_debug_type => 1);
  END IF;
END Log_EndProc;

-- API name   : Log_APICallIn
-- Type       : Private
-- Function   : Level 2: API level progress reporting
--              Log for Input Parameters API calls
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_module_name IN VARCHAR2
--              p_procedure_name IN VARCHAR2
--              p_call_api_name IN VARCHAR2
--              p_in_param_name1 IN VARCHAR2   := NULL
--              p_in_param_value1 IN VARCHAR2  := NULL
--              p_in_param_name2 IN VARCHAR2   := NULL
--              p_in_param_value2 IN VARCHAR2  := NULL
--              p_in_param_name3 IN VARCHAR2   := NULL
--              p_in_param_value3 IN VARCHAR2  := NULL
--              p_in_param_name4 IN VARCHAR2   := NULL
--              p_in_param_value4 IN VARCHAR2  := NULL
--              p_in_param_name5 IN VARCHAR2   := NULL
--              p_in_param_value5 IN VARCHAR2  := NULL
--              p_in_param_name6 IN VARCHAR2   := NULL
--              p_in_param_value6 IN VARCHAR2  := NULL
--              p_in_param_name7 IN VARCHAR2   := NULL
--              p_in_param_value7 IN VARCHAR2  := NULL
--              p_in_param_name8 IN VARCHAR2   := NULL
--              p_in_param_value8 IN VARCHAR2  := NULL
--              p_in_param_name9 IN VARCHAR2   := NULL
--              p_in_param_value9 IN VARCHAR2  := NULL
--              p_in_param_name10 IN VARCHAR2  := NULL
--              p_in_param_value10 IN VARCHAR2 := NULL
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Log_APICallIn (p_module_name IN VARCHAR2,
                         p_procedure_name IN VARCHAR2,
                         p_call_api_name IN VARCHAR2,
                         p_in_param_name1 IN VARCHAR2   := NULL,
                         p_in_param_value1 IN VARCHAR2  := NULL,
                         p_in_param_name2 IN VARCHAR2   := NULL,
                         p_in_param_value2 IN VARCHAR2  := NULL,
                         p_in_param_name3 IN VARCHAR2   := NULL,
                         p_in_param_value3 IN VARCHAR2  := NULL,
                         p_in_param_name4 IN VARCHAR2   := NULL,
                         p_in_param_value4 IN VARCHAR2  := NULL,
                         p_in_param_name5 IN VARCHAR2   := NULL,
                         p_in_param_value5 IN VARCHAR2  := NULL,
                         p_in_param_name6 IN VARCHAR2   := NULL,
                         p_in_param_value6 IN VARCHAR2  := NULL,
                         p_in_param_name7 IN VARCHAR2   := NULL,
                         p_in_param_value7 IN VARCHAR2  := NULL,
                         p_in_param_name8 IN VARCHAR2   := NULL,
                         p_in_param_value8 IN VARCHAR2  := NULL,
                         p_in_param_name9 IN VARCHAR2   := NULL,
                         p_in_param_value9 IN VARCHAR2  := NULL,
                         p_in_param_name10 IN VARCHAR2  := NULL,
                         p_in_param_value10 IN VARCHAR2 := NULL)
IS
BEGIN
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,p_module_name||' '||p_procedure_name,' Call to '||p_call_api_name);
     IF (p_in_param_name1 IS NOT NULL OR p_in_param_value1 IS NOT NULL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,p_module_name||' '||p_procedure_name,p_in_param_name1||': '||p_in_param_value1);
        -- Write on concurrent log
        Log_Concurrent(p_module_name => p_module_name,
                       p_procedure_name => p_procedure_name,
                       p_debug_info => NULL,
                       p_call_api_name => p_call_api_name,
                       p_var_name => p_in_param_name1,
                       p_var_value => p_in_param_value1,
                       p_debug_type => 3);
     END IF;
     IF (p_in_param_name2 IS NOT NULL OR p_in_param_value2 IS NOT NULL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,p_module_name||' '||p_procedure_name,p_in_param_name2||': '||p_in_param_value2);
        -- Write on concurrent log
        Log_Concurrent(p_module_name => p_module_name,
                       p_procedure_name => p_procedure_name,
                       p_debug_info => NULL,
                       p_call_api_name => p_call_api_name,
                       p_var_name => p_in_param_name2,
                       p_var_value => p_in_param_value2,
                       p_debug_type => 3);
     END IF;
     IF (p_in_param_name3 IS NOT NULL OR p_in_param_value3 IS NOT NULL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,p_module_name||' '||p_procedure_name,p_in_param_name3||': '||p_in_param_value3);
        -- Write on concurrent log
        Log_Concurrent(p_module_name => p_module_name,
                       p_procedure_name => p_procedure_name,
                       p_debug_info => NULL,
                       p_call_api_name => p_call_api_name,
                       p_var_name => p_in_param_name3,
                       p_var_value => p_in_param_value3,
                       p_debug_type => 3);
     END IF;
     IF (p_in_param_name4 IS NOT NULL OR p_in_param_value4 IS NOT NULL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,p_module_name||' '||p_procedure_name,p_in_param_name4||': '||p_in_param_value4);
        -- Write on concurrent log
        Log_Concurrent(p_module_name => p_module_name,
                       p_procedure_name => p_procedure_name,
                       p_debug_info => NULL,
                       p_call_api_name => p_call_api_name,
                       p_var_name => p_in_param_name4,
                       p_var_value => p_in_param_value4,
                       p_debug_type => 3);
     END IF;
     IF (p_in_param_name5 IS NOT NULL OR p_in_param_value5 IS NOT NULL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,p_module_name||' '||p_procedure_name,p_in_param_name5||': '||p_in_param_value5);
        -- Write on concurrent log
        Log_Concurrent(p_module_name => p_module_name,
                       p_procedure_name => p_procedure_name,
                       p_debug_info => NULL,
                       p_call_api_name => p_call_api_name,
                       p_var_name => p_in_param_name5,
                       p_var_value => p_in_param_value5,
                       p_debug_type => 3);
     END IF;
     IF (p_in_param_name6 IS NOT NULL OR p_in_param_value6 IS NOT NULL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,p_module_name||' '||p_procedure_name,p_in_param_name6||': '||p_in_param_value6);
        -- Write on concurrent log
        Log_Concurrent(p_module_name => p_module_name,
                       p_procedure_name => p_procedure_name,
                       p_debug_info => NULL,
                       p_call_api_name => p_call_api_name,
                       p_var_name => p_in_param_name6,
                       p_var_value => p_in_param_value6,
                       p_debug_type => 3);
     END IF;
     IF (p_in_param_name7 IS NOT NULL OR p_in_param_value7 IS NOT NULL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,p_module_name||' '||p_procedure_name,p_in_param_name7||': '||p_in_param_value7);
        -- Write on concurrent log
        Log_Concurrent(p_module_name => p_module_name,
                       p_procedure_name => p_procedure_name,
                       p_debug_info => NULL,
                       p_call_api_name => p_call_api_name,
                       p_var_name => p_in_param_name7,
                       p_var_value => p_in_param_value7,
                       p_debug_type => 3);
     END IF;
     IF (p_in_param_name8 IS NOT NULL OR p_in_param_value8 IS NOT NULL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,p_module_name||' '||p_procedure_name,p_in_param_name8||': '||p_in_param_value8);
        -- Write on concurrent log
        Log_Concurrent(p_module_name => p_module_name,
                       p_procedure_name => p_procedure_name,
                       p_debug_info => NULL,
                       p_call_api_name => p_call_api_name,
                       p_var_name => p_in_param_name8,
                       p_var_value => p_in_param_value8,
                       p_debug_type => 3);
     END IF;
     IF (p_in_param_name9 IS NOT NULL OR p_in_param_value9 IS NOT NULL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,p_module_name||' '||p_procedure_name,p_in_param_name9||': '||p_in_param_value9);
        -- Write on concurrent log
        Log_Concurrent(p_module_name => p_module_name,
                       p_procedure_name => p_procedure_name,
                       p_debug_info => NULL,
                       p_call_api_name => p_call_api_name,
                       p_var_name => p_in_param_name9,
                       p_var_value => p_in_param_value9,
                       p_debug_type => 3);
     END IF;
     IF (p_in_param_name10 IS NOT NULL OR p_in_param_value10 IS NOT NULL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,p_module_name||' '||p_procedure_name,p_in_param_name10||': '||p_in_param_value10);
        -- Write on concurrent log
        Log_Concurrent(p_module_name => p_module_name,
                       p_procedure_name => p_procedure_name,
                       p_debug_info => NULL,
                       p_call_api_name => p_call_api_name,
                       p_var_name => p_in_param_name10,
                       p_var_value => p_in_param_value10,
                       p_debug_type => 3);
     END IF;
  END IF;
END Log_APICallIn;

-- API name   : Log_APICallOut
-- Type       : Private
-- Function   : Level 2: API level progress reporting
--              Log for Input Parameters API calls
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_module_name IN VARCHAR2
--              p_procedure_name IN VARCHAR2
--              p_call_api_name IN VARCHAR2
--              p_in_param_name1 IN VARCHAR2   := NULL
--              p_in_param_value1 IN VARCHAR2  := NULL
--              p_in_param_name2 IN VARCHAR2   := NULL
--              p_in_param_value2 IN VARCHAR2  := NULL
--              p_in_param_name3 IN VARCHAR2   := NULL
--              p_in_param_value3 IN VARCHAR2  := NULL
--              p_in_param_name4 IN VARCHAR2   := NULL
--              p_in_param_value4 IN VARCHAR2  := NULL
--              p_in_param_name5 IN VARCHAR2   := NULL
--              p_in_param_value5 IN VARCHAR2  := NULL
--              p_in_param_name6 IN VARCHAR2   := NULL
--              p_in_param_value6 IN VARCHAR2  := NULL
--              p_in_param_name7 IN VARCHAR2   := NULL
--              p_in_param_value7 IN VARCHAR2  := NULL
--              p_in_param_name8 IN VARCHAR2   := NULL
--              p_in_param_value8 IN VARCHAR2  := NULL
--              p_in_param_name9 IN VARCHAR2   := NULL
--              p_in_param_value9 IN VARCHAR2  := NULL
--              p_in_param_name10 IN VARCHAR2  := NULL
--              p_in_param_value10 IN VARCHAR2 := NULL
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Log_APICallOut (p_module_name IN VARCHAR2,
                          p_procedure_name IN VARCHAR2,
                          p_call_api_name IN VARCHAR2,
                          p_out_param_name1 IN VARCHAR2   := NULL,
                          p_out_param_value1 IN VARCHAR2  := NULL,
                          p_out_param_name2 IN VARCHAR2   := NULL,
                          p_out_param_value2 IN VARCHAR2  := NULL,
                          p_out_param_name3 IN VARCHAR2   := NULL,
                          p_out_param_value3 IN VARCHAR2  := NULL,
                          p_out_param_name4 IN VARCHAR2   := NULL,
                          p_out_param_value4 IN VARCHAR2  := NULL,
                          p_out_param_name5 IN VARCHAR2   := NULL,
                          p_out_param_value5 IN VARCHAR2  := NULL,
                          p_out_param_name6 IN VARCHAR2   := NULL,
                          p_out_param_value6 IN VARCHAR2  := NULL,
                          p_out_param_name7 IN VARCHAR2   := NULL,
                          p_out_param_value7 IN VARCHAR2  := NULL,
                          p_out_param_name8 IN VARCHAR2   := NULL,
                          p_out_param_value8 IN VARCHAR2  := NULL,
                          p_out_param_name9 IN VARCHAR2   := NULL,
                          p_out_param_value9 IN VARCHAR2  := NULL,
                          p_out_param_name10 IN VARCHAR2  := NULL,
                          p_out_param_value10 IN VARCHAR2 := NULL)
IS
BEGIN
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,p_module_name||' '||p_procedure_name,' Returning from '||p_call_api_name);
     IF (p_out_param_name1 IS NOT NULL OR p_out_param_value1 IS NOT NULL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,p_module_name||' '||p_procedure_name,p_out_param_name1||': '||p_out_param_value1);
        -- Write on concurrent log
        Log_Concurrent(p_module_name => p_module_name,
                       p_procedure_name => p_procedure_name,
                       p_debug_info => NULL,
                       p_call_api_name => p_call_api_name,
                       p_var_name => p_out_param_name1,
                       p_var_value => p_out_param_value1,
                       p_debug_type => 4);
     END IF;
     IF (p_out_param_name2 IS NOT NULL OR p_out_param_value2 IS NOT NULL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,p_module_name||' '||p_procedure_name,p_out_param_name2||': '||p_out_param_value2);
        -- Write on concurrent log
        Log_Concurrent(p_module_name => p_module_name,
                       p_procedure_name => p_procedure_name,
                       p_debug_info => NULL,
                       p_call_api_name => p_call_api_name,
                       p_var_name => p_out_param_name2,
                       p_var_value => p_out_param_value2,
                       p_debug_type => 4);

     END IF;
     IF (p_out_param_name3 IS NOT NULL OR p_out_param_value3 IS NOT NULL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,p_module_name||' '||p_procedure_name,p_out_param_name3||': '||p_out_param_value3);
        -- Write on concurrent log
        Log_Concurrent(p_module_name => p_module_name,
                       p_procedure_name => p_procedure_name,
                       p_debug_info => NULL,
                       p_call_api_name => p_call_api_name,
                       p_var_name => p_out_param_name3,
                       p_var_value => p_out_param_value3,
                       p_debug_type => 4);

     END IF;
     IF (p_out_param_name4 IS NOT NULL OR p_out_param_value4 IS NOT NULL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,p_module_name||' '||p_procedure_name,p_out_param_name4||': '||p_out_param_value4);
        -- Write on concurrent log
        Log_Concurrent(p_module_name => p_module_name,
                       p_procedure_name => p_procedure_name,
                       p_debug_info => NULL,
                       p_call_api_name => p_call_api_name,
                       p_var_name => p_out_param_name4,
                       p_var_value => p_out_param_value4,
                       p_debug_type => 4);

     END IF;
     IF (p_out_param_name5 IS NOT NULL OR p_out_param_value5 IS NOT NULL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,p_module_name||' '||p_procedure_name,p_out_param_name5||': '||p_out_param_value5);
        -- Write on concurrent log
        Log_Concurrent(p_module_name => p_module_name,
                       p_procedure_name => p_procedure_name,
                       p_debug_info => NULL,
                       p_call_api_name => p_call_api_name,
                       p_var_name => p_out_param_name5,
                       p_var_value => p_out_param_value5,
                       p_debug_type => 4);
     END IF;
     IF (p_out_param_name6 IS NOT NULL OR p_out_param_value6 IS NOT NULL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,p_module_name||' '||p_procedure_name,p_out_param_name6||': '||p_out_param_value6);
        -- Write on concurrent log
        Log_Concurrent(p_module_name => p_module_name,
                       p_procedure_name => p_procedure_name,
                       p_debug_info => NULL,
                       p_call_api_name => p_call_api_name,
                       p_var_name => p_out_param_name6,
                       p_var_value => p_out_param_value6,
                       p_debug_type => 4);
     END IF;
     IF (p_out_param_name7 IS NOT NULL OR p_out_param_value7 IS NOT NULL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,p_module_name||' '||p_procedure_name,p_out_param_name7||': '||p_out_param_value7);
        -- Write on concurrent log
        Log_Concurrent(p_module_name => p_module_name,
                       p_procedure_name => p_procedure_name,
                       p_debug_info => NULL,
                       p_call_api_name => p_call_api_name,
                       p_var_name => p_out_param_name7,
                       p_var_value => p_out_param_value7,
                       p_debug_type => 4);
     END IF;
     IF (p_out_param_name8 IS NOT NULL OR p_out_param_value8 IS NOT NULL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,p_module_name||' '||p_procedure_name,p_out_param_name8||': '||p_out_param_value8);
        -- Write on concurrent log
        Log_Concurrent(p_module_name => p_module_name,
                       p_procedure_name => p_procedure_name,
                       p_debug_info => NULL,
                       p_call_api_name => p_call_api_name,
                       p_var_name => p_out_param_name8,
                       p_var_value => p_out_param_value8,
                       p_debug_type => 4);

     END IF;
     IF (p_out_param_name9 IS NOT NULL OR p_out_param_value9 IS NOT NULL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,p_module_name||' '||p_procedure_name,p_out_param_name9||': '||p_out_param_value9);
        -- Write on concurrent log
        Log_Concurrent(p_module_name => p_module_name,
                       p_procedure_name => p_procedure_name,
                       p_debug_info => NULL,
                       p_call_api_name => p_call_api_name,
                       p_var_name => p_out_param_name9,
                       p_var_value => p_out_param_value9,
                       p_debug_type => 4);
     END IF;
     IF (p_out_param_name10 IS NOT NULL OR p_out_param_value10 IS NOT NULL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,p_module_name||' '||p_procedure_name,p_out_param_name10||': '||p_out_param_value10);
        -- Write on concurrent log
        Log_Concurrent(p_module_name => p_module_name,
                       p_procedure_name => p_procedure_name,
                       p_debug_info => NULL,
                       p_call_api_name => p_call_api_name,
                       p_var_name => p_out_param_name10,
                       p_var_value => p_out_param_value10,
                       p_debug_type => 4);
     END IF;
  END IF;
END Log_APICallOut;

-- API name   : Log_Event
-- Type       : Private
-- Function   : Level 3: High-level progress reporting Log for Events
--              Examples: "User authenticated successfully",
--              "Retrieved user preferences successfully", "Menu rendering completed"
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_module_name IN VARCHAR2
--              p_procedure_name IN VARCHAR2
--              p_debug_info IN VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Log_Event (p_module_name IN VARCHAR2,
                     p_procedure_name IN VARCHAR2,
                     p_debug_info IN VARCHAR2)
IS
BEGIN
  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL AND LENGTH(p_debug_info)>0) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_EVENT,p_module_name||' '||p_procedure_name,p_debug_info);
      -- Write on concurrent log
      Log_Concurrent(p_module_name => p_module_name,
                     p_procedure_name => p_procedure_name,
                     p_debug_info => p_debug_info,
                     p_call_api_name => NULL,
                     p_var_name => NULL,
                     p_var_value => NULL,
                     p_debug_type => 1);
  END IF;
END Log_Event;

-- API name   : Log_Exception
-- Type       : Private
-- Function   : Level 4: Warnings, Handled internal software failure (may need fix, but not critical)
--              Log for Exceptions
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_module_name IN VARCHAR2
--              p_procedure_name IN VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Log_Exception   (p_module_name IN VARCHAR2,
                           p_procedure_name IN VARCHAR2)
IS
BEGIN
  IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,p_module_name||' '||p_procedure_name,SQLERRM);
       -- Write on concurrent log
       Log_Concurrent(p_module_name => p_module_name,
                      p_procedure_name => p_procedure_name,
                      p_debug_info => SQLERRM,
                      p_call_api_name => NULL,
                      p_var_name => NULL,
                      p_var_value => NULL,
                      p_debug_type => 1);
  END IF;
END Log_Exception;

-- API name   : Log_ExpecError
-- Type       : Private
-- Function   : Level 5: External end-user error (typically requires end-user to fix the issue)
--              Log for Expected Error
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_module_name IN VARCHAR2
--              p_procedure_name IN VARCHAR2
--              p_debug_info IN VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Log_ExpecError (p_module_name IN VARCHAR2,
                          p_procedure_name IN VARCHAR2,
                          p_debug_info IN VARCHAR2 := NULL)
IS
BEGIN
  IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    IF p_debug_info IS NOT NULL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_ERROR,p_module_name||' '||p_procedure_name,p_debug_info);
    ELSE
       FND_LOG.STRING(FND_LOG.LEVEL_ERROR,p_module_name||' '||p_procedure_name,SQLERRM);
    END IF;
    -- Write on concurrent log
    Log_Concurrent(p_module_name => p_module_name,
                   p_procedure_name => p_procedure_name,
                   p_debug_info => NVL(p_debug_info, SQLERRM),
                   p_call_api_name => NULL,
                   p_var_name => NULL,
                   p_var_value => NULL,
                   p_debug_type => 1);
  END IF;
END Log_ExpecError;

-- API name   : Log_UnexpecError
-- Type       : Private
-- Function   : Level 6: Unhandlred internal software failure (typically requires cod/env fix)
--              Log for Unexpected Error
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_module_name IN VARCHAR2
--              p_procedure_name IN VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
PROCEDURE Log_UnexpecError (p_module_name IN VARCHAR2,
                            p_procedure_name IN VARCHAR2)
IS
BEGIN
  IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,p_module_name||' '||p_procedure_name,SQLERRM);
       -- Write on concurrent log
       Log_Concurrent(p_module_name => p_module_name,
                      p_procedure_name => p_procedure_name,
                      p_debug_info => SQLERRM,
                      p_call_api_name => NULL,
                      p_var_name => NULL,
                      p_var_value => NULL,
                      p_debug_type => 1);
  END IF;
END Log_UnexpecError;

END INL_LOGGING_PVT;

/
