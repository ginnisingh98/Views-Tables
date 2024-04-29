--------------------------------------------------------
--  DDL for Package Body BIS_FND_LOG_ADAPTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_FND_LOG_ADAPTER" AS
/* $Header: BISMGPKB.pls 120.0 2005/06/01 16:09:39 appldev noship $ */

 TYPE T_PROGRESS_REC_TYPE IS RECORD(
   object_key          FND_LOG_MESSAGES.MODULE%TYPE,
   progress_name       FND_LOG_MESSAGES.MODULE%TYPE,
   progress_start      NUMBER,
   progress_end        NUMBER,
   progress_start_time Date,
   progress_end_time   Date
 );

 TYPE G_PROGRESS_TAB_TYPE is table of T_PROGRESS_REC_TYPE index by binary_integer;
 G_PROGRESS_TABLE  G_PROGRESS_TAB_TYPE ;
 G_PROG_TABLE_SIZE binary_integer := 0;
 G_LOG_LEVEL        NUMBER := 1000;

 STRING_UNEXPECTED CONSTANT VARCHAR2(30)  := 'UNEXPECTED';
 STRING_ERROR      CONSTANT VARCHAR2(30)  := 'ERROR';
 STRING_EXCEPTION  CONSTANT VARCHAR2(30)  := 'EXCEPTION';
 STRING_EVENT      CONSTANT VARCHAR2(30)  := 'EVENT';
 STRING_PROCEDURE  CONSTANT VARCHAR2(30)  := 'PROCEDURE';
 STRING_STATEMENT  CONSTANT VARCHAR2(30)  := 'STATEMENT';
 STRING_UNKNOWN    CONSTANT VARCHAR2(30)  := 'UNKNOWN';

 MAX_STRING_SIZE   CONSTANT NUMBER       := 4000;

 g_module_prefix varchar2(3):='bis';

 FUNCTION GET_FND_DEBUG_LEVEL
 RETURN NUMBER
 IS
 BEGIN
   IF (G_LOG_LEVEL = 1000 ) THEN
     G_LOG_LEVEL := FND_PROFILE.VALUE('AFLOG_LEVEL');
   END IF;
   RETURN G_LOG_LEVEL;
 END;

 FUNCTION IS_ENABLED(p_servirity number ) RETURN BOOLEAN
 IS
   enable boolean;
   module varchar2(2000):= NULL;
 BEGIN
   --module := UPPER(SUBSTR(FND_PROFILE.VALUE('AFLOG_MODULE'), 1, 2000));
   enable := --(module is NULL OR module ='%') OR
             FND_LOG.TEST(p_servirity, g_module_prefix||'.' ) OR
             FND_LOG.TEST(p_servirity, g_module_prefix )  OR
             FND_LOG.TEST(p_servirity, '%' );
   RETURN enable;
 END;



 FUNCTION GET_LEVEL_STRING( p_level number )
 RETURN VARCHAR2
 IS
 BEGIN
   IF( p_level = FND_LOG.LEVEL_UNEXPECTED) then
     return STRING_UNEXPECTED;
   ELSIF ( p_level = FND_LOG.LEVEL_ERROR) then
     return STRING_ERROR;
   ELSIF ( p_level = FND_LOG.LEVEL_EXCEPTION) then
     return STRING_EXCEPTION;
   ELSIF ( p_level = FND_LOG.LEVEL_EVENT) then
     return STRING_EVENT;
   ELSIF ( p_level = FND_LOG.LEVEL_PROCEDURE) then
     return STRING_PROCEDURE;
   ELSIF ( p_level = FND_LOG.LEVEL_STATEMENT) then
     return STRING_STATEMENT;
   ELSE
     return STRING_UNKNOWN;
   end if;
 END;



 FUNCTION GET_SESSIONID_FROM_KEY(p_logkey varchar2)
 RETURN VARCHAR2
 IS
 BEGIN
  return substr(p_logkey,
              instr( p_logkey, '-', instr(p_logkey, '__')) + 1  ,
              instr(p_logkey, '__', 1, 2 ) -
              instr( p_logkey, '-', instr(p_logkey, '__')) - 1 );
 END;

 FUNCTION get_mili(
	p_time		number) return VARCHAR2 IS
    l_mil  number;
 BEGIN
   l_mil := mod(p_time, 100);
   if (l_mil < 10) then
      return '0' || l_mil;
   else
      return l_mil;
   end if;
 END get_mili;



 FUNCTION duration(
	p_duration		number) return VARCHAR2 IS
    l_hrs number;
    l_mins number;
    l_ses number;
    l_mil number;
    l_dur   number := p_duration;
    l_dur_chr   VARCHAR2(2);
 BEGIN

   l_hrs  := floor(l_dur/360000);
   l_dur := l_dur -l_hrs*360000;
   l_mins := floor(l_dur/6000);
   l_dur := l_dur - l_mins * 6000;
   l_ses  := floor(l_dur/100);
   l_dur := l_dur - l_mins * 100;
   l_mil := l_dur;
   if (l_mil < 10) then
     l_dur_chr :=  '0' || l_mil;
   else
     l_dur_chr :=  l_mil;
   end if;
   return( l_hrs  ||':'||
           l_mins ||':'||
           l_ses  ||'.'||
           l_dur_chr);
 END duration;

 PROCEDURE  WRITE_CHUNK(p_level number, p_msg_txt varchar2, p_module varchar2,
                        p_session_id number, p_user_id number)
 IS
   l_chunk   number := 0;
 BEGIN
   WHILE( l_chunk*MAX_STRING_SIZE < length(p_msg_txt) )
   LOOP
     FND_LOG_REPOSITORY.STR_UNCHKED_INT_WITH_CONTEXT(
                                LOG_LEVEL=> p_level,
                                MODULE=> p_module,
                                MESSAGE_TEXT=> substr(p_msg_txt, l_chunk*MAX_STRING_SIZE + 1, MAX_STRING_SIZE),
                                SESSION_ID=> p_session_id,
                                USER_ID=> p_user_id);
     l_chunk := l_chunk + 1;
   END LOOP;
 END;

 PROCEDURE  WRITE(p_level number, p_msg_txt varchar2, p_module varchar2 default null)
 IS
   l_user_id varchar2(2000);
   l_session_id varchar2(2000);
 BEGIN

   l_user_id := fnd_profile.value('USER_ID');
   if (l_user_id is null) then
     l_user_id := -1;
   end if ;

   l_session_id := GET_SESSIONID_FROM_KEY(p_module);
   if (l_session_id is null) then
     l_session_id := -1;
   end if;

   -- MAX_STRING_SIZE
   IF (IS_ENABLED(p_level)) THEN
     WRITE_CHUNK(p_level, p_msg_txt, p_module, l_session_id, l_user_id);
   END IF;
 END;

 PROCEDURE DEBUG(msg varchar2)
 IS
 BEGIN
 if FND_LOG.LEVEL_UNEXPECTED>= FND_LOG.G_CURRENT_RUNTIME_LEVEL then
   FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, 'bis.plsql.BIS_FND_LOG_ADAPTER.DEBUG', msg);
 end if;
 EXCEPTION
    WHEN OTHERS THEN NULL;
 END;

 PROCEDURE  NEW_PROGRESS(p_logkey varchar2, p_progress varchar2)
 IS
   l_errbuf varchar2(4000);
 BEGIN

   if (p_progress is null OR p_logkey is null) then
     return;
   end if;

   -- Ensure p_progress uniqueness.
   FOR i in 1 ..G_PROG_TABLE_SIZE
   LOOP
     IF(G_PROGRESS_TABLE(i).progress_name = p_progress AND
        G_PROGRESS_TABLE(i).object_key = p_logkey) THEN
       return;
     END IF;
   END LOOP;
   G_PROG_TABLE_SIZE:= G_PROG_TABLE_SIZE + 1;
   G_PROGRESS_TABLE(G_PROG_TABLE_SIZE).object_key := p_logkey;
   G_PROGRESS_TABLE(G_PROG_TABLE_SIZE).progress_name := p_progress;
   G_PROGRESS_TABLE(G_PROG_TABLE_SIZE).progress_start := dbms_utility.get_time;
   G_PROGRESS_TABLE(G_PROG_TABLE_SIZE).progress_start_time := sysdate;

 EXCEPTION
    WHEN OTHERS THEN
      l_errbuf :=sqlerrm;
      DEBUG(l_errbuf);
 END;


-- PROCEDURE  LOG(p_logkey varchar2, p_progress varchar2, p_message varchar2, p_servirity number )
 PROCEDURE  LOG(p_logkey varchar2, p_progress varchar2, p_message varchar2 )
 IS
   l_module VARCHAR2(2000) := NULL;
   l_match  boolean := false;
   l_errbuf varchar2(4000);
   p_servirity number;
 BEGIN
   p_servirity := GET_FND_DEBUG_LEVEL;
   IF (p_servirity <> 5 OR p_servirity <> 3 ) THEN
     RETURN;
   ELSIF ( NOT IS_ENABLED(p_servirity)) THEN
     RETURN;
   END IF;

   if (p_progress is null OR p_logkey is null) then
     return;
   end if;

   FOR i in 1 ..G_PROG_TABLE_SIZE
   LOOP
     IF(G_PROGRESS_TABLE(i).progress_name = p_progress AND
       G_PROGRESS_TABLE(i).object_key = p_logkey AND
       G_PROGRESS_TABLE(i).progress_end is not null) THEN
       return;
     END IF;

     IF(G_PROGRESS_TABLE(i).progress_name = p_progress AND
       G_PROGRESS_TABLE(i).object_key = p_logkey ) THEN
       l_match := true;
     END IF;
   END LOOP;

   IF (l_match) THEN
     l_module := g_module_prefix||'.'|| p_logkey || '.PLSQL:' || p_progress || '.' || GET_LEVEL_STRING( p_servirity);
     WRITE(p_servirity , p_message, l_module);
   END IF;

 EXCEPTION
    WHEN OTHERS THEN
      l_errbuf :=sqlerrm;
      DEBUG(l_errbuf);
 END;

 PROCEDURE  ClOSE_PROGRESS(p_logkey varchar2, p_progress varchar2)
 IS
   l_module VARCHAR2(2000) := NULL;
   l_index NUMBER := 0;
   l_message varchar2(2000):= NULL;
   l_errbuf varchar2(4000);
 BEGIN
   if (p_progress is null OR p_logkey is null) then
     return;
   end if;

   l_module := g_module_prefix||'.'|| p_logkey || '.PLSQL:' || p_progress || '.TIME';

   -- Ensure p_progress uniqueness.
   FOR l_index in 1 ..G_PROG_TABLE_SIZE
   LOOP
     IF(G_PROGRESS_TABLE(l_index).progress_name = p_progress AND
        G_PROGRESS_TABLE(l_index).object_key = p_logkey AND
       G_PROGRESS_TABLE(l_index).progress_end is null) THEN
       G_PROGRESS_TABLE(l_index).progress_end := dbms_utility.get_time;
       G_PROGRESS_TABLE(l_index).progress_end_time := sysdate;
       l_message := to_char(G_PROGRESS_TABLE(l_index).progress_start_time, 'yyyy-mm-dd hh24:mi:ss') || '.' ||
                get_mili(G_PROGRESS_TABLE(l_index).progress_start) ||'#'||
                to_char(G_PROGRESS_TABLE(l_index).progress_end_time, 'yyyy-mm-dd hh24:mi:ss') ||  '.' ||
                get_mili(G_PROGRESS_TABLE(l_index).progress_end)||'#' ||
                duration(G_PROGRESS_TABLE(l_index).progress_end - G_PROGRESS_TABLE(l_index).progress_start);
       WRITE(FND_LOG.LEVEL_UNEXPECTED , l_message, l_module);
       EXIT;
     END IF;
   END LOOP;

 EXCEPTION
    WHEN OTHERS THEN
      l_errbuf :=sqlerrm;
      DEBUG(l_errbuf);
 END;


END BIS_FND_LOG_ADAPTER;

/
