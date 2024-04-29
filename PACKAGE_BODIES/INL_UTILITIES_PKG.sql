--------------------------------------------------------
--  DDL for Package Body INL_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INL_UTILITIES_PKG" AS
/* $Header: INLVUTLB.pls 120.0.12010000.3 2013/09/12 19:31:15 ebarbosa noship $ */

-- Utility name : Get_LookupMeaning
-- Type       : Private
-- Function   : Get the meaning for a given lookup code.
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_lookup_type IN VARCHAR2
--              p_lookup_code IN VARCHAR2
--
-- OUT        : x_return_status OUT NOCOPY VARCHAR2
--              x_msg_count OUT NOCOPY NUMBER
--              x_msg_data OUT NOCOPY VARCHAR2
--
-- Version    : Current version 1.0
--
-- Notes      :
Function Get_LookupMeaning (p_lookup_type IN VARCHAR2,
                                p_lookup_code IN VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count OUT NOCOPY NUMBER,
                                x_msg_data OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

l_func_name CONSTANT VARCHAR2(30) := 'Get_LookupMeaning';
l_debug_info VARCHAR2(200);
l_meaning VARCHAR2(80);
BEGIN

    --  Initialize return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INL_LOGGING_PVT.Log_BeginProc(p_module_name => g_module_name,
                                  p_procedure_name => l_func_name);

    INL_LOGGING_PVT.Log_Variable(p_module_name => g_module_name,
                                  p_procedure_name => l_func_name,
                                  p_var_name => 'p_lookup_type',
                                  p_var_value => p_lookup_type);

    INL_LOGGING_PVT.Log_Variable(p_module_name => g_module_name,
                                  p_procedure_name => l_func_name,
                                  p_var_name => 'p_lookup_code',
                                  p_var_value => p_lookup_code);

    SELECT flv.meaning
    INTO l_meaning
    FROM fnd_lookup_values_vl flv
    WHERE flv.lookup_type = p_lookup_type
    AND flv.lookup_code = p_lookup_code
    AND flv.enabled_flag = 'Y'
    AND  SYSDATE BETWEEN nvl(flv.start_date_active,sysdate)
    AND NVL(flv.end_date_active,SYSDATE);

    INL_LOGGING_PVT.Log_Variable(p_module_name => g_module_name,
                                  p_procedure_name => l_func_name,
                                  p_var_name => 'l_meaning',
                                  p_var_value => l_meaning);

     -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.g_false,
                              p_count => x_msg_count,
                              p_data => x_msg_data);

    INL_LOGGING_PVT.Log_EndProc(p_module_name => g_module_name,
                                p_procedure_name => l_func_name);

    RETURN l_meaning;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        -- Standard Expected Error Logging
        INL_LOGGING_PVT.Log_ExpecError(p_module_name => g_module_name,
                                       p_procedure_name => l_func_name);
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError(p_module_name => g_module_name,
                                         p_procedure_name => l_func_name);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        -- Standard Unexpected Error Logging
        INL_LOGGING_PVT.Log_UnexpecError(p_module_name => g_module_name,
                                         p_procedure_name => l_func_name);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(p_pkg_name => g_pkg_name,
                                  p_procedure_name => l_func_name);
        END IF;
END Get_LookupMeaning;


-- Utility name : Expose_Feature
-- Type       : Private
-- Function   : Check feature exposure
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_feature IN VARCHAR2
--
--
-- Notes      :

FUNCTION Expose_Feature(p_feature IN VARCHAR2) RETURN VARCHAR2 IS

l_func_name CONSTANT VARCHAR2(30) := 'Expose_Feature';
l_debug_info VARCHAR2(200);
l_count_elc_profile NUMBER;
l_elc_update_profile_value VARCHAR2(1);

BEGIN

    -- Standard Beginning of Procedure/Function Logging
    INL_LOGGING_PVT.Log_BeginProc(p_module_name => g_module_name,
                                  p_procedure_name => l_func_name) ;

    INL_LOGGING_PVT.Log_Variable(p_module_name => g_module_name,
                                 p_procedure_name => l_func_name,
                                 p_var_name => 'p_feature',
                                 p_var_value => p_feature);

  IF p_feature = 'MANAGE_CHARGES' THEN
    IF fnd_release.major_version >= 12 AND
       fnd_release.minor_version >= 2 AND
       fnd_release.point_version >= 2 THEN
      RETURN 'Y'; -- Release >= 12.2.2
    ELSE
      RETURN 'N';
    END IF;
  ELSIF p_feature = 'ELC_UPDATE' THEN
     IF NVL(FND_PROFILE.VALUE('INL_ELC_UPDATE_ENABLED'), 'N') = 'N' THEN
        RETURN 'N';
     ELSE
        RETURN 'Y';
     END IF;
  END IF;

  -- Standard End of Procedure/Function Logging
  INL_LOGGING_PVT.Log_EndProc(p_module_name    => g_module_name,
                              p_procedure_name => l_func_name);
EXCEPTION
WHEN OTHERS THEN
    -- Standard Unexpected Error Logging
    INL_LOGGING_PVT.Log_UnexpecError ( p_module_name => g_module_name,
                                       p_procedure_name => l_func_name) ;
    IF FND_MSG_PUB.Check_Msg_Level (p_message_level  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg ( p_pkg_name => g_pkg_name,
                                  p_procedure_name => l_func_name) ;
    END IF;
    RETURN NULL;
END Expose_Feature;

END INL_UTILITIES_PKG;

/
