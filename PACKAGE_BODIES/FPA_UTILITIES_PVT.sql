--------------------------------------------------------
--  DDL for Package Body FPA_UTILITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FPA_UTILITIES_PVT" as
/* $Header: FPAVUTLB.pls 120.1 2005/08/18 11:03:53 appldev ship $ */

g_aw_space_name         VARCHAR2(30) := fpa_global_pvt.aw_space_name;


/**********************************************************************************
**********************************************************************************/
-- The attach_AW procedure attaches PJP's AW space in either one of the following
-- 3 modes:
-- ro - for read only
-- rw - for write only.
-- This procedure's signature has the standard Oracle APPS parameters.  It also
-- expects a parameter for the attach mode.

procedure attach_AW(
  p_api_version                 IN              number
 ,p_attach_mode                 IN              varchar2
 ,x_return_status               OUT NOCOPY      varchar2
 ,x_msg_count                   OUT NOCOPY      number
 ,x_msg_data                    OUT NOCOPY      varchar2
) is

begin

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string (FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_utilities_pvt.attach_aw.begin',
                     'Entering fpa_utilities_pvt.attach_aw');
    END IF;

    -- Attach the AW space read write.
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     'fpa.sql.fpa_utilities_pvt.attach_aw',
                     'Attaching OLAP workspace: ' || g_aw_space_name);
    END IF;

--    dbms_aw.execute('AW ATTACH ' || g_aw_space_name || ' RW FIRST WAIT');
    dbms_aw.execute('AW ATTACH ' || g_aw_space_name || ' ' || p_attach_mode || ' FIRST WAIT');

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_utilities_pvt.attach_aw.end',
                     'Exiting fpa_utilities_pvt.attach_aw');
    END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;

end attach_AW;

/**********************************************************************************
**********************************************************************************/

-- The detach_AW procedure detaches PJP's AW space.
-- This procedure's signature has the standard Oracle APPS parameters.

procedure detach_AW(
  p_api_version                 IN              number
 ,x_return_status               OUT NOCOPY      varchar2
 ,x_msg_count                   OUT NOCOPY      number
 ,x_msg_data                    OUT NOCOPY      varchar2
) is

begin

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string (FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_utilities_pvt.detach_aw.begin',
                     'Entering fpa_utilities_pvt.detach_aw');
    END IF;

    -- Detach the AW space.
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     'fpa.sql.fpa_utilities_pvt.detach_aw',
                     'Detaching OLAP workspace: ' || g_aw_space_name);
    END IF;

    dbms_aw.execute('AW DETACH ' || g_aw_space_name);

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_utilities_pvt.detach_aw.end',
                     'Exiting fpa_utilities_pvt.detach_aw');
    END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    raise;

end detach_AW;

/**********************************************************************************
**********************************************************************************/

-- The following function returns the AW space for PJP.
-- It is used in the DDL for PJPs views.
function aw_space_name
return varchar2 is

l_pjp_schema            varchar2(15);
l_pjp_aw_name           varchar2(30) := 'FPAPJP';

begin

  SELECT application_short_name
    into l_pjp_schema
    from FND_APPLICATION
   WHERE application_id = 440;

  return l_pjp_schema || '.' || l_pjp_aw_name;

end;

/**********************************************************************************
**********************************************************************************/

-- function Duplicate_Name determines if the name already exists.
-- This function expects: p_table_name ----- Name of table being checked
--                        p_column_name ---- Name of the column for the shortname
--                        p_shortname ------ Shortname being checked.
-- If the shortname already exists then the function will return a non-zero number,
-- if it does not exist it will return a zero.

function Duplicate_Name(
  p_table_name                  IN              varchar2
 ,p_column_name                 IN              varchar2
 ,p_name                    IN              varchar2
) return number is

TYPE sn_csr_type                IS REF CURSOR; -- cursor to get shortname.
sn_csr                          sn_csr_type;

l_count                     number;

l_sql                       varchar2(255);

begin

  l_sql := 'select count(' || p_column_name || ')' ||
           '  from ' || p_table_name ||
           ' where upper(' || p_column_name || ') = upper(''' ||  p_name || ''')';


  open sn_csr for l_sql;
    fetch sn_csr into l_count;
  close sn_csr;

  return l_count;

EXCEPTION
  WHEN OTHERS THEN
    return null;

end Duplicate_Name;

/************************************************************************************
************************************************************************************/

-- This function is used to get the cash needed.
function Get_Net_Cash_Needed(
  p_budget                      IN              number
 ,p_cash_req                    IN              number
) return  number is

l_net_cash_needed                                number;

begin

  if p_cash_req > p_budget then
    l_net_cash_needed := p_cash_req - p_budget;
  else
    l_net_cash_needed := 0;
  end if;

  return l_net_cash_needed;

EXCEPTION
  WHEN OTHERS THEN
    return null;

end Get_Net_Cash_Needed;

/************************************************************************************
************************************************************************************/

function Get_Overtime_Resources(
  p_req_resources               IN              number
 ,p_curr_resources              IN              number
) return number is

l_overtime_resources                number := 0;

begin

  if (p_req_resources > p_curr_resources) then
    l_overtime_resources := p_req_resources - p_curr_resources;
  end if;

  return l_overtime_resources;

EXCEPTION
  WHEN OTHERS THEN
    return null;

end Get_Overtime_Resources;

/************************************************************************************
************************************************************************************/

function Get_Unused_Resources(
  p_req_resources               IN              number
 ,p_curr_resources              IN              number
) return number is

l_unused_resources              number := 0;

begin

  if (p_curr_resources > p_req_resources) then
    l_unused_resources := p_curr_resources - p_req_resources;
  end if;

  return l_unused_resources;

EXCEPTION
  WHEN OTHERS THEN
    return null;

end Get_Unused_Resources;

/************************************************************************************
************************************************************************************/

/******  Section for common API messages, exception handling and logging. *********
******** created: ashariff Dt: 10/29/2004 ****************************************/


-- MESSAGE CONSTANTS

--G_MSG_LEVEL_THRESHOLD       CONSTANT NUMBER := FPA_UTILITIES_PVT.G_MISS_NUM;
--------------------------------------------------------------------------------
-- PROCEDURE init_msg_list
--------------------------------------------------------------------------------
PROCEDURE init_msg_list (
    p_init_msg_list IN VARCHAR2
) IS
BEGIN
  IF (FND_API.to_boolean(p_init_msg_list)) THEN
    FND_MSG_PUB.initialize;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
END init_msg_list;
--------------------------------------------------------------------------------
-- FUNCTION start_activity
--------------------------------------------------------------------------------
FUNCTION start_activity(
    p_api_name          IN VARCHAR2,
    p_pkg_name          IN VARCHAR2,
    p_init_msg_list     IN VARCHAR2,
    l_api_version       IN NUMBER,
    p_api_version       IN NUMBER,
    p_api_type          IN VARCHAR2,
    p_msg_log           IN VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2
) RETURN VARCHAR2 IS
BEGIN
    IF (p_msg_log IS NOT NULL
        AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)  THEN
        FND_LOG.String(
                FND_LOG.LEVEL_PROCEDURE,
                'fpa.sql.'||p_pkg_name||p_api_name,
                p_msg_log);
    END IF;
    FPA_UTILITIES_PVT.init_msg_list(p_init_msg_list);
    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
    RETURN(FPA_UTILITIES_PVT.G_RET_STS_SUCCESS);
END start_activity;

PROCEDURE start_activity(
    p_api_name          IN VARCHAR2,
    p_pkg_name          IN VARCHAR2,
    p_init_msg_list     IN VARCHAR2,
    p_msg_log           IN VARCHAR2
) IS
BEGIN
    IF (p_msg_log IS NOT NULL
        AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)  THEN
        FND_LOG.String(
                FND_LOG.LEVEL_PROCEDURE,
                'fpa.sql.'||p_pkg_name||p_api_name,
                p_msg_log);
    END IF;
    FPA_UTILITIES_PVT.init_msg_list(p_init_msg_list);
END start_activity;
--------------------------------------------------------------------------------
-- FUNCTION handle_exceptions
--------------------------------------------------------------------------------
FUNCTION handle_exceptions (
    p_api_name      IN VARCHAR2,
    p_pkg_name      IN VARCHAR2,
    p_exc_name      IN VARCHAR2,
    p_msg_log       IN VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2,
    p_api_type      IN VARCHAR2
) RETURN VARCHAR2 IS
    l_return_value      VARCHAR2(200) := FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR;
BEGIN
    IF p_exc_name = 'FPA_UTILITIES_PVT.G_RET_STS_ERROR'  THEN
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.String(
                    FND_LOG.LEVEL_PROCEDURE,
                    'fpa.sql.'||p_pkg_name||p_api_name,
                    p_exc_name||p_msg_log);
        END IF;
        l_return_value := FPA_UTILITIES_PVT.G_RET_STS_ERROR;
    ELSIF p_exc_name = 'FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR'  THEN
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.String(
                    FND_LOG.LEVEL_PROCEDURE,
                    'fpa.sql.'||p_pkg_name||p_api_name,
                    p_exc_name||p_msg_log);
        END IF;
    ELSE -- WHEN OTHERS EXCEPTION
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(
                p_pkg_name,
                p_api_name);
        END IF;
    END IF;
    FND_MSG_PUB.Count_And_Get(
                p_count =>  x_msg_count,
                p_data  =>  x_msg_data);
    RETURN(l_return_value);
END handle_exceptions;
--------------------------------------------------------------------------------
-- FUNCTION end_activity
--------------------------------------------------------------------------------
PROCEDURE end_activity (
    p_api_name     IN VARCHAR2,
    p_pkg_name     IN VARCHAR2,
    p_msg_log      IN VARCHAR2,
    x_msg_count    OUT NOCOPY NUMBER,
    x_msg_data     OUT NOCOPY VARCHAR2) IS
BEGIN
    IF (p_msg_log IS NOT NULL
        AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.String(
                FND_LOG.LEVEL_PROCEDURE,
                p_pkg_name||p_api_name,
                p_msg_log);
    END IF;
    --- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
               p_count =>  x_msg_count,
                p_data  =>  x_msg_data);
END end_activity;
--------------------------------------------------------------------------------
-- PROCEDURE set_message
--------------------------------------------------------------------------------
PROCEDURE set_message (
    p_app_name      IN VARCHAR2,
    p_msg_name      IN VARCHAR2,
    p_token1        IN VARCHAR2,
    p_token1_value      IN VARCHAR2,
    p_token2        IN VARCHAR2,
    p_token2_value      IN VARCHAR2,
    p_token3        IN VARCHAR2,
    p_token3_value      IN VARCHAR2,
    p_token4        IN VARCHAR2,
    p_token4_value      IN VARCHAR2,
    p_token5        IN VARCHAR2,
    p_token5_value      IN VARCHAR2,
    p_token6        IN VARCHAR2,
    p_token6_value      IN VARCHAR2,
    p_token7        IN VARCHAR2,
    p_token7_value      IN VARCHAR2,
    p_token8        IN VARCHAR2,
    p_token8_value      IN VARCHAR2,
    p_token9        IN VARCHAR2,
    p_token9_value      IN VARCHAR2,
    p_token10       IN VARCHAR2,
    p_token10_value     IN VARCHAR2
) IS
BEGIN
    FND_MESSAGE.SET_NAME( FPA_UTILITIES_PVT.G_APP_NAME, P_MSG_NAME);
    IF (p_token1 IS NOT NULL) AND (p_token1_value IS NOT NULL) THEN
        FND_MESSAGE.SET_TOKEN(  TOKEN       => p_token1,
                    VALUE       => p_token1_value);
    END IF;
    IF (p_token2 IS NOT NULL) AND (p_token2_value IS NOT NULL) THEN
        FND_MESSAGE.SET_TOKEN(  TOKEN       => p_token2,
                    VALUE       => p_token2_value);
    END IF;
    IF (p_token3 IS NOT NULL) AND (p_token3_value IS NOT NULL) THEN
        FND_MESSAGE.SET_TOKEN(  TOKEN       => p_token3,
                    VALUE       => p_token3_value);
    END IF;
    IF (p_token4 IS NOT NULL) AND (p_token4_value IS NOT NULL) THEN
        FND_MESSAGE.SET_TOKEN(  TOKEN       => p_token4,
                    VALUE       => p_token4_value);
    END IF;
    IF (p_token5 IS NOT NULL) AND (p_token5_value IS NOT NULL) THEN
        FND_MESSAGE.SET_TOKEN(  TOKEN       => p_token5,
                    VALUE       => p_token5_value);
    END IF;
    IF (p_token6 IS NOT NULL) AND (p_token6_value IS NOT NULL) THEN
        FND_MESSAGE.SET_TOKEN(  TOKEN       => p_token6,
                    VALUE       => p_token6_value);
    END IF;
    IF (p_token7 IS NOT NULL) AND (p_token7_value IS NOT NULL) THEN
        FND_MESSAGE.SET_TOKEN(  TOKEN       => p_token7,
                    VALUE       => p_token7_value);
    END IF;
    IF (p_token8 IS NOT NULL) AND (p_token8_value IS NOT NULL) THEN
        FND_MESSAGE.SET_TOKEN(  TOKEN       => p_token8,
                    VALUE       => p_token8_value);
    END IF;
    IF (p_token9 IS NOT NULL) AND (p_token9_value IS NOT NULL) THEN
        FND_MESSAGE.SET_TOKEN(  TOKEN       => p_token9,
                    VALUE       => p_token9_value);
    END IF;
    IF (p_token10 IS NOT NULL) AND (p_token10_value IS NOT NULL) THEN
        FND_MESSAGE.SET_TOKEN(  TOKEN       => p_token10,
                    VALUE       => p_token10_value);
    END IF;
    FND_MSG_PUB.add;
END set_message;

/****END: Section for common API messages, exception handling and logging.******
********************************************************************************/

end FPA_Utilities_PVT;

/
