--------------------------------------------------------
--  DDL for Package IBE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_UTIL" AUTHID CURRENT_USER AS
/* $Header: IBEUTILS.pls 120.0 2005/05/30 03:11:09 appldev noship $ */
/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURES                                                          |
 |    debug                - Display text message if in debug mode            |
 |    enable_debug_new     - Enable run time debugging                        |
 |    disable_debug_new    - Disable run time debugging                       |
 |    file_debug           - Write text messages into a file if in            |
 |                           file_debug mode                                  |
 |                                                                            |
 |    enable_file_debug    - Enable writing debug messages to a file.        |
 |                  Requires file patch (directory), THIS SHOULD BE |
 |            DEFINED IN INIT.ORA PARAMETER 'UTIL_FILE_DIR',  |
 |            file name (Any valid OS file name).             |
 |   disable_file_debug    - Stops writing into the file.                     |
 |   get_install_info      - Calls FND_INSTALLATION.get() to determine if an  |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Generate standard debug information for PL/SQL apis by sending it to    |
 |    to a operating system file.                 |
 |                                                                            |
 | HOW TO USE ISTORE DEBUGGING:                                               |
 |                                                                            |
 | 1. Turn on the Debugging                                                   |
 |  a) If calling pl/sql from java before calling PL/SQL api from java itself |
 |    enable runtime debugging. and after pl/sql is finished, disable run time|
 |    debugging.                                                              |
 |    Example:                                                                |
 |    ocsStmt.append("BEGIN " +                                               |
 |                   IBEUtil.getEnableDebugString() +  <= To turn on debugging|
 |                   "IBE_Quote_W1_Pvt.SaveWrapper(" +  <= Your PL/SQL api    |
 |                       .....                                                |
 |                       .....                                                |
 |                       .....                                                |
 |                   );                                                       |
 |    .....                                                                   |
 |    ocsStmt.append(IBEUtil.getDisableDebugString() + "END;"); <= Turn off   |
 |                                                                 debugging  |
 |                                                                            |
 |  b) If calling pl/sql api from  within PL/SQL itself                       |
 |       call ibe_util.enable_debug_new before and call                       |
 |       ibe_util.disable_debug_new afterwards                                |
 |                                                                            |
 | 2. Within your PL/SQL api's call IBE_UTIL.debug to print the messages      |
 |    NO NEED TO CALL enable_Debug or disable_debug from within pl/sql api    |
 |                                                                            |
 |                                                                            |
 | REQUIRES                                                                   |
 |                            |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |   Harish Ekkirala Created 04/03/2000.              |
 |   05/05/2000 - Audrey Yu added get_install_info            |
 |   07/29/2002 - achalana - Changed the Debugging mechanism for performance  |                                                                            |
 |      fix (bug 2406789)                                     |
 |   08/26/2003 - abhandar : new procedure check_jtf_permission               |
 |   09/04/2003 - abhandar - Modified for NOCOPY .                            |
 |   01/14/2004 - batoleti - Added nls_number_format  function                |
 |   02/18/2004 - ssekar   - Added insert_into_temp_table and                 |
 |                           delete_from_temp_table created by Anita          |
 |---------------------------------------------------------------------------*/

G_DEBUG      Varchar2(1)    := FND_API.G_FALSE;

/* New variable 07/29 - achalana */
G_DEBUGON      Varchar2(1)    := NULL;

procedure file_debug(p_line in varchar2);

procedure enable_file_debug(p_path_name in varchar2,
                  p_file_name in varchar2);

procedure disable_file_debug;

procedure debug(p_line in varchar2);

procedure enable_debug;

/* New procedure 07/29 - achalana */
procedure enable_debug_new(p_check_profile varchar2 default NULL);

procedure enable_debug_pvt;

procedure disable_debug;

/* New procedure 07/29 - achalana */
procedure disable_debug_new;
procedure reset_debug;


procedure disable_debug_pvt;

procedure get_install_info(p_appl_id     in  number,
         p_dep_appl_id in  number,
         x_status   out NOCOPY  varchar2,
         x_industry   out NOCOPY  varchar2,
         x_installed   out NOCOPY  number);


--added by abhandar 08/26/03 : new procedure --
--replicates jtf SecurityManager.check() functionality
FUNCTION check_jtf_permission(
               p_permission     in  VARCHAR2,
               p_user_name      in  VARCHAR2 :=fnd_global.user_name
               ) RETURN BOOLEAN;

-- replicates RequestCtx.userHasPermission() functionality
-- always returns true for IBE_INDIVIDUAL user
FUNCTION check_user_permission(
               p_permission     in  VARCHAR2,
               p_user_name      in  VARCHAR2 :=fnd_global.user_name
               ) RETURN BOOLEAN;

--added by batoleti 01/14/04 : new function
--converts the number format to canonical format
FUNCTION nls_number_format(
                            p_number_in     in  VARCHAR2
                          ) RETURN VARCHAR2;

-- delete data from temporary table
FUNCTION delete_from_temp_table (p_keyString IN VARCHAR2)  RETURN VARCHAR2;
-- inserts data from temporary table
PROCEDURE insert_into_temp_table (p_inString IN VARCHAR2,
                                  p_Type     IN VARCHAR2,
                                  p_keyString IN VARCHAR2,
                                  x_QueryString OUT NOCOPY VARCHAR2);

--Concatenates phone elements to phone format of iStore
FUNCTION format_phone(
                            p_country_code     in  VARCHAR2,
                            p_area_code     in  VARCHAR2,
                            p_phone_number     in  VARCHAR2,
                            p_phone_ext     in  VARCHAR2

                          ) RETURN VARCHAR2;
End IBE_UTIL;

 

/
