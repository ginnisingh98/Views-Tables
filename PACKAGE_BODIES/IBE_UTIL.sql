--------------------------------------------------------
--  DDL for Package Body IBE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_UTIL" AS
/* $$Header: IBEUTILB.pls 120.0 2005/05/30 02:39:04 appldev noship $$ */
/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURES                                                          |
 |    debug                - Display text message if in debug mode            |
 |    enable_debug_new     - Enable run time debugging                        |
 |    disable_debug_new    - Disable run time debugging                       |
 |    file_debug           - Write text messages into a file if in            |
 |                           file_debug mode                                  |
 |			           				                                 |
 |    enable_file_debug    - Enable writing debug messages to a file.	        |
 |		             Requires file patch (directory), THIS SHOULD BE        |
 |			     DEFINED IN INIT.ORA PARAMETER 'UTIL_FILE_DIR',            |
 |			     file name (Any valid OS file name).                       |
 |   disable_file_debug    - Stops writing into the file.                     |
 |   get_install_info      - Calls FND_INSTALLATION.get() to determine if an  |
 |			               application is installed.	                  |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Generate standard debug information for PL/SQL apis by sending it to    |
 |    to a operating system file. 					                       |
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
 |    									                            |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |   Harish Ekkirala Created 04/03/2000.				                  |
 |   05/05/2000 - Audrey Yu added get_install_info			             |
 |   05/11/2001 - Modified the logging mechanism to use OM log file. Now you  |
 |                turn on the logging for a specific user by turning on       |
 |                IBE_DEBUG profile at user level. -- hekkiral                |
 |   07/29/2002 - achalana - Changed the Debugging mechanism for performance  |                                                                            |
 |			fix (bug 2406789)                                              |
 |   08/26/2003 - abhandar - added procedure check_jtf_permission()           |
 |   09/04/2003 - abhandar - Modified for NOCOPY .                            |
 |   01/14/2004 - batoleti - Added nls_number_format function                 |
 |   02/18/2004 - ssekar   - Added insert_into_temp_table and                 |
 |                           delete_from_temp_table created by Anita          |
 *----------------------------------------------------------------------------*/

-------------------------------------------------------------------------
-- Private Variables
-------------------------------------------------------------------------
l_file_name	    VARCHAR2(100) := NULL;
l_path_name     VARCHAR2(100) := NULL;
l_file_type	    utl_file.file_type;
l_debug_flag    boolean := false;

procedure file_debug(p_line in varchar2) IS

begin
  if (l_file_name is not null) THEN
    utl_file.put_line(l_file_type, p_line);
    utl_file.fflush(l_file_type);
  end if;
end file_debug;

procedure enable_file_debug(p_path_name in varchar2,
			    p_file_name in varchar2) IS
begin

  if (l_file_name is null) THEN
    l_file_type := utl_file.fopen(p_path_name, p_file_name, 'a');
    l_file_name := p_file_name;
    l_path_name := p_path_name;
  end if;

exception
     when utl_file.invalid_path then
        app_exception.raise_exception;
     when utl_file.invalid_mode then
        app_exception.raise_exception;

end ;

procedure disable_file_debug is
begin
  if (l_file_name is not null) THEN
    utl_file.fclose(l_file_type);
  end if;
end;

procedure debug(p_line in varchar2 ) is
	x_rest varchar2(32767);
	debug_msg varchar2(32767);
	buffer_overflow exception;
	pragma exception_init(buffer_overflow, -20000);
begin

          /**
               Changed to not call fnd_profile everytime but to check IBE_UTIL.DEBUGON global variable
                - achalana 07/29
          **/
--        If fnd_profile.value_specific('IBE_DEBUG',FND_GLOBAL.USER_ID,null,null) = 'Y' Then
          If IBE_UTIL.G_DEBUGON  = FND_API.G_TRUE Then
              -- utl_file.put_line(ASO_DEBUG_PUB.G_FILE_PTR, to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS')||'IBE IBE_UTIL:Using New Debugging');
             enable_debug_pvt();
             x_rest := p_line;
             loop
			if (x_rest is null) then
			    exit;
			else
			    --OE_DEBUG_PUB.ADD(to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS')||' '||substr(x_rest,1,255));
                      debug_msg := to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS')||' IBE '||substr(x_rest,1,255);
                      utl_file.put_line(ASO_DEBUG_PUB.G_FILE_PTR, debug_msg);
	                utl_file.fflush(ASO_DEBUG_PUB.G_FILE_PTR);
			    x_rest := substr(x_rest,256);
		   	end if;
  		 end loop;

          Elsif IBE_UTIL.G_DEBUGON  = FND_API.G_FALSE Then
              disable_debug_pvt();
          Elsif IBE_UTIL.G_DEBUGON  IS NULL Then
		/**
                wrote this section of code for backward compatibility, so that code that was not changed
                for new debugging should work
            **/
		    If fnd_profile.value_specific('IBE_DEBUG',FND_GLOBAL.USER_ID,null,null) = 'Y' Then
                      	enable_debug_pvt();
              		x_rest := p_line;
             		loop
					if (x_rest is null) then
					    exit;
					else
					    --OE_DEBUG_PUB.ADD(to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS')||' '||substr(x_rest,1,255));
                  		    debug_msg := to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS')||' IBE '||substr(x_rest,1,255);
                  		    utl_file.put_line(ASO_DEBUG_PUB.G_FILE_PTR, debug_msg);
	            		    utl_file.fflush(ASO_DEBUG_PUB.G_FILE_PTR);
					    x_rest := substr(x_rest,256);
		   			end if;
  		 		end loop;
 		    End If;
          End If;

     exception
         when buffer_overflow then
               null;  -- buffer overflow, ignore
         when others then
              -- raise; -- Modified so that it will not raise any exceptions.
	        null;
end;

procedure enable_debug is
l_file_name VARCHAR2(100);
begin
   null; -- Modified so that this will not be used by developers.
end;

/* New procedure 07/29 - achalana */
procedure enable_debug_new(p_check_profile varchar2 default NULL) is
	l_file_name VARCHAR2(100);
begin

	/**
	    If in java before calling enable_debug_new we already have checked the cookie by calling
          IBEUtil.logEnabled() you can pass p_check_profile = 'N' to this api, it will not check
          fnd_profile again, and set G_DEBUGON to true
      **/

      If p_check_profile = 'N' Then
             IBE_UTIL.G_DEBUGON := FND_API.G_TRUE;
		   IBE_UTIL.debug('IBE_UTIL.enable_debug_new p_check_profile is N');
      Else
           If fnd_profile.value_specific('IBE_DEBUG',FND_GLOBAL.USER_ID,null,null) = 'Y' Then
               IBE_UTIL.G_DEBUGON := FND_API.G_TRUE;
	     Else
               IBE_UTIL.G_DEBUGON := FND_API.G_FALSE;
  	     End If;

  	     IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('IBE_UTIL.enable_debug_new p_check_profile is not passed');
	     END IF;
      End If;
end;


procedure enable_debug_pvt is
begin
   --l_debug_flag := true;
   --dbms_output.enable;
/* Modified the procedure so that we can enable debug at user level. If the
profile IBE: Enable Debug is Set to 'Yes' for a User, we will start writing
the debug messages into a file. */

 		IF (ASO_DEBUG_PUB.G_FILE is NULL OR ASO_DEBUG_PUB.G_FILE <> 'IBE_'||FND_GLOBAL.USER_NAME||'.log') Then
               ASO_DEBUG_PUB.G_DEBUG_MODE := 'FILE';
		   ASO_DEBUG_PUB.G_FILE := 'IBE_'||FND_GLOBAL.USER_NAME||'.log';
		   ASO_DEBUG_PUB.G_FILE_PTR := utl_file.fopen(ASO_DEBUG_PUB.G_DIR,ASO_DEBUG_PUB.G_FILE,'a');
		   ASO_DEBUG_PUB.debug_on;
		   ASO_DEBUG_PUB.setdebuglevel(ASO_DEBUG_PUB.G_DEBUG_LEVEL);
		   /* Setting OM Debug variables on */
               OE_DEBUG_PUB.G_DEBUG_MODE := 'FILE';
		   OE_DEBUG_PUB.G_FILE := 'IBE_'||FND_GLOBAL.USER_NAME||'.log';
		   OE_DEBUG_PUB.G_FILE_PTR := ASO_DEBUG_PUB.G_FILE_PTR;
		   OE_DEBUG_PUB.debug_on;
		   OE_DEBUG_PUB.setdebuglevel(ASO_DEBUG_PUB.G_DEBUG_LEVEL);

	    END IF;
end;

procedure disable_debug is
begin
	null; -- Modified to developers don't use this.
end;

/* New procedure 07/29 - achalana */
procedure disable_debug_new is
begin
          disable_debug_pvt();
          IBE_UTIL.G_DEBUGON := FND_API.G_FALSE;
end;

/* New procedure 07/29 - achalana */
procedure reset_debug is
begin
          disable_debug_pvt();
          IBE_UTIL.G_DEBUGON := NULL;
end;

procedure disable_debug_pvt is
begin
   ASO_DEBUG_PUB.Debug_off;
   ASO_DEBUG_PUB.G_FILE := null;
   OE_DEBUG_PUB.Debug_off;
   OE_DEBUG_PUB.G_FILE := null;
   If utl_file.is_Open(ASO_DEBUG_PUB.G_FILE_PTR) Then
      utl_file.fclose(ASO_DEBUG_PUB.G_FILE_PTR);
   End If;
exception
  When Others Then
     null;
end;


procedure get_install_info(p_appl_id     in  number,
			   p_dep_appl_id in  number,
			   x_status	 out NOCOPY  varchar2,
			   x_industry	 out NOCOPY varchar2,
			   x_installed   out NOCOPY number)
	IS
	  l_installed BOOLEAN;

	BEGIN
	   l_installed := fnd_installation.get(	appl_id     => p_appl_id,
                                    		dep_appl_id => p_dep_appl_id,
                                    		status      => x_status,
                                    		industry    => x_industry );
	  IF (l_installed) THEN
	     x_installed := 1;
	  ELSE
	     x_installed := 0;
          END IF;

	END get_install_info;

-- replicates RequestCtx.userHasPermission() functionality
-- always returns true for IBE_INDIVIDUAL user
FUNCTION check_user_permission(
               p_permission     in  VARCHAR2,
               p_user_name      in  VARCHAR2 :=fnd_global.user_name
               ) RETURN BOOLEAN
IS

Cursor c_get_party_type(c_user_name VARCHAR2) IS
    select d.party_type
    from fnd_user c , hz_parties d
    where d.party_id=c.customer_id
    and c.user_name=c_user_name;

l_PartyType  Varchar2(30);

BEGIN
  l_PartyType :='';

  open c_get_party_type(p_user_name);
  fetch c_get_party_type into l_PartyType;
  CLOSE c_get_party_type;
  if (l_PartyType='PERSON') then
         return true;
  else  return check_jtf_permission(p_permission,p_user_name);
  end if;


END check_user_permission;


-- added by abhandar :new procedure
-- replicates jtf SecurityManager.check() function
FUNCTION check_jtf_permission(
               p_permission     in  VARCHAR2,
               p_user_name      in  VARCHAR2 :=fnd_global.user_name
               ) RETURN BOOLEAN
 IS

 l_api_name         CONSTANT VARCHAR2(40) := 'check_jtf_permission';
 l_temp_var         VARCHAR2(1);
 l_hasPermission    boolean :=false;

 CURSOR c_get_permission(l_user_name VARCHAR2,l_permission VARCHAR2)  IS
 SELECT 'Y' FROM JTF_AUTH_PERMISSIONS_B A,
		JTF_AUTH_PRINCIPAL_MAPS B,
		JTF_AUTH_ROLE_PERMS C,
		JTF_AUTH_PRINCIPALS_B D,
		JTF_AUTH_PRINCIPALS_B E,
 	    JTF_AUTH_DOMAINS_B F
	WHERE D.PRINCIPAL_NAME = l_user_name AND D.IS_USER_FLAG = 1 AND
		D.JTF_AUTH_PRINCIPAL_ID = B.JTF_AUTH_PRINCIPAL_ID AND
 		B.JTF_AUTH_PARENT_PRINCIPAL_ID=E.JTF_AUTH_PRINCIPAL_ID AND
        E.IS_USER_FLAG = 0 AND
		E.JTF_AUTH_PRINCIPAL_ID = C.JTF_AUTH_PRINCIPAL_ID AND
		C.JTF_AUTH_PERMISSION_ID = A.JTF_AUTH_PERMISSION_ID AND
		C.POSITIVE_FLAG=1 AND
		B.JTF_AUTH_DOMAIN_ID = F.JTF_AUTH_DOMAIN_ID AND
		F.DOMAIN_NAME ='CRM_DOMAIN' AND
		A.PERMISSION_NAME = l_permission;

 BEGIN
  IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
   ibe_util.debug(l_api_name||'input user name  ='|| p_user_name);
   ibe_util.debug(l_api_name||'input permission ='|| p_permission);
  END IF;

  OPEN  c_get_permission(p_user_name,p_permission);
  FETCH c_get_permission INTO l_temp_var;
  IF (c_get_permission%FOUND) THEN
          l_hasPermission:=true;
  END IF;

  IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
     ibe_util.debug(l_api_name||'l_temp_var ='|| l_temp_var);
  END IF;

  return l_hasPermission;

END check_jtf_permission;

/*

  nls_number_format function is used to convert the number to
  canonical format.
  The input is a number in string.
  The out put is also a string.

*/

FUNCTION nls_number_format(
               p_number_in     in  VARCHAR2
               ) RETURN VARCHAR2
IS

  l_number_out  VARCHAR2(50);

BEGIN

    l_number_out :=  to_char(fnd_number.canonical_to_number(p_number_in));

    RETURN (l_number_out);

END nls_number_format;

--This function deletes the data from the temporary table
FUNCTION delete_from_temp_table (p_keyString IN VARCHAR2)  RETURN VARCHAR2

IS
BEGIN
  delete from ibe_temp_table where key=p_keyString;
  IF SQL%FOUND THEN
     return FND_API.G_TRUE;
  ELSE
    return FND_API.G_FALSE;
  END IF;
END delete_from_temp_table;

--Concatenates phone elements to phone format of iStore
FUNCTION format_phone(
                            p_country_code     in  VARCHAR2,
                            p_area_code     in  VARCHAR2,
                            p_phone_number     in  VARCHAR2,
                            p_phone_ext     in  VARCHAR2
                          ) RETURN VARCHAR2
IS
  l_phone_number_out VARCHAR2(86);
BEGIN
  IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
  IBE_UTIL.debug('Begin format_phone,input cc,ac,phnum,phext '||p_country_code||','||p_area_code||','||p_phone_number||','||p_phone_ext);
  END IF;

  IF p_country_code IS NOT NULL AND p_country_code <> FND_API.G_MISS_CHAR THEN
   l_phone_number_out := p_country_code||'-';
  END IF;
  IF p_area_code IS NOT NULL AND p_area_code <> FND_API.G_MISS_CHAR THEN
   l_phone_number_out := l_phone_number_out || p_area_code ||'-';
  END IF;
  IF p_phone_number IS NOT NULL AND p_phone_number <> FND_API.G_MISS_CHAR THEN
   l_phone_number_out := l_phone_number_out || p_phone_number ||' ';
  END IF;
  IF p_phone_ext IS NOT NULL AND p_phone_ext <> FND_API.G_MISS_CHAR THEN
   l_phone_number_out := l_phone_number_out || 'x' || p_phone_ext;
  END IF;

  IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
  IBE_UTIL.debug('Exit format_phone, output phone number '||l_phone_number_out);
  END IF;
  RETURN l_phone_number_out;
END format_phone;

--This procudure inserts the data from the temporary table
PROCEDURE insert_into_temp_table (p_inString IN VARCHAR2,
                                  p_Type     IN VARCHAR2,
                                  p_keyString IN VARCHAR2,
                                  x_QueryString OUT NOCOPY VARCHAR2)
IS

 BEGIN

   IF  IBE_UTIL.G_DEBUGON = FND_API.G_TRUE THEN
       IBE_UTIL.debug('START: insert_into_temp_table');
   END IF;

   IF p_Type = 'CHAR' THEN
      INSERT into IBE_TEMP_TABLE (KEY, CHAR_VAL) VALUES (p_keyString,p_inString);
   ELSIF p_Type = 'NUM' THEN
      INSERT into IBE_TEMP_TABLE (KEY, NUM_VAL) VALUES (p_keyString,to_number(p_inString));
   END IF;

   IF p_Type = 'CHAR' THEN
     x_QueryString := 'SELECT CHAR_VAL FROM IBE_TEMP_TABLE WHERE KEY = :1';
   ELSIF p_Type = 'NUM' THEN
     x_QueryString := 'SELECT NUM_VAL FROM IBE_TEMP_TABLE WHERE KEY = :1';
   END IF;

 EXCEPTION
   WHEN OTHERS then
    IF  IBE_UTIL.G_DEBUGON = FND_API.G_TRUE THEN
       IBE_UTIL.debug('Exception.....'||sqlerrm);
    END IF;
   Raise;

 END insert_into_temp_table;

END IBE_UTIL;

/
