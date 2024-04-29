--------------------------------------------------------
--  DDL for Package Body ECX_UTIL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_UTIL_API" AS
-- $Header: ECXUTLAB.pls 120.3 2006/06/07 07:54:06 susaha ship $


l_procedure          PLS_INTEGER := ecx_debug.g_procedure;
l_statement          PLS_INTEGER := ecx_debug.g_statement;
l_unexpected         PLS_INTEGER := ecx_debug.g_unexpected;
l_procedureEnabled   boolean     := ecx_debug.g_procedureEnabled;
l_statementEnabled   boolean     := ecx_debug.g_statementEnabled;
l_unexpectedEnabled  boolean     := ecx_debug.g_unexpectedEnabled;

function validate_direction
	(
   	p_direction in varchar2
   	) return boolean
is
begin
	if (p_direction is null)
	then
		return false;
	end if;

	if (p_direction = 'IN' OR p_direction = 'OUT')
	then
		return true;
	else
		return false;
	end if;

exception
when others then
	return false;
end validate_direction;

Function validate_party_type
	(
	p_party_type In Varchar2
	)  return boolean
Is

l_insmode	VARCHAR2(15);
l_Select	VARCHAR2(500);
l_CursorID	INTEGER;
l_result	INTEGER;
Begin

	-- Identiy the installation mode and based on the build the query.
	-- For Standalone, refer to WF_LOOKUPS otherwise refer to ECX_LOOKUP_VALUES.

	l_insmode := wf_core.translate('WF_INSTALL');

	IF l_insmode = 'EMBEDDED' THEN
	   l_Select := 'SELECT 	1 ' ||
		       ' FROM 	ecx_lookup_values' ||
		       ' WHERE 	lookup_type = ' || '''' || 'PARTY_TYPE' || '''' ||
		       ' AND 	lookup_code = :party_type ' ||
		       ' AND 	enabled_flag = ' || '''' || 'Y' || '''' ||
		       ' AND 	to_date(sysdate, ' || '''' || 'DD-MON-RRRR' || '''' || ') between' ||
		       '	to_date(nvl(start_date_active, sysdate), ' || '''' || 'DD-MON-RRRR' || '''' || ') ' ||
		       ' AND    to_date(nvl(end_date_active, sysdate), ' || '''' || 'DD-MON-RRRR' || '''' || ')';
	ELSE
	   l_Select := 'SELECT 1 ' ||
		       ' FROM	wf_lookups' ||
		       ' WHERE	lookup_type = ' || '''' || 'PARTY_TYPE' || '''' ||
		       ' AND    lookup_code = :party_type ';
	END IF;

	l_CursorID := DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE(l_CursorID, l_Select, DBMS_SQL.V7);

	if l_insmode <> 'EMBEDDED'
	then
		DBMS_SQL.BIND_VARIABLE(l_CursorID, ':party_type', 'STANDALONE');
	else
		DBMS_SQL.BIND_VARIABLE(l_CursorID, ':party_type', p_party_type);
	end if;

	l_result := DBMS_SQL.EXECUTE(l_CursorID);
	IF DBMS_SQL.FETCH_ROWS(l_CursorID) = 0 THEN
	   DBMS_SQL.CLOSE_CURSOR(l_CursorID);
	   return false;
	ELSE
	   DBMS_SQL.CLOSE_CURSOR(l_CursorID);
	   return true;
	END IF;

exception
when others then
	return false;
End Validate_party_type;

/* Bug 2122579 */
Function validate_party_id
	(
	p_party_type In Varchar2,
	p_party_id In number
	)
	return boolean
Is

l_Select	VARCHAR2(500);
l_CursorID	INTEGER;
l_result	INTEGER;
Begin

	/* The query string is built based on the party type.
	   For STANDALONE, no query is executed the function returns TRUE. */

	IF p_party_type = 'C' THEN
	   l_Select := 'SELECT 1 FROM hz_parties hz ' ||
		       'WHERE  hz.party_id  = :party_id ' ||
		       'AND    hz.party_type = ' || '''' || 'ORGANIZATION' || '''' ||
		       ' AND    hz.status = ' || '''' || 'A' || '''' ||
		       ' AND EXISTS ( SELECT  hzc.party_id FROM hz_cust_accounts hzc' ||
		       '	     WHERE   hzc.party_id = hz.party_id)' ;
	ELSIF p_party_type = 'E' THEN
	   l_Select := 'SELECT 1 FROM hz_parties hz' ||
		       ' WHERE  hz.party_id = :party_id' ;
	ELSIF p_party_type = 'S' THEN
	   l_Select := 'SELECT 1 FROM po_vendors' ||
			' WHERE   vendor_id = :party_id' ;
	ELSIF p_party_type = 'B' THEN
	   l_Select := 'SELECT 1 FROM ce_bank_branches_v' ||
		       ' WHERE  branch_party_id = :party_id' ;
	ELSIF p_party_type = 'I' THEN
	   l_Select := 'SELECT 1 FROM hr_locations' ||
		       ' WHERE  location_id = :party_id' ;
        ELSIF p_party_type = 'CARRIER' THEN

           /* Bug 2242598
              Validation of party id for party type of CARRIER. */

           l_Select := ' SELECT 1 FROM hz_parties hp,' ||
                       '               hz_code_assignments hca' ||
                       ' WHERE  hp.status = ' || '''' || 'A' || '''' ||
                       ' AND    hp.party_id = hca.owner_table_id' ||
                       ' AND    hca.owner_table_name = ' || '''' ||
                                     'HZ_PARTIES' || '''' ||
                       ' AND    hca.class_category = ' || '''' ||
                                     'TRANSPORTATION_PROVIDERS' || '''' ||
                       ' AND    hca.class_code = ' || '''' ||
                                     'CARRIER' || '''' ||
                       ' AND    nvl(hca.start_date_active, ' ||
                                'sysdate) <= sysdate' ||
                       ' AND    nvl(hca.end_date_active, sysdate) >= sysdate' ||
                       ' AND    hp.party_id = :party_id';
	END IF;

	IF p_party_type <> 'STANDALONE' THEN
	   l_CursorID := DBMS_SQL.OPEN_CURSOR;
	   DBMS_SQL.PARSE(l_CursorID, l_Select, DBMS_SQL.V7);
	   DBMS_SQL.BIND_VARIABLE(l_CursorID, ':party_id', p_party_id);
	   l_result := DBMS_SQL.EXECUTE(l_CursorID);
	   IF DBMS_SQL.FETCH_ROWS(l_CursorID) = 0 THEN
	      DBMS_SQL.CLOSE_CURSOR(l_CursorID);
	      return false;
	   ELSE
	      DBMS_SQL.CLOSE_CURSOR(l_CursorID);
	      return true;
	   END IF;
	ELSE
	      return true;
	END IF;

exception
when others then
	return false;
End validate_party_id;

/* BUg 2122579 */
Function validate_party_site_id
	(
	p_party_type In Varchar2,
	p_party_id   In number,
	p_party_site_id In number
	)
return boolean
Is

l_Select	VARCHAR2(500);
l_CursorID	INTEGER;
l_result	INTEGER;
Begin

	/* The query string is built based on the party type.
	   For STANDALONE, no query is executed the function returns TRUE. */

	IF p_party_type = 'C' THEN
	   l_Select := 'SELECT  1' ||
		       ' FROM   hz_party_sites hps,' ||
		       '	hz_locations hzl' ||
		       ' WHERE  hps.party_id  = :party_id' ||
		       ' AND    hps.party_site_id = :party_site_id' ||
		       ' AND    hzl.location_id = hps.location_id';
        ELSIF p_party_type = 'B' THEN
           l_Select := 'SELECT 1 FROM ce_bank_branches_v' ||
                       ' WHERE  branch_party_id = :party_site_id' ;
	ELSIF p_party_type = 'S' THEN
	   l_Select := 'SELECT  1' ||
		       ' FROM 	po_vendor_sites' ||
		       ' WHERE  vendor_id = :party_id' ||
		       ' AND    vendor_site_id = :party_site_id';
	ELSIF p_party_type = 'I' THEN
	   l_Select := 'SELECT  1' ||
		       ' FROM   hr_locations' ||
		       ' WHERE  location_id = :party_id' ;
        ELSIF p_party_type = 'CARRIER' THEN

           /* Bug 2242598
              Validation of party id for party type of CARRIER. */

	   l_Select := 'SELECT  1' ||
		       ' FROM   hz_party_sites hps,' ||
		       '	hz_locations hzl' ||
		       ' WHERE  hps.party_id  = :party_id' ||
		       ' AND    hps.party_site_id = :party_site_id' ||
		       ' AND    hzl.location_id = hps.location_id';
	END IF;

	IF p_party_type <> 'STANDALONE' THEN
	   l_CursorID := DBMS_SQL.OPEN_CURSOR;
	   DBMS_SQL.PARSE(l_CursorID, l_Select, DBMS_SQL.V7);
           IF (p_party_type <> 'B')  THEN
	   DBMS_SQL.BIND_VARIABLE(l_CursorID, ':party_id', p_party_id);
           END IF;
	   IF (p_party_type <> 'I')  THEN
	  DBMS_SQL.BIND_VARIABLE(l_CursorID, ':party_site_id', p_party_site_id);
	   END IF;
	   l_result := DBMS_SQL.EXECUTE(l_CursorID);
	   IF DBMS_SQL.FETCH_ROWS(l_CursorID) = 0 THEN
	      DBMS_SQL.CLOSE_CURSOR(l_CursorID);
	      return false;
	   ELSE
	      DBMS_SQL.CLOSE_CURSOR(l_CursorID);
	      return true;
	   END IF;
	ELSE
	      return true;
	END IF;

exception
when others then
	return false;
End validate_party_site_id;

Function validate_email_address
	(
	p_email_addr In Varchar2
	) return boolean
Is
Begin
	if (instr(p_email_addr, '@') = 0)
	then
		return false;
	else
		return true;
	end if;
exception
when others then
	return false;
End Validate_email_address;

Function validate_password_length
	(
	p_password In varchar2
	) return boolean
Is
Begin
	If (length(p_password) < 5) Then
		return false;
	else
		return true;
	end if;
exception
when others then
	return false;
End validate_password_length;

/* New function added for bug #2410173 to verify special characters
   and to trim spaces in the password */
Function validate_password
        (
        x_password In Out NOCOPY varchar2
        ) return boolean
Is

l_passwdlen NUMBER;
counter     NUMBER;
l_ascPasswd NUMBER;
l_char      VARCHAR2(1);

begin

x_password := ltrim(rtrim(x_password));
l_passwdLen := length(x_password);


IF x_password IS NOT NULL THEN
   for counter in 1 .. l_passwdLen
   loop
       l_char := substr(x_password,counter,1);
       select ascii(l_char) into l_ascPasswd from dual;
       if     ((l_ascPasswd >= 0 and l_ascPasswd <= 47) OR
               (l_ascPasswd >= 58 and l_ascPasswd <= 64) OR
               (l_ascPasswd >= 91 and l_ascPasswd <= 96) OR
               (l_ascPasswd >= 123 and l_ascPasswd <= 127)) then
                  return false;
       end if;
   end loop;
END IF;
return true;

Exception
when others then
        return false;

End validate_password;

Function validate_confirmation_code
	(
	p_confirmation In Varchar2
	)  return boolean
Is

l_insmode	VARCHAR2(15);
l_Select	VARCHAR2(500);
l_CursorID	INTEGER;
l_result	INTEGER;
Begin

	-- Identiy the installation mode and based on the build the query.
	-- For Standalone, refer to WF_LOOKUPS otherwise refer to ECX_LOOKUP_VALUES.

	l_insmode := wf_core.translate('WF_INSTALL');

	IF l_insmode = 'EMBEDDED' THEN
	   l_Select := 'SELECT 	1 ' ||
		       ' FROM 	ecx_lookup_values' ||
		       ' WHERE 	lookup_type = ' || '''' || 'CONFIRMATION_CODE' || '''' ||
		       ' AND 	lookup_code = :confirmation ' ||
		       ' AND 	enabled_flag = ' || '''' || 'Y' || '''' ||
		       ' AND 	to_date(sysdate, ' || '''' || 'DD-MON-RRRR' || '''' || ') between' ||
		       '	to_date(nvl(start_date_active, sysdate), ' || '''' || 'DD-MON-RRRR' || '''' || ') ' ||
		       ' AND    to_date(nvl(end_date_active, sysdate), ' || '''' || 'DD-MON-RRRR' || '''' || ')';
	ELSE
	   l_Select := 'SELECT 1 ' ||
		       ' FROM	wf_lookups' ||
		       ' WHERE	lookup_type = ' || '''' || 'CONFIRMATION_CODE' || '''' ||
		       ' AND    lookup_code = :confirmation ';
	END IF;

	l_CursorID := DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE(l_CursorID, l_Select, DBMS_SQL.V7);
	DBMS_SQL.BIND_VARIABLE(l_CursorID, ':confirmation', p_confirmation);
	l_result := DBMS_SQL.EXECUTE(l_CursorID);
	IF DBMS_SQL.FETCH_ROWS(l_CursorID) = 0 THEN
	   DBMS_SQL.CLOSE_CURSOR(l_CursorID);
	   return false;
	ELSE
	   DBMS_SQL.CLOSE_CURSOR(l_CursorID);
	   return true;
	END IF;

exception
when others then
	return false;
End Validate_confirmation_code;

Function validate_protocol_type
	(
	p_protocol_type In Varchar2
	)  return boolean
Is

l_insmode	VARCHAR2(15);
l_Select	VARCHAR2(500);
l_CursorID	INTEGER;
l_result	INTEGER;
Begin

	-- Identiy the installation mode and based on the build the query.
	-- For Standalone, refer to WF_LOOKUPS otherwise refer to ECX_LOOKUP_VALUES.

	l_insmode := wf_core.translate('WF_INSTALL');

	IF l_insmode = 'EMBEDDED' THEN
	   l_Select := 'SELECT 	1 ' ||
		       ' FROM 	ecx_lookup_values' ||
		       ' WHERE 	lookup_type = ' || '''' || 'COMM_METHOD' || '''' ||
		       ' AND 	lookup_code = :protocol_type ' ||
		       ' AND 	enabled_flag = ' || '''' || 'Y' || '''' ||
		       ' AND 	to_date(sysdate, ' || '''' || 'DD-MON-RRRR' || '''' || ') between' ||
		       '	to_date(nvl(start_date_active, sysdate), ' || '''' || 'DD-MON-RRRR' || '''' || ') ' ||
		       ' AND    to_date(nvl(end_date_active, sysdate), ' || '''' || 'DD-MON-RRRR' || '''' || ')';
	ELSE
	   l_Select := 'SELECT 1 ' ||
		       ' FROM	wf_lookups' ||
		       ' WHERE	lookup_type = ' || '''' || 'COMM_METHOD' || '''' ||
		       ' AND    lookup_code = :protocol_type ';
	END IF;

	l_CursorID := DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE(l_CursorID, l_Select, DBMS_SQL.V7);
	DBMS_SQL.BIND_VARIABLE(l_CursorID, ':protocol_type', p_protocol_type);
	l_result := DBMS_SQL.EXECUTE(l_CursorID);
	IF DBMS_SQL.FETCH_ROWS(l_CursorID) = 0 THEN
	   DBMS_SQL.CLOSE_CURSOR(l_CursorID);
	   return false;
	ELSE
	   DBMS_SQL.CLOSE_CURSOR(l_CursorID);
	   return true;
	END IF;

exception
when others then
	return false;
End Validate_protocol_type;

Function validate_queue_name
	(
	p_queue_name In Varchar2
	)  return boolean
is
num	pls_integer;
cursor 	c is
select 	count(*)
from 	wf_agents
where  	queue_name = p_queue_name;

begin
num := 0;

	open c;
	fetch c into num;
	close c;

	if (num = 1) then
		return true;
	else
		return false;
	end if;

exception
when others then
	return false;
end validate_queue_name;


Function validate_trading_partner
        (
        p_tp_header_id 	In 	Varchar2
        )  return boolean
is
   num	pls_integer	:= 0;

   cursor get_tp_hdr_cnt is
   select count(*) from ecx_tp_headers
   where tp_header_id = p_tp_header_id;

begin

   open  get_tp_hdr_cnt;
   fetch get_tp_hdr_cnt into num;
   close get_tp_hdr_cnt;

   if (num >= 1)
   then
      return true;
   else
      return false;
   end if;

exception
when others then
   if get_tp_hdr_cnt%ISOPEN
   then
      close get_tp_hdr_cnt;
   end if;

   return false;
end validate_trading_partner;

Function validate_data_seeded_flag
        (
        p_data_seeded In      Varchar2
        )  return boolean
is
begin
   if (p_data_seeded = 'N') or (p_data_seeded = 'Y')
   then
      return true;
   else
      return false;
   end if;
end validate_data_seeded_flag;


PROCEDURE validate_user(
   p_username           IN  VARCHAR2,
   p_password           IN  VARCHAR2,
   p_party_id           IN  VARCHAR2,
   p_party_site_id      IN  VARCHAR2,
   p_party_type         IN  VARCHAR2,
   x_ret_code           OUT NOCOPY PLS_INTEGER) IS

   l_insmode            VARCHAR2(15);
   l_proc_call          VARCHAR2(32000);
   l_proc_cursor        PLS_INTEGER;
   l_numrows            PLS_INTEGER;
   l_result             VARCHAR2(20);
   l_person_party_id    NUMBER;
   l_party_site_id      VARCHAR2(50);
   l_status             VARCHAR2(20) := 'N';
   l_msg                VARCHAR2(500);


BEGIN
   -- validate_user set x_ret_code = 0 if success; otherwise, x_ret_code = 1.
   -- Identiy the installation mode and based on the installation mode,
   -- call different procedures dynamically.

   x_ret_code := 1;
   l_insmode := wf_core.translate('WF_INSTALL');

   IF l_insmode = 'EMBEDDED' THEN
      -- Call the Java Wrapper API that validates the password
      -- fnd_web_sec.validate_login(p_username,p_password);
      -- if this function returns 'Y' means valid; otherwise not valid.

      l_proc_call := 'BEGIN :l_result:= fnd_web_sec.validate_login (p_user=> :p_username,' ||
                     ' p_pwd => :p_password); END; ';
      l_proc_cursor := dbms_sql.open_cursor;

      begin
         dbms_sql.parse(l_proc_cursor, l_proc_call, dbms_sql.native);
      exception
        when others then
           raise;
      end;

      dbms_sql.bind_variable(l_proc_cursor, ':l_result', l_result, 32000);
      dbms_sql.bind_variable(l_proc_cursor, ':p_username', p_username, 32000);
      dbms_sql.bind_variable(l_proc_cursor, ':p_password', p_password, 32000);

      begin
         l_numrows := dbms_sql.execute(l_proc_cursor);
      exception
         when others then
            raise;
      end;

      if (l_numrows > 0) then
         dbms_sql.variable_value(l_proc_cursor, ':l_result', l_result);
      else
         l_result := 'N';
      end if;

   ELSE
      -- standalone always return valid.
      l_result := 'Y';
   END IF;

   IF UPPER(l_result) = 'Y' THEN
      if (p_party_type = 'E') then
         retrieve_customer_id(p_username        => p_username,
                              p_description     => 'Oracle Exchange User',
                              x_person_party_id => l_person_party_id);

         if (l_person_party_id <> -1) then
            retrieve_site_party_id (p_person_party_id => l_person_party_id,
                                    x_party_id        => l_party_site_id,
                                    x_status          => l_status,
                                    x_msg             => l_msg);

            if (l_status = 'Y' and (l_party_site_id = p_party_site_id)) then
               x_ret_code := 0;
            end if;
         end if;
      else
         x_ret_code := 0;
      end if;
   END IF;

   dbms_sql.close_cursor(l_proc_cursor);

EXCEPTION
   WHEN OTHERS THEN
      x_ret_code := 1;
      dbms_sql.close_cursor(l_proc_cursor);
END validate_user;

procedure retrieve_customer_id(
   p_username        IN  VARCHAR2,
   p_description     IN  VARCHAR2,
   x_person_party_id OUT NOCOPY NUMBER ) is

   l_select          VARCHAR2(400);
   l_cursor          PLS_INTEGER;
   l_numrows         PLS_INTEGER;
   l_username        VARCHAR2(250);

BEGIN
   l_select := 'select customer_id' ||
               ' from fnd_user where user_name = :user_name' ||
               ' AND description = :description';

   l_cursor := dbms_sql.open_cursor;
   begin
      dbms_sql.parse(l_cursor, l_select, dbms_sql.native);
   exception
     when others then
       raise;
   end;
   l_username := upper(p_username);
   dbms_sql.define_column(l_cursor, 1, x_person_party_id);
   dbms_sql.bind_variable(l_cursor, ':user_name', l_username);
   dbms_sql.bind_variable(l_cursor, ':description', p_description);
   begin
      l_numrows := dbms_sql.execute(l_cursor);
      if dbms_sql.fetch_rows(l_cursor) = 0 then
         x_person_party_id := -1;
      else
         dbms_sql.column_value(l_cursor, 1, x_person_party_id);
      end if;
   exception
      when others then
         raise;
   end;

   dbms_sql.close_cursor(l_cursor);

EXCEPTION
   when others then
      x_person_party_id := -1;
      dbms_sql.close_cursor(l_cursor);
END;

procedure retrieve_site_party_id(
   p_person_party_id IN  NUMBER,
   x_party_id        OUT NOCOPY VARCHAR2,
   x_status          OUT NOCOPY VARCHAR2,
   x_msg             OUT NOCOPY VARCHAR2) IS

   l_proc_call          VARCHAR2(32000);
   l_proc_cursor        PLS_INTEGER;
   l_numrows            PLS_INTEGER;

BEGIN
      l_proc_call := 'BEGIN pom_user_hz_wrapper_pkg.retrieve_site_party_id(' ||
                     'p_user_party_id => :p_person_party_id, ' ||
                     'x_site_party_id => :x_party_id, ' ||
                     'x_status => :x_status, x_exception_msg => :x_msg); END; ';
      l_proc_cursor := dbms_sql.open_cursor;

      begin
         dbms_sql.parse(l_proc_cursor, l_proc_call, dbms_sql.native);
      exception
        when others then
           raise;
      end;

      dbms_sql.bind_variable(l_proc_cursor, ':p_person_party_id', p_person_party_id);
      dbms_sql.bind_variable(l_proc_cursor, ':x_party_id', x_party_id, 32000);
      dbms_sql.bind_variable(l_proc_cursor, ':x_status', x_status, 32000);
      dbms_sql.bind_variable(l_proc_cursor, ':x_msg', x_msg, 32000);

      begin
         l_numrows := dbms_sql.execute(l_proc_cursor);
         dbms_sql.variable_value(l_proc_cursor, ':x_party_id', x_party_id);
         dbms_sql.variable_value(l_proc_cursor, ':x_status', x_status);
         dbms_sql.variable_value(l_proc_cursor, ':x_msg', x_msg);
      exception
         when others then
            raise;
      end;

      if (x_status is null) then
         x_status := 'Y';
      end if;

      dbms_sql.close_cursor(l_proc_cursor);

EXCEPTION
   WHEN OTHERS THEN
      x_status := 'N';
      dbms_sql.close_cursor(l_proc_cursor);
END retrieve_site_party_id;

Function getIANACharset return varchar2 is
l_IANAcharset           varchar2(2000);
l_DBcharset             varchar2(2000);
l_xmldecl               varchar2(2000);
l_proc_call             VARCHAR2(32000);
l_proc_cursor           PLS_INTEGER;
l_numrows               PLS_INTEGER;
Begin
        Begin
              select v$nls_parameters.value into l_DBcharset
              from v$nls_parameters
              where v$nls_parameters.parameter='NLS_CHARACTERSET';
         Exception
              When others then
                l_DBcharset := 'UTF8';
         End;

        /* Call the utl_gdk mapping api to do the Oracle-IANA conversion */

         Begin
                l_proc_call := 'BEGIN :l_IANACharset :=  utl_gdk.charset_map(:l_DBcharset);End;';
                l_proc_cursor := dbms_sql.open_cursor;
                dbms_sql.parse(l_proc_cursor, l_proc_call, dbms_sql.native);
                dbms_sql.bind_variable(l_proc_cursor, ':l_IANACharset',
                                       l_IANACharset, 32000);
                dbms_sql.bind_variable(l_proc_cursor, ':l_DBcharset',
                                       l_DBcharset, 32000);
                l_numrows  := dbms_sql.execute(l_proc_cursor);

                if (l_numrows > 0) then
                    dbms_sql.variable_value(l_proc_cursor, ':l_IANACharset',
                                            l_IANACharset);
                else
                    l_IANACharset := 'UTF-8';
                end if;

                if (l_IANACharset is null) then
                    l_IANACharset := 'UTF-8';
                end if;

         Exception
                When Others then
                    l_IANACharset := 'UTF-8';
         End;
	 IF (dbms_sql.is_open(l_proc_cursor)) then
	   dbms_sql.close_cursor(l_proc_cursor);
	 END IF;
return l_IANACharset;
End;


Function getValidationFlag return boolean is

i_string   varchar2(2000);
l_validate varchar2(1) := 'Y';

begin

if (ecx_utils.g_install_mode is null) then
         ecx_utils.g_install_mode := wf_core.translate('WF_INSTALL');
end if;

if ecx_utils.g_install_mode = 'EMBEDDED'
then
      i_string := 'begin
      fnd_profile.get('||'''ECX_XML_VALIDATE_FLAG'''||',
                      :l_validate);
      end;';
      execute immediate i_string USING OUT l_validate;
else
     l_validate := wf_core.translate('ECX_XML_VALIDATE_FLAG');
end if;

/* if profile option is not set assume that the validation should happen */

if (l_validate is null) then
       return true;
end if;

return (l_validate = 'Y') OR (l_validate = 'y');
end;

Function getMaximumXMLSize return Number is

i_string   varchar2(2000);
l_size     Number;
begin

if (ecx_utils.g_install_mode is null) then
         ecx_utils.g_install_mode := wf_core.translate('WF_INSTALL');
end if;

if ecx_utils.g_install_mode = 'EMBEDDED'
then
      i_string := 'begin
      fnd_profile.get('||'''ECX_XML_MAXIMUM_SIZE'''||',
                      :l_size);
      end;';
      execute immediate i_string USING OUT l_size;
else
 l_size := wf_core.translate('ECX_XML_MAXIMUM_SIZE');
end if;

if(l_size is null) then
   l_size := 2000000;
end if;

return l_size ;

Exception
When Others then
   l_size := 2000000;
   return l_size;
end;

procedure parseXML(
   p_parser     IN          xmlparser.parser,
   p_xmlclob    IN          clob,
   x_validate   OUT NOCOPY  boolean,
   x_xmldoc     OUT NOCOPY  xmlDOM.DOMNode) is

   i_method_name varchar2(2000) := 'ecx_util_api.parsexml';
   l_max_size   number;
   l_ndoc       xmlDOM.DOMDOcument;
   l_clobLen    number;

begin

   /* Parse the document when
      1.  the document is less than the maximum size regardless what
          ECX_XML_VALIDATE_FLAG is.
      2.  The document is larger than ECX_XML_MAXIMUM_SIZE and
          ECX_XML_VALIDATE_FLAG is true */

   x_validate := getValidationFlag();

   if not (x_validate) then
      l_max_size := getMaximumXMLSize();
      l_clobLen  := dbms_lob.getLength(p_xmlclob);

      if (l_clobLen is null) then
          l_cloblen := 0;
      end if;

      if (l_max_size is not null) then
          x_validate := l_cloblen < l_max_size;
      end if;
   end if;

   if x_validate then
      /**
      Parse from the Clob
      **/
      xmlparser.parseCLOB(p_parser, p_xmlclob);
      l_ndoc := xmlparser.getDocument(p_parser);

      -- assign ndoc to g_xmldoc for XSLT transformation, if any
      x_xmldoc := xmlDOM.makeNode(l_ndoc);
   end If;

exception
   when others then
        ecx_debug.setErrorInfo(1, 30, SQLERRM);
        if(l_statementEnabled) then
             ecx_debug.log(l_statement,'ECX', SQLERRM,i_method_name);
        end if;
        if NOT xmlDOM.isNull(l_ndoc) then
           xmlDOM.freeDocument(l_ndoc);
        end if;
        raise ecx_utils.program_exit;
end parseXML;


END ECX_UTIL_API;

/
