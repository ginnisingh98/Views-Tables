--------------------------------------------------------
--  DDL for Package Body XTR_RISK_DEBUG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_RISK_DEBUG_PKG" as
/* $Header: xtrrmbgb.pls 115.14 2003/11/22 00:40:23 prafiuly ship $ */
/*==========================  risk_debug  ============================*/

/*===========================================================================

  PROCEDURE NAME: write_output (private)

  DESCRIPTION:    This procedure writes output to the requested areas

  PARAMETERS:	  p_Line IN VARCHAR2

===========================================================================*/
PROCEDURE  write_output(p_Line IN VARCHAR2)
IS

BEGIN

  IF g_sql_debug THEN
     --dbms_output.put_line(SUBSTR(p_Line, 1, 200));
     null;
  ELSE

     utl_file.put_line(g_FileHandle, SUBSTR(p_Line, 1, 1000));
     utl_file.fflush(g_FileHandle);
  END IF;

END write_output;



/*===========================================================================

  FUNCTION NAME:	make_space (private)

===========================================================================*/
FUNCTION make_space(p_Mode IN NUMBER := 0) RETURN VARCHAR2 IS

  v_Temp	VARCHAR2(500);

BEGIN

  v_Temp := RPAD(' ', 2 * (g_CallStack.COUNT - 1), ' ');

  IF p_Mode  = 0 AND g_CallStack.COUNT > 0 THEN

    v_Temp := v_Temp || '  ';
  END IF;

  v_Temp := TO_CHAR(SYSDATE,'HH24:MI:SS') || ' - ' || v_Temp;

  RETURN(v_Temp);

END make_space;


/*===========================================================================

  PROCEDURE NAME:  tstart (private)

  DESCRIPTION:     This procedure stores start time for a function

  PARAMETERS:	   p_Marker  IN VARCHAR2

===========================================================================*/
PROCEDURE  tstart(p_Marker IN VARCHAR2)
IS

  v_Context	VARCHAR2(100);
  v_Position    NUMBER := 0;

BEGIN

  IF g_Debug THEN

    FOR v_Count IN 1..g_TimeStack.COUNT LOOP

      IF g_TimeStack(v_Count).Marker = UPPER(p_Marker) THEN

        v_Position := v_Count;
        EXIT;
      END IF;

    END LOOP;

    IF v_Position = 0 THEN
      v_Position := g_TimeStack.COUNT + 1;

      g_TimeStack(v_Position).Marker    := UPPER(p_Marker);
      g_TimeStack(v_Position).TotalTime := 0;
      g_TimeStack(v_Position).CallCount := 0;
    END IF;

    g_TimeStack(v_Position).Time      := dbms_utility.get_time;
    g_TimeStack(v_Position).CallCount := g_TimeStack(v_Position).CallCount + 1;
  END IF;

END tstart;


/*===========================================================================


  PROCEDURE NAME:  tstop (private)

  DESCRIPTION:     This procedure stores elapsed time for a function

  PARAMETERS:	    p_Marker  IN VARCHAR2

===========================================================================*/
PROCEDURE  tstop(p_Marker IN VARCHAR2) IS

  v_Context	VARCHAR2(100);
  v_Position    NUMBER := 0;

BEGIN


  IF g_Debug THEN
    FOR v_Count IN 1..g_TimeStack.COUNT LOOP

      IF g_TimeStack(v_Count).Marker = UPPER(p_Marker) THEN
        g_TimeStack(v_Count).TotalTime :=
		g_TimeStack(v_Count).TotalTime + ((( dbms_utility.get_time -
                			g_TimeStack(v_Count).Time)/100));
        EXIT;
      END IF;

    END LOOP;
  END IF;

END tstop;


/*===========================================================================

  FUNCTION NAME:   tprint (private)

  DESCRIPTION:     This function prints elapsed time for a function

  PARAMETERS:	   p_Marker  IN VARCHAR2

===========================================================================*/
FUNCTION  tprint(p_Marker IN VARCHAR2) RETURN VARCHAR2 IS

  v_Context	VARCHAR2(100);
  v_Position    NUMBER := 0;

BEGIN

  IF g_Debug THEN

    FOR v_Count IN 1..g_TimeStack.COUNT LOOP

      IF g_TimeStack(v_Count).Marker = UPPER(p_Marker) THEN
        RETURN(ROUND(((dbms_utility.get_time -
			g_TimeStack(v_Count).Time) / 100), 2) || ' seconds');
      END IF;

    END LOOP;
    RETURN(NULL);

  END IF;

END tprint;



/*===========================================================================

  PROCEDURE NAME:  set_filehandle

  DESCRIPTION:     This procedure set the g_FileHandle

  PARAMETERS:	   p_FileHandle IN utl_file.file_type

===========================================================================*/
PROCEDURE set_filehandle (p_FileHandle IN utl_file.file_type := NULL) IS

BEGIN

  IF not utl_file.is_open(g_FileHandle) and
	utl_file.is_open(p_FileHandle) THEN

    g_debug := TRUE;
    g_FileHandle := p_FileHandle;
  END IF;

END set_filehandle;




/*===========================================================================

  PROCEDURE NAME:  check_fnd_profile (private)

  DESCRIPTION:     This procedure check the fnd_profile_options and
		   fnd_profile_option_values table for concurrent program
		   debugging

===========================================================================*/
FUNCTION check_fnd_profile return BOOLEAN IS

  v_value     VARCHAR2(128);
  v_path_name VARCHAR2(128);
  v_file_name VARCHAR2(128);


BEGIN
  SELECT profile_option_value
  INTO 	 v_value
  FROM	 fnd_profile_options fpo,
	 fnd_profile_option_values fpov
  WHERE  fpo.profile_option_id = fpov.profile_option_id and
	 fpo.profile_option_name = 'XTR: CONCURRENT PROGRAM DEBUG' and
	 fpov.level_value = FND_GLOBAL.USER_ID;

  IF v_value = '' or v_value is NULL THEN
     RETURN(FALSE);
  END IF;

  v_path_name  := substr(v_value, 1, instr(v_value, ' ', 1) - 1);
  v_file_name  := substr(v_value, instr(v_value, ' ', 1) + 1,
                    NVL(length(v_value), 0) - instr(v_value, ' ', 1));

  start_debug(v_path_name, v_file_name);

  RETURN(TRUE);
EXCEPTION
  WHEN OTHERS THEN
    RETURN(FALSE);

END check_fnd_profile;



/*===========================================================================

  PROCEDURE NAME:  start_debug

  DESCRIPTION:     This procedure initializes the debug session.

  PARAMETERS:	   p_file_name VARCHAR2 DEFAULT null

===========================================================================*/
PROCEDURE start_debug(p_path_name VARCHAR2,
			   p_file_name VARCHAR2) IS

  v_filename    VARCHAR2(30);

BEGIN

-- RV: Bug 3011847 --

  --Bug 3236479 Bug NULL;
  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        'xtr', 'START_DEBUG********');
  end if;

--REMCOMMENTS 115.13

END start_debug;


/*===========================================================================


  PROCEDURE NAME:  stop_debug

  DESCRIPTION:     This procedure closes the debug session.

===========================================================================*/
PROCEDURE  stop_debug IS

BEGIN

-- RV: Bug 3011847 --

  --Bug 3236479 Bug NULL;
  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        'xtr', 'STOP_DEBUG********');
  end if;

--REMCOMMENTS 115.13

END stop_debug;


/*===========================================================================

  PROCEDURE NAME: stop_conc_debug

  DESCRIPTION:    This procedure turn off the concurrent program debuging.

===========================================================================*/
PROCEDURE  stop_conc_debug IS

BEGIN

-- RV: Bug 3011847 --

  --bug 3236479
  stop_debug;

--REMCOMMENTS 115.13

END stop_conc_debug;


/*===========================================================================
   Bug 3236479

   PROCEDURE NAME:  dlog with Module and Log Level

   DESCRIPTION:     This procedure prints string followed by a string.
		    Does not require level and always prints.

   PARAMETERS:	    p_Text  IN VARCHAR2
 		    p_Value IN VARCHAR2 := NULL

===========================================================================*/
PROCEDURE  dlog(p_Text IN VARCHAR2, p_Value IN VARCHAR2 := NULL,
		p_module IN VARCHAR2 := 'xtr',
		p_log_level IN NUMBER := FND_LOG.LEVEL_PROCEDURE) IS

  v_count NUMBER;
  v_length NUMBER;
  i NUMBER;
  --the maximum characters allowed for dbms_output
  v_max NUMBER(3):=100;
  v_start NUMBER;
BEGIN

  if( p_LOG_LEVEL >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(p_log_level,
        p_module, p_Text || G_DELIMITER || p_Value );
  end if;

END dlog;


/*===========================================================================
  Bug 3236479

  PROCEDURE NAME:  dlog - Number with Module and Log Level

  DESCRIPTION:     This procedure prints string followed by a number.
		   Does not require level and always prints.

  PARAMETERS:	   p_Text  IN VARCHAR2
 		   p_Value IN NUMBER

===========================================================================*/
PROCEDURE  dlog(p_Text IN VARCHAR2, p_Value IN NUMBER,
		p_module IN VARCHAR2 := 'xtr',
		p_log_level IN NUMBER := FND_LOG.LEVEL_PROCEDURE) IS

BEGIN

  if( p_LOG_LEVEL >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(p_log_level,
        p_module, p_Text || G_DELIMITER || p_Value );
  end if;

END dlog;


/*===========================================================================
  Bug 3236479

  PROCEDURE NAME:   dlog - boolean with Module and Level Args

  DESCRIPTION:      This procedure prints string followed by a boolean
		    Does not require level and always prints.

  PARAMETERS:	    p_Text  IN VARCHAR2
 		    p_Value IN boolean
		    p_module IN VARCHAR2
		    p_log_level IN NUMBER

===========================================================================*/
PROCEDURE dlog(p_Text IN VARCHAR2, p_Value IN BOOLEAN,
		p_module IN VARCHAR2 := 'xtr',
		p_log_level IN NUMBER := FND_LOG.LEVEL_PROCEDURE) IS

  v_Temp	VARCHAR2(5) := 'FALSE';

BEGIN

  if p_Value then
      v_Temp := 'TRUE';
  end if;

  if( p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(p_log_level,
        p_module, p_Text || G_DELIMITER || v_Temp );
  end if;

END dlog;


/*===========================================================================
  Bug 3236479

  PROCEDURE NAME:  dlog - date with Module and Log Level

  DESCRIPTION:     This procedure prints string followed by a date.
		   Does not require level and always prints.

  PARAMETERS:	    p_Text  IN VARCHAR2
		    p_Value IN DATE
 		    p_Mask  IN VARCHAR2 := 'DD-MON-YYYY HH24:MI:SS'
		    p_module IN VARCHAR2
		    p_log_level IN NUMBER

===========================================================================*/
PROCEDURE  dlog(p_Text IN VARCHAR2, p_Value IN DATE,
                p_Mask IN VARCHAR2 := 'DD-MON-YYYY HH24:MI:SS',
		p_module IN VARCHAR2 := 'xtr',
		p_log_level IN NUMBER := FND_LOG.LEVEL_PROCEDURE) IS

BEGIN

  if( p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(p_log_level,
        p_module, p_Text || G_DELIMITER || TO_CHAR(p_Value, p_Mask) );
  end if;

END dlog;


/*===========================================================================
  Bug 3236479

  PROCEDURE NAME: dpush

  DESCRIPTION:    This procedure pushes a call onto the call stack

  PARAMETERS:	  p_Name IN VARCHAR2

===========================================================================*/
PROCEDURE  dpush(p_Name IN VARCHAR2,
		p_module IN VARCHAR2 := 'xtr',
		p_log_level IN NUMBER := FND_LOG.LEVEL_PROCEDURE) IS
  v_Name	VARCHAR2(80);
BEGIN

-- RV: Bug 3011847 --

  if( p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(p_log_level,
        p_module, 'Entering ' || UPPER(nvl(p_Name,p_module)));
  end if;

--REMCOMMENTS 115.13

END dpush;



/*===========================================================================
  Bug 3236479

  PROCEDURE NAME: dpop

  DESCRIPTION:    This procedure pops a call off the call stack

  PARAMETERS:	  p_Context IN	VARCHAR2

===========================================================================*/
PROCEDURE  dpop(p_Context IN VARCHAR2 := NULL,
		p_module IN VARCHAR2 := 'xtr',
		p_log_level IN NUMBER := FND_LOG.LEVEL_PROCEDURE) IS

  v_pretext	VARCHAR2(500);
  v_post_text	VARCHAR2(500);

BEGIN

-- RV: Bug 3011847 --

  if( p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(p_log_level,
        p_module, 'Exiting ' || UPPER(nvl(p_Context,p_module)));
  end if;

--REMCOMMENTS 115.13

END dpop;


/*===========================================================================

  PROCEDURE NAME: start_conc_prog

  DESCRIPTION:    This procedure check the fnd_profile_options and
		   fnd_profile_option_values table for concurrent program
		   debugging.  If the profile option is on, start the debug
		   package for concurrent programs.

===========================================================================*/
PROCEDURE start_conc_prog IS
BEGIN

-- RV: Bug 3011847 --

  --bug 3236479
  start_debug;

--REMCOMMENTS 115.13

END start_conc_prog;


END XTR_RISK_DEBUG_PKG;

/
