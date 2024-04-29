--------------------------------------------------------
--  DDL for Package XTR_RISK_DEBUG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_RISK_DEBUG_PKG" AUTHID CURRENT_USER as
/* $Header: xtrrmbgs.pls 115.8 2003/11/24 20:06:26 prafiuly ship $ */


TYPE DebugLevels_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

TYPE TimeType_rec_type IS RECORD(Marker    VARCHAR2(100),
  				 Time	   NUMBER,
				 CallCount NUMBER,
				 TotalTime NUMBER);

TYPE TimeStack_table_type IS TABLE OF TimeType_rec_type
	INDEX BY BINARY_INTEGER;

TYPE CallStack_table_type IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;

g_TimeStack     TimeStack_table_type;
g_CallStack	CallStack_table_type;
g_DebugLevels 	DebugLevels_table_type;
g_Debug		BOOLEAN := TRUE; --bug 3236479 set the default to TRUE
g_sql_debug     BOOLEAN := FALSE;
g_FileHandle	utl_file.file_type := NULL;
G_DELIMITER	VARCHAR2(5) := ' ==> ';
g_debug_conc	BOOLEAN := FALSE;


--
-- PROCEDURE NAME:  start_debug
--
-- DESCRIPTION:     This procedure initializes the debug session.
--
-- PARAMETERS:	    p_file_name VARCHAR2 DEFAULT null
--
PROCEDURE start_debug(p_path_name VARCHAR2 DEFAULT NULL,
		      p_file_name VARCHAR2 DEFAULT NULL);


--
-- PROCEDURE NAME:  stop_debug
--
-- DESCRIPTION:     This procedure closes the debug session.
--
PROCEDURE stop_debug;


--
-- Bug 3236479
--
-- PROCEDURE NAME: dpush
--
-- DESCRIPTION:    This procedure pushes a call onto the call stack
--
-- PARAMETERS:	   p_Name IN VARCHAR2
--
PROCEDURE dpush(p_Name IN VARCHAR2,
		p_module IN VARCHAR2 := 'xtr',
		p_log_level IN NUMBER := FND_LOG.LEVEL_PROCEDURE);


--
-- Bug 3236479
--
-- PROCEDURE NAME: dpop
--
-- DESCRIPTION:    This procedure pops a call off the call stack
--
-- PARAMETERS:	   p_Context IN	VARCHAR2
--
PROCEDURE dpop (p_Context IN VARCHAR2 := NULL,
		p_module IN VARCHAR2 := 'xtr',
		p_log_level IN NUMBER := FND_LOG.LEVEL_PROCEDURE);



--
-- PROCEDURE NAME: start_conc_prog
--
-- DESCRIPTION:   This procedure informs debug package that the request is
--                from a concurrent program.
--
PROCEDURE start_conc_prog;


--
-- PROCEDURE NAME: stop_conc_debug
--
-- DESCRIPTION:   This procedure turn off the concurrent program debuging.
--
PROCEDURE stop_conc_debug;

--
-- PROCEDURE NAME: set_filehandle
--
-- DESCRIPTION:   This procedure turn off the concurrent program debuging.
--
PROCEDURE set_filehandle(p_FileHandle utl_file.file_type := NULL);


--
-- Bug 3236479
--
-- PROCEDURE NAME:  dlog
--
-- DESCRIPTION:     This procedure prints string followed by a number.
--		    Does not require level and always prints.
--
-- PARAMETERS:	    p_Text  IN VARCHAR2
-- 		    p_Value IN NUMBER
--
PROCEDURE dlog (p_Text  IN VARCHAR2,
		p_Value IN NUMBER,
		p_module IN VARCHAR2 := 'xtr',
		p_log_level IN NUMBER := FND_LOG.LEVEL_PROCEDURE);


--
-- Bug 3236479
--
-- PROCEDURE NAME:  dlog
--
-- DESCRIPTION:     This procedure prints string followed by a string.
--		    Does not require level and always prints.
--
-- PARAMETERS:	    p_Text  IN VARCHAR2
-- 		    p_Value IN VARCHAR2 := NULL
--
PROCEDURE dlog (p_Text  IN VARCHAR2,
		p_Value IN VARCHAR2 := NULL,
		p_module IN VARCHAR2 := 'xtr',
		p_log_level IN NUMBER := FND_LOG.LEVEL_PROCEDURE);


--
-- Bug 3236479
--
-- PROCEDURE NAME:  dlog
--
-- DESCRIPTION:     This procedure prints string followed by a date.
--		    Does not require level and always prints.
--
-- PARAMETERS:	    p_Text  IN VARCHAR2
--		    p_Value IN DATE
-- 		    p_Mask  IN VARCHAR2 := 'DD-MON-YYYY HH24:MI:SS'
--
PROCEDURE dlog (p_Text IN VARCHAR2,
		p_Value IN DATE,
                p_Mask IN VARCHAR2 := 'DD-MON-YYYY HH24:MI:SS',
		p_module IN VARCHAR2 := 'xtr',
		p_log_level IN NUMBER := FND_LOG.LEVEL_PROCEDURE);


--
-- Bug 3236479
--
-- PROCEDURE NAME:  dlog
--
-- DESCRIPTION:     This procedure prints string followed by a boolean
--		    Does not require level and always prints.
--
-- PARAMETERS:	    p_Text  IN VARCHAR2
-- 		    p_Value IN boolean
--
PROCEDURE dlog (p_Text  IN VARCHAR2,
		p_Value IN BOOLEAN,
		p_module IN VARCHAR2 := 'xtr',
		p_log_level IN NUMBER := FND_LOG.LEVEL_PROCEDURE);




END XTR_RISK_DEBUG_PKG;

 

/
