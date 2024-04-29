--------------------------------------------------------
--  DDL for Package Body OKC_AQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_AQ_PVT" AS
/* $Header: OKCRAQB.pls 120.0 2005/05/25 18:34:40 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- TYPES
  ---------------------------------------------------------------------------
  -- CONSTANTS
  g_pkg_name constant varchar2(100) := 'OKC_AQ_PVT';
  ---------------------------------------------------------------------------
  -- PUBLIC VARIABLES
  ---------------------------------------------------------------------------
  -- EXCEPTIONS
  ---------------------------------------------------------------------------

--


-----------------------------------
-- Private procedures and functions
-----------------------------------

FUNCTION get_acn_type (p_corrid  IN  VARCHAR2)
RETURN VARCHAR2
IS
CURSOR acn_cur
IS
SELECT acn_type
FROM okc_actions_b
WHERE correlation = p_corrid;
acn_rec  acn_cur%ROWTYPE;
v_acn_type  okc_actions_b.acn_type%TYPE;

   --
   l_proc varchar2(72) := '  OKC_AQ_PVT.'||'get_acn_type';
   --

BEGIN
  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  OPEN acn_cur;
  FETCH acn_cur INTO acn_rec;
  IF acn_cur%NOTFOUND THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('1000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    RETURN('Not Available');
  ELSE
    v_acn_type := acn_rec.acn_type;

    IF (l_debug = 'Y') THEN
       okc_debug.Log('2000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN(v_acn_type);
  END IF;


EXCEPTION
  WHEN others THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('3000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    RETURN('Not Available');
END get_acn_type;


PROCEDURE enqueue_message (
  p_clob_msg   IN system.okc_aq_msg_typ
, p_corrid_rec IN corrid_rec_typ
, p_queue_name IN VARCHAR2
, p_delay      IN NUMBER
, x_msg_handle OUT NOCOPY RAW)
IS
  v_nq_options      dbms_aq.enqueue_options_t;
  v_msg_prop        dbms_aq.message_properties_t;
  v_msg_handle      raw(16);
  v_recipient_list  DBMS_AQ.aq$_recipient_list_t;
   --
   l_proc varchar2(72) := '  OKC_AQ_PVT.'||'enqueue_message';
   --

BEGIN
  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;


  v_msg_prop.recipient_list := v_recipient_list;
  v_msg_prop.expiration     := okc_aq_pvt.g_msg_expire;
  v_msg_prop.correlation    := p_corrid_rec.corrid;
  v_msg_prop.delay          := p_delay;
  v_nq_options.visibility   := dbms_aq.ON_COMMIT;
  DBMS_AQ.enqueue ( queue_name         => p_queue_name
		  , enqueue_options    => v_nq_options
		  , message_properties => v_msg_prop
		  , payload            => p_clob_msg
		  , msgid              => v_msg_handle );
  x_msg_handle := v_msg_handle;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

END enqueue_message;



PROCEDURE build_char_clob ( p_msg       IN VARCHAR2,
			    x_char_clob OUT NOCOPY system.okc_aq_msg_typ )
IS
  l_char_clob    system.okc_aq_msg_typ;
   --
   l_proc varchar2(72) := '  OKC_AQ_PVT.'||'build_char_clob';
   --

BEGIN
  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;


  l_char_clob := system.okc_aq_msg_typ(empty_clob());
  DBMS_LOB.createtemporary  ( l_char_clob.body
			    , TRUE
			    , DBMS_LOB.session );
  DBMS_LOB.write ( l_char_clob.body
		 , length(p_msg)
		 , 1
		 , p_msg );
  x_char_clob := l_char_clob;
  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


EXCEPTION
  WHEN others THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('2000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
  null;
END build_char_clob;

PROCEDURE clob_to_char ( p_clob_msg IN  system.okc_aq_msg_typ
		       , x_char_msg OUT NOCOPY varchar2)
IS
  l_amount  INTEGER;
  l_clob_msg  system.okc_aq_msg_typ;
   --
   l_proc varchar2(72) := '  OKC_AQ_PVT.'||'clob_to_char';
   --

BEGIN
  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;


  l_clob_msg := system.okc_aq_msg_typ (empty_clob());
  dbms_lob.createtemporary(l_clob_msg.body,TRUE,dbms_lob.session);
  l_clob_msg := p_clob_msg;
  l_amount := DBMS_LOB.getlength ( l_clob_msg.body );
  -- read clob message into char variable
  DBMS_LOB.read ( l_clob_msg.body
		, l_amount
		, 1
		, x_char_msg);
  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

END clob_to_char;

PROCEDURE code_dots (
  p_name IN   VARCHAR2 ,
  x_name OUT NOCOPY  VARCHAR2  )
IS
   --
   l_proc varchar2(72) := '  OKC_AQ_PVT.'||'code_dots';
   --

BEGIN
  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
     okc_debug.Log('20: p_name : '||p_name,2);
  END IF;

  x_name := translate (p_name, '.', '#');

  IF (l_debug = 'Y') THEN
     okc_debug.Log('50: x_name : '||x_name,2);
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

END code_dots;

PROCEDURE decode_dots (
  p_name IN  VARCHAR2
, x_name OUT NOCOPY VARCHAR2  )
IS
   --
   l_proc varchar2(72) := '  OKC_AQ_PVT.'||'decode_dots';
   --

BEGIN
  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
     okc_debug.Log('20: p_name : '||p_name,2);
  END IF;

  x_name := translate (p_name, '#', '.');

  IF (l_debug = 'Y') THEN
     okc_debug.Log('50: x_name : '||x_name,2);
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


END decode_dots;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

PROCEDURE send_message
    (p_api_version   IN  NUMBER,
     p_init_msg_list IN  VARCHAR2 ,
     p_commit        IN  VARCHAR2 ,
     x_msg_count     OUT NOCOPY NUMBER,
     x_msg_data      OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     p_corrid_rec    IN  corrid_rec_typ,
     p_msg_tab       IN  msg_tab_typ,
     p_queue_name    IN  VARCHAR2,
     p_delay         IN  INTEGER
     )
IS
  l_api_name	  CONSTANT VARCHAR2(30)	:= 'SEND_MESSAGE';
  l_api_version	  CONSTANT NUMBER 	:= 1.0;
  l_return_status VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
  l_xml_clob      system.okc_aq_msg_typ;
  x_msg_handle    RAW(16);
  OKC_ENQUEUE_FAILED   EXCEPTION;
  PRAGMA EXCEPTION_INIT (OKC_ENQUEUE_FAILED, -99095 );
   --
   l_proc varchar2(72) := '  OKC_AQ_PVT.'||'send_message';
   --

BEGIN
  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  -- Call start_activity to create savepoint, check compatibility
  -- and initialize message list
 l_return_status := OKC_API.START_ACTIVITY ( l_api_name
    	                                     , g_pkg_name
		                             , p_init_msg_list
				             , l_api_version
					     , p_api_version
				             , '_PVT'
					     , x_return_status
					    );

  IF (l_debug = 'Y') THEN
     okc_debug.Log('20: l_return_status : '||l_return_status,2);
  END IF;

  -- Check if activity started successfully
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  IF p_corrid_rec.corrid IS NOT NULL AND
     p_msg_tab.count > 0 THEN

    -- build XML clob
  IF (l_debug = 'Y') THEN
     okc_debug.Log('50: Calling okc_xml_pvt.build_xml_clob ',2);
  END IF;

    okc_xml_pvt.build_xml_clob (
        p_corrid_rec
      , p_msg_tab
      , l_xml_clob );

  IF (l_debug = 'Y') THEN
     okc_debug.Log('55: After Call To okc_xml_pvt.build_xml_clob ',2);
  END IF;

  END IF;

    -- enqueue message
  IF (l_debug = 'Y') THEN
     okc_debug.Log('60: Calling enqueue_message ',2);
  END IF;

    enqueue_message  ( l_xml_clob
		     , p_corrid_rec
		     , p_queue_name
		     , p_delay
		     , x_msg_handle);

  IF (l_debug = 'Y') THEN
     okc_debug.Log('70: After Call To enqueue_message ',2);
  END IF;

    IF x_msg_handle IS NULL THEN
      IF (l_debug = 'Y') THEN
         okc_debug.Log('100:  Raising OKC_ENQUEUE_FAILED ',2);
         okc_debug.Log('100:  Leaving ',2);
         okc_debug.Reset_Indentation;
      END IF;
      RAISE OKC_ENQUEUE_FAILED;
    END IF;
  -- end activity
  OKC_API.END_ACTIVITY ( x_msg_count
		       , x_msg_data );
  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


EXCEPTION
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS (
                         l_api_name
                       , g_pkg_name
                       , 'OKC_API.G_EXCEPTION_UNEXPECTED_ERROR'
                       , x_msg_count
                       , x_msg_data
		       , '_PVT'
		       );
    IF (l_debug = 'Y') THEN
       okc_debug.Log('2000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
  WHEN OTHERS THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS (
			 l_api_name
		       , g_pkg_name
		       , 'OTHERS'
		       , x_msg_count
		       , x_msg_data
		       , '_PVT'
		       );
    IF (l_debug = 'Y') THEN
       okc_debug.Log('3000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
END send_message;


/*PROCEDURE send_message
    (p_api_version   IN  NUMBER,
     p_init_msg_list IN  VARCHAR2 ,
     p_commit        IN  VARCHAR2 ,
     x_msg_count     OUT NOCOPY NUMBER,
     x_msg_data      OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     p_msg           IN  VARCHAR2,
     p_queue_name    IN  VARCHAR2,
     p_delay         IN  NUMBER
     )
IS
  l_api_name	  CONSTANT VARCHAR2(30)	:= 'SEND_MESSAGE';
  l_api_version	  CONSTANT NUMBER 	:= 1.0;
  l_return_status VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
  l_char_clob     system.okc_aq_msg_typ;
  x_msg_handle    RAW(16);
  OKC_ENQUEUE_FAILED   EXCEPTION;
  PRAGMA EXCEPTION_INIT (OKC_ENQUEUE_FAILED, -99095 );
   --
   l_proc varchar2(72) := '  OKC_AQ_PVT.'||'send_message';
   --

BEGIN
  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  IF p_msg IS NOT NULL THEN
  -- Call start_activity to create savepoint, check compatibility
  -- and initialize message list
  l_return_status := OKC_API.START_ACTIVITY ( l_api_name
    	                                    , g_pkg_name
			                    , p_init_msg_list
				            , l_api_version
					    , p_api_version
				            , '_PVT'
					    , x_return_status
					    );
  -- Check if activity started successfully
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- build character clob
  build_char_clob ( p_msg, l_char_clob );

  -- enqueue message
  enqueue_message ( l_char_clob
		  , p_queue_name
		  , p_delay
		  , x_msg_handle);

  IF x_msg_handle IS NULL THEN
    RAISE OKC_ENQUEUE_FAILED;
  END IF;
  -- end activity
  OKC_API.END_ACTIVITY ( x_msg_count
		       , x_msg_data );
  END IF;
  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


EXCEPTION
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS (
                         l_api_name
                       , g_pkg_name
                       , 'OKC_API.G_RET_STS_ERROR'
                       , x_msg_count
		       , x_msg_data
		       , '_PVT'
		       );
    IF (l_debug = 'Y') THEN
       okc_debug.Log('2000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
  WHEN OTHERS THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS (
			 l_api_name
		       , g_pkg_name
		       , 'OTHERS'
		       , x_msg_count
		       , x_msg_data
		       , '_PVT'
		       );
    IF (l_debug = 'Y') THEN
       okc_debug.Log('3000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
END send_message;*/

-- This function checks for messages of correlation 'SHUTDOWN'
-- if it finds one then it removes it from the queue and returns true
-- else returns false.
FUNCTION shutdown_event_listener(p_queue IN VARCHAR2) RETURN boolean
IS

  l_dq_options    dbms_aq.dequeue_options_t;
  l_msg_prop      dbms_aq.message_properties_t;
  l_msg_handle    raw(16);
  l_msg           system.okc_aq_msg_typ;
CURSOR queue_cur
IS
SELECT h.msgid msgid ,
       decode(h.subscriber#,0
       ,decode(h.name,'0',NULL,h.name),s.name) consumer_name
from   AQ$_OKC_AQ_EV_TAB_H h,
       aq$_okc_aq_ev_tab_s s,
       okc_aq_ev_tab q
WHERE  q.q_name = substr(p_queue,5)
and    q.STATE = 0
and    h.msgid = q.msgid
AND    ( (h.subscriber# <> 0 AND h.subscriber# = s.subscriber_id)
	  OR
       (h.subscriber# = 0 AND h.address# = s.subscriber_id))
AND    q.CORRID = 'SHUTDOWN';
/*
changed cursor for performance bug# 1563692
SELECT msg_id,consumer_name
FROM   aq$okc_aq_ev_tab
WHERE  'OKC.'||queue = p_queue
AND    msg_state = 'READY'
AND    UPPER(corr_id) = 'SHUTDOWN';*/
queue_rec   queue_cur%ROWTYPE;


   --
   l_proc varchar2(72) := '  OKC_AQ_PVT.'||'shutdown_event_listener';
   --

BEGIN
--  okc_debug.Set_Indentation(l_proc);
--  okc_debug.Log('10: Entering ',2);

    IF queue_cur%ISOPEN THEN
      CLOSE queue_cur;
    END IF;

    OPEN queue_cur;
    FETCH queue_cur INTO queue_rec;
      IF queue_cur%FOUND THEN
        l_dq_options.consumer_name := queue_rec.consumer_name;
        l_dq_options.dequeue_mode  := dbms_aq.REMOVE_NODATA;
        l_dq_options.msgid         := queue_rec.msgid;
	DBMS_AQ.dequeue (  queue_name         => p_queue
		         , dequeue_options    => l_dq_options
		         , message_properties => l_msg_prop
			 , payload            => l_msg
			 , msgid              => l_msg_handle );
        commit;
    CLOSE queue_cur;

--    okc_debug.Log('1000: Leaving ',2);
--    okc_debug.Reset_Indentation;
        RETURN(TRUE);
      ELSE
    CLOSE queue_cur;
--    okc_debug.Log('2000: Leaving ',2);
--    okc_debug.Reset_Indentation;
        RETURN(FALSE);
      END IF;

END shutdown_event_listener;

-- This function checks for messages of correlation 'SHUTDOWN'
-- if it finds one then it removes it from the outcome queue and returns true
-- else returns false.
FUNCTION shutdown_outcome_listener(p_queue IN VARCHAR2) RETURN boolean
IS

  l_dq_options    dbms_aq.dequeue_options_t;
  l_msg_prop      dbms_aq.message_properties_t;
  l_msg_handle    raw(16);
  l_msg           system.okc_aq_msg_typ;
CURSOR queue_cur
IS
SELECT h.msgid msgid ,
       decode(h.subscriber#,0
       ,decode(h.name,'0',NULL,h.name),s.name) consumer_name
from   AQ$_OKC_AQ_EV_TAB_H h,
       aq$_okc_aq_ev_tab_s s,
       okc_aq_ev_tab q
WHERE  q.q_name = substr(p_queue,5)
and    q.STATE = 0
and    h.msgid = q.msgid
AND    ( (h.subscriber# <> 0 AND h.subscriber# = s.subscriber_id)
	  OR
       (h.subscriber# = 0 AND h.address# = s.subscriber_id))
AND    q.CORRID = 'SHUTDOWN';
--changed cursor for performance bug# 1563692
/*SELECT msg_id,consumer_name
FROM   aq$okc_aq_ev_tab
WHERE  'OKC.'||queue = p_queue
AND    msg_state = 'READY'
AND    UPPER(corr_id) = 'SHUTDOWN';*/
queue_rec   queue_cur%ROWTYPE;


   --
   l_proc varchar2(72) := '  OKC_AQ_PVT.'||'shutdown_outcome_listener';
   --

BEGIN
--  okc_debug.Set_Indentation(l_proc);
--  okc_debug.Log('10: Entering ',2);

    IF queue_cur%ISOPEN THEN
      CLOSE queue_cur;
    END IF;

    OPEN queue_cur;
    FETCH queue_cur INTO queue_rec;
      IF queue_cur%FOUND THEN

        l_dq_options.consumer_name := queue_rec.consumer_name;
        l_dq_options.dequeue_mode  := dbms_aq.REMOVE_NODATA;
        l_dq_options.msgid         := queue_rec.msgid;
	DBMS_AQ.dequeue (  queue_name         => p_queue
		         , dequeue_options    => l_dq_options
		         , message_properties => l_msg_prop
			 , payload            => l_msg
			 , msgid              => l_msg_handle );
        commit;
    CLOSE queue_cur;

--    okc_debug.Log('1000: Leaving ',2);
--    okc_debug.Reset_Indentation;
        RETURN(TRUE);
      ELSE
    CLOSE queue_cur;
--    okc_debug.Log('2000: Leaving ',2);
--    okc_debug.Reset_Indentation;
        RETURN(FALSE);
      END IF;

END shutdown_outcome_listener;

PROCEDURE listen_event (
		       errbuf  OUT NOCOPY VARCHAR2
		       ,retcode OUT NOCOPY VARCHAR2
		       ,p_wait  IN INTEGER
                       ,p_sleep IN NUMBER
		       )
IS
  l_agent_list  DBMS_AQ.aq$_agent_list_t;
  l_agent       SYS.aq$_agent;
  l_index       integer;
  l_procedure   VARCHAR2(200);
  l_retval      INTEGER;
  e_listen_timeout  EXCEPTION;

  l_listener_iterations NUMBER;

  PRAGMA EXCEPTION_INIT ( e_listen_timeout, -25254);
  -- bug 3621354 changed cursor to query subscriber view rather than table
  CURSOR c_subscriber IS
    SELECT name
    FROM   AQ$OKC_AQ_EV_TAB_S
    WHERE  queue = substr(OKC_AQ_PVT.g_event_queue_name,5);
   --
   l_proc varchar2(72) := '  OKC_AQ_PVT.'||'listen_event';
   --

BEGIN
--  okc_debug.Set_Indentation(l_proc);
--  okc_debug.Log('10: Entering ',2);

  retcode := 0;
  l_index := 1;

--  okc_debug.Log('50: Before subscriber LOOP',2);

  FOR r_subscriber IN c_subscriber LOOP
    l_agent_list(l_index) := SYS.aq$_agent ( r_subscriber.name
					   , OKC_AQ_PVT.g_event_queue_name
   	         			   , NULL );
    l_index := l_index + 1;
  END LOOP;

--  okc_debug.Log('60: After subscriber LOOP',2);


  -- changed to unconditional loop

--  okc_debug.Log('70: Before unconditional LOOP',2);
  /*  LOOP -- limit loop in order to enable faster shutdown of listeners */
  l_listener_iterations := nvl(fnd_profile.value('OKC_LISTEN_EVENT'),100);

  FOR i IN 1..l_listener_iterations LOOP

    /* bug 2258913 - shut down cursor performs poorly when queue load is high
       Shutdown process no longer needed as listener no longer runs infinately.

    IF shutdown_event_listener(OKC_AQ_PVT.g_event_queue_name) THEN
      EXIT;
    ELSE
    */

      BEGIN
        DBMS_AQ.listen ( agent_list => l_agent_list
		       , wait       => p_wait
		       , agent      => l_agent );
        decode_dots ( l_agent.name, l_procedure );
        execute immediate 'begin '||l_procedure||'; end;';
      EXCEPTION
        WHEN e_listen_timeout THEN
          exit;
	  null;
      END;
  /*  END IF; bug 2258913 */
  /*  DBMS_LOCK.sleep (p_sleep ); */
  END LOOP;

--  okc_debug.Log('70: After unconditional LOOP',2);
--  okc_debug.Log('1000: Leaving ',2);
--  okc_debug.Reset_Indentation;


exception
  when others then
  retcode := 2;
  errbuf := substr(sqlerrm,1,250);
--    okc_debug.Log('2000: errbuf : '||errbuf,2);
--    okc_debug.Log('2000: Leaving ',2);
--    okc_debug.Reset_Indentation;
END listen_event;

PROCEDURE listen_outcome(
		         errbuf  OUT NOCOPY VARCHAR2
		        ,retcode OUT NOCOPY VARCHAR2
			     ,p_wait  IN INTEGER
              ,p_sleep IN NUMBER
		        )

IS
  l_agent_list  DBMS_AQ.aq$_agent_list_t;
  l_agent       SYS.aq$_agent;
  l_index       integer;
  l_procedure   VARCHAR2(200);
  l_retval      INTEGER;
  e_listen_timeout  EXCEPTION;

  l_listener_iterations NUMBER;

  PRAGMA EXCEPTION_INIT ( e_listen_timeout, -25254);

  -- bug 3621354 changed cursor to query subscriber view rather than table
  CURSOR c_subscriber IS
    SELECT name
    FROM   AQ$OKC_AQ_EV_TAB_S
    WHERE  queue = substr(OKC_AQ_PVT.g_outcome_queue_name,5);
   --
   l_proc varchar2(72) := '  OKC_AQ_PVT.'||'listen_outcome';
   --

BEGIN
--  okc_debug.Set_Indentation(l_proc);
--  okc_debug.Log('10: Entering ',2);

  retcode := 0;
  l_index := 1;

--  okc_debug.Log('20: Before subscriber LOOP',2);

  FOR r_subscriber IN c_subscriber LOOP
    l_agent_list(l_index) := SYS.aq$_agent ( r_subscriber.name
					   , OKC_AQ_PVT.g_outcome_queue_name
   	         			   , NULL );

--    okc_debug.Log('21: Index : '||l_index,2);

    l_index := l_index + 1;
  END LOOP;

--  okc_debug.Log('30: After subscriber LOOP',2);

--  okc_debug.Log('40: Before unconditional LOOP',2);

  l_listener_iterations := nvl(fnd_profile.value('OKC_LISTEN_OUTCOME'),100);
  /*  changed to unconditional loop
      Changed to conditional loop to allow faster shutdown of listeners
      and to reduce CPU usage by host system.
  */
  FOR i IN 1..l_listener_iterations LOOP

   /* bug 2258913 - shut down cursor performs poorly when queue load is high
      Shutdown process no longer needed as listener no longer runs infinately.

    IF shutdown_outcome_listener(OKC_AQ_PVT.g_outcome_queue_name) THEN
      IF (l_debug = 'Y') THEN
         okc_debug.Log('45: Inside unconditional LOOP - exiting ',2);
      END IF;
      EXIT;
    ELSE
   */
--      okc_debug.Log('46: Inside unconditional LOOP at 46 ',2);
    BEGIN
--       okc_debug.Log('52: Calling DBMS_AQ.listen',2);

    DBMS_AQ.listen ( agent_list => l_agent_list
		   , wait       => p_wait
		   , agent      => l_agent );

--        okc_debug.Log('53: Calling decode_dots',2);

    decode_dots ( l_agent.name, l_procedure );

--        okc_debug.Log('54: After Calling decode_dots',2);

    execute immediate 'begin '||l_procedure||'; end;';

    EXCEPTION
      WHEN e_listen_timeout THEN
                exit;
	        null;
    END;
/*    END IF;  bug 2258913 */
  /* DBMS_LOCK.sleep (p_sleep ); */
  END LOOP;

--  okc_debug.Log('50: After unconditional LOOP',2);

--  okc_debug.Log('1000: Leaving ',2);
--  okc_debug.Reset_Indentation;


exception
  when others then
  retcode := 2;
  errbuf := substr(sqlerrm,1,250);
--    okc_debug.Log('2000: Error : '||errbuf,2);
--    okc_debug.Log('2000: Leaving ',2);
--    okc_debug.Reset_Indentation;
END listen_outcome;


PROCEDURE dequeue_event
IS
  l_dq_options    dbms_aq.dequeue_options_t;
  l_msg_prop      dbms_aq.message_properties_t;
  l_msg_handle    raw(16);
  l_msg           system.okc_aq_msg_typ;
  l_sub_name      varchar2(30);
  l_msg_tab       OKC_AQ_PVT.msg_tab_typ;
  l_corrid        OKC_AQ_PVT.corrid_rec_typ;
  l_acn_id        OKC_ACTIONS_V.ID%TYPE;
  l_msg_text      VARCHAR2(1000);
  l_msg_data      VARCHAR2(1000);
  l_msg_count     NUMBER;
  v_msg_data      VARCHAR2(1000);
  v_msg_count     NUMBER;
  v_return_status VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
  l_api_name	  CONSTANT VARCHAR2(30)	:= 'DEQUEUE_EVENT';
  l_api_version	  CONSTANT NUMBER 	:= 1.0;
  l_return_status VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
  x_return_status VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
  x_msg_count     NUMBER;
  x_msg_data      VARCHAR2(1000);
  l_token1        VARCHAR2(50);
  l_token1_value  VARCHAR2(50);
  l_token2        VARCHAR2(50);
  l_token2_value  VARCHAR2(50);
  CURSOR acn_cur IS
  SELECT acn.id id
  FROM   okc_actions_b acn
  WHERE  acn.correlation = l_corrid.corrid;
  acn_rec     acn_cur%ROWTYPE;
  e_dequeue_timeout EXCEPTION;
  PRAGMA EXCEPTION_INIT (e_dequeue_timeout, -25228 );
  OKC_PROCESS_FAILED   EXCEPTION;
  OKC_DEQUEUE_FAILED   EXCEPTION;
  OKC_REMOVE_MSG       EXCEPTION;

   --
   l_proc varchar2(72) := '  OKC_AQ_PVT.'||'dequeue_event';
   --

BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  -- Call start_activity to create savepoint, check compatibility
  -- and initialize message list
  l_return_status := OKC_API.START_ACTIVITY ( l_api_name
    	                                    , g_pkg_name
			                    , OKC_API.G_FALSE
				            , l_api_version
					    , 1.0
				            , '_PVT'
					    , x_return_status
					    );
  IF (l_debug = 'Y') THEN
     okc_debug.Log('20: l_return_status : '||l_return_status,2);
  END IF;

  -- Check if activity started successfully
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  -- convert dots to hashes to make sub name legal
  code_dots ('OKC_AQ_PVT.DEQUEUE_EVENT', l_sub_name);
  l_dq_options.consumer_name := l_sub_name;
  l_dq_options.wait          := OKC_AQ_PVT.g_dequeue_wait;
  l_dq_options.navigation    := dbms_aq.first_message;
  l_dq_options.dequeue_mode  := dbms_aq.LOCKED;
  l_dq_options.visibility    := dbms_aq.on_commit;


  IF (l_debug = 'Y') THEN
     okc_debug.Log('30: Calling DBMS_AQ.dequeue with following parameters',2);
     okc_debug.Log('30: queue_name : '||OKC_AQ_PVT.g_event_queue_name,2);
  END IF;

  -- get the message from the queue
  DBMS_AQ.dequeue ( queue_name          => OKC_AQ_PVT.g_event_queue_name
		   , dequeue_options    => l_dq_options
		   , message_properties => l_msg_prop
		   , payload            => l_msg
		   , msgid              => l_msg_handle );

  IF (l_debug = 'Y') THEN
     okc_debug.Log('40: After Call to DBMS_AQ.dequeue',2);
  END IF;

    -- if the payload is null then remove message from the queue and commit
    IF l_msg IS NULL THEN
	   OKC_API.SET_MESSAGE(p_app_name      => g_app_name
			     ,p_msg_name      =>  'OKC_REMOVE_MSG'
			     ,p_token1        =>  'MSG_ID'
			     ,p_token1_value  =>  RAWTOHEX(l_msg_handle)
			     ,p_token2        =>  'CORRID'
			     ,p_token2_value  =>  l_dq_options.correlation
			     );
      raise OKC_REMOVE_MSG;
    END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('50: Calling OKC_XML_PVT.get_element_vals ',2);
  END IF;

  -- convert the clob message to a table of element names and values
  OKC_XML_PVT.get_element_vals ( l_msg
			       , l_msg_tab
			       , l_corrid );
  -- call the event APIs
     OPEN acn_cur;
     FETCH acn_cur INTO acn_rec;
     l_acn_id := acn_rec.id;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('60: Calling  OKC_CONDITION_EVAL_PUB.evaluate_condition ',2);
     okc_debug.Log('60: l_acn_id : '||l_acn_id,2);
  END IF;

     OKC_CONDITION_EVAL_PUB.evaluate_condition (
                            p_api_version    => 1.0,
		            x_return_status  =>l_return_status,
		            x_msg_count      =>l_msg_count,
			    x_msg_data       =>l_msg_data,
			    p_acn_id         =>l_acn_id ,
			    p_msg_tab        =>l_msg_tab
			    );

  IF (l_debug = 'Y') THEN
     okc_debug.Log('70: After Call To OKC_CONDITION_EVAL_PUB.evaluate_condition ',2);
     okc_debug.Log('70: l_return_status : '||l_return_status,2);
  END IF;

    -- if evaluation is successfull then remove message from the queue
    -- and commit the transaction
    IF NVL(l_return_status,'X') = OKC_API.G_RET_STS_SUCCESS THEN
      l_dq_options.dequeue_mode  := dbms_aq.REMOVE_NODATA;
      l_dq_options.msgid         := l_msg_handle;
      DBMS_AQ.dequeue ( queue_name         => OKC_AQ_PVT.g_event_queue_name
		      , dequeue_options    => l_dq_options
		      , message_properties => l_msg_prop
		      , payload            => l_msg
		      , msgid              => l_msg_handle );
      commit;
    -------------------------------------------------------------------------
    -- if the evaluation is not successfull then remove message from the queue
    -- and rollback so that message will be again available on the queue
    -- after 30 minutes of delay_retry time period and can be evaluated
    -- again for a max_retry of 5 times. After 5th try if the evaluation
    -- still fails then message is moved to exception queue.
    -------------------------------------------------------------------------
    ELSIF NVL(l_return_status,'X') <> OKC_API.G_RET_STS_SUCCESS THEN
	   OKC_API.SET_MESSAGE(p_app_name      => g_app_name
			     ,p_msg_name      =>  'OKC_PROCESS_FAILED'
			     ,p_token1        =>  'SOURCE'
			     ,p_token1_value  =>  'Condition Evaluator'
			     ,p_token2        =>  'PROCESS'
			     ,p_token2_value  =>  'Evaluate Condition'
			     );
      l_dq_options.dequeue_mode  := dbms_aq.REMOVE_NODATA;
      l_dq_options.msgid         := l_msg_handle;
      DBMS_AQ.dequeue ( queue_name         => OKC_AQ_PVT.g_event_queue_name
		      , dequeue_options    => l_dq_options
		      , message_properties => l_msg_prop
		      , payload            => l_msg
		      , msgid              => l_msg_handle );
      raise OKC_PROCESS_FAILED;
    END IF;
  -- end activity
  OKC_API.END_ACTIVITY ( l_msg_count
		       , l_msg_data );

  IF (l_debug = 'Y') THEN
     okc_debug.Log('100: l_msg_count : '||l_msg_count,2);
     okc_debug.Log('100: l_msg_data : '||l_msg_data,2);
  END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


EXCEPTION

  WHEN e_dequeue_timeout THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('2000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    null;
  WHEN OKC_REMOVE_MSG THEN
      l_dq_options.dequeue_mode  := dbms_aq.REMOVE_NODATA;
      l_dq_options.msgid         := l_msg_handle;
      DBMS_AQ.dequeue ( queue_name         => OKC_AQ_PVT.g_event_queue_name
		      , dequeue_options    => l_dq_options
		      , message_properties => l_msg_prop
		      , payload            => l_msg
		      , msgid              => l_msg_handle );
      commit;
  OKC_AQ_WRITE_ERROR_PVT.WRITE_MSGDATA(
     p_api_version    => 1.0,
     p_init_msg_list  => OKC_API.G_TRUE,
     p_source_name    => 'Advanced Queuing',
     p_datetime       => sysdate,
     p_msg_tab        => l_msg_tab,
     p_q_name         => 'Events Queue',
     p_corrid         => l_corrid.corrid,
     p_msgid         => l_msg_handle,
     p_msg_count      => l_msg_count,
     p_msg_data       => l_msg_data
     );
    IF (l_debug = 'Y') THEN
       okc_debug.Log('3000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;

  WHEN OTHERS THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS (
			 l_api_name
		       , g_pkg_name
		       , 'OTHERS'
		       , x_msg_count
		       , x_msg_data
		       , '_PVT'
		       );
  OKC_AQ_WRITE_ERROR_PVT.WRITE_MSGDATA(
     p_api_version    => 1.0,
     p_init_msg_list  => OKC_API.G_TRUE,
     p_source_name    => 'Advanced Queuing',
     p_datetime       => sysdate,
     p_msg_tab        => l_msg_tab,
     p_q_name         => 'Events Queue',
     p_corrid         => l_corrid.corrid,
     p_msgid         => l_msg_handle,
     p_msg_count      => l_msg_count,
     p_msg_data       => l_msg_data
     );
    IF (l_debug = 'Y') THEN
       okc_debug.Log('4000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
END dequeue_event;


-- This procedure deques all actions that are Date Based Actions
PROCEDURE dequeue_date_event
IS
  l_dq_options    dbms_aq.dequeue_options_t;
  l_msg_prop      dbms_aq.message_properties_t;
  l_msg_handle    raw(16);
  l_msg           system.okc_aq_msg_typ;
  l_sub_name      varchar2(30);
  l_msg_tab       OKC_AQ_PVT.msg_tab_typ;
  l_corrid        OKC_AQ_PVT.corrid_rec_typ;
  l_cnh_id        OKC_CONDITION_HEADERS_B.ID%TYPE;
  l_msg_text      VARCHAR2(1000);
  l_msg_data      VARCHAR2(1000);
  l_msg_count     NUMBER;
  v_msg_data      VARCHAR2(1000);
  v_msg_count     NUMBER;
  v_return_status VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
  l_api_name	  CONSTANT VARCHAR2(30)	:= 'DEQUEUE_DATE_EVENT';
  l_api_version	  CONSTANT NUMBER 	:= 1.0;
  l_return_status VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
  x_return_status VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
  x_msg_count     NUMBER;
  x_msg_data      VARCHAR2(1000);
  l_token1        VARCHAR2(50);
  l_token1_value  VARCHAR2(50);
  l_token2        VARCHAR2(50);
  l_token2_value  VARCHAR2(50);
  e_dequeue_timeout EXCEPTION;
  PRAGMA EXCEPTION_INIT (e_dequeue_timeout, -25228 );
  OKC_PROCESS_FAILED   EXCEPTION;
  OKC_DEQUEUE_FAILED   EXCEPTION;
  OKC_REMOVE_MSG       EXCEPTION;

   --
   l_proc varchar2(72) := '  OKC_AQ_PVT.'||'dequeue_date_event';
   --

BEGIN
  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;


  -- Call start_activity to create savepoint, check compatibility
  -- and initialize message list
  l_return_status := OKC_API.START_ACTIVITY ( l_api_name
    	                                    , g_pkg_name
			                    , OKC_API.G_FALSE
				            , l_api_version
					    , 1.0
				            , '_PVT'
					    , x_return_status
					    );
  -- Check if activity started successfully
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  -- convert dots to hashes to make sub name legal
  code_dots ('OKC_AQ_PVT.DEQUEUE_DATE_EVENT', l_sub_name);
  l_dq_options.consumer_name := l_sub_name;
  l_dq_options.wait          := OKC_AQ_PVT.g_dequeue_wait;
  l_dq_options.navigation    := dbms_aq.first_message;
  l_dq_options.dequeue_mode  := dbms_aq.LOCKED;
  l_dq_options.visibility    := dbms_aq.on_commit;


  -- get the message from the queue

  DBMS_AQ.dequeue ( queue_name          => OKC_AQ_PVT.g_event_queue_name
		   , dequeue_options    => l_dq_options
		   , message_properties => l_msg_prop
		   , payload            => l_msg
		   , msgid              => l_msg_handle );
    -- if the payload is null then remove message from the queue and commit
    IF l_msg IS NULL THEN
	   OKC_API.SET_MESSAGE(p_app_name      => g_app_name
			     ,p_msg_name      =>  'OKC_REMOVE_MSG'
			     ,p_token1        =>  'MSG_ID'
			     ,p_token1_value  =>  RAWTOHEX(l_msg_handle)
			     ,p_token2        =>  'CORRID'
			     ,p_token2_value  =>  l_dq_options.correlation
			     );
      raise OKC_REMOVE_MSG;
    END IF;

  -- convert the clob message to a table of element names and values
  OKC_XML_PVT.get_element_vals ( l_msg
			       , l_msg_tab
			       , l_corrid );
  -- get the condition header id from msg table
     FOR i IN 1..l_msg_tab.COUNT LOOP
       IF l_msg_tab(i).element_name = 'CNH_ID' THEN
	  l_cnh_id := l_msg_tab(i).element_value;
       END IF;
     END LOOP;
  -- call the event APIs
     OKC_CONDITION_EVAL_PUB.evaluate_date_condition (
                            p_api_version    => 1.0,
		            x_return_status  =>l_return_status,
		            x_msg_count      =>l_msg_count,
			    x_msg_data       =>l_msg_data,
			    p_cnh_id         =>l_cnh_id ,
			    p_msg_tab        =>l_msg_tab
			    );
    -- if evaluation is successfull then remove message from the queue
    -- and commit the transaction
    IF NVL(l_return_status,'X') = OKC_API.G_RET_STS_SUCCESS THEN
      l_dq_options.dequeue_mode  := dbms_aq.REMOVE_NODATA;
      l_dq_options.msgid         := l_msg_handle;
      DBMS_AQ.dequeue ( queue_name         => OKC_AQ_PVT.g_event_queue_name
		      , dequeue_options    => l_dq_options
		      , message_properties => l_msg_prop
		      , payload            => l_msg
		      , msgid              => l_msg_handle );
      commit;
    -------------------------------------------------------------------------
    -- if the evaluation is not successfull then remove message from the queue
    -- and rollback so that message will be again available on the queue
    -- after 30 minutes of delay_retry time period and can be evaluated
    -- again for a max_retry of 5 times. After 5th try if the evaluation
    -- still fails then message is moved to exception queue.
    -------------------------------------------------------------------------
    ELSIF NVL(l_return_status,'X') <> OKC_API.G_RET_STS_SUCCESS THEN
	   OKC_API.SET_MESSAGE(p_app_name      => g_app_name
			     ,p_msg_name      =>  'OKC_PROCESS_FAILED'
			     ,p_token1        =>  'SOURCE'
			     ,p_token1_value  =>  'Condition Evaluator'
			     ,p_token2        =>  'PROCESS'
			     ,p_token2_value  =>  'Evaluate Date Condition'
			     );
      l_dq_options.dequeue_mode  := dbms_aq.REMOVE_NODATA;
      l_dq_options.msgid         := l_msg_handle;
      DBMS_AQ.dequeue ( queue_name         => OKC_AQ_PVT.g_event_queue_name
		      , dequeue_options    => l_dq_options
		      , message_properties => l_msg_prop
		      , payload            => l_msg
		      , msgid              => l_msg_handle );
      raise OKC_PROCESS_FAILED;
    END IF;
  -- end activity
  OKC_API.END_ACTIVITY ( l_msg_count
		       , l_msg_data );

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


EXCEPTION

  WHEN e_dequeue_timeout THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('2000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    null;
  WHEN OKC_REMOVE_MSG THEN
      l_dq_options.dequeue_mode  := dbms_aq.REMOVE_NODATA;
      l_dq_options.msgid         := l_msg_handle;
      DBMS_AQ.dequeue ( queue_name         => OKC_AQ_PVT.g_event_queue_name
		      , dequeue_options    => l_dq_options
		      , message_properties => l_msg_prop
		      , payload            => l_msg
		      , msgid              => l_msg_handle );
      commit;
  OKC_AQ_WRITE_ERROR_PVT.WRITE_MSGDATA(
     p_api_version    => 1.0,
     p_init_msg_list  => OKC_API.G_TRUE,
     p_source_name    => 'Advanced Queuing',
     p_datetime       => sysdate,
     p_msg_tab        => l_msg_tab,
     p_q_name         => 'Events Queue',
     p_corrid         => l_corrid.corrid,
     p_msgid         => l_msg_handle,
     p_msg_count      => l_msg_count,
     p_msg_data       => l_msg_data
     );
    IF (l_debug = 'Y') THEN
       okc_debug.Log('3000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;

  WHEN OTHERS THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS (
			 l_api_name
		       , g_pkg_name
		       , 'OTHERS'
		       , x_msg_count
		       , x_msg_data
		       , '_PVT'
		       );
  OKC_AQ_WRITE_ERROR_PVT.WRITE_MSGDATA(
     p_api_version    => 1.0,
     p_init_msg_list  => OKC_API.G_TRUE,
     p_source_name    => 'Advanced Queuing',
     p_datetime       => sysdate,
     p_msg_tab        => l_msg_tab,
     p_q_name         => 'Events Queue',
     p_corrid         => l_corrid.corrid,
     p_msgid         => l_msg_handle,
     p_msg_count      => l_msg_count,
     p_msg_data       => l_msg_data
     );
    IF (l_debug = 'Y') THEN
       okc_debug.Log('4000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
END dequeue_date_event;

PROCEDURE dequeue_outcome
IS
  l_dq_options    dbms_aq.dequeue_options_t;
  l_msg_prop      dbms_aq.message_properties_t;
  l_msg_handle    raw(16);
  l_msg           system.okc_aq_msg_typ;
  l_sub_name      varchar2(30);
  l_msg_text      varchar2(1000);
  l_msg_data      varchar2(1000);
  l_msg_count     number;
  l_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
  x_msg_data      varchar2(1000);
  x_msg_count     number;
  x_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
  v_msg_data      varchar2(1000);
  v_msg_count     number;
  v_return_status varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_api_name      CONSTANT VARCHAR2(30) := 'DEQUEUE_OUTCOME';
  l_api_version   CONSTANT NUMBER       := 1.0;
  l_msg_tab       OKC_AQ_PVT.msg_tab_typ;
  l_corrid        OKC_AQ_PVT.corrid_rec_typ;
  l_init_msg_list VARCHAR2(1) := okc_api.G_FALSE;
  l_token1        VARCHAR2(50);
  l_token1_value  VARCHAR2(50);
  l_token2        VARCHAR2(50);
  l_token2_value  VARCHAR2(50);
  e_dequeue_timeout EXCEPTION;
  PRAGMA EXCEPTION_INIT (e_dequeue_timeout, -25228 );
  OKC_PROCESS_FAILED   EXCEPTION;
  OKC_DEQUEUE_FAILED   EXCEPTION;
  OKC_REMOVE_MSG       EXCEPTION;

   --
   l_proc varchar2(72) := '  OKC_AQ_PVT.'||'dequeue_outcome';
   --

BEGIN
  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;


  -- Call start_activity to create savepoint, check compatibility
  -- and initialize message list
  l_return_status := OKC_API.START_ACTIVITY ( l_api_name
    	                                    , g_pkg_name
			                    , OKC_API.G_FALSE
				            , l_api_version
					    , 1.0
				            , '_PVT'
					    , x_return_status
					    );
  -- Check if activity started successfully
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('50: Calling code_dots ',2);
  END IF;

  -- convert dots to hashes to make sub name legal
  code_dots ('OKC_AQ_PVT.DEQUEUE_OUTCOME', l_sub_name);

  l_dq_options.consumer_name := l_sub_name;
  l_dq_options.wait          := OKC_AQ_PVT.g_dequeue_wait;
  l_dq_options.navigation    := dbms_aq.next_message;
  l_dq_options.dequeue_mode  := dbms_aq.LOCKED;
  l_dq_options.visibility    := dbms_aq.ON_COMMIT;


  IF (l_debug = 'Y') THEN
     okc_debug.Log('100: Calling DBMS_AQ.dequeue',2);
  END IF;

  -- get the message from the queue

  DBMS_AQ.dequeue ( queue_name          => OKC_AQ_PVT.g_outcome_queue_name
		   , dequeue_options    => l_dq_options
		   , message_properties => l_msg_prop
		   , payload            => l_msg
		   , msgid              => l_msg_handle );

  IF (l_debug = 'Y') THEN
     okc_debug.Log('110: After Calling DBMS_AQ.dequeue',2);
  END IF;

    IF l_msg IS NULL THEN
	   OKC_API.SET_MESSAGE(p_app_name      => g_app_name
			     ,p_msg_name      =>  'OKC_DEQUEUE_FAILED'
			     ,p_token1        =>  'MSG_ID'
			     ,p_token1_value  =>  RAWTOHEX(l_msg_handle)
			     ,p_token2        =>  'QUEUE'
			     ,p_token2_value  =>  'Outcome Queue'
			     );
      raise OKC_REMOVE_MSG;
    END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('120: Calling OKC_XML_PVT.get_element_vals ',2);
  END IF;

  -- converts message from clob to table of element names and values
  OKC_XML_PVT.get_element_vals ( l_msg
			       , l_msg_tab
			       , l_corrid );

  IF (l_debug = 'Y') THEN
     okc_debug.Log('130: After Calling OKC_XML_PVT.get_element_vals ',2);
     okc_debug.Log('130: l_corrid.corrid  : '||l_corrid.corrid,2);
     okc_debug.Log('130: l_msg_tab.count : '||l_msg_tab.count,2);
  END IF;

  -- call the outcome APIs
  IF l_corrid.corrid IS NOT NULL AND
     l_msg_tab.count <> 0 THEN
    OKC_OUTCOME_INIT_PVT.Launch_outcome(p_api_version     => 1.0,
					 p_init_msg_list   => OKC_API.G_FALSE,
	                                 p_corrid_rec      => l_corrid,
		                         p_msg_tab_typ     => l_msg_tab,
			                 x_msg_count       => l_msg_count,
			                 x_msg_data        => l_msg_data,
					 x_return_status   => l_return_status
					 );
  END IF;
  IF NVL(l_return_status,'X') = OKC_API.G_RET_STS_SUCCESS THEN
      l_dq_options.dequeue_mode  := dbms_aq.REMOVE_NODATA;
      l_dq_options.msgid         := l_msg_handle;
      DBMS_AQ.dequeue ( queue_name         => OKC_AQ_PVT.g_outcome_queue_name
		      , dequeue_options    => l_dq_options
		      , message_properties => l_msg_prop
		      , payload            => l_msg
		      , msgid              => l_msg_handle );
    commit;
  ELSE
    OKC_API.SET_MESSAGE(p_app_name      => g_app_name
			,p_msg_name      =>  'OKC_PROCESS_FAILED'
			,p_token1        =>  'SOURCE'
			,p_token1_value  =>  'Outcome Initiator'
			,p_token2        =>  'PROCESS'
			,p_token2_value  =>  'Launch Outcome'
			);
      l_dq_options.dequeue_mode  := dbms_aq.REMOVE_NODATA;
      l_dq_options.msgid         := l_msg_handle;
      DBMS_AQ.dequeue ( queue_name         => OKC_AQ_PVT.g_outcome_queue_name
		      , dequeue_options    => l_dq_options
		      , message_properties => l_msg_prop
		      , payload            => l_msg
		      , msgid              => l_msg_handle );
    RAISE OKC_PROCESS_FAILED;
  END IF;

  -- end activity
  OKC_API.END_ACTIVITY ( l_msg_count
		       , l_msg_data );


  IF (l_debug = 'Y') THEN
     okc_debug.Log('500: l_msg_count : '||l_msg_count,2);
     okc_debug.Log('500: l_msg_data  : '||l_msg_data,2);
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


EXCEPTION

  WHEN e_dequeue_timeout THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('2000: e_dequeue_timeout EXCEPTION',2);
       okc_debug.Log('2000: l_msg_count : '||l_msg_count,2);
       okc_debug.Log('2000: l_msg_data  : '||l_msg_data,2);
       okc_debug.Log('2000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    null;
  WHEN OKC_REMOVE_MSG THEN
      l_dq_options.dequeue_mode  := dbms_aq.REMOVE_NODATA;
      l_dq_options.msgid         := l_msg_handle;
      DBMS_AQ.dequeue ( queue_name         => OKC_AQ_PVT.g_outcome_queue_name
		      , dequeue_options    => l_dq_options
		      , message_properties => l_msg_prop
		      , payload            => l_msg
		      , msgid              => l_msg_handle );
      commit;
  OKC_AQ_WRITE_ERROR_PVT.WRITE_MSGDATA(
     p_api_version    => 1.0,
     p_init_msg_list  => OKC_API.G_TRUE,
     p_source_name    => 'Advanced Queuing',
     p_datetime       => sysdate,
     p_msg_tab        => l_msg_tab,
     p_q_name         => 'Outcome Queue',
     p_corrid         => l_corrid.corrid,
     p_msgid         => l_msg_handle,
     p_msg_count      => l_msg_count,
     p_msg_data       => l_msg_data
     );
    IF (l_debug = 'Y') THEN
       okc_debug.Log('3000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;

  WHEN OTHERS THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS (
			 l_api_name
		       , g_pkg_name
		       , 'OTHERS'
		       , x_msg_count
		       , x_msg_data
		       , '_PVT'
		       );
  OKC_AQ_WRITE_ERROR_PVT.WRITE_MSGDATA(
     p_api_version    => 1.0,
     p_init_msg_list  => OKC_API.G_TRUE,
     p_source_name    => 'Advanced Queuing',
     p_datetime       => sysdate,
     p_msg_tab        => l_msg_tab,
     p_q_name         => 'Outcome Queue',
     p_corrid         => l_corrid.corrid,
     p_msgid         => l_msg_handle,
     p_msg_count      => l_msg_count,
     p_msg_data       => l_msg_data
     );
    IF (l_debug = 'Y') THEN
       okc_debug.Log('4000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
END dequeue_outcome;

PROCEDURE add_subscriber (
  p_sub_name       IN  VARCHAR2
, p_queue_name     IN  VARCHAR2
, p_rule           IN  VARCHAR2  )
IS
  l_subscriber sys.aq$_agent;
  l_sub_name   VARCHAR2(2000);
   --
   l_proc varchar2(72) := '  OKC_AQ_PVT.'||'add_subscriber';
   --

BEGIN
  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  -- code the sub name by replacing dots with hash
  code_dots (p_sub_name, l_sub_name);
  l_subscriber := sys.aq$_agent (l_sub_name,null,null);
  DBMS_AQADM.add_subscriber ( p_queue_name
			    , l_subscriber
			    , p_rule );
END add_subscriber;


PROCEDURE remove_subscriber (
  p_sub_name       IN  VARCHAR2
, p_queue_name     IN  VARCHAR2 )
IS
  l_sub_name VARCHAR2(2000);
  l_subscriber SYS.aq$_agent;
   --
   l_proc varchar2(72) := '  OKC_AQ_PVT.'||'remove_subscriber';
   --

BEGIN
  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  code_dots (p_sub_name, l_sub_name);
  l_subscriber := sys.aq$_agent (l_sub_name,null,null);
  DBMS_AQADM.remove_subscriber ( p_queue_name, l_subscriber);

    IF (l_debug = 'Y') THEN
       okc_debug.Log('1000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;

END remove_subscriber;


PROCEDURE dequeue_exception (
		        errbuf  OUT NOCOPY VARCHAR2
		       ,retcode OUT NOCOPY VARCHAR2
		       ,p_msg_id  IN  VARCHAR2)
IS
  l_dq_options    dbms_aq.dequeue_options_t;
  l_msg_prop      dbms_aq.message_properties_t;
  l_msg_handle    raw(16);
  l_msg           system.okc_aq_msg_typ;
  l_sub_name      varchar2(30);
  l_corrid        OKC_AQ_PVT.corrid_rec_typ;
  l_api_name	  CONSTANT VARCHAR2(30)	:= 'DEQUEUE_EXCEPTION';
  l_api_version	  CONSTANT NUMBER 	:= 1.0;
  l_return_status VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
  x_return_status VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
  x_msg_count     NUMBER;
  x_msg_data      VARCHAR2(1000);
  l_token1        VARCHAR2(50);
  l_token1_value  VARCHAR2(50);
  l_token2        VARCHAR2(50);
  l_token2_value  VARCHAR2(50);
  l_consumer_name VARCHAR2(50);


  CURSOR msg_cur IS
  SELECT consumer_name,corr_id
  FROM   aq$okc_aq_ev_tab
  WHERE  msg_id = HEXTORAW(p_msg_id);
  msg_rec  msg_cur%ROWTYPE;

  e_dequeue_timeout EXCEPTION;
  PRAGMA EXCEPTION_INIT (e_dequeue_timeout, -25228 );
  OKC_REMOVE_MSG       EXCEPTION;

   --
   l_proc varchar2(72) := '  OKC_AQ_PVT.'||'dequeue_exception';
   --
   l_queue_name   varchar2(25) := g_app_name||'.AQ$_OKC_AQ_EV_TAB_E';
BEGIN
  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;


  retcode := 0;
  -- Call start_activity to create savepoint, check compatibility
  -- and initialize message list
  l_return_status := OKC_API.START_ACTIVITY ( l_api_name
    	                                    , g_pkg_name
			                    , OKC_API.G_FALSE
				            , l_api_version
					    , 1.0
				            , '_PVT'
					    , x_return_status
					    );
  -- Check if activity started successfully
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- get the consumer name to enqueue message
    OPEN msg_cur;
    FETCH msg_cur INTO msg_rec;
      IF msg_rec.consumer_name IS NOT NULL THEN
	l_consumer_name := msg_rec.consumer_name;
	l_corrid.corrid := msg_rec.corr_id;
      END IF;
    CLOSE msg_cur;

  l_dq_options.consumer_name := null;
  l_dq_options.wait          := OKC_AQ_PVT.g_dequeue_wait;
  l_dq_options.navigation    := dbms_aq.next_message;
  l_dq_options.dequeue_mode  := dbms_aq.REMOVE;
  l_dq_options.visibility    := dbms_aq.on_commit;
  l_dq_options.msgid        := HEXTORAW(p_msg_id);


  -- get the message from the exception queue
  DBMS_AQ.dequeue ( queue_name          => l_queue_name
		   , dequeue_options    => l_dq_options
		   , message_properties => l_msg_prop
		   , payload            => l_msg
		   , msgid              => l_msg_handle);
    -- if the payload is null then remove message from the queue and commit
    IF l_msg IS NULL THEN
	   OKC_API.SET_MESSAGE(p_app_name      => g_app_name
			     ,p_msg_name      =>  'OKC_REMOVE_MSG'
			     ,p_token1        =>  'MSG_ID'
			     ,p_token1_value  =>  RAWTOHEX(l_msg_handle)
			     ,p_token2        =>  'CORRID'
			     ,p_token2_value  =>  l_dq_options.correlation
			     );
      raise OKC_REMOVE_MSG;
    END IF;

    -- enqueue the message into appropriate queue based on consumer name
      IF l_consumer_name = 'OKC_AQ_PVT#DEQUEUE_OUTCOME' THEN
         enqueue_message  ( l_msg
		           , l_corrid
		           ,OKC_AQ_PVT.g_outcome_queue_name
		           ,dbms_aq.no_delay
		           , l_msg_handle);
      ELSE
         enqueue_message  ( l_msg
		           , l_corrid
		           ,OKC_AQ_PVT.g_event_queue_name
		           ,dbms_aq.no_delay
		           , l_msg_handle);
      END IF;
      commit;
  -- end activity
  OKC_API.END_ACTIVITY ( x_msg_count
		       , x_msg_data );

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


EXCEPTION

  WHEN e_dequeue_timeout THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('2000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    null;

  WHEN OTHERS THEN
  retcode := 2;
  errbuf := substr(sqlerrm,1,250);
    x_return_status := OKC_API.HANDLE_EXCEPTIONS (
			 l_api_name
		       , g_pkg_name
		       , 'OTHERS'
		       , x_msg_count
		       , x_msg_data
		       , '_PVT'
		       );
    IF (l_debug = 'Y') THEN
       okc_debug.Log('3000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
END dequeue_exception;

-- This procedure removes any message from events,outcome or
-- exception queue. This will be registered as concurrent
-- program which accepts msg_id as input parameter. This program
-- can be run to remove messages in situations where message is
-- not dequeued or retried due to some errors and also when
-- it causes overflow of aqerror log tables.
PROCEDURE remove_message(
		        errbuf  OUT NOCOPY VARCHAR2
		       ,retcode OUT NOCOPY VARCHAR2
		       ,p_msg_id  IN  VARCHAR2)
IS
  l_dq_options    dbms_aq.dequeue_options_t;
  l_msg_prop      dbms_aq.message_properties_t;
  l_msg_handle    raw(16);
  l_msg           system.okc_aq_msg_typ;
  l_sub_name      varchar2(30);
  l_corrid        OKC_AQ_PVT.corrid_rec_typ;
  l_api_name	  CONSTANT VARCHAR2(30)	:= 'REMOVE_MESSAGE';
  l_api_version	  CONSTANT NUMBER 	:= 1.0;
  l_return_status VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
  x_return_status VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
  x_msg_count     NUMBER;
  x_msg_data      VARCHAR2(1000);
  l_token1        VARCHAR2(50);
  l_token1_value  VARCHAR2(50);
  l_token2        VARCHAR2(50);
  l_token2_value  VARCHAR2(50);
  l_consumer_name VARCHAR2(50);
  l_queue         VARCHAR2(30);
  l_error_queue         VARCHAR2(30) := g_app_name||'.AQ$_OKC_AQ_EV_TAB_E';


  CURSOR msg_cur IS
  SELECT consumer_name,corr_id,queue
  FROM   aq$okc_aq_ev_tab
  WHERE  msg_id = HEXTORAW(p_msg_id);
  msg_rec  msg_cur%ROWTYPE;

  e_dequeue_timeout EXCEPTION;
  PRAGMA EXCEPTION_INIT (e_dequeue_timeout, -25228 );
  OKC_REMOVE_MSG       EXCEPTION;

   --
   l_proc varchar2(72) := '  OKC_AQ_PVT.'||'remove_message';
   --

BEGIN
  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;


  retcode := 0;
  -- Call start_activity to create savepoint, check compatibility
  -- and initialize message list
  l_return_status := OKC_API.START_ACTIVITY ( l_api_name
    	                                    , g_pkg_name
			                    , OKC_API.G_FALSE
				            , l_api_version
					    , 1.0
				            , '_PVT'
					    , x_return_status
					    );
  -- Check if activity started successfully
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- get the consumer name to enqueue message
    OPEN msg_cur;
    FETCH msg_cur INTO msg_rec;
      IF msg_rec.consumer_name IS NOT NULL THEN
	l_consumer_name := msg_rec.consumer_name;
	l_corrid.corrid := msg_rec.corr_id;
	l_queue         := msg_rec.queue;
      END IF;
    CLOSE msg_cur;
  l_dq_options.consumer_name := l_consumer_name;
  l_dq_options.wait          := OKC_AQ_PVT.g_dequeue_wait;
  l_dq_options.navigation    := dbms_aq.next_message;
  l_dq_options.dequeue_mode  := dbms_aq.REMOVE;
  l_dq_options.visibility    := dbms_aq.on_commit;
  l_dq_options.msgid        := HEXTORAW(p_msg_id);

  IF    l_queue = 'OKC_AQ_EV_QUEUE' THEN
        l_queue := okc_aq_pvt.g_event_queue_name;
  ELSIF l_queue = 'OKC_AQ_OC_QUEUE' THEN
	l_queue := okc_aq_pvt.g_outcome_queue_name;
  ELSIF l_queue =      'AQ$_OKC_AQ_EV_TAB_E' THEN
	l_queue := l_error_queue;
  END IF;

  -- get the message from the queue
  DBMS_AQ.dequeue ( queue_name          => l_queue
		   , dequeue_options    => l_dq_options
		   , message_properties => l_msg_prop
		   , payload            => l_msg
		   , msgid              => l_msg_handle);

      commit;
  -- end activity
  OKC_API.END_ACTIVITY ( x_msg_count
		       , x_msg_data );

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


EXCEPTION

  WHEN e_dequeue_timeout THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('2000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
   -- null;

  WHEN OTHERS THEN
  retcode := 2;
  errbuf := substr(sqlerrm,1,250);
    x_return_status := OKC_API.HANDLE_EXCEPTIONS (
			 l_api_name
		       , g_pkg_name
		       , 'OTHERS'
		       , x_msg_count
		       , x_msg_data
		       , '_PVT'
		       );
    IF (l_debug = 'Y') THEN
       okc_debug.Log('3000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
END remove_message;


PROCEDURE clear_message( errbuf  OUT NOCOPY VARCHAR2
		        ,retcode OUT NOCOPY VARCHAR2
		        )
IS
  l_dq_options    dbms_aq.dequeue_options_t;
  l_msg_prop      dbms_aq.message_properties_t;
  l_msg_handle    raw(16);
  l_msg           system.okc_aq_msg_typ;
  l_sub_name      varchar2(30);
  l_corrid        OKC_AQ_PVT.corrid_rec_typ;
  l_api_name	  CONSTANT VARCHAR2(30)	:= 'REMOVE_MESSAGE';
  l_api_version	  CONSTANT NUMBER 	:= 1.0;
  l_return_status VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
  x_return_status VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
  x_msg_count     NUMBER;
  x_msg_data      VARCHAR2(1000);
  l_token1        VARCHAR2(50);
  l_token1_value  VARCHAR2(50);
  l_token2        VARCHAR2(50);
  l_token2_value  VARCHAR2(50);
  l_consumer_name VARCHAR2(50);
  l_queue         VARCHAR2(30);
  l_profile       VARCHAR2(240);

  CURSOR profile_cur IS
  SELECT opval.profile_option_value profile_value
  FROM   fnd_profile_options op,
	 fnd_profile_option_values opval
  WHERE  op.profile_option_id = opval.profile_option_id
  AND    op.application_id    = opval.application_id
  AND    op.profile_option_name = 'OKC_RETAIN_MSG_DAYS';
  profile_rec  profile_cur%ROWTYPE;

  CURSOR msg_cur(x IN NUMBER) IS
  SELECT msgid
  FROM   okc_aq_ev_tab
  WHERE  q_name = 'AQ$_OKC_AQ_EV_TAB_E'
  AND    trunc(enq_time) + (x) = trunc(sysdate);
  msg_rec  msg_cur%ROWTYPE;

  e_dequeue_timeout EXCEPTION;
  PRAGMA EXCEPTION_INIT (e_dequeue_timeout, -25228 );
  OKC_REMOVE_MSG       EXCEPTION;

   --
   l_proc varchar2(72) := '  OKC_AQ_PVT.'||'clear_message';
   l_error_queue  varchar2(30) := g_app_name||'.AQ$_OKC_AQ_EV_TAB_E';
   --

BEGIN
  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;


  retcode := 0;
  -- Call start_activity to create savepoint, check compatibility
  -- and initialize message list
  l_return_status := OKC_API.START_ACTIVITY ( l_api_name
    	                                    , g_pkg_name
			                    , OKC_API.G_FALSE
				            , l_api_version
					    , 1.0
				            , '_PVT'
					    , x_return_status
					    );
  -- Check if activity started successfully
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  OPEN profile_cur;
  FETCH profile_cur INTO profile_rec;
    l_profile := profile_rec.profile_value;
  CLOSE profile_cur;
  -- get the msg_id name to dequeue message
  IF msg_cur%ISOPEN THEN
    CLOSE msg_cur;
  END IF;
  OPEN msg_cur(l_profile);
    LOOP
    FETCH msg_cur INTO msg_rec;
      IF msg_cur%NOTFOUND THEN
        EXIT;
      ELSE

    l_dq_options.consumer_name := null;
    l_dq_options.wait          := OKC_AQ_PVT.g_dequeue_wait;
    l_dq_options.navigation    := dbms_aq.next_message;
    l_dq_options.dequeue_mode  := dbms_aq.REMOVE;
    l_dq_options.visibility    := dbms_aq.on_commit;
    l_dq_options.msgid        := HEXTORAW(msg_rec.msgid);


    -- remove the message from the exception queue
    DBMS_AQ.dequeue ( queue_name          => l_error_queue
		     , dequeue_options    => l_dq_options
		     , message_properties => l_msg_prop
		     , payload            => l_msg
		     , msgid              => l_msg_handle);

        commit;
      END IF;
  END LOOP;
  CLOSE msg_cur;
  -- end activity
  OKC_API.END_ACTIVITY ( x_msg_count
		       , x_msg_data );

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


EXCEPTION

  WHEN e_dequeue_timeout THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('2000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    null;

  WHEN OTHERS THEN
  retcode := 2;
  errbuf := substr(sqlerrm,1,250);
    x_return_status := OKC_API.HANDLE_EXCEPTIONS (
			 l_api_name
		       , g_pkg_name
		       , 'OTHERS'
		       , x_msg_count
		       , x_msg_data
		       , '_PVT'
		       );
    IF (l_debug = 'Y') THEN
       okc_debug.Log('3000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
END clear_message;

-- This procedure will be executed by ICM at the time of database shutdown
PROCEDURE stop_listener
IS
  l_corrid_rec    okc_aq_pvt.corrid_rec_typ;
  l_msg_tab       okc_aq_pvt.msg_tab_typ := okc_aq_pvt.msg_tab_typ() ;
  l_msg_count     number;
  l_msg_data      varchar2(1000);
  l_return_status varchar2(1);
  x_msg_count     number;
  x_msg_data      varchar2(1000);
  x_return_status varchar2(1);
  l_api_name      CONSTANT VARCHAR2(30) := 'STOP_LISTENER';
  PRAGMA AUTONOMOUS_TRANSACTION;
   --
   l_proc varchar2(72) := '  OKC_AQ_PVT.'||'stop_listener';
   --

BEGIN
  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

 --Initialize return status
  l_return_status := OKC_API.G_RET_STS_SUCCESS;

    l_corrid_rec.corrid := 'SHUTDOWN';
  -- enqueues shutdown message into events queue
  okc_aq_pvt.send_message ( p_api_version   => '1.0'
			  , x_msg_count     => l_msg_count
		          , x_msg_data      => l_msg_data
		          , x_return_status => l_return_status
		          , p_corrid_rec    => l_corrid_rec
		          , p_msg_tab       => l_msg_tab
		          , p_queue_name    => okc_aq_pvt.g_event_queue_name );

  -- enqueues shutdown message into outcomes queue
  okc_aq_pvt.send_message ( p_api_version   => '1.0'
			  , x_msg_count     => l_msg_count
		          , x_msg_data      => l_msg_data
		          , x_return_status => l_return_status
		          , p_corrid_rec    => l_corrid_rec
		          , p_msg_tab       => l_msg_tab
		          , p_queue_name    => okc_aq_pvt.g_outcome_queue_name );
  commit;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


EXCEPTION
  WHEN others THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('2000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    rollback;
END stop_listener;

END okc_aq_pvt;

/
