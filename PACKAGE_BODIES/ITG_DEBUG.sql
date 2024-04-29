--------------------------------------------------------
--  DDL for Package Body ITG_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITG_DEBUG" AS
/* ARCS: $Header: itgdbugb.pls 120.1 2005/10/06 02:03:28 bsaratna noship $
 * CVS:  itgdbugb.pls,v 1.17 2003/02/05 18:50:42 ecoe Exp
 */

  G_SECT_WIDTH   CONSTANT NUMBER := 4;
  G_PROMPT_WIDTH CONSTANT NUMBER := 30;

  g_msg_level  NUMBER	     := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
  g_pkg_name   VARCHAR2(40);
  g_proc_name  VARCHAR2(40);
  g_changed    BOOLEAN;

  l_debug_level NUMBER;

  FUNCTION spacer(
    p_cnt NUMBER
  ) RETURN VARCHAR2 IS
    l_buf VARCHAR2(100) := '';
    l_cnt NUMBER        := p_cnt;
  BEGIN
    WHILE l_cnt > 0 LOOP
      l_buf := l_buf || ' ';
      l_cnt := l_cnt - 1;
    END LOOP;
    RETURN l_buf;
  END;

  PROCEDURE error_message IS
    l_buff	VARCHAR2(2000);
  BEGIN
      /* Insert error prefix before message in fnd_message buffer. */
      l_buff := FND_MESSAGE.get;

    IF l_debug_level <= 3 THEN
	cln_debug_pub.Add('ITGDBG>' || G_ERROR_PREFIX || substrb(SQLERRM, 1, 2000 - lengthb(G_ERROR_PREFIX)) ,  3);
    END IF;

      ITG_MSG.text(
        G_ERROR_PREFIX||substrb(l_buff, 1, 2000 - lengthb(G_ERROR_PREFIX))); /* bug 4002567*/
  END;

  /* Public procedures. */

  PROCEDURE setup(
    p_reset     BOOLEAN  := FALSE,
    p_msg_level NUMBER   := NULL,
    p_pkg_name  VARCHAR2 := NULL,
    p_proc_name VARCHAR2 := NULL
  ) IS
  BEGIN
    IF p_reset THEN
      g_msg_level  := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
      g_pkg_name   := NULL;
      g_proc_name  := NULL;
      g_changed    := FALSE;
    END IF;
    IF p_msg_level IS NOT NULL AND
       p_msg_level >= FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW   AND
       p_msg_level <= FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR THEN
      g_msg_level := p_msg_level;
    END IF;
    IF p_pkg_name IS NOT NULL THEN
      g_pkg_name := substrb(p_pkg_name, 1, 40); /* bug 4002567*/
      g_changed  := TRUE;
    END IF;
    IF p_proc_name IS NOT NULL THEN
      g_proc_name := substrb(p_proc_name, 1, 40); /* bug 4002567*/
      g_changed  := TRUE;
    END IF;
  END setup;


  --- THIS DOES THE WORK
  --- SET CLN LOGGING to Statement.
  PROCEDURE msg(
    p_text      VARCHAR2,
    p_error     BOOLEAN  := FALSE
  ) IS

    l_err VARCHAR2(20);
  BEGIN
    IF p_error THEN
      l_err := '[ERROR] ';
    END IF;

    IF l_debug_level <= 1 THEN
	cln_debug_pub.Add('ITG Debug - ' || l_err || substrb(p_text,1,2000),  1);
    END IF;

    IF p_error THEN
	ITG_MSG.debug_more(substrb(p_text,1,2000));
    END IF;
  END;


  PROCEDURE msg(
    p_sect      VARCHAR2,
    p_text      VARCHAR2,
    p_error     BOOLEAN  := FALSE
  ) IS
  BEGIN
    msg(p_sect || ': ' || spacer(G_SECT_WIDTH - length(p_sect)) ||
        NVL(p_text, 'NULL'), p_error);
  END;

  PROCEDURE msg(
    p_sect      VARCHAR2,
    p_prompt    VARCHAR2,
    p_value     VARCHAR2,
    p_quote     BOOLEAN  := FALSE,
    p_error     BOOLEAN  := FALSE
  ) IS
    l_value     VARCHAR2(2000);
  BEGIN
    IF p_value IS NULL THEN
      l_value := 'NULL';
    ELSIF p_quote THEN
      l_value := ''''||p_value||'''';
    ELSE
      l_value := p_value;
    END IF;
    msg(p_sect,
        p_prompt||spacer(G_PROMPT_WIDTH - length(p_prompt))||' = '||l_value,
	p_error);
  END;

  PROCEDURE msg(
    p_sect      VARCHAR2,
    p_prompt    VARCHAR2,
    p_value     NUMBER,
    p_error     BOOLEAN  := FALSE
  ) IS
  BEGIN
    msg(p_sect, p_prompt, to_char(p_value), p_error);
  END;

  PROCEDURE msg(
    p_sect      VARCHAR2,
    p_prompt    VARCHAR2,
    p_value     DATE,
    p_error     BOOLEAN  := FALSE
  ) IS
  BEGIN
    msg(p_sect, p_prompt, to_char(p_value), p_error);
  END;

  PROCEDURE add_error(
    p_level     NUMBER   := FND_MSG_PUB.G_MSG_LVL_ERROR
  ) IS
  BEGIN
    IF FND_MSG_PUB.Check_Msg_Level(p_level) THEN
      error_message;
      FND_MSG_PUB.Add;
    END IF;
  END add_error;

  PROCEDURE add_exc_error(
    p_pkg_name  VARCHAR2,
    p_api_name  VARCHAR2,
    p_level     NUMBER   := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
  ) IS
  BEGIN


    IF FND_MSG_PUB.Check_Msg_Level(p_level) THEN
      ITG_MSG.text(
        G_ERROR_PREFIX||substrb(SQLERRM, 1, 2000 - lengthb(G_ERROR_PREFIX))); /* bug 4002567*/
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Build_Exc_Msg(p_pkg_name, p_api_name, 'exceptional error');
      error_message;
      FND_MSG_PUB.Add;
    END IF;
  END add_exc_error;

  PROCEDURE flush_to_logfile(
    p_dir_name  VARCHAR2 := NULL,
    p_file_name VARCHAR2 := NULL
  ) IS
    l_dir_name  VARCHAR2(500);
    l_file_name VARCHAR2(200);
    l_fh        UTL_FILE.file_type;
    l_text      VARCHAR2(2000);
    l_inxout    NUMBER;
    i           NUMBER;
  BEGIN
    IF p_dir_name IS NULL THEN
      l_dir_name := FND_PROFILE.value('CLN_DEBUG_LOG_DIRECTORY');
    ELSE
      l_dir_name := p_dir_name;
    END IF;

    IF p_file_name IS NULL THEN
      l_file_name :=
        'itg-'||lower(to_char(sysdate, 'DD-MON-YYYY-HH24-MI-SS'))||'.log';
    ELSE
      l_file_name := p_file_name;
    END IF;

    IF l_dir_name IS NOT NULL THEN
      FND_MSG_PUB.get(
	p_msg_index     => FND_MSG_PUB.G_FIRST,
	p_encoded       => FND_API.G_FALSE,
	p_data          => l_text,
	p_msg_index_out => l_inxout);
      IF l_text IS NULL THEN
	RETURN;
      END IF;
      l_fh := UTL_FILE.fopen(l_dir_name, l_file_name, 'w');
      WHILE l_text IS NOT NULL LOOP
	i := instr(l_text, ITG_Debug.G_ERROR_PREFIX);
	IF i > 0 THEN
	  l_text := substr(l_text, length(ITG_Debug.G_ERROR_PREFIX) + i);
	END IF;
	UTL_FILE.put_line(l_fh, l_text);
	FND_MSG_PUB.get(
	  p_msg_index     => FND_MSG_PUB.G_NEXT,
	  p_encoded       => FND_API.G_FALSE,
	  p_data          => l_text,
	  p_msg_index_out => l_inxout);
      END LOOP;
      UTL_FILE.fclose(l_fh);
    END IF;
    FND_MSG_PUB.Delete_Msg;
  EXCEPTION WHEN OTHERS THEN
    NULL; -- added this section to capture lower level exceptions if any. 3554249
  END flush_to_logfile;

BEGIN
	 l_debug_level           := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));
EXCEPTION
	WHEN OTHERS THEN
		NULL;
END ITG_Debug;

/
