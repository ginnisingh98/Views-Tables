--------------------------------------------------------
--  DDL for Package Body ENG_CHANGE_TEXT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CHANGE_TEXT_UTIL" AS
/* $Header: ENGUIMTB.pls 120.3 2005/12/09 02:36:55 lkasturi noship $ */

G_PKG_NAME		CONSTANT  VARCHAR2(30)  :=  'ENG_CHANGE_TEXT_UTIL';

-- -----------------------------------------------------------------------------
--  				Private Globals
-- -----------------------------------------------------------------------------

g_Prod_Short_Name	CONSTANT  VARCHAR2(30)  :=  'ENG';
g_Prod_Schema		VARCHAR2(30);
g_Index_Owner		VARCHAR2(30);
g_Index_Name            VARCHAR2(30)    :=  'ENG_CHANGE_IMTEXT_TL_CTX1';
g_Indexing_Context	VARCHAR2(30)    :=  'SYNC_INDEX';

g_installed		BOOLEAN;
g_inst_status		VARCHAR2(1);
g_industry		VARCHAR2(1);

g_DB_Version_Num	NUMBER        :=  NULL;
g_DB_Version_Str	VARCHAR2(30)  :=  NULL;
g_compatibility		VARCHAR2(30)  :=  NULL;

g_MSTK_Flex_Delimiter	VARCHAR2(1)   :=  NULL;

--Bug 4516938
  l_DB_Version_Str        VARCHAR2(30)           :=  NULL;
  l_DB_Numeric_Character  VARCHAR2(30)           :=  NULL;
--Bug 4516938

--c_Eng_Appl_Id		CONSTANT  NUMBER        :=  703;
--c_Eng_DFF_Name		CONSTANT  VARCHAR2(30)  :=  'ENG_CHANGEMGMT_GROUP';

-- Global debug flag
g_Debug			BOOLEAN  :=  TRUE;

t_temp			NUMBER := 0;

   -- Variable used to buffer text strings before writing into LOB.
   --
   g_Buffer			VARCHAR2(32767);
   g_Buffer_Length		INTEGER;

   --
   -- Bug 4771458
   -- Initialized Exception for oracle text errors
   ORA20000_TEXT_EXCEPTION exception;
   pragma exception_init (ORA20000_TEXT_EXCEPTION, -20000);
/*
-- -----------------------------------------------------------------------------
--					Debug
-- -----------------------------------------------------------------------------

PROCEDURE Debug
(
   p_change_id     IN    NUMBER
,  p_org_id        IN    NUMBER
,  p_msg_name      IN    VARCHAR2
,  p_error_text    IN    VARCHAR2
);
*/
-- -----------------------------------------------------------------------------
--  				Set_Context
-- -----------------------------------------------------------------------------

PROCEDURE Set_Context ( p_context  IN  VARCHAR2 )
IS
BEGIN
   g_Indexing_Context := p_context;
END Set_Context;

-- -----------------------------------------------------------------------------
--				Append_VARCHAR_to_LOB
-- -----------------------------------------------------------------------------

PROCEDURE Append_VARCHAR_to_LOB
(
   x_tlob      IN OUT NOCOPY  CLOB
,  p_string    IN             VARCHAR2
,  p_action    IN             VARCHAR2  DEFAULT  'APPEND'
)
IS
   start_writing	BOOLEAN  :=  TRUE;
   l_offset		INTEGER  :=  1;
   l_Max_Length		INTEGER  :=  32767;
   l_String_Length	INTEGER;
BEGIN

   IF ( p_action = 'BEGIN' ) THEN

      -- Empty the LOB, if this is the first chunk of text to append
      DBMS_LOB.Trim ( lob_loc => x_tlob, newlen => 0 );

      g_Buffer := p_string;
      g_Buffer_Length := -1;

   ELSIF ( p_action IN ('APPEND', 'END') ) THEN

      start_writing := ( g_Buffer_Length = -1 );
      IF ( start_writing ) THEN
         g_Buffer_Length := Length (g_Buffer);
      END IF;

      l_String_Length := Length (p_string);

      -- Write buffer to LOB if required

      IF ( g_Buffer_Length + l_String_Length >= l_Max_Length ) THEN
         IF ( start_writing ) THEN
            DBMS_LOB.Write (  lob_loc  =>  x_tlob
                           ,  amount   =>  Length (g_Buffer)
                           ,  offset   =>  l_offset
                           ,  buffer   =>  g_Buffer
                           );
         ELSE
            DBMS_LOB.WriteAppend (  lob_loc  =>  x_tlob
                                 ,  amount   =>  Length (g_Buffer)
                                 ,  buffer   =>  g_Buffer
                                 );
         END IF;

         -- Reset buffer
         g_Buffer := p_string;
         g_Buffer_Length := Length (g_Buffer);
      ELSE
         g_Buffer := g_Buffer || p_string;
         g_Buffer_Length := g_Buffer_Length + l_String_Length;
      END IF;  -- Max_Length reached

      IF ( p_action = 'END' ) THEN
         start_writing := ( g_Buffer_Length = -1 );
         IF ( start_writing ) THEN
            DBMS_LOB.Write (  lob_loc  =>  x_tlob
                           ,  amount   =>  Length (g_Buffer)
                           ,  offset   =>  l_offset
                           ,  buffer   =>  g_Buffer
                           );
         ELSE
            DBMS_LOB.WriteAppend (  lob_loc  =>  x_tlob
                                 ,  amount   =>  Length (g_Buffer)
                                 ,  buffer   =>  g_Buffer
                                 );
         END IF;
         -- Reset buffer
         g_Buffer := '';
         g_Buffer_Length := -1;
      END IF;

   END IF;  -- p_action

END Append_VARCHAR_to_LOB;

-- -----------------------------------------------------------------------------
--				Get_Change_Text
-- -----------------------------------------------------------------------------

PROCEDURE Get_Change_Text
(
   p_rowid          IN             ROWID
,  p_output_type    IN             VARCHAR2
,  x_tlob           IN OUT NOCOPY  CLOB
,  x_tchar          IN OUT NOCOPY  VARCHAR2
)
IS
   l_api_name		CONSTANT    VARCHAR2(30)  :=  'Get_Change_Text';
   l_return_status	VARCHAR2(1);

   l_change_id			NUMBER;
   l_change_notice		VARCHAR2(2000);
   l_change_name		VARCHAR2(2000);
   l_org_id			NUMBER;
   l_language			VARCHAR2(4);
   l_source_lang		VARCHAR2(4);
   change_mgmt_type_code	NUMBER;


   l_text			VARCHAR2(32767);
   l_amount			BINARY_INTEGER;
   --l_buffer				VARCHAR2(32767) :=  NULL;
   --pos1				INTEGER;
   --pos2				INTEGER;



   cursor l_line_text(L_CHG_ID NUMBER,L_LANG VARCHAR2) is
   SELECT NAME , DESCRIPTION FROM  ENG_CHANGE_LINES_TL TL ,ENG_CHANGE_LINES B
   WHERE
   TL.CHANGE_LINE_ID = B.CHANGE_LINE_ID
   AND B.CHANGE_ID = L_CHG_ID
   AND TL.LANGUAGE = L_LANG;

   cursor l_actions_text(L_CHG_ID NUMBER,L_LANG VARCHAR2) is
   SELECT DESCRIPTION FROM  ENG_CHANGE_ACTIONS_TL TL ,ENG_CHANGE_ACTIONS B
   WHERE
   TL.ACTION_ID = B.ACTION_ID
   AND B.OBJECT_ID1 = L_CHG_ID
   AND B.OBJECT_NAME = 'ENG_CHANGE'
   AND TL.LANGUAGE = L_LANG
   AND DESCRIPTION IS NOT NULL;

BEGIN


   BEGIN

      SELECT  eec.change_id
      ,  eec.change_notice
      ,   eitl.LANGUAGE
      ,  eec.change_notice||' '||eec.change_name||' '||eec.description || ' ' || eec.resolution
      INTO
         l_change_id
      ,  l_change_notice
      ,  l_language
      ,  l_text
      FROM
         ENG_CHANGE_IMTEXT_TL     eitl
      ,  ENG_ENGINEERING_CHANGES  eec
      WHERE
          eitl.rowid = p_rowid
      and eitl.change_id = eec.change_id
      and eitl.language in(select language_code
      from fnd_languages
      where INSTALLED_FLAG ='B' or INSTALLED_FLAG='I');  -- use fnd_languages


   EXCEPTION
	WHEN no_data_found THEN
--		IF (g_Debug) THEN Debug(l_change_id, l_org_id, l_change_notice, '** 1: ' || SQLERRM); END IF;
		ENG_CHANGE_TEXT_PVT.Log_Line (l_api_name || ': CTX End_Log');

	WHEN others THEN
		ENG_CHANGE_TEXT_PVT.Log_Line (l_api_name || SQLERRM);

   END;
-- debug ( ' DX change_id : ' || l_change_id );
   Append_VARCHAR_to_LOB (x_tlob, ' ', 'BEGIN');


   IF ( l_language IN ('JA', 'KO', 'ZHS', 'ZHT') ) THEN
      l_text := TRANSLATE(l_text, '_*~^.$#@:|&', '----+++++++');
   END IF;
    Append_VARCHAR_to_LOB (x_tlob, l_text);


     FOR LINE_REC IN L_LINE_TEXT(L_CHANGE_ID , L_LANGUAGE)
     LOOP
      IF ( l_language IN ('JA', 'KO', 'ZHS', 'ZHT') ) THEN
        l_text := TRANSLATE(LINE_REC.NAME, '_*~^.$#@:|&', '----+++++++');
      ELSE
        l_text := LINE_REC.NAME;
      END IF;
      Append_VARCHAR_to_LOB (x_tlob, ' ');
      Append_VARCHAR_to_LOB (x_tlob, l_text);
      IF ( l_language IN ('JA', 'KO', 'ZHS', 'ZHT') ) THEN
      l_text := TRANSLATE(LINE_REC.DESCRIPTION, '_*~^.$#@:|&', '----+++++++');
      ELSE
        l_text := LINE_REC.DESCRIPTION;
       END IF;
      Append_VARCHAR_to_LOB (x_tlob, ' ');
      Append_VARCHAR_to_LOB (x_tlob, l_text);

      END LOOP;

      FOR ACTION_REC IN L_ACTIONS_TEXT(L_CHANGE_ID , L_LANGUAGE)
      LOOP

       IF ( l_language IN ('JA', 'KO', 'ZHS', 'ZHT') ) THEN
          l_text := TRANSLATE(ACTION_REC.DESCRIPTION, '_*~^.$#@:|&', '----+++++++');
       ELSE
          l_text := ACTION_REC.DESCRIPTION;
       END IF;

       Append_VARCHAR_to_LOB (x_tlob, ' ');
       Append_VARCHAR_to_LOB (x_tlob, l_text);

     END LOOP;





   Append_VARCHAR_to_LOB (x_tlob, ' ','END');

EXCEPTION

   WHEN others THEN
	NULL;

END Get_Change_Text;

/*
-- -----------------------------------------------------------------------------
--					Debug
-- -----------------------------------------------------------------------------

PROCEDURE Debug
(
   p_change_id     IN    NUMBER
,  p_org_id        IN    NUMBER
,  p_msg_name      IN    VARCHAR2
,  p_error_text    IN    VARCHAR2
)
IS
   l_sysdate       DATE  :=  SYSDATE;
BEGIN

   INSERT INTO mtl_interface_errors
   (
      transaction_id
   ,  unique_id
   ,  organization_id
   ,  table_name
   ,  message_name
   ,  error_message
   ,  creation_date
   ,  created_by
   ,  last_update_date
   ,  last_updated_by
   )
   VALUES
   (
      mtl_system_items_interface_s.NEXTVAL
   ,  p_change_id
   ,  p_org_id
   ,  'ENG_CHANGE_IMTEXT_TL'
   ,  p_msg_name
   ,  SUBSTRB(p_error_text, 1,240)
   ,  l_sysdate
   ,  1
   ,  l_sysdate
   ,  1
   );

END Debug;
*/
-- -----------------------------------------------------------------------------
--  				  Print_Lob
-- -----------------------------------------------------------------------------

PROCEDURE Print_Lob ( p_tlob_loc  IN  CLOB )
IS
   l_amount		BINARY_INTEGER    :=  255;
   l_offset		INTEGER           :=  1;
   l_offset_max		INTEGER           :=  32767;
   l_buffer		VARCHAR2(32767);
BEGIN

   --DBMS_OUTPUT.put_line('LOB contents:');

   -- Read portions of LOB
   LOOP
      DBMS_LOB.Read (  lob_loc  =>  p_tlob_loc
                    ,  amount   =>  l_amount
                    ,  offset   =>  l_offset
                    ,  buffer   =>  l_buffer
                    );

      --DBMS_OUTPUT.put_line(l_buffer);

      l_offset := l_offset + l_amount;
      EXIT WHEN l_offset > l_offset_max;
   END LOOP;

EXCEPTION
   WHEN no_data_found THEN
      NULL;

END Print_Lob;



-- -----------------------------------------------------------------------------
--  				Sync_Index
-- -----------------------------------------------------------------------------

PROCEDURE Sync_Index ( p_idx_name  IN  VARCHAR2    DEFAULT  NULL )
IS
BEGIN

   AD_CTX_DDL.Sync_Index ( idx_name  =>  NVL(g_Index_Owner || '.' || p_idx_name, g_Index_Owner ||'.'|| g_Index_Name) );

EXCEPTION
WHEN ORA20000_TEXT_EXCEPTION THEN
    --DRG-10502 index string does not exist
    --Cause: The specified index does not exist or you do not have access to it.
    --Action: Check the name of the index and your access to it.
    --As per bug 4771458, if index does not exist then do nothing.
    --throw/log the error otherwise.
    IF (INSTR(SQLERRM, 'DRG-10502') = 0)
    THEN
        ENG_CHANGE_TEXT_PVT.Log_Line ('ENG_CHANGE_TEXT_UTIL : Error in Sync Index '||SQLERRM);
    END IF;
WHEN OTHERS THEN
    ENG_CHANGE_TEXT_PVT.Log_Line ('ENG_CHANGE_TEXT_UTIL : Error in Sync Index '||SQLERRM);
END Sync_Index;

-- -----------------------------------------------------------------------------
--  				Sync_Index_For_Forms
-- -----------------------------------------------------------------------------

PROCEDURE Sync_Index_For_Forms ( p_idx_name  IN  VARCHAR2    DEFAULT  NULL )
IS
BEGIN

   EXECUTE IMMEDIATE 'ALTER INDEX ' || g_Index_Owner ||'.'|| g_Index_Name || ' REBUILD ONLINE PARAMETERS (''SYNC'')';

EXCEPTION
   WHEN others THEN
	NULL;

	ENG_CHANGE_TEXT_PVT.Log_Line ('ENG_CHANGE_TEXT_UTIL : Error in Sync_Index_For_Forms');

END Sync_Index_For_Forms;
-- -----------------------------------------------------------------------------
--  				Optimize_Index
-- -----------------------------------------------------------------------------

-- Start : Concurrent Program for Optimize iM index
PROCEDURE Optimize_Index
(
   ERRBUF      OUT NOCOPY VARCHAR2
,  RETCODE     OUT NOCOPY NUMBER
,  p_optlevel  IN         VARCHAR2 DEFAULT  AD_CTX_DDL.Optlevel_Full
,  p_dummy     IN         VARCHAR2 DEFAULT  NULL
,  p_maxtime   IN         NUMBER   DEFAULT  AD_CTX_DDL.Maxtime_Unlimited
)
IS

   Mctx        INV_ITEM_MSG.Msg_Ctx_type;
   l_api_name  CONSTANT  VARCHAR2(30)  := 'Optimize_Index';
   l_success   CONSTANT  NUMBER :=  0;
   l_error     CONSTANT  NUMBER :=  2;
   l_debug               NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   l_maxtime             NUMBER := NVL(p_maxtime,AD_CTX_DDL.Maxtime_Unlimited);

BEGIN

   IF p_optlevel ='FAST' THEN
      l_maxtime := NULL;
   END IF;

   AD_CTX_DDL.Optimize_Index ( idx_name  =>  g_Index_Owner ||'.'|| g_Index_Name
                             , optlevel  =>  NVL(p_optlevel,AD_CTX_DDL.Optlevel_Full)
                             , maxtime   =>  l_maxtime);

   RETCODE := l_success;
   ERRBUF  := FND_MESSAGE.Get_String('EGO', 'EGO_OPTIMINDEX_SUCCESS');


EXCEPTION
   WHEN OTHERS THEN
      RETCODE := l_error;
      ERRBUF  := FND_MESSAGE.Get_String('EGO', 'EGO_OPTIMINDEX_FAILURE');
      ENG_CHANGE_TEXT_PVT.Log_Line ('ENG_CHANGE_TEXT_UTIL : Error in Optimize Index for CM Text Index');

END Optimize_Index;
-- End : Concurrent Program for Optimize iM index


-- -----------------------------------------------------------------------------
--				  get_Prod_Schema
-- -----------------------------------------------------------------------------

FUNCTION get_Prod_Schema
RETURN VARCHAR2
IS
BEGIN
   RETURN (g_Prod_Schema);
END get_Prod_Schema;

-- -----------------------------------------------------------------------------
--				get_DB_Version_Num
-- -----------------------------------------------------------------------------

FUNCTION get_DB_Version_Num
RETURN NUMBER
IS
BEGIN
   RETURN (g_DB_Version_Num);
END get_DB_Version_Num;

FUNCTION get_DB_Version_Str
RETURN VARCHAR2
IS
BEGIN
   RETURN (g_DB_Version_Str);
END get_DB_Version_Str;

-- -----------------------------------------------------------------------------
--				insert_change
-- -----------------------------------------------------------------------------

PROCEDURE Insert_Update_Change
(
   p_change_id            IN  NUMBER      DEFAULT  FND_API.G_MISS_NUM
)
IS
   l_change_id		NUMBER;
   l_language		VARCHAR2(4);
   temp			VARCHAR2(500);
   l_text		VARCHAR2(1);
   cursor EEC_REC  is
   SELECT change_id,  text
   FROM ENG_CHANGE_IMTEXT_TL
   WHERE
	change_id = p_change_id;
BEGIN
   OPEN EEC_REC;
   LOOP
	FETCH EEC_REC INTO l_change_id,l_text;
	EXIT WHEN EEC_REC%NOTFOUND;
	UPDATE ENG_CHANGE_IMTEXT_TL SET TEXT = DECODE(l_text,'1','0','1') WHERE change_id = l_change_id;
--	debug ( p_change_id , 0471 , 'update','updated ' || l_text );
   END LOOP;

   IF ( EEC_REC%ROWCOUNT = 0 ) THEN
--	debug ( p_change_id , 0471 , 'create','created ' || l_text );
	INSERT INTO ENG_CHANGE_IMTEXT_TL
	(
		CHANGE_ID         ,
		LANGUAGE          ,
		TEXT 		  ,
		CREATED_BY        ,
		CREATION_DATE     ,
		LAST_UPDATED_BY   ,
		LAST_UPDATE_DATE  ,
		LAST_UPDATE_LOGIN )
		SELECT EEC.CHANGE_ID,
		  FLA.LANGUAGE_CODE,
		  TEXT,
		  EEC.CREATED_BY     ,
		  EEC.CREATION_DATE     ,
		  EEC.LAST_UPDATED_BY   ,
		  EEC.LAST_UPDATE_DATE  ,
		  EEC.LAST_UPDATE_LOGIN
		  FROM
		  (SELECT EEC.CHANGE_ID,  1 TEXT,
		  EEC.CREATED_BY     ,
		  EEC.CREATION_DATE     ,
		  EEC.LAST_UPDATED_BY   ,
		  EEC.LAST_UPDATE_DATE  ,
		  EEC.LAST_UPDATE_LOGIN FROM ENG_ENGINEERING_CHANGES EEC
		  WHERE
			CHANGE_ID = p_change_id ) EEC, FND_LANGUAGES FLA
		  WHERE FLA.INSTALLED_FLAG IN ('I','B');
   END IF;

   CLOSE EEC_REC;

   EXCEPTION
	WHEN others THEN
		BEGIN
			NULL;
			ENG_CHANGE_TEXT_PVT.Log_Line ('ENG_CHANGE_TEXT_UTIL : Error in Insert_Update_Change');
		END;

END Insert_Update_Change;

-- *****************************************************************************
-- **                      Package initialization block                       **
-- *****************************************************************************

BEGIN

   ------------------------------------------------------------------
   -- Determine index schema and store in a private global variable
   ------------------------------------------------------------------

   g_installed := FND_INSTALLATION.Get_App_Info ('ENG', g_inst_status, g_industry, g_Prod_Schema);

   g_Index_Owner := g_Prod_Schema;

   -------------------------
   -- Determine DB version
   -------------------------
  --Bug 4516938: We need to convert the db version string to be compativle with the
     --numeric characters of that language. Eg. '9.2' need to be changed to '9F2'
     -- in French before we can use it in TO_NUMBER

   DBMS_UTILITY.db_Version (g_DB_Version_Str, g_compatibility);
   l_DB_Version_Str := SUBSTR(g_DB_Version_Str, 1, INSTR(g_DB_Version_Str, '.', 1, 2) - 1);
   SELECT SUBSTR(VALUE,0,1) into l_DB_Numeric_Character
     FROM V$NLS_PARAMETERS
     Where PARAMETER = 'NLS_NUMERIC_CHARACTERS';
   g_DB_Version_Num := TO_NUMBER( REPLACE(l_DB_Version_Str, '.', l_DB_Numeric_Character) );


END ENG_CHANGE_TEXT_UTIL;

/

  GRANT EXECUTE ON "APPS"."ENG_CHANGE_TEXT_UTIL" TO "CTXSYS";
