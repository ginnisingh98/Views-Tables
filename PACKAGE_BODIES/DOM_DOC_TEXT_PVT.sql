--------------------------------------------------------
--  DDL for Package Body DOM_DOC_TEXT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DOM_DOC_TEXT_PVT" AS
/* $Header: DOMVIDXB.pls 120.0 2006/04/05 06:06:11 dedatta noship $ */

G_PKG_NAME	CONSTANT  VARCHAR2(30)  :=  'DOM_TEXT_PVT';

-- -----------------------------------------------------------------------------
--  				Private Globals
-- -----------------------------------------------------------------------------

g_Ctx_Schema		CONSTANT  VARCHAR2(30)  :=  'CTXSYS';
--g_Apps_Schema		VARCHAR2(30);
g_Prod_Schema			VARCHAR2(30);
g_Index_Owner			VARCHAR2(30);
g_Pref_Owner			VARCHAR2(30);

g_installed		BOOLEAN;
g_inst_status		VARCHAR2(1);
g_industry		VARCHAR2(1);

--g_Debug		VARCHAR2(1)  :=  NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');
--g_debug		NUMBER  :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);

-- Log mode
g_Log_Mode		VARCHAR2(30)  :=  NULL;
g_Conc_Req_flag		BOOLEAN  :=  TRUE;
g_Log_Sqlplus_Flag	BOOLEAN  :=  FALSE;
g_Log_File_Flag		BOOLEAN  :=  TRUE;
g_Log_Dbdrv_Flag	BOOLEAN  :=  FALSE;

g_Msg_Text		VARCHAR2(1000);

-- Log directory
g_Log_Dir		v$parameter.value%TYPE;
g_Dump_Dir		v$parameter.value%TYPE;

-- Log files for Sqlplus
g_Log_File		VARCHAR2(30)  :=  'dom_doc_text_tl_srs.log';
g_Out_File		VARCHAR2(30)  :=  'dom_doc_text_tl_srs.out';

-- -----------------------------------------------------------------------------
--				  Log_Line
-- -----------------------------------------------------------------------------

PROCEDURE Log_Line ( p_Buffer  IN  VARCHAR2 )
IS
BEGIN
   IF ( g_Log_File_Flag ) THEN
      FOR l IN 0 .. ( FLOOR( (NVL(LENGTH(p_Buffer),0) - 1)/240 ) ) LOOP
         FND_FILE.Put_Line (FND_FILE.Log, SUBSTRB(p_Buffer, l*240 + 1, 240));
      END LOOP;
   END IF;

   IF ( g_Log_Sqlplus_Flag ) THEN
      FOR l IN 0 .. ( FLOOR( (NVL(LENGTH(p_Buffer),0) - 1)/255 ) ) LOOP
         --DBMS_OUTPUT.Put_Line( SUBSTR(p_Buffer, l*255 + 1, 255) );
         NULL;
      END LOOP;
   END IF;

   IF ( g_Log_Dbdrv_Flag ) THEN
      --IF ( (INSTR(p_Buffer, 'Error:') + INSTR(p_Buffer, 'Warning:')) > 0 ) THEN
      IF (    ( INSTR(p_Buffer, 'Error:') > 0 )
           OR ( INSTR(p_Buffer, 'Warning:') > 0 )
           OR ( INSTR(p_Buffer, 'Executing:') > 0 )
           OR ( INSTR(p_Buffer, 'Done.') > 0 )
           OR ( INSTR(p_Buffer, 'Upgrade:') > 0 ) )
      THEN
         g_Msg_Text := g_Msg_Text || SUBSTRB(p_Buffer, 1, 255) || FND_GLOBAL.Newline;
      END IF;
   END IF;

EXCEPTION

	WHEN others THEN
		NULL;

END Log_Line;

PROCEDURE Out_Line ( p_Buffer  IN  VARCHAR2 )
IS
BEGIN
   IF ( g_Log_File_Flag ) THEN
      FOR l IN 0 .. ( FLOOR( (NVL(LENGTH(p_Buffer),0) - 1)/240 ) ) LOOP
         FND_FILE.Put_Line (FND_FILE.Log, SUBSTRB(p_Buffer, l*240 + 1, 240));
      END LOOP;
   END IF;

   IF ( g_Log_Sqlplus_Flag ) THEN
      FOR l IN 0 .. ( FLOOR( (NVL(LENGTH(p_Buffer),0) - 1)/255 ) ) LOOP
         --DBMS_OUTPUT.Put_Line( SUBSTR(p_Buffer, l*255 + 1, 255) );
         NULL;
      END LOOP;
   END IF;

   IF ( g_Log_Dbdrv_Flag ) THEN
      IF ( INSTR(p_Buffer, 'Completed ') > 0 ) THEN
         g_Msg_Text := g_Msg_Text || SUBSTRB(p_Buffer, 1, 255) || FND_GLOBAL.Newline;
      END IF;
   END IF;
END Out_Line;

-- -----------------------------------------------------------------------------
--				  set_Log_Mode
-- -----------------------------------------------------------------------------

FUNCTION set_Log_Mode ( p_Mode  IN  VARCHAR2 )
RETURN VARCHAR2
IS
   l_api_name		CONSTANT  VARCHAR2(30)  :=  'set_Log_Mode';
BEGIN
   g_Log_Mode := p_Mode;

   g_Log_Sqlplus_Flag := ( INSTR(g_Log_Mode, 'SQLPLUS') > 0 );
   g_Log_File_Flag    := ( (INSTR(g_Log_Mode, 'FILE') + INSTR(g_Log_Mode, 'SRS')) > 0 );
   g_Log_Dbdrv_Flag   := ( INSTR(g_Log_Mode, 'DBDRV') > 0 );

   g_Msg_Text := NULL;

   -- Determine log directory

   BEGIN
      SELECT value INTO g_Dump_Dir
      FROM v$parameter WHERE name = 'user_dump_dest';

      SELECT TRANSLATE(LTRIM(value), ',', ' ') INTO g_Log_Dir
      FROM v$parameter
      WHERE name = 'utl_file_dir';

      IF ( g_Log_Dir IS NOT NULL ) THEN
         IF ( INSTR(g_Log_Dir, ' ') > 0 ) THEN
            g_Log_Dir := SUBSTRB(g_Log_Dir, 1, INSTR(g_Log_Dir,' ')-1);
         END IF;
      END IF;

   --EXCEPTION
   --   WHEN others THEN
   --      Log_Line ('Error determining CTX log directory: ' || SQLERRM);
   END;

   IF ( NVL(FND_GLOBAL.CONC_REQUEST_ID,-1) < 0 ) THEN
      g_Conc_Req_flag := FALSE;
      FND_FILE.Put_Names (g_Log_File, g_Out_File, g_Log_Dir);
      Log_Line (l_api_name || ': standalone execution');
   ELSE
      Log_Line (l_api_name || ': concurrent request');
   END IF;

   Log_Line (l_api_name || ': log mode: ' || g_Log_Mode);
   Log_Line (l_api_name || ': dump directory: ' || g_Dump_Dir);
   Log_Line (l_api_name || ': CTX log directory: ' || g_Log_Dir);

   RETURN (NULL);

END set_Log_Mode;

PROCEDURE set_Log_Mode ( p_Mode  IN  VARCHAR2 )
IS
   l_output_name	VARCHAR2(255);
BEGIN
   l_output_name := set_Log_Mode (p_Mode);
END set_Log_Mode;

-- -----------------------------------------------------------------------------
--			  Process_Index_Preferences
-- -----------------------------------------------------------------------------

PROCEDURE Process_Index_Preferences
(
   p_Index_Name		IN           VARCHAR2
,  x_return_status	OUT  NOCOPY  VARCHAR2
)
IS
   l_api_name		CONSTANT  VARCHAR2(30)  :=  'Process_Index_Preferences';
   l_return_status		VARCHAR2(1);

   tspace_tbl_param		VARCHAR2(256);
   tspace_idx_param		VARCHAR2(256);

   Lang_Code			VARCHAR2(4);
   Lexer_Name			VARCHAR2(30);

   TYPE Lang_Code_List_type  IS TABLE OF VARCHAR2(4);
   --TYPE Lang_ISO_List_type   IS TABLE OF VARCHAR2(2);

   Lang_Code_List    Lang_Code_List_type := Lang_Code_List_type
                     ( 'US', 'GB', 'NL', 'D', 'DK', 'S', 'N',
                       'F', 'I', 'E', 'ESA', 'EL',
                       'JA', 'KO', 'ZHS', 'ZHT' );

   --Lang_ISO_List     Lang_ISO_List_type :=
   --                  Lang_ISO_List_type ('EN', '', 'DE', 'SV', 'NO', 'FR', '', '');

BEGIN
   Log_Line (l_api_name || ': begin');

   l_return_status := G_STATUS_SUCCESS;
   ------------------------------
   -- Drop existing preferences
   ------------------------------

   Log_Line (l_api_name || ': dropping all existing preferences ...');

   FOR multi_lexer_rec IN	( SELECT pre_owner, pre_name
                         	  FROM ctxsys.ctx_preferences
                         	  WHERE pre_name = 'DOM_DOC_MULTI_LEXER' )
   LOOP
      ad_ctx_ddl.drop_preference (multi_lexer_rec.pre_owner ||'.'|| multi_lexer_rec.pre_name);
   END LOOP;

   FOR sub_lexer_rec IN		( SELECT pre_owner, pre_name
                       		  FROM ctxsys.ctx_preferences
                       		  WHERE pre_name LIKE 'DOM_DOC_LEXER%' )
   LOOP
      ad_ctx_ddl.drop_preference (sub_lexer_rec.pre_owner ||'.'|| sub_lexer_rec.pre_name);
   END LOOP;

   FOR wordlist_rec IN		( SELECT pre_owner, pre_name
                       		  FROM ctxsys.ctx_preferences
                       		  WHERE pre_name = 'DOM_DOC_WORDLIST' )
   LOOP
      ad_ctx_ddl.drop_preference (wordlist_rec.pre_owner ||'.'|| wordlist_rec.pre_name);
   END LOOP;

   FOR stoplist_rec IN		( SELECT spl_owner, spl_name
                       		  FROM ctxsys.ctx_stoplists
                       		  WHERE spl_name = 'DOM_DOC_STOPLIST' )
   LOOP
      ad_ctx_ddl.Drop_Stoplist (stoplist_rec.spl_owner || '.DOM_DOC_STOPLIST');
   END LOOP;

   FOR section_group_rec IN	( SELECT sgp_owner, sgp_name
                       		  FROM ctxsys.ctx_section_groups
                       		  WHERE sgp_name = 'DOM_DOC_SECTION_GROUP' )
   LOOP
      ad_ctx_ddl.Drop_Section_Group (section_group_rec.sgp_owner ||'.'|| section_group_rec.sgp_name);
   END LOOP;

   FOR datastore_rec IN		( SELECT pre_owner, pre_name
                       		  FROM ctxsys.ctx_preferences
                       		  WHERE pre_name = 'DOM_DOC_DATASTORE' )
   LOOP
      ad_ctx_ddl.drop_preference (datastore_rec.pre_owner ||'.'|| datastore_rec.pre_name);
   END LOOP;

   FOR storage_rec IN		( SELECT pre_owner, pre_name
                       		  FROM ctxsys.ctx_preferences
                       		  WHERE pre_name = 'DOM_DOC_STORAGE' )
   LOOP
      ad_ctx_ddl.drop_preference (storage_rec.pre_owner ||'.'|| storage_rec.pre_name);
   END LOOP;

   ------------------------------
   -- Create STORAGE preference
   ------------------------------

   -- Index tables use the same tablespaces used by other  tables and indexes
   -- or use logical tablespace for indexes (TRANSACTION_INDEXES).

   Log_Line (l_api_name || ': querying tablespace parameters ...');

   SELECT 'tablespace ' || tablespace_name ||
          ' storage (initial 1M next 1M minextents 1 maxextents unlimited pctincrease 0)'
     INTO tspace_tbl_param
   FROM all_tables
   WHERE owner = g_Prod_Schema AND table_name = 'DOM_DOCUMENTS_IMTEXT_TL';


   SELECT 'tablespace ' || tablespace_name ||
          ' storage (initial 1M next 1M minextents 1 maxextents unlimited pctincrease 0)'
     INTO tspace_idx_param
   FROM all_indexes
   WHERE owner = g_Prod_Schema
     AND index_name = 'DOM_DOCUMENTS_IMTEXT_TL_U1'
     AND table_name = 'DOM_DOCUMENTS_IMTEXT_TL';


   Log_Line (l_api_name || ': creating STORAGE preference ...');

   ad_ctx_ddl.create_preference (g_Pref_Owner || '.DOM_DOC_STORAGE', 'BASIC_STORAGE');

   ad_ctx_ddl.set_attribute (g_Pref_Owner || '.DOM_DOC_STORAGE',
                             'I_TABLE_CLAUSE', tspace_tbl_param);

   ad_ctx_ddl.set_attribute (g_Pref_Owner || '.DOM_DOC_STORAGE',
                             'K_TABLE_CLAUSE', tspace_tbl_param);

   ad_ctx_ddl.set_attribute (g_Pref_Owner || '.DOM_DOC_STORAGE',
                             'R_TABLE_CLAUSE', tspace_tbl_param || ' LOB (data) STORE AS (CACHE)');

   -- Caching the "data" LOB column is the default (at later versions of Oracle Text).
   -- For index specific STORAGE preference, setting the clause "lob (data) (cache reads)"
   -- should be ensured (the "lob .. store as" clause is only for newly added LOB columns).
   --alter table dr$prd_ctx_index$r modify lob (data) (cache reads);

   ad_ctx_ddl.set_attribute (g_Pref_Owner || '.DOM_DOC_STORAGE',
                             'N_TABLE_CLAUSE', tspace_tbl_param);

   ad_ctx_ddl.set_attribute (g_Pref_Owner || '.DOM_DOC_STORAGE',
                             'P_TABLE_CLAUSE', tspace_tbl_param);

   ad_ctx_ddl.set_attribute (g_Pref_Owner || '.DOM_DOC_STORAGE',
                             'I_INDEX_CLAUSE', tspace_idx_param || ' COMPRESS 2');

   --ad_ctx_ddl.set_attribute (g_Pref_Owner || '.DOM_DOC_STORAGE',
   --                          'I_ROWID_INDEX_CLAUSE', tspace_idx_param);

   --------------------------------
   -- Create DATASTORE preference
   --------------------------------

   Log_Line (l_api_name || ': creating DATASTORE preference ...');

   ad_ctx_ddl.Create_Preference (g_Pref_Owner || '.DOM_DOC_DATASTORE', 'USER_DATASTORE');


   /* Commented by Gopi as CLOB output is not required for DOM module*/
   --ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.DOM_DOC_DATASTORE', 'OUTPUT_TYPE', 'CLOB');
   --ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.DOM_DOC_DATASTORE', 'PROCEDURE', '"DOM_DOC_TEXT_CTX_PKG"."Get_Dom_Text_CLOB"');

   /* Unommented by Gopi as varchar output is required for DOM module*/
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.DOM_DOC_DATASTORE', 'OUTPUT_TYPE', 'VARCHAR2');
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.DOM_DOC_DATASTORE', 'PROCEDURE', '"DOM_DOC_TEXT_CTX_PKG"."Get_Doc_Text_VARCHAR2"');
   ------------------------------------
   -- Create SECTION GROUP preference
   ------------------------------------

   --Log_Line (l_api_name || ': creating SECTION_GROUP preference ...');

   --ad_ctx_ddl.Create_Section_Group (g_Pref_Owner || '.DOM_DOC_STOPLIST', 'AUTO_SECTION_GROUP');

   -------------------------------
   -- Create STOPLIST preference
   -------------------------------

   Log_Line (l_api_name || ': creating STOPLIST preference ...');

   -- This should create stoplist equivalent to CTXSYS.EMPTY_STOPLIST
   ad_ctx_ddl.Create_Stoplist (g_Pref_Owner || '.DOM_DOC_STOPLIST');

   -------------------------------
   -- Create WORDLIST preference
   -------------------------------

   Log_Line (l_api_name || ': creating WORDLIST preference ...');

   ad_ctx_ddl.Create_Preference (g_Pref_Owner || '.DOM_DOC_WORDLIST', 'BASIC_WORDLIST');

   -- Enable prefix indexing to improve performance for wildcard searches
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.DOM_DOC_WORDLIST', 'PREFIX_INDEX', 'TRUE');
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.DOM_DOC_WORDLIST', 'PREFIX_MIN_LENGTH', 2);
   --ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.DOM_DOC_WORDLIST', 'PREFIX_LENGTH_MIN', 2);
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.DOM_DOC_WORDLIST', 'PREFIX_MAX_LENGTH', 32);
   --ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.DOM_DOC_WORDLIST', 'PREFIX_LENGTH_MAX', 32);
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.DOM_DOC_WORDLIST', 'WILDCARD_MAXTERMS', 5000);

   -- This option should be TRUE only when left-truncated wildcard searching is expected
   -- to be frequent and needs to be fast (at the cost of increased index time and space).
   --
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.DOM_DOC_WORDLIST', 'SUBSTRING_INDEX', 'FALSE');

   -- WORDLIST attribute defaults: STEMMER: 'ENGLISH'; FUZZY_MATCH: 'GENERIC'
   -- Use automatic language detection for stemming and fuzzy matching
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.DOM_DOC_WORDLIST', 'STEMMER', 'AUTO');
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.DOM_DOC_WORDLIST', 'FUZZY_MATCH', 'AUTO');
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.DOM_DOC_WORDLIST', 'FUZZY_SCORE', 40);
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.DOM_DOC_WORDLIST', 'FUZZY_NUMRESULTS', 120);

   -----------------------------------------------
   -- Create language-specific LEXER preferences
   -----------------------------------------------

   Log_Line (l_api_name || ': creating language-specific LEXER preferences ...');

   FOR i IN Lang_Code_List.FIRST .. Lang_Code_List.LAST
   LOOP
      Lexer_Name := g_Pref_Owner || '.DOM_DOC_LEXER_' || Lang_Code_List(i);

      IF ( Lang_Code_List(i) = 'JA' ) THEN

         -- Use JAPANESE_LEXER if db charset is UTF8, JA16SJIS, or JA16EUC.
         IF ( DOM_DOC_TEXT_UTIL.get_DB_Version_Num >= 9.0 ) THEN
            ad_ctx_ddl.Create_Preference (Lexer_Name, 'JAPANESE_LEXER');
         ELSE
            ad_ctx_ddl.Create_Preference (Lexer_Name, 'JAPANESE_VGRAM_LEXER');
         END IF;

      ELSIF ( Lang_Code_List(i) = 'KO' ) THEN

         -- Use KOREAN_MORPH_LEXER if db charset is UTF8 or KO16KSC5601.
         IF ( DOM_DOC_TEXT_UTIL.get_DB_Version_Num >= 9.0 ) THEN
            ad_ctx_ddl.Create_Preference (Lexer_Name, 'KOREAN_MORPH_LEXER');
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'VERB_ADJECTIVE', 'TRUE');
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'ONE_CHAR_WORD', 'TRUE');
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'NUMBER', 'TRUE');
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'COMPOSITE', 'NGRAM');
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'MORPHEME', 'TRUE');
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'HANJA', 'FALSE');
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'LONG_WORD', 'TRUE');
            --ad_ctx_ddl.Set_Attribute (Lexer_Name, 'JAPANESE', 'FALSE');
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'ENGLISH', 'TRUE');
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'TO_UPPER', 'TRUE');
         ELSE

            ad_ctx_ddl.Create_Preference (Lexer_Name, 'KOREAN_LEXER');
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'VERB', 'TRUE');
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'ADJECTIVE', 'TRUE');
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'ADVERB', 'TRUE');
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'ONECHAR', 'TRUE');
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'NUMBER', 'TRUE');
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'COMPOSITE', 'TRUE');
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'MORPHEME', 'TRUE');
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'TOHANGEUL', 'TRUE');
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'TOUPPER', 'TRUE');
         END IF;

      ELSIF ( Lang_Code_List(i) IN ('ZHS', 'ZHT') ) THEN

         IF ( DOM_DOC_TEXT_UTIL.get_DB_Version_Num >= 9.2 ) THEN
            ad_ctx_ddl.Create_Preference (Lexer_Name, 'CHINESE_LEXER');
         ELSE
            ad_ctx_ddl.Create_Preference (Lexer_Name, 'CHINESE_VGRAM_LEXER');
         END IF;

      ELSE
         -- All other languages use basic lexer.

         ad_ctx_ddl.Create_Preference (Lexer_Name, 'BASIC_LEXER');

         -- The following language-independent attributes are
         -- common to the BASIC_LEXER preference object.

         ad_ctx_ddl.Set_Attribute (Lexer_Name, 'INDEX_TEXT', 'YES');
         ad_ctx_ddl.Set_Attribute (Lexer_Name, 'INDEX_THEMES', 'NO');

         -- For printjoin characters include all possible flex segment separators
         ad_ctx_ddl.Set_Attribute (Lexer_Name, 'PRINTJOINS', '-_*~^+.$#@:|&');
         ad_ctx_ddl.Set_Attribute (Lexer_Name, 'CONTINUATION', '-\');
         ad_ctx_ddl.Set_Attribute (Lexer_Name, 'PUNCTUATIONS', '.?!');

         -- The default values for numjoin and numgroup are determined by
         -- the NLS initialization parameters that are specified for the database.
         --ad_ctx_ddl.Set_Attribute (Lexer_Name, 'NUMGROUP', ',');
         --ad_ctx_ddl.Set_Attribute (Lexer_Name, 'NUMJOIN', '.');

         -- Stem indexing stems tokens at indexing time to a single base form in addition
         -- to the normal forms. This enables better query performance for stem ($) queries.

         -- Disable stem indexing to improve index creation performance.
         -- This would not affect stem expansion (with $) at query time.
         --
         --IF ( DOM_DOC_TEXT_UTIL.get_DB_Version_Num >= 9.2 ) THEN
         --   IF ( Lang_Code_List(i) IN ('US', 'GB') ) THEN
         --      ad_ctx_ddl.Set_Attribute (Lexer_Name, 'INDEX_STEMS', 'ENGLISH');
         --   ELSIF ( Lang_Code_List(i) = 'NL' ) THEN
         --      ad_ctx_ddl.Set_Attribute (Lexer_Name, 'INDEX_STEMS', 'DUTCH');
         --   ELSIF ( Lang_Code_List(i) = 'D' ) THEN
         --      ad_ctx_ddl.Set_Attribute (Lexer_Name, 'INDEX_STEMS', 'GERMAN');
         --   ELSIF ( Lang_Code_List(i) = 'F' ) THEN
         --      ad_ctx_ddl.Set_Attribute (Lexer_Name, 'INDEX_STEMS', 'FRENCH');
         --   ELSIF ( Lang_Code_List(i) = 'I' ) THEN
         --      ad_ctx_ddl.Set_Attribute (Lexer_Name, 'INDEX_STEMS', 'ITALIAN');
         --   ELSIF ( Lang_Code_List(i) IN ('E', 'ESA') ) THEN
         --      ad_ctx_ddl.Set_Attribute (Lexer_Name, 'INDEX_STEMS', 'SPANISH');
         --   END IF;
         --END IF;

         -- Language-specific attribute values for BASIC_LEXER preference object

         IF ( Lang_Code_List(i) = 'NL' ) THEN
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'COMPOSITE', 'DUTCH');

         ELSIF ( Lang_Code_List(i) = 'D' ) THEN
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'COMPOSITE', 'GERMAN');
            -- Basic lexer in 8.1.7 allows the MIXED_CASE to be FALSE when COMPOSITE is set.
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'MIXED_CASE', 'NO');
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'ALTERNATE_SPELLING', 'GERMAN');

         ELSIF ( Lang_Code_List(i) = 'DK' ) THEN
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'ALTERNATE_SPELLING', 'DANISH');

         ELSIF ( Lang_Code_List(i) = 'S' ) THEN
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'ALTERNATE_SPELLING', 'SWEDISH');

         ELSIF ( Lang_Code_List(i) = 'N' ) THEN
            -- Both Norwegian and Danish use the same special characters that are
            -- rendered alternatively as "aa", "ae", and "oe".
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'ALTERNATE_SPELLING', 'DANISH');

         ELSIF ( Lang_Code_List(i) = 'F' ) THEN
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'BASE_LETTER', 'YES');

         ELSE
            ad_ctx_ddl.Set_Attribute (Lexer_Name, 'ALTERNATE_SPELLING', 'NONE');

         END IF;
      END IF;

   END LOOP;  -- Lang_Code_List

   ----------------------------------
   -- Create MULTI_LEXER preference
   ----------------------------------

   Log_Line (l_api_name || ': creating MULTI_LEXER preference ...');

   ad_ctx_ddl.Create_Preference (g_Pref_Owner || '.DOM_DOC_MULTI_LEXER', 'MULTI_LEXER');

   FOR i IN Lang_Code_List.FIRST .. Lang_Code_List.LAST
   LOOP
      Lexer_Name := g_Pref_Owner || '.DOM_DOC_LEXER_' || Lang_Code_List(i);

      -- The language column is case-independent, and can contain either the NLS name
      -- or abbreviation of the language.  If the table uses some other value for the
      -- language, that alternate value needs to be specified as the fourth argument
      -- when adding the sub lexers:

      IF ( Lang_Code_List(i) = 'US' ) THEN
         -- US English lexer to handle everything else.
         ad_ctx_ddl.Add_Sub_Lexer ( g_Pref_Owner || '.DOM_DOC_MULTI_LEXER', 'DEFAULT'
                                  , g_Pref_Owner || '.DOM_DOC_LEXER_US' );
      ELSE
         ad_ctx_ddl.Add_Sub_Lexer
         (  lexer_name    =>  g_Pref_Owner || '.DOM_DOC_MULTI_LEXER'
         ,  language      =>  Lang_Code_List(i)
         ,  sub_lexer     =>  Lexer_Name
         --,  alt_value     =>  Lang_ISO_List(i)
         );
      END IF;

   END LOOP;

   x_return_status := l_return_status;

   Log_Line (l_api_name || ': end');

EXCEPTION

   WHEN G_EXC_ERROR THEN
      x_return_status := G_STATUS_ERROR;

   WHEN others THEN

      Log_Line (l_api_name || ': Error: ' || SQLERRM);
      x_return_status := G_STATUS_UNEXP_ERROR;


END Process_Index_Preferences;

-- -----------------------------------------------------------------------------
--			   Process_Doc_Text_Index
-- -----------------------------------------------------------------------------

PROCEDURE Process_Doc_Text_Index
(
   p_Index_Name		IN           VARCHAR2
,  p_Action		IN           VARCHAR2
,  x_return_status	OUT  NOCOPY  CLOB
)
IS
   l_api_name		CONSTANT  VARCHAR2(30)  :=  'Process_Doc_Text_Index';
   l_return_status		VARCHAR2(1);
   ctx_Log_File_Name		VARCHAR2(512)   :=  NULL;

   l_index_exists		BOOLEAN         :=  FALSE;
   l_index_valid		BOOLEAN         :=  TRUE;

   l_create_index		BOOLEAN         :=  TRUE;
   l_drop_index			BOOLEAN         :=  FALSE;

   l_rows_processed		INTEGER;

   -- Limit the indexing memory in case the default parameter max value is higher.
   --l_Index_Memory		ctx_parameters.par_value%TYPE  :=  '67108864'; -- '64M'
   l_Index_Memory		ctx_parameters.par_value%TYPE  :=  '134217728'; -- '128M'
   l_Index_Memory_Max		ctx_parameters.par_value%TYPE;

   l_idx_docid_count		NUMBER;
   l_idx_status			VARCHAR2(256);

   l_index_populate		VARCHAR2(30)    :=  'POPULATE';

   -- Use parallel indexing when this issue is resolved
   c_parallel_clause	CONSTANT  VARCHAR2(30)  :=  'PARALLEL 4';
   --c_parallel_clause	CONSTANT  VARCHAR2(30)  :=  NULL;

   l_index_parallel		VARCHAR2(30)    :=  NULL;
   l_error_text VARCHAR2 (550) := 'ERROR:';
   sql_stmt			VARCHAR2(32767);
BEGIN

   Log_Line (l_api_name || ': begin: Index_Name=' || p_Index_Name || ' Action=' || p_Action);

   l_return_status := G_STATUS_SUCCESS;

   IF ( p_Action NOT IN ('CREATE', 'REBUILD', 'UPGRADE', 'DROP') ) THEN
      Log_Line (l_api_name || ': Error: invalid value for parameter p_Action: ' || p_Action);
      RAISE G_EXC_ERROR;
   END IF;

   -- Check for existing indexes in the DOM product, APPS Universal, and interMedia schemas.
   --
   FOR index_rec IN ( SELECT owner, index_name, status, domidx_status, domidx_opstatus
                      FROM all_indexes
                      WHERE ( owner = g_Prod_Schema OR owner = USER OR owner = g_Ctx_Schema )
                        AND table_name = 'DOM_DOCUMENTS_IMTEXT_TL'
                        AND index_name = p_Index_Name )
   LOOP
      -- Check index schema
      --

      IF ( index_rec.owner <> g_Index_Owner )
      THEN
         Log_Line (l_api_name || ': Error: index exists in wrong schema: ' || index_rec.owner);
         BEGIN
            Log_Line (l_api_name || ': dropping index: ' || index_rec.owner || '.' || p_Index_Name);
            EXECUTE IMMEDIATE 'DROP INDEX ' || index_rec.owner || '.' || p_Index_Name || ' FORCE';
         EXCEPTION
            WHEN others THEN
               Log_Line (l_api_name || ': Error: DROP INDEX ' || index_rec.owner || '.' || p_Index_Name || ' FORCE: ' || SQLERRM);
               l_return_status := G_STATUS_ERROR;
         END;

      ELSE
         l_index_exists := TRUE;

         -- Check status of an existing index, if any.
         --
         IF ( (NVL(index_rec.status, 'FAILED') <> 'VALID') OR
              (NVL(index_rec.domidx_status, 'FAILED') <> 'VALID') OR
              (NVL(index_rec.domidx_opstatus, 'FAILED') <> 'VALID') )
         THEN
            l_index_valid := FALSE;
            Log_Line (l_api_name || ': Warning: existing index status is invalid:'
                      || ' status=' || index_rec.status
                      || ' domidx_status=' || index_rec.domidx_status
                      || ' domidx_opstatus=' || index_rec.domidx_opstatus);
         ELSE
            Log_Line (l_api_name || ': valid index exists: ' || index_rec.owner || '.' || p_Index_Name);
         END IF;

      END IF;  -- index owner

   END LOOP;  -- check for any existing indexes

   IF ( l_return_status NOT IN (G_STATUS_SUCCESS, G_STATUS_WARNING) ) THEN
      RAISE G_EXC_ERROR;
   END IF;

   --   x_return_status := l_return_status;

   -- Set indexing flags depending on the action and the index status

   IF ( p_Action = 'CREATE' ) THEN
      IF ( l_index_exists ) THEN
         IF ( l_index_valid ) THEN
            Log_Line (l_api_name || ': Error: cannot execute ' || p_Action || ' because the index exists.');
            RAISE G_EXC_ERROR;
         ELSE
            l_drop_index := TRUE;
         END IF;
      END IF;

   ELSIF ( p_Action = 'REBUILD' ) THEN
      l_drop_index := l_index_exists;

   ELSIF ( p_Action = 'UPGRADE' ) THEN
      IF ( l_index_exists ) THEN
         IF ( l_index_valid ) THEN
            Log_Line (l_api_name || ': Upgrade: skipping index creation because valid index exists.');
            l_create_index := FALSE;
         ELSE
            l_drop_index := TRUE;
         END IF;
      END IF;

   ELSIF ( p_Action = 'DROP' ) THEN
      l_create_index := FALSE;
      IF ( l_index_exists ) THEN
         l_drop_index := TRUE;
      ELSE
         Log_Line (l_api_name || ': Warning: cannot execute ' || p_Action || ' because the index does not exist.');
         l_return_status := G_STATUS_WARNING;
      END IF;

   END IF;  -- Action


   IF ( l_drop_index ) THEN
      BEGIN
         Log_Line (l_api_name || ': dropping index: ' || g_Index_Owner || '.' || p_Index_Name);
         EXECUTE IMMEDIATE 'DROP INDEX ' || g_Index_Owner || '.' || p_Index_Name || ' FORCE';
         IF ( l_index_valid ) THEN
            Log_Line (l_api_name || ': existing index has been successfully dropped.');
            Out_Line ('Existing index has been successfully dropped: ' || g_Index_Owner || '.' || p_Index_Name);
         ELSE
            Log_Line (l_api_name || ': invalid index has been dropped.');
            Out_Line ('Invalid index has been dropped: ' || g_Index_Owner || '.' || p_Index_Name);
         END IF;
      EXCEPTION
         WHEN others THEN
            Log_Line (l_api_name || ': Error: DROP INDEX ' || g_Index_Owner || '.' || p_Index_Name || ' FORCE: ' || SQLERRM);
            l_return_status := G_STATUS_ERROR;
      END;
   END IF;  -- drop index

   IF ( l_return_status NOT IN (G_STATUS_SUCCESS, G_STATUS_WARNING) ) THEN
      RAISE G_EXC_ERROR;
   END IF;

   -- Build index

   IF ( l_create_index ) THEN

      -- Determine index memory parameter value
      --ctxsys.CTX_ADM.Set_Parameter ('MAX_INDEX_MEMORY', l_Index_Memory);
      BEGIN
         SELECT par_value INTO l_Index_Memory_Max
         FROM ctx_parameters
         WHERE par_name = 'MAX_INDEX_MEMORY';
      EXCEPTION
         WHEN no_data_found THEN
            Log_Line (l_api_name || ': Error: MAX_INDEX_MEMORY parameter record not found.');
            RAISE G_EXC_ERROR;
      END;

      IF ( TO_NUMBER(l_Index_Memory) > TO_NUMBER(l_Index_Memory_Max) ) THEN
         l_Index_Memory := l_Index_Memory_Max;
      END IF;

      Log_Line (l_api_name || ': CTX index_memory: ' || l_Index_Memory);

      -- Decide whether parallel indexing can be used, depending on DB version.

      IF ( DOM_DOC_TEXT_UTIL.get_DB_Version_Num >= 9.2 ) THEN
         l_index_parallel := c_parallel_clause;
         Log_Line (l_api_name || ': DB version: ' || DOM_DOC_TEXT_UTIL.get_DB_Version_Str || ', using parallel clause: ' || l_index_parallel);
      END IF;

      -- Start logging indexing progress

      IF ( g_Log_Dir IS NOT NULL ) THEN
         BEGIN
            Log_Line (l_api_name || ': CTX Log_Directory: ' || g_Log_Dir);
            ctxsys.CTX_ADM.Set_Parameter ( 'LOG_DIRECTORY', g_Log_Dir );
            Log_Line (l_api_name || ': CTX Start_Log');
            CTX_OUTPUT.Start_Log ( LOWER(p_Index_Name) || '.log' );
            ctx_Log_File_Name := CTX_OUTPUT.LogFileName;
            Log_Line (l_api_name || ': CTX LogFileName:   ' || ctx_Log_File_Name);
         EXCEPTION
            WHEN others THEN
               Log_Line (l_api_name || ': Warning: CTX Start_Log: ' || SQLERRM);
               l_return_status := G_STATUS_WARNING;
         END;
      END IF;

      -- Choose indexing method
      --IF ( ) THEN
      --   l_index_populate := 'NOPOPULATE';
      --END IF;

      IF ( l_create_index ) THEN
      BEGIN

         DOM_DOC_TEXT_UTIL.Set_Context ('CREATE_INDEX');

         sql_stmt :=
            'CREATE INDEX ' || g_Index_Owner || '.' || p_Index_Name              ||
            ' ON ' || g_Prod_Schema || '.DOM_DOCUMENTS_IMTEXT_TL (text)               ' ||
            ' INDEXTYPE IS CTXSYS.context                                      ' ||
            ' PARAMETERS                                                       ' ||
            ' (''DATASTORE      ' || g_Pref_Owner || '.DOM_DOC_DATASTORE      ' ||
            '  WORDLIST         ' || g_Pref_Owner || '.DOM_DOC_WORDLIST       ' ||
            '  STOPLIST         ' || g_Pref_Owner || '.DOM_DOC_STOPLIST       ' ||
            '  LEXER            ' || g_Pref_Owner || '.DOM_DOC_MULTI_LEXER    ' ||
            '  LANGUAGE COLUMN  language                                       ' ||
            --'  SECTION GROUP    ' || g_Pref_Owner || '.DOM_DOC_STOPLIST  ' ||
            '  SECTION GROUP    CTXSYS.NULL_SECTION_GROUP  '                     ||
            '  STORAGE          ' || g_Pref_Owner || '.DOM_DOC_STORAGE        ' ||
            '  MEMORY           ' || l_Index_Memory ||
            --'  ' || l_index_populate ||
            ' '')' ;
--	    || '  ' || l_index_parallel ;

         Log_Line (l_api_name || ': creating index ' || g_Index_Owner || '.' || p_Index_Name || ' ...');
         Log_Line (l_api_name || ': sql_stmt = ' || sql_stmt || ' /* End SQL */');

         EXECUTE IMMEDIATE sql_stmt;

         Log_Line (l_api_name || ': done creating index.');

      EXCEPTION

         WHEN others THEN
            Log_Line (l_api_name || ': Error creating index ' || g_Index_Owner || '.' || p_Index_Name || ': ' || SQLERRM);

            -- Drop the index in case of an error during index creation to prevent the table lock.
            BEGIN
               EXECUTE IMMEDIATE 'DROP INDEX ' || g_Index_Owner || '.' || p_Index_Name || ' FORCE';
            EXCEPTION
               WHEN others THEN
                  Log_Line (l_api_name || ': Error: DROP INDEX ' || g_Index_Owner || '.' || p_Index_Name || ' FORCE: ' || SQLERRM);

                 RAISE G_EXC_ERROR;
            END;

            RAISE G_EXC_ERROR;

      END;  -- execute sql
      END IF;  -- create index
/*
      Log_Line (l_api_name || ': calling Incremental_Sync');

      DOM_DOC_TEXT_UTIL.Incremental_Sync
      (
         p_Index_Name      =>  p_Index_Name
      ,  p_batch_size      =>  40000
      ,  x_rows_processed  =>  l_rows_processed
      ,  x_return_status   =>  l_return_status
      );
*/
      -- End logging

      IF ( ctx_Log_File_Name IS NOT NULL ) THEN
         BEGIN
            CTX_OUTPUT.End_Log;
            Log_Line (l_api_name || ': CTX End_Log');
         EXCEPTION
            WHEN others THEN
               Log_Line (l_api_name || ': Warning: CTX End_Log: ' || SQLERRM);
               l_return_status := G_STATUS_WARNING;
         END;
      END IF;

       Log_Line (l_api_name || 'Completed building Document Management Text Index.');

      -- Check the created index status

         Log_Line (l_api_name || 'Checking Status of Document Management Text Index.');

         SELECT idx_docid_count, idx_status
           INTO l_idx_docid_count, l_idx_status
         FROM ctxsys.ctx_indexes
         WHERE idx_owner = g_Index_Owner AND idx_name = 'DOM_IMTEXT_TL_CTX1'
           AND idx_table = 'DOM_DOCUMENTS_IMTEXT_TL';


         IF NOT( l_idx_status = 'INDEXED' ) THEN
            Log_Line (l_api_name || ': Error: Index status is ' || l_idx_status || '.');
            l_return_status := G_STATUS_ERROR;
         END IF;

         IF ( NVL(l_idx_docid_count, 0) = 0 ) THEN
            Log_Line (l_api_name || ': Error: Indexed document count is ' || TO_CHAR(l_idx_docid_count) || '.');
            l_return_status := G_STATUS_ERROR;
         END IF;

         IF ( l_return_status NOT IN (G_STATUS_SUCCESS, G_STATUS_WARNING) ) THEN
            RAISE G_EXC_ERROR;
         END IF;



   END IF;  -- build index

   x_return_status := l_return_status;
   Log_Line (l_api_name || ': end');

EXCEPTION

   WHEN G_EXC_ERROR THEN
      x_return_status := G_STATUS_ERROR;

   WHEN others THEN
      Log_Line (l_api_name || ': Error: ' || SQLERRM);
      x_return_status := G_STATUS_UNEXP_ERROR;

END Process_Doc_Text_Index;

-- -----------------------------------------------------------------------------
--			     Build_Doc_Text_Index
-- -----------------------------------------------------------------------------

PROCEDURE Build_Doc_Text_Index
(
   ERRBUF		OUT  NOCOPY  VARCHAR2
,  RETCODE		OUT  NOCOPY  NUMBER
,  p_Action		IN           VARCHAR2
)
IS
   l_api_name		CONSTANT  VARCHAR2(30)  :=  'Build_Doc_Text_Index';
   l_Index_Name			VARCHAR2(30)    :=  'DOM_IMTEXT_TL_CTX1';
   l_return_status		VARCHAR2(1);
BEGIN
   Log_Line (l_api_name || ': begin: Action=' || p_Action);

   IF ( g_Log_Mode IS NULL ) THEN
      set_Log_Mode ('FILE');
   END IF;

   l_return_status := G_STATUS_SUCCESS;

   IF ( p_Action IN ('CREATE', 'REBUILD', 'UPGRADE') ) THEN
      Log_Line (l_api_name || ': calling Process_Index_Preferences ...');

      Process_Index_Preferences
      (
         p_Index_Name     =>  l_Index_Name
      ,  x_return_status  =>  l_return_status
      );

      IF ( l_return_status NOT IN (G_STATUS_SUCCESS, G_STATUS_WARNING) ) THEN
         RAISE G_EXC_ERROR;
      END IF;

      Out_Line ('Re-created Text Index preferences.');
   END IF;

   Log_Line (l_api_name || ': calling Process_Doc_Text_Index ...');

   Process_Doc_Text_Index
   (
      p_Index_Name     =>  l_Index_Name
   ,  p_Action         =>  p_Action
   ,  x_return_status  =>  l_return_status
   );

   IF ( l_return_status NOT IN (G_STATUS_SUCCESS, G_STATUS_WARNING) ) THEN
      RAISE G_EXC_ERROR;
   END IF;

   -- Assign conc request return code

   IF ( l_return_status = G_STATUS_SUCCESS ) THEN
      RETCODE := G_RETCODE_SUCCESS;
      ERRBUF  := FND_MESSAGE.Get_String('DOM', 'DOM_CP_SUCCESS');
   ELSIF ( l_return_status = G_STATUS_WARNING ) THEN
      RETCODE := G_RETCODE_WARNING;
      ERRBUF  := FND_MESSAGE.Get_String('DOM', 'DOM_CP_WARNING');
   ELSE
      RETCODE := G_RETCODE_ERROR;
      ERRBUF  := FND_MESSAGE.Get_String('DOM', 'DOM_CP_FAILURE');
   END IF;

   IF NOT(g_Conc_Req_flag) THEN
      FND_FILE.Close;
   END IF;

   Log_Line (l_api_name || ': end');

EXCEPTION

   WHEN G_EXC_ERROR THEN
      Log_Line (l_api_name || ': Error.');
      RETCODE := G_RETCODE_ERROR;
      ERRBUF  := FND_MESSAGE.Get_String('EGO', 'DOM_CP_FAILURE');
      --ERRBUF  := 'Build of CM Text Index failed. Please check error messages for further details.';

      IF NOT(g_Conc_Req_flag) THEN
         FND_FILE.Close;
      END IF;

   WHEN others THEN
      Log_Line (l_api_name || ': Unexpected Error: ' || SQLERRM);
      RETCODE := G_RETCODE_ERROR;
      ERRBUF  := 'Build of CM Text Index failed due to unexpected error. Please check error messages for further details.';

      IF NOT(g_Conc_Req_flag) THEN
         FND_FILE.Close;
      END IF;

END Build_Doc_Text_Index;


-- -----------------------------------------------------------------------------
--				  get_Msg_Text
-- -----------------------------------------------------------------------------

FUNCTION get_Msg_Text
RETURN VARCHAR2
IS
BEGIN
   RETURN (g_Msg_Text);
END get_Msg_Text;

-- *****************************************************************************
-- **                      Package initialization block                       **
-- *****************************************************************************

BEGIN

   -- Get DOM product schema name
   --
   g_installed := FND_INSTALLATION.Get_App_Info ('DOM', g_inst_status, g_industry, g_Prod_Schema);

   g_Index_Owner := g_Prod_Schema;
   g_Pref_Owner  := g_Prod_Schema;

END DOM_DOC_TEXT_PVT;

/
