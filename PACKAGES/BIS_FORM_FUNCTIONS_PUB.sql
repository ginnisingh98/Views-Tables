--------------------------------------------------------
--  DDL for Package BIS_FORM_FUNCTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_FORM_FUNCTIONS_PUB" AUTHID CURRENT_USER as
/* $Header: BISPFFNS.pls 120.2 2005/08/25 02:02:06 kyadamak noship $ */
----------------------------------------------------------------------------
--  PACKAGE:      BIS_FORM_FUNCTIONS_PUB                                  --
--                                                                        --
--  DESCRIPTION:  Private package that calls the FND packages to          --
--        insert records in the FND tables.                   --
--
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification
--  XX-XXX-XX  XXXXXXXX   Modifications made, which procedures changed &  --
--                        list bug number, if fixing a bug.               --
--                                                                        --
--  11/21/01   mdamle     Initial creation                                --
--  12/25/03   mdamle     Page Definer Integration - overloaded for addnl --
--                functionality and error messaging               --
--  06/07/04   mdamle     Added delete_function_and_menu_ent              --
--  08/04/04   mdamle     Bug#3823878 - Add lock_row                      --
--  09/28/04   mdamle     Bug#3919538 - Update function menu prompts      --
--  10/27/04   mdamle     Bug#3972992 - Region code and app id in form fn --
--  01/03/05   mdamle     Enh#3014083 - Integrate with Extension table    --
--  01/13/05   vtulasi    Bug#4102897 - Change in size of variables       --
--  01/29/05   akoduri    Bug#4083833 - Select Content FROM OA Region     --
--  05/22/05   akoduri    Enhancement#3865711 -- Obsolete Seeded Objects  --
--  05/03/05   rpenneru   Enhancement#4346994 -- HTML Portlet             --
--  19-MAY-2005  visuri   GSCC Issues bug 4363854                         --
--  17-AUG-2005 kyadamak Bug#4516889 added regioncode,regionapplid to update_row --
----------------------------------------------------------------------------

-- Defaults
c_WEB_SECURED               constant varchar2(1)    := 'N';
c_WEB_ENCRYPT_PARAMETERS    constant varchar2(1)    := 'N';
c_RECORD_DELETED            constant varchar2(7)    := 'DELETED';
c_RECORD_CHANGED            constant varchar2(7)    := 'CHANGED';
C_LAST_UPDATE_DATE_FORMAT varchar2(21) := 'YYYY/MM/DD-HH24:MI:SS';
c_CUSTOM_FUNCTIONAL_AREA    constant varchar2(7) := 'BIS_UNN';

TYPE FormFunction_Rec_Type IS RECORD (
  function_name         FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE,
  user_function_name        VARCHAR2(80),
  type              VARCHAR2(30),
  web_html_call         VARCHAR2(240),
  web_host_name         VARCHAR2(80),
  web_agent_name        VARCHAR2(80),
  web_encrypt_parameters    VARCHAR2(1),
  web_secured           VARCHAR2(1),
  web_icon          VARCHAR2(30),
  object_id         NUMBER,
  region_application_id     NUMBER,
  region_code           VARCHAR2(30),
  application_id        NUMBER,
  form_id           NUMBER,
  maintenance_mode_support  VARCHAR2(8),
  context_dependence        VARCHAR2(8),
  parameters            VARCHAR2(2000),
  description           VARCHAR2(240)
);

procedure INSERT_ROW (
    X_ROWID in out NOCOPY VARCHAR2,
    X_USER_ID in NUMBER,
    X_FUNCTION_ID in out NOCOPY VARCHAR2,
    X_WEB_HTML_CALL in VARCHAR2,
    X_FUNCTION_NAME in VARCHAR2,
    X_PARAMETERS in VARCHAR2,
    X_TYPE in VARCHAR2,
    X_USER_FUNCTION_NAME in VARCHAR2,
    X_DESCRIPTION in VARCHAR2);

-- mdamle 12/25/2003 - overloaded for additional functionality & error messaging
procedure INSERT_ROW (
 p_FUNCTION_NAME    in VARCHAR2
,p_WEB_HTML_CALL    in VARCHAR2
,p_PARAMETERS       in VARCHAR2
,p_TYPE         in VARCHAR2
,p_USER_FUNCTION_NAME   in VARCHAR2
,p_DESCRIPTION      in VARCHAR2 := NULL
,x_FUNCTION_ID      OUT NOCOPY NUMBER
,x_return_status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_data             OUT NOCOPY VARCHAR2
,p_REGION_CODE           in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_REGION_APPLICATION_ID in NUMBER := BIS_COMMON_UTILS.G_DEF_NUM
,p_APPLICATION_ID        in NUMBER := BIS_COMMON_UTILS.G_DEF_NUM
,p_OBJECT_TYPE           in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_FUNCTIONAL_AREA_ID        in NUMBER := BIS_COMMON_UTILS.G_DEF_NUM
);

procedure UPDATE_ROW (
    X_USER_ID in NUMBER,
    X_FUNCTION_ID in NUMBER,
    X_PARAMETERS in VARCHAR2,
    X_DESCRIPTION in VARCHAR2);

-- mdamle 12/25/2003 - overloaded for additional functionality & error messaging
procedure UPDATE_ROW (
 p_FUNCTION_ID            IN  NUMBER
,p_USER_FUNCTION_NAME     IN  VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_PARAMETERS             IN  VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_DESCRIPTION            IN  VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_WEB_HTML_CALL          IN  VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_APPLICATION_ID         IN  NUMBER := BIS_COMMON_UTILS.G_DEF_NUM
,p_OBJECT_TYPE            IN  VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_FUNCTIONAL_AREA_ID     IN  NUMBER := BIS_COMMON_UTILS.G_DEF_NUM
,x_return_status          OUT NOCOPY VARCHAR2
,x_msg_count              OUT NOCOPY NUMBER
,x_msg_data               OUT NOCOPY VARCHAR2
,p_REGION_CODE            IN  VARCHAR2 := NULL
,p_REGION_APPLICATION_ID  IN  NUMBER := NULL

);

-- mdamle 12/25/2003
PROCEDURE DELETE_ROW (
 p_FUNCTION_ID          in VARCHAR2
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
 );

PROCEDURE DELETE_FUNCTION_AND_MENU_ENT
(p_function_name                IN VARCHAR2
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2);

PROCEDURE DELETE_ROW_FUNC_MENUENTRIES (
 p_FUNCTION_ID          in VARCHAR2
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2) ;

PROCEDURE LOCK_FUNCTION_ROW
(  p_function_id                  IN         NUMBER
 , p_last_update_date             IN         VARCHAR2
 , x_record_status                OUT NOCOPY VARCHAR2
);

PROCEDURE UPDATE_FUNCTION_MENU_PROMPTS
(p_function_id                  IN NUMBER
,p_user_function_name           IN VARCHAR2
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);

PROCEDURE Update_Form_Func_Obsolete_Flag (
    p_commit                      IN VARCHAR2 := FND_API.G_FALSE,
    p_func_name                   IN VARCHAR2,
    p_obsolete                    IN VARCHAR2,
    x_return_status               OUT nocopy VARCHAR2,
    x_Msg_Count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT nocopy VARCHAR2
);

PROCEDURE Check_Form_Function(
   p_functionName                 IN  VARCHAR2
  ,p_user_functionName            IN  VARCHAR2
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
);

END BIS_FORM_FUNCTIONS_PUB;

 

/
