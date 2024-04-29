--------------------------------------------------------
--  DDL for Package Body MWA_UTL_SM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MWA_UTL_SM_PKG" AS
/* $Header: MWASMGRB.pls 120.1.12010000.2 2008/12/04 06:39:26 pbonthu ship $ */

Procedure Get_Users
(num_of_users		OUT nocopy INTEGER,
 user_table		OUT nocopy t_user_table,
 status			OUT nocopy VARCHAR2,
 status_msg             OUT nocopy VARCHAR2,
 server_host		IN  VARCHAR2,
 server_port		IN  VARCHAR2,
 proxy_host		IN  VARCHAR2,
 user_name		IN  VARCHAR2,
 password		IN  VARCHAR2
) AS

    request_string varchar2(256);
    users varchar2(2000);
    done boolean;
    curtIndex integer;
    tempString varchar2(2000);

begin
    request_string := 'http://' || server_host || ':' || server_port || '/';
    request_string := request_string || user_name || ',' || password || ',_,';
    request_string := request_string || 'USERS' || fnd_global.local_chr(13);
    users := utl_http.request(request_string, proxy_host);

    curtIndex := instr(users, 'FAIL');
--    dbms_output.put_line('curtIndex of string FAIL is ' || curtIndex);
    if (curtIndex > 0) then
--       dbms_output.put_line('failed');
       status := 'E';
       status_msg := users;
    else
        -- users is a newline-separated string of users
--        dbms_output.put_line('output of Get_Users is ' || users);
        num_of_users := 0;
        done := false;

        while (NOT done) LOOP
 	   -- string comparison uses '='
           if (users = fnd_global.local_chr(10)) then
--               dbms_output.put_line('No more users....done!');
               done := true;
               status := 'S';
           else
	       curtIndex := instr(users, fnd_global.local_chr(10));
--             dbms_output.put_line('curtIndex is ' || curtIndex);
               tempString := substr(users, 0, curtIndex-1);
--             dbms_output.put_line('tempString is ' || tempString);
               users := substr(users, curtIndex+1);
	       num_of_users := num_of_users + 1;
--             dbms_output.put_line('after chopping off users is ' || users);
	       user_table(num_of_users) := tempString;
           end if;
        END LOOP;
    end if;

end Get_Users;

Procedure Send_Message
(status		OUT nocopy VARCHAR2,
 status_msg     OUT nocopy VARCHAR2,
 server_host	IN  VARCHAR2,
 server_port	IN  VARCHAR2,
 proxy_host	IN  VARCHAR2,
 user_name	IN  VARCHAR2,
 password	IN  VARCHAR2,
 recipient	IN  VARCHAR2,
 message	IN  VARCHAR2
 ) AS

    request_string varchar2(4096);
    result varchar2(2000);
    curtIndex integer;
begin
    request_string := 'http://' || server_host || ':' || server_port || '/';
    request_string := request_string || user_name || ',' || password || ',_,';
    request_string := request_string || 'MESSAGE ' || recipient || ' ';
    request_string := request_string || message || fnd_global.local_chr(13);
    result := utl_http.request(request_string, proxy_host);
--    dbms_output.put_line('output of Send_Message is ' || result);
    curtIndex := instr(result, 'FAIL');
--    dbms_output.put_line('curtIndex of string FAIL is ' || curtIndex);

    if (curtIndex > 0) then
--       dbms_output.put_line('failed');
       status := 'E';
       status_msg := result;
    else
       curtIndex := instr(result, 'NOSUCHUSER');
       if (curtIndex > 0) then
--        dbms_output.put_line('no such user');
          status := 'E';
          status_msg := result;
       else
          status := 'S';
       end if;
    end if;
end Send_Message;

--Added for bug 7584728 start
function test(function_name in varchar2, test_maint_avilability in varchar2) return NUMBER IS
begin

if(fnd_function.test(function_name,test_maint_avilability)) then
return 1;
else
return 0;
end if;

end test;
--Added for bug 7584728 end


END MWA_UTL_SM_PKG;

/
