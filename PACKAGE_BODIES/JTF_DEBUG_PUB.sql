--------------------------------------------------------
--  DDL for Package Body JTF_DEBUG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DEBUG_PUB" as
/* $Header: JTFPDBGB.pls 120.2 2005/10/17 04:22:40 vimohan ship $ */
-- Start of Comments
-- Package name     : JTF_DEBUG_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


  G_PKG_NAME varchar2(100):= 'JTF_DEBUG_PUB';

  G_ICX_SESSION_ID NUMBER := NULL;

----------------------------------------------------------------------------
  FUNCTION FormatNumber(parameter in varchar2, value in number)
                        RETURN VARCHAR2 IS
  l_value varchar2(240);
  BEGIN
    return (rpad(parameter,PAD_LENGTH)||'< '||nvl(to_char(value), 'NULL')||' >');
  END;

----------------------------------------------------------------------------
  FUNCTION FormatDate(parameter in varchar2, value in date) RETURN VARCHAR2 IS
  BEGIN
    return (rpad(parameter,PAD_LENGTH)||'< '||nvl(to_char(value),'NULL')||' >');
  END;

----------------------------------------------------------------------------
  FUNCTION FormatChar(parameter in varchar2, value in varchar2)
                      RETURN VARCHAR2 IS
  BEGIN
    return (rpad(parameter,PAD_LENGTH)||'< '||nvl(value, 'NULL')||' >');
  END;

----------------------------------------------------------------------------
  FUNCTION FormatBoolean(parameter in varchar2, value in boolean)
                         RETURN VARCHAR2 IS
  BEGIN
    return (rpad(parameter,PAD_LENGTH)||'< '||nvl(JTF_DBSTRING_UTILS.getBooleanString(value),'NULL')||' >');
  END;

----------------------------------------------------------------------------
  FUNCTION FormatIndent(parameter in varchar2) RETURN VARCHAR2 IS
  BEGIN
      return ('   '||parameter);
  END;

----------------------------------------------------------------------------
  /** Fuction getVersion returns the header information for this file */
  FUNCTION getVersion RETURN VARCHAR2 IS
  BEGIN
    RETURN('$Header: JTFPDBGB.pls 120.2 2005/10/17 04:22:40 vimohan ship $');
  END;

----------------------------------------------------------------------------
  FUNCTION FormatSeperator RETURN VARCHAR2
  IS
  BEGIN
    RETURN('-----------------------------------------------------------------');
  END;


---------------------------------------------------------------------------
/* this procedure handles all exceptions raised by utl_file
 */

procedure handle_utl_file_exceptions (exception_name in varchar2,
                                      x_return_Status out nocopy varchar2,
                                      x_msg_count out nocopy number,
                                      x_msg_data out nocopy varchar2) is
 CURSOR C_profile IS
     select  user_profile_option_name
     from   fnd_profile_options_vl
     where  profile_option_name = 'UTL_FILE_LOG';

 l_profile_name varchar2(250);
begin
   begin
             OPEN C_profile;
             FETCH C_profile into l_profile_name;
             CLOSE C_profile;
             l_profile_name := nvl(l_profile_name, 'UTL_FILE_LOG');

           exception
            when others then
             l_profile_name :=  'UTL_FILE_LOG';
           end;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		 FND_MESSAGE.Set_Name('JTF', 'JTF_DEBUG_ERROR1');
		 FND_MESSAGE.Set_Token('EXCEPTION_NAME',exception_name, FALSE);
                 FND_MESSAGE.Set_Token('PROFILE_NAME',l_profile_name, FALSE);
                 FND_MSG_PUB.ADD;
 	    END IF;
            JTF_DEBUG_PUB.HANDLE_EXCEPTIONS(
	          P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_MSG_COUNT => 1
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);
end handle_utl_file_exceptions;

----------------------------------------------------------------------------
/** set the global session ID  */
   PROCEDURE  SET_ICX_SESSION_ID(
                   p_sessionID   IN NUMBER) is
   begin
        G_ICX_SESSION_ID := p_sessionID;

   end SET_ICX_SESSION_ID;
----------------------------------------------------------------------------
   /*
   **  Writes the message to the log file for the spec'd level and module
   **  if logging is enabled for this level and module
   */
   PROCEDURE LOG_DEBUG(p_log_level IN NUMBER,
                    p_module    IN VARCHAR2,
                    p_message   IN VARCHAR2,
                    p_icx_session_id IN NUMBER) is
   PRAGMA AUTONOMOUS_TRANSACTION;
   l_icx_session_id NUMBER;
   begin
      /* Setting icx_session_id to -1 if it is NULL */
      /* Moved code *after* checking if logger is ON
      if (p_icx_session_id is NULL) then
         l_icx_session_id := -1;
      else
         l_icx_session_id := p_icx_session_id;
      end if;
      */
      /* Bug #3468334 */
      if FND_LOG.TEST (p_log_level, p_module) then
        if (p_icx_session_id is NULL) then
         l_icx_session_id := -1;
        else
         l_icx_session_id := p_icx_session_id;
        end if;

	if (p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
	  FND_LOG.STRING(p_log_level, p_module, p_message);
	  COMMIT;
	end if;
      end if;
   end LOG_DEBUG;

   /*
   **  Writes the message to the log file for the spec'd level and module
   **  if logging is enabled for this level and module
   **
   **  Overloaded method which invokes the actual method with the value for ICX session ID
   */
   PROCEDURE LOG_DEBUG(p_log_level IN NUMBER,
                    p_module    IN VARCHAR2,
                    p_message   IN VARCHAR2) is
   begin

   -- Invoking the actual method with global parameter
   LOG_DEBUG( p_log_level, p_module, p_message, G_ICX_SESSION_ID );
   end LOG_DEBUG;

   /*
   **  Utility method to write specific kind of logging messages
   */
   PROCEDURE LOG_ENTERING_METHOD( p_module    IN VARCHAR2,
                    p_message   IN VARCHAR2) is
   begin

   -- Invoking the actual method with global parameter
   /* Bug #3468334 */
      if FND_LOG.TEST (FND_LOG.LEVEL_PROCEDURE, p_module) then

	if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
	  LOG_DEBUG( FND_LOG.LEVEL_PROCEDURE, p_module, 'Entered procedure : ' || p_message || ' at ' || SUBSTR(TO_CHAR(9999999999+DBMS_UTILITY.GET_TIME),5) , G_ICX_SESSION_ID );
	end if;
   end if;
   end LOG_ENTERING_METHOD;

   /*
   **  Utility method to write specific kind of logging messages
   */
   PROCEDURE LOG_EXITING_METHOD( p_module    IN VARCHAR2,
                    p_message   IN VARCHAR2) is
   begin

   -- Invoking the actual method with global parameter
      if FND_LOG.TEST (FND_LOG.LEVEL_PROCEDURE, p_module) then

	if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          LOG_DEBUG( FND_LOG.LEVEL_PROCEDURE, p_module, 'Exiting procedure : ' || p_message || ' at ' || SUBSTR(TO_CHAR(9999999999+DBMS_UTILITY.GET_TIME),5) , G_ICX_SESSION_ID );
	end if;

      end if;
   end LOG_EXITING_METHOD;

   /*
   **  Utility method to write specific kind of logging messages
   */
   PROCEDURE LOG_UNEXPECTED_ERROR( p_module    IN VARCHAR2,
                    p_message   IN VARCHAR2) is
   begin

   -- Invoking the actual method with global parameter
   LOG_DEBUG( FND_LOG.LEVEL_UNEXPECTED, p_module,  p_message, G_ICX_SESSION_ID );
   end LOG_UNEXPECTED_ERROR;

   /*
   **  Utility method to write specific kind of logging messages
   */
   PROCEDURE LOG_PARAMETERS( p_module    IN VARCHAR2,
                    p_message   IN VARCHAR2) is
   begin

   -- Invoking the actual method with global parameter
   LOG_DEBUG( FND_LOG.LEVEL_PROCEDURE, p_module,  p_message, G_ICX_SESSION_ID );
   end LOG_PARAMETERS;

   /*
   * A method to find out, if logging is on at the level of
   * logging parameters
   */

   FUNCTION IS_LOG_PARAMETERS_ON( p_module IN VARCHAR2) RETURN BOOLEAN IS

   BEGIN

   IF FND_LOG.TEST (FND_LOG.LEVEL_PROCEDURE, p_module) THEN
   RETURN TRUE;
   ELSE
   RETURN FALSE;
   END IF;
   END IS_LOG_PARAMETERS_ON;

   /*
   **  Utility method to write specific kind of logging messages
   */
   PROCEDURE LOG_EXCEPTION( p_module    IN VARCHAR2,
                    p_message   IN VARCHAR2) is
   begin

   -- Invoking the actual method with global parameter
   LOG_DEBUG( FND_LOG.LEVEL_EXCEPTION, p_module,  p_message, G_ICX_SESSION_ID );
   end LOG_EXCEPTION;

   /*
   **  Utility method to write specific kind of logging messages
   */
   PROCEDURE LOG_EVENT( p_module    IN VARCHAR2,
                    p_message   IN VARCHAR2) is
   begin

   -- Invoking the actual method with global parameter
   LOG_DEBUG( FND_LOG.LEVEL_EVENT, p_module,  p_message, G_ICX_SESSION_ID );
   end LOG_EVENT;

   /*
   **  Utility method to write specific kind of logging messages
   */
   PROCEDURE LOG_STATEMENT( p_module    IN VARCHAR2,
                    p_message   IN VARCHAR2) is
   begin

   -- Invoking the actual method with global parameter
   LOG_DEBUG( FND_LOG.LEVEL_STATEMENT, p_module,  p_message, G_ICX_SESSION_ID );
   end LOG_STATEMENT;
----------------------------------------------------------------------------
/** returns filename if alteast one message has been written to it.
    otherwise returns NULL */

   PROCEDURE  Debug(
                   p_file_name   IN varchar2 := FND_API.G_MISS_CHAR,
                   p_debug_tbl  IN  debug_tbl_type := G_MISS_DEBUG_TBL,
                   p_module            IN  varchar2,
                   x_path              OUT NOCOPY varchar2,
                   x_filename          OUT NOCOPY varchar2,
                   x_msg_count         OUT NOCOPY number,
                   X_MSG_DATA        OUT NOCOPY VARCHAR2,
	           X_RETURN_STATUS   OUT NOCOPY VARCHAR2
                  ) IS

    CURSOR C_log_message(p_session_id NUMBER, p_user_id NUMBER, p_module VARCHAR2, p_timestamp VARCHAR2) IS
      SELECT message_text
      FROM   fnd_log_messages
      WHERE  module like p_module
      AND    session_id = p_session_id
      AND    user_id = p_user_id
      AND    timestamp >= to_date(p_timestamp, 'DD-MM-YYYY HH24:MI:SS')
      ORDER BY log_sequence;

  CURSOR C_current_time IS
     SELECT to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS')
     FROM dual;

     l_session_id NUMBER;
     l_user_id    NUMBER ;
     l_dir        VARCHAR2(2000);
     l_filename   VARCHAR2(240);
     l_filetype   UTL_FILE.file_type;
     l_module     VARCHAR2(200);
     l_buffer     VARCHAR2(4000);
     l_profile_name VARCHAR2(240);
     l_timestamp    VARCHAR2(240);
     l_return     BOOLEAN := FALSE;
  BEGIN

     X_Return_Status   :=  FND_API.G_RET_STS_SUCCESS;

     OPEN  C_current_time;
     FETCH C_current_time into l_timestamp;
     CLOSE C_current_time;


  if((FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then

     FOR i in 1..p_debug_tbl.count LOOP

     fnd_log.String(FND_LOG.LEVEL_EVENT, p_debug_tbl(i).module_name,
                         p_debug_tbl(i).debug_message);
     END LOOP;
  end if;

     fnd_profile.get('UTL_FILE_LOG', l_dir);
     if l_dir is null then
        SELECT substr(value,1,instr(value,',',1,1)-1)
        INTO   l_dir
        FROM  v$parameter
        WHERE name = 'utl_file_dir';
        if l_dir is null then                  -- if there is only 1 directory
           SELECT value
           INTO l_dir
           FROM v$parameter
           WHERE name = 'utl_file_dir';
        end if;

        --fnd_profile.put('UTL_FILE_LOG',l_dir);
        if l_dir is null then
            RAISE UTL_FILE.INVALID_PATH;
        end if;
      end if;

        SELECT  substr('l'|| substr(to_char(sysdate,'MI'),1,1)
                 || lpad(jtf_Debug_s.nextval,6,'0'),1,8) || '.dbg'
          into l_filename
          from dual;

        l_filetype := UTL_FILE.fopen(location => l_dir,
                                    filename => l_filename,
                                    open_mode=> 'a');

        l_user_id := to_number(FND_PROFILE.VALUE( 'USER_ID'));
        l_session_id := icx_sec.getsessioncookie();
        if l_session_id is NULL then
           l_session_id := -1;
        end if;

        FOR i in C_log_message(l_session_id, l_user_id, p_module, l_timestamp) LOOP
          l_return := TRUE; -- need to move this out of the loop
          UTL_FILE.put_line(l_filetype, i.message_text);
        END LOOP;

        UTL_FILE.fflush(l_filetype);
        UTL_FILE.fclose(l_filetype);

        x_path     := l_dir;
        if l_return then
          x_filename := l_filename;
        else
          x_filename := NULL;
        end if;


   EXCEPTION
          WHEN UTL_FILE.INVALID_PATH THEN
           handle_utl_file_exceptions('INVALID PATH', x_return_Status, x_msg_count, x_msg_data);
          WHEN UTL_FILE.INVALID_MODE THEN
           handle_utl_file_exceptions('INVALID MODE', x_return_Status, x_msg_count, x_msg_data);
          WHEN UTL_FILE.INVALID_FILEHANDLE THEN
           handle_utl_file_exceptions('INVALID FILEHANDLE', x_return_Status, x_msg_count, x_msg_data);
          WHEN UTL_FILE.INVALID_OPERATION THEN
            handle_utl_file_exceptions('INVALID OPERATION', x_return_Status, x_msg_count, x_msg_data);
          WHEN UTL_FILE.WRITE_ERROR THEN
            handle_utl_file_exceptions('WRITE ERROR', x_return_Status, x_msg_count, x_msg_data);
          WHEN UTL_FILE.INTERNAL_ERROR THEN
            handle_utl_file_exceptions('INTERNAL ERROR', x_return_Status, x_msg_count, x_msg_data);
          WHEN OTHERS THEN
             JTF_DEBUG_PUB.HANDLE_EXCEPTIONS(
                   P_API_NAME => NULL
                  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => G_EXC_OTHERS
                  ,P_SQLCODE  => SQLCODE
                  ,P_SQLERRM  => SQLERRM
                  ,P_MSG_COUNT => 0
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

  END Debug;

PROCEDURE Handle_Exceptions(
                P_API_NAME        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
                P_PKG_NAME        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
                P_EXCEPTION_LEVEL IN  NUMBER   := FND_API.G_MISS_NUM,
                P_SQLCODE         IN  NUMBER   DEFAULT NULL,
                P_SQLERRM         IN  VARCHAR2 DEFAULT NULL,
                P_MSG_COUNT       IN NUMBER := FND_API.G_MISS_NUM,
                P_LOG_LEVEL       IN  NUMBER   DEFAULT NULL,
                P_LOG_MODULE      IN  VARCHAR2 DEFAULT NULL,
                X_MSG_COUNT       OUT NOCOPY NUMBER,
                X_MSG_DATA        OUT NOCOPY VARCHAR2,
	        X_RETURN_STATUS   OUT NOCOPY VARCHAR2)
IS
l_api_name    VARCHAR2(30);
l_len_sqlerrm Number ;
i number := 1;
k number := 1;
l_msg_data VARCHAR2(2000);
l_msg_count number := 1;

BEGIN
    l_api_name := UPPER(p_api_name);

    if l_api_name <> FND_API.G_MISS_CHAR then
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
    end if;

    IF p_exception_level = FND_MSG_PUB.G_MSG_LVL_ERROR
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF p_msg_count <> FND_API.G_MISS_NUM THEN
            x_msg_count := p_msg_count;
        ELSE
          FND_MSG_PUB.Count_And_Get(
            p_encoded =>  fnd_api.g_false,
            p_count   =>  x_msg_count,
            p_data    =>  x_msg_data);
        END IF;
    ELSIF p_exception_level = FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
    THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF p_msg_count <> FND_API.G_MISS_NUM THEN
            x_msg_count := p_msg_count;
        ELSE
          FND_MSG_PUB.Count_And_Get(
            p_encoded =>  fnd_api.g_false,
            p_count   =>  x_msg_count,
            p_data    =>  x_msg_data);
        END IF;
    ELSIF p_exception_level = G_EXC_OTHERS
    THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       /*   FND_MSG_PUB.Count_And_Get(
            p_count   =>  l_msg_count,
            p_data    =>  x_msg_data);
       */
        FND_MESSAGE.Set_Name('JTF', 'JTF_ERROR_RETURNED');
        FND_MESSAGE.Set_token('PKG_NAME' , p_pkg_name);
        FND_MESSAGE.Set_token('API_NAME' , p_api_name);
        FND_MSG_PUB.ADD;
        l_len_sqlerrm := Length(P_SQLERRM) ;
           While l_len_sqlerrm >= i Loop
             FND_MESSAGE.Set_Name('JTF', 'JTF_SQLERRM');
             FND_MESSAGE.Set_token('ERR_TEXT' , substr(P_SQLERRM,i,240));
             i := i + 240;
             FND_MSG_PUB.ADD;
             l_msg_count := l_msg_count + 1;
          end loop;

        IF p_msg_count <> FND_API.G_MISS_NUM THEN
            x_msg_count := p_msg_count + l_msg_count;
                                        -- messages added by this API
        ELSE
          FND_MSG_PUB.Count_And_Get(
            p_encoded =>  fnd_api.g_false,
            p_count   =>  x_msg_count,
            p_data    =>  x_msg_data);
        END IF;
    END IF;
    -- Logging the error

    IF (P_LOG_LEVEL is not null ) AND (P_LOG_MODULE is not null) THEN
       for k in 1 ..x_msg_count loop
          l_msg_data := fnd_msg_pub.get( p_msg_index => k,
                        p_encoded => 'F'
                        );
          LOG_DEBUG( P_LOG_LEVEL, P_LOG_MODULE, P_PKG_NAME || '.' || P_API_NAME || '-' || k || '-' || substr(l_msg_data,1,200) );
        end loop;
    END IF;

END Handle_Exceptions;

PROCEDURE Get_Messages (
p_message_count IN  NUMBER,
x_message_count OUT NOCOPY NUMBER,
x_msgs          OUT NOCOPY VARCHAR2)
IS
      l_msg_list        VARCHAR2(2500) := '
';  -- this should be more than 4000 so that it does not error out before
    -- the limit is checked.
      l_temp_msg        VARCHAR2(2000);
      l_appl_short_name  VARCHAR2(20) ;
      l_message_name    VARCHAR2(30) ;

      l_id              NUMBER;
      l_message_num     NUMBER;

	 l_msg_count       NUMBER;
	 l_msg_data        VARCHAR2(2000);
     MSG_INDEX NUMBER := 1; -- index of the message that needs to be retrieved.

      Cursor Get_Appl_Id (x_short_name VARCHAR2) IS
        SELECT  application_id
        FROM    fnd_application_vl
        WHERE   application_short_name = x_short_name;

      Cursor Get_Message_Num (x_msg VARCHAR2, x_id NUMBER, x_lang_id NUMBER) IS
        SELECT  msg.message_number
        FROM    fnd_new_messages msg, fnd_languages_vl lng
        WHERE   msg.message_name = x_msg
          and   msg.application_id = x_id
          and   lng.LANGUAGE_CODE = msg.language_code
          and   lng.language_id = x_lang_id;
BEGIN

      MSG_INDEX := FND_MSG_PUB.count_msg - p_message_count + 1;

      FOR l_count in 1..NVL(p_message_count,0) LOOP
      --  l_temp_msg := fnd_msg_pub.get(fnd_msg_pub.g_next, fnd_api.g_true);
        l_temp_msg := fnd_msg_pub.get(MSG_INDEX, fnd_api.g_true);
        fnd_message.parse_encoded(l_temp_msg, l_appl_short_name, l_message_name);

        OPEN Get_Appl_Id (l_appl_short_name);
        FETCH Get_Appl_Id into l_id;
        CLOSE Get_Appl_Id;

        l_message_num := NULL;
        IF l_id is not NULL THEN
          OPEN Get_Message_Num (l_message_name, l_id,
                        to_number(NVL(FND_PROFILE.Value('LANGUAGE'), '0')));
          FETCH Get_Message_Num into l_message_num;
          CLOSE Get_Message_Num;
        END IF;

        l_temp_msg := fnd_msg_pub.get(fnd_msg_pub.g_previous, fnd_api.g_true);

        IF NVL(l_message_num, 0) <> 0 THEN
          l_temp_msg := 'APP-' || to_char(l_message_num) || ': ';
        ELSE
          l_temp_msg := NULL;
        END IF;

          l_msg_list := l_msg_list || l_temp_msg ||
                       fnd_msg_pub.get(MSG_INDEX, fnd_api.g_false);
    /*
        IF l_count = 1 THEN
          l_msg_list := l_msg_list || l_temp_msg ||
                       fnd_msg_pub.get(fnd_msg_pub.g_first, fnd_api.g_false);
        ELSE
          l_msg_list := l_msg_list || l_temp_msg ||
                        fnd_msg_pub.get(fnd_msg_pub.g_next, fnd_api.g_false);
        END IF;
    */

        l_msg_list := l_msg_list || '
';

        x_message_count := l_count;
        MSG_INDEX := MSG_INDEX + 1;

        EXIT WHEN length(l_msg_list) > 2000;
      END LOOP;

      x_msgs := substr(l_msg_list, 0, 2000);

    -- delete all the messages that have been read
    -- can do this when the message is read but i don't want to mess with
    -- the index

       MSG_INDEX := FND_MSG_PUB.count_msg - p_message_count + 1;
       for i in 1..x_message_count loop
         fnd_msg_pub.delete_msg(MSG_INDEX);
         MSG_INDEX := MSG_INDEX + 1;
      end loop;

END Get_Messages;

    /*
    * This function will substitute a token for an invalid paramater
    *
    */

FUNCTION GET_INVALID_PARAM_MSG (p_token_value IN VARCHAR2) RETURN VARCHAR2 IS

   BEGIN

   fnd_message.set_name('JTF','JTF-1013');
   fnd_message.set_token('0', p_token_value);

   return fnd_message.get;

END GET_INVALID_PARAM_MSG;

   /*
    * This function will return the translatable message
    *
    */

    FUNCTION GET_MSG (p_message_name IN VARCHAR2) RETURN VARCHAR2 IS

    BEGIN
    fnd_message.set_name('JTF',p_message_name);
    return fnd_message.get;
    END GET_MSG ;


End JTF_DEBUG_PUB;

/
