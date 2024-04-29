--------------------------------------------------------
--  DDL for Package Body GMS_ERROR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_ERROR_PKG" as
/* $Header: gmserhnb.pls 120.3 2006/03/17 05:09:54 appldev ship $ */

G_EXEC_TYPE     VARCHAR2(1) := NULL;

--=================================================================================
-- This procedure is used set a message into the message stack. The message
-- returns x_err_code and x_err_buff which could be used by the caller of
-- this procedure for further error handling.
--================================================================================

PROCEDURE gms_message ( 	x_err_name IN VARCHAR2,
				x_token_name1 IN VARCHAR2 default NULL,
				x_token_val1 IN VARCHAR2 default NULL,
				x_token_name2 IN VARCHAR2 default NULL,
				x_token_val2 IN VARCHAR2 default NULL,
				x_token_name3 IN VARCHAR2 default NULL,
				x_token_val3 IN VARCHAR2 default NULL,
				x_token_name4 IN VARCHAR2 default NULL,
				x_token_val4 IN VARCHAR2 default NULL,
				x_token_name5 IN VARCHAR2 default NULL,
				x_token_val5 IN VARCHAR2 default NULL,
				x_exec_type IN VARCHAR2 default NULL,
				x_err_code IN OUT NOCOPY NUMBER,
				x_err_buff IN OUT NOCOPY VARCHAR2)
IS

x_err_buff_1	varchar2(2000);
l_log_level 	NUMBER  DEFAULT FND_LOG.LEVEL_PROCEDURE; --For bug 3269365
BEGIN
	x_err_code := 0; -- Initialize the value to 0 (Success)

	if x_err_name = 'GMS_UNEXPECTED_ERROR'
	then
		fnd_message.set_name('GMS', 'GMS_UNEXPECTED_ERROR');
		fnd_message.set_token(x_token_name1, x_token_val1);
		fnd_message.set_token(x_token_name2, x_token_val2);

		-- x_token_name5 is used for the Program Name.

		if x_token_name5 IS NOT NULL THEN
			fnd_message.set_token(x_token_name5, x_token_val5);
		end if;

		x_err_code := 1; -- Unexpected Error
		l_log_level := FND_LOG.LEVEL_EXCEPTION;	--For bug 3269365
	else
		fnd_message.set_name('GMS', x_err_name);
		IF x_token_name1 IS NOT NULL THEN
			fnd_message.set_token(x_token_name1, x_token_val1);
		END IF;
		IF x_token_name2 IS NOT NULL THEN
			fnd_message.set_token(x_token_name2, x_token_val2);
		END IF;
		IF x_token_name3 IS NOT NULL THEN
			fnd_message.set_token(x_token_name3, x_token_val3);
		END IF;
		IF x_token_name4 IS NOT NULL THEN
			fnd_message.set_token(x_token_name4, x_token_val4);
		END IF;
		IF x_token_name5 IS NOT NULL THEN
			fnd_message.set_token(x_token_name5, x_token_val5);
		END IF;

		x_err_code := 2; -- Expected Error

	end if;
--For bug 3269365: Common logging
IF l_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
	FND_LOG.MESSAGE(l_log_level,'gms.plsql.gms',FALSE);
END IF;
--End of bug 3269365

	if G_EXEC_TYPE = 'C'
	then
		x_err_buff_1 := fnd_message.get;	-- Added for Bug: 1780253
		fnd_file.put_line(FND_FILE.LOG, x_err_buff_1); -- Added for Bug: 1780253
            If x_err_buff IS NOT NULL THEN -- Bug 2587078 : To prevent blank line getting printed in the log file.
         	   fnd_file.put_line(FND_FILE.LOG, x_err_buff);
            End If;
		x_err_buff := x_err_buff_1; -- Added for Bug: 1780253
	end if;
end gms_message;

--======================================================================================
-- This procedure can be used from PL/SQL programs to show debug messages in the
-- conurrent process log. If the PL/SQL program is not called from a concurrent
-- process then the message will be added to the global message table.
--======================================================================================

PROCEDURE gms_debug (x_debug_msg IN VARCHAR2
		    ,x_exec_type IN VARCHAR2)
IS

l_time_stamp	varchar2(30) := 'Time: '||to_char(SYSDATE, 'DD-MON-YYYY HH:MI:SS');
--Bug Fix 2178027 Changed the width of variable l_debug_msg from 255 to 4030
--Bug Fix 2178027 . 05-FEB-02 Changed the width of variable l_debug_msg to 255
l_debug_msg 	varchar2(255) := SUBSTR((l_time_stamp||'::'||x_debug_msg),1,255);

BEGIN

	if (fnd_profile.value('GMS_ENABLE_DEBUG_MODE') = 'Y')
	then
		if G_EXEC_TYPE = 'C'
		then
			fnd_file.put_line(FND_FILE.LOG, l_debug_msg);

                -- Bug 2587078 : If the procedure is not called from a concurrent request (G_EXEC_TYPE <> 'C')
                --               then a blank message is getting added to the message stack as the control
                --               goes to else part.Modified the code such that the debug message will be
                --               added to message stack only if the Parameter X_EXEC_TYPE <> 'C'.
                --
		elsif X_EXEC_TYPE <> 'C' then -- Bug 2587078
			fnd_msg_pub.add;
		end if;
	end if;

---FOR bug 3269365-Introduced the check for Common logging for ATG projects. When the AFLOG_LEVEL is set to
--any level greater than PROCEDURE and GMS DEBUG profile is ON then the following code
-- shall log messages into fnd_log_messages

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'gms.plsql.gms',l_debug_msg);
END IF;
--End of bug 3269365

END gms_debug;
--=====================================================================================

PROCEDURE gms_print
IS
BEGIN
	fnd_msg_pub.dump_list;
END gms_print;

-- Added for Bug 1744641: To Generate errors when an exception occurs
-- during the process of generation of invoice/Revenue.

FUNCTION gms_lookup_values(p_lookup_type IN VARCHAR2,
                           p_lookup_code IN VARCHAR2)
RETURN VARCHAR2
IS
l_meaning varchar2(80);

BEGIN
    select meaning
    into   l_meaning
    from   gms_lookups
    where  lookup_type =p_lookup_type
    and    lookup_code =p_lookup_code;

RETURN l_meaning;
EXCEPTION
    WHEN OTHERS THEN
    RETURN null;
END gms_lookup_values;

--=========================================================================

PROCEDURE Gms_Exception_Head_Proc(x_calling_Process IN VARCHAR2)

IS
l_prompt_name varchar2(240);
l_prompt_award_name varchar2(240);
l_prompt_award_number varchar2(240);

Begin


fnd_file.put_line(FND_FILE.OUTPUT,'         ');
fnd_file.put_line(FND_FILE.OUTPUT,'         ');
 l_prompt_name := gms_lookup_values('DYNAMIC_PROMPTS','DATE');

fnd_file.put_line(FND_FILE.OUTPUT,'
                                                                                                    ' || l_prompt_name||'            '||TO_CHAR(sysdate,'DD-Mon-YYYY HH:MI'));

IF x_calling_process = 'Invoice' THEN
 l_prompt_name := gms_lookup_values('DYNAMIC_PROMPTS','INVOICE_GENERATION');
fnd_file.put_line(FND_FILE.OUTPUT,'
                                               ' ||l_prompt_name);
ELSE
 l_prompt_name := gms_lookup_values('DYNAMIC_PROMPTS','REVENUE_GENERATION');
 fnd_file.put_line(FND_FILE.OUTPUT,'                                                '||l_prompt_name);


END IF ;

 l_prompt_name := gms_lookup_values('DYNAMIC_PROMPTS','EXCEPTION_REPORT');
fnd_file.put_line(FND_FILE.OUTPUT,'                                                      '||l_prompt_name);
fnd_file.put_line(FND_FILE.OUTPUT,' ');
fnd_file.put_line(FND_FILE.OUTPUT,' ');
fnd_file.put_line(FND_FILE.OUTPUT,' ');
fnd_file.put_line(FND_FILE.OUTPUT,'------------------------------------------------------------------------------------------------------------------------------------');


 l_prompt_award_number := gms_lookup_values('DYNAMIC_PROMPTS','AWARD_NUMBER');
 l_prompt_award_name   := gms_lookup_values('DYNAMIC_PROMPTS','AWARD_NAME');
 l_prompt_name := gms_lookup_values('DYNAMIC_PROMPTS','REJECTION_REASON');
fnd_file.put_line(FND_FILE.OUTPUT,l_prompt_award_number||'         '||l_prompt_award_name||'    		 '        ||l_prompt_name);
fnd_file.put_line(FND_FILE.OUTPUT,'------------------------------------------------------------------------------------------------------------------------------------');


END Gms_Exception_Head_Proc ;
--======================================================================================

PROCEDURE Gms_Exception_Lines_Proc(
			        x_exception_msg IN VARCHAR2,
			        x_token_1 IN VARCHAR2,
			        x_calling_place IN VARCHAR2,
                                x_project_id IN NUMBER DEFAULT NULL ,
                                x_award_number IN VARCHAR2 DEFAULT NULL ,
                                x_award_name   IN VARCHAR2 DEFAULT NULL,
                                x_sql_code IN VARCHAR2 DEFAULT NULL,
                                x_sql_message IN VARCHAR2 DEFAULT NULL)

IS
x_err_buff_1  VARCHAR2(2000) ;
Begin
fnd_message.set_name('GMS', x_exception_msg);

IF x_exception_msg = 'GMS_UNEXPECTED_ERROR' THEN
	fnd_message.set_token('SQLCODE',x_sql_code) ;
	fnd_message.set_token('SQLERRM',x_sql_message) ;
	fnd_message.set_token('PROGRAM_NAME',x_calling_place) ;
END IF;


if x_token_1 = 'PROJECT_ID' THEN
fnd_message.set_token('project_id',x_project_id) ;
ELSIF x_token_1 = 'PRJ' THEN
fnd_message.set_token('PRJ',x_project_id) ;
END IF;

x_err_buff_1 := fnd_message.get;
if x_award_number IS NULL Then
fnd_file.put_line(FND_FILE.OUTPUT,'                                                 '||x_err_buff_1);
else
fnd_file.put_line(FND_FILE.OUTPUT,x_award_number||'        '||x_award_name ||'               '||x_err_buff_1);
end if;
gms_debug('X_calling_place'||x_calling_place,'C');

END Gms_exception_lines_proc;
-- End of the code added for bug 1744641

--=========================================================================
-- This procedure is used to set the Debug Context so that debug messages
-- can be written into the Concurrent Log file.
--
-- NOTE: It is sufficient to call this procedure ONCE in a PL/SQL program
-- and the context will be set for all the other PL/SQL program being
-- called from the enclosing PL/SQL program.
--=========================================================================
-- Added for Bug: 2510024

PROCEDURE set_debug_context
IS

 BEGIN

      If NVL(fnd_global.conc_request_id,-1) > 0 THEN

           G_EXEC_TYPE := 'C';

      End If;

   END set_debug_context;

--=========================================================================
-- This procedure can be used to write a line of text to the Concurrent
-- process output.
--=========================================================================

PROCEDURE gms_output( x_output IN VARCHAR2)
IS

Begin

     If G_EXEC_TYPE = 'C' THEN

        FND_FILE.put_line(FND_FILE.OUTPUT, x_output);

     END IF;
End gms_output;

--=========================================================================
Begin /* Bug 5061139*/
gms_error_pkg.set_debug_context;
END GMS_ERROR_PKG;

/
