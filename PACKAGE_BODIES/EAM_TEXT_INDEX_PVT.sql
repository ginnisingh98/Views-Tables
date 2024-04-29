--------------------------------------------------------
--  DDL for Package Body EAM_TEXT_INDEX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_TEXT_INDEX_PVT" AS
/* $Header: EAMVTICB.pls 120.4 2006/05/23 07:07:20 yjhabak noship $*/
   -- Start of comments
   -- API name    : EAM_TEXT_INDEX_PVT
   -- Type     : Private.
   -- Function :
   -- Pre-reqs : None.
   -- Parameters  :
   -- IN       p_api_version      IN NUMBER   Required
   --          p_init_msg_list    IN VARCHAR2 Optional
   --                                         Default = FND_API.G_FALSE
   --          p_commit           IN VARCHAR2 Optional
   --                                         Default = FND_API.G_FALSE
   --          p_validation_level IN NUMBER   Optional
   --                                         Default = FND_API.G_VALID_LEVEL_FULL
   --          parameter1
   --          parameter2
   --          .
   --          .
   -- OUT      x_return_status   OUT   VARCHAR2(1)
   --          x_msg_count       OUT   NUMBER
   --          x_msg_data        OUT   VARCHAR2(2000)
   --          parameter1
   --          parameter2
   --          .
   --          .
   -- Version  Current version x.x
   --          Changed....
   --          previous version   y.y
   --          Changed....
   --         .
   --         .
   --         previous version   2.0
   --         Changed....
   --         Initial version    1.0
   --
   -- Notes   Note text
   --
   -- End of comments

-- -----------------------------------------------------------------------------
--  				Private Globals
-- -----------------------------------------------------------------------------
G_PKG_NAME	CONSTANT  VARCHAR2(30)  :=  'EAM_TEXT_INDEX_PVT';

g_Ctx_Schema		CONSTANT  VARCHAR2(30)  :=  'CTXSYS';
g_Prod_Schema			VARCHAR2(30);
g_Index_Owner			VARCHAR2(30);
g_Pref_Owner			VARCHAR2(30);

g_installed		BOOLEAN;
g_inst_status		VARCHAR2(1);
g_industry		VARCHAR2(1);

-- Log mode
g_Log_Mode		VARCHAR2(30)  :=  NULL;
g_Conc_Req_flag		BOOLEAN  :=  TRUE;
g_Log_Sqlplus_Flag	BOOLEAN  :=  FALSE;
g_Log_File_Flag		BOOLEAN  :=  FALSE;
g_Log_Dbdrv_Flag        BOOLEAN  :=  FALSE;

g_Msg_Text		VARCHAR2(1000);

-- Log directory
g_Log_Dir		v$parameter.value%TYPE;
g_Dump_Dir		v$parameter.value%TYPE;

-- Log files for Sqlplus
g_Log_File		VARCHAR2(30)  :=  'eam_text_index.log';
g_Out_File		VARCHAR2(30)  :=  'eam_text_index.out';



-- -----------------------------------------------------------------------------
--				  Log_Line
-- -----------------------------------------------------------------------------

PROCEDURE Log_Line ( p_Buffer  IN  VARCHAR2
                   , p_Log_Type IN NUMBER
		   , p_Module IN VARCHAR2 )
IS
BEGIN
   IF ( g_Log_File_Flag AND p_Log_Type >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FOR l IN 0 .. ( FLOOR( (NVL(LENGTH(p_Buffer),0) - 1)/240 ) ) LOOP
          FND_LOG.STRING(p_Log_Type, p_module, SUBSTRB(p_Buffer, l*240 + 1, 240));
          --FND_FILE.Put_Line (FND_FILE.Log, SUBSTRB(p_Buffer, l*240 + 1, 240));
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
END Log_Line;

-- -----------------------------------------------------------------------------
--				  Requets_Log
-- -----------------------------------------------------------------------------

PROCEDURE Request_Log (p_msg_name IN VARCHAR2)
IS
BEGIN
    FND_MESSAGE.SET_NAME('EAM', p_msg_name);
    fnd_file.put_line(FND_FILE.LOG, FND_MESSAGE.GET);
END Request_Log;

-- -----------------------------------------------------------------------------
--				  Out_Line
-- -----------------------------------------------------------------------------
/*
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
         DBMS_OUTPUT.Put_Line( SUBSTR(p_Buffer, l*255 + 1, 255) );
         NULL;
      END LOOP;
   END IF;

   IF ( g_Log_Dbdrv_Flag ) THEN
      IF ( INSTR(p_Buffer, 'Completed ') > 0 ) THEN
         g_Msg_Text := g_Msg_Text || SUBSTRB(p_Buffer, 1, 255) || FND_GLOBAL.Newline;
      END IF;
   END IF;
END Out_Line;
*/

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
      Log_Line (l_api_name || ': standalone execution', FND_LOG.LEVEL_EVENT, l_api_name);
   ELSE
      Log_Line (l_api_name || ': concurrent request', FND_LOG.LEVEL_EVENT, l_api_name);
   END IF;

   Log_Line (l_api_name || ': log mode: ' || g_Log_Mode, FND_LOG.LEVEL_EVENT, l_api_name);
   Log_Line (l_api_name || ': dump directory: ' || g_Dump_Dir, FND_LOG.LEVEL_EVENT, l_api_name);
   Log_Line (l_api_name || ': CTX log directory: ' || g_Log_Dir, FND_LOG.LEVEL_EVENT, l_api_name);

   RETURN (NULL);

END set_Log_Mode;



PROCEDURE set_Log_Mode ( p_Mode  IN  VARCHAR2 )
IS
   l_output_name	VARCHAR2(255);
BEGIN
   l_output_name := set_Log_Mode (p_Mode);
END set_Log_Mode;



-- -----------------------------------------------------------------------------
--			  Set_Asset_Index_Preferences
-- -----------------------------------------------------------------------------

PROCEDURE Set_Asset_Index_Preferences
(
   p_Index_Name		IN           VARCHAR2
,  x_return_status	OUT  NOCOPY  VARCHAR2
)
IS
   l_api_name	      CONSTANT  VARCHAR2(30)  :=  'Set_Asset_Index_Preferences';
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
   Log_Line (l_api_name || ': begin',  FND_LOG.LEVEL_EVENT, l_api_name);

   l_return_status := G_STATUS_SUCCESS;

   ------------------------------
   -- Drop existing preferences
   ------------------------------

   Log_Line (l_api_name || ': dropping all existing preferences ...',  FND_LOG.LEVEL_EVENT, l_api_name);

   FOR multi_lexer_rec IN	( SELECT pre_owner, pre_name
                               	    FROM ctxsys.ctx_preferences
                         	   WHERE pre_name = 'EAM_ASSET_MULTI_LEXER' )
   LOOP
      ad_ctx_ddl.drop_preference (multi_lexer_rec.pre_owner ||'.'|| multi_lexer_rec.pre_name);
   END LOOP;

   FOR sub_lexer_rec IN		( SELECT pre_owner, pre_name
                       		    FROM ctxsys.ctx_preferences
                       		   WHERE pre_name LIKE 'EAM_ASSET_LEXER%' )
   LOOP
      ad_ctx_ddl.drop_preference (sub_lexer_rec.pre_owner ||'.'|| sub_lexer_rec.pre_name);
   END LOOP;

   FOR wordlist_rec IN		( SELECT pre_owner, pre_name
                       		    FROM ctxsys.ctx_preferences
                       		   WHERE pre_name = 'EAM_ASSET_WORDLIST' )
   LOOP
      ad_ctx_ddl.drop_preference (wordlist_rec.pre_owner ||'.'|| wordlist_rec.pre_name);
   END LOOP;

   FOR stoplist_rec IN		( SELECT spl_owner, spl_name
                       		    FROM ctxsys.ctx_stoplists
                       		   WHERE spl_name = 'EAM_ASSET_STOPLIST' )
   LOOP
      --ad_ctx_ddl.Drop_Stoplist (stoplist_rec.spl_owner || '.EAM_ASSET_STOPLIST');
      ad_ctx_ddl.Drop_Stoplist (stoplist_rec.spl_owner || '.'|| stoplist_rec.spl_name);
   END LOOP;

   FOR section_group_rec IN	( SELECT sgp_owner, sgp_name
                       		    FROM ctxsys.ctx_section_groups
                       		   WHERE sgp_name = 'EAM_ASSET_SECTION_GROUP' )
   LOOP
      ad_ctx_ddl.Drop_Section_Group (section_group_rec.sgp_owner ||'.'|| section_group_rec.sgp_name);
   END LOOP;

   FOR datastore_rec IN		( SELECT pre_owner, pre_name
                       		    FROM ctxsys.ctx_preferences
                       		   WHERE pre_name = 'EAM_ASSET_DATASTORE' )
   LOOP
      ad_ctx_ddl.drop_preference (datastore_rec.pre_owner ||'.'|| datastore_rec.pre_name);
   END LOOP;

   FOR storage_rec IN		( SELECT pre_owner, pre_name
                       		    FROM ctxsys.ctx_preferences
                       		    WHERE pre_name = 'EAM_ASSET_STORAGE' )
   LOOP
      ad_ctx_ddl.drop_preference (storage_rec.pre_owner ||'.'|| storage_rec.pre_name);
   END LOOP;

   ------------------------------
   -- Create STORAGE preference
   ------------------------------
   -- Index tables use the same tablespaces used by other EAM tables and indexes
   -- or use logical tablespace for indexes (TRANSACTION_INDEXES).

   Log_Line (l_api_name || ': querying tablespace parameters ...',  FND_LOG.LEVEL_EVENT, l_api_name);

   SELECT 'tablespace ' || tablespace_name ||
          ' storage (initial 1M next 1M minextents 1 maxextents unlimited pctincrease 0)'
     INTO tspace_tbl_param
     FROM all_tables
    WHERE owner = g_Prod_Schema AND table_name = 'EAM_ASSET_TEXT';

   SELECT 'tablespace ' || tablespace_name ||
          ' storage (initial 1M next 1M minextents 1 maxextents unlimited pctincrease 0)'
     INTO tspace_idx_param
     FROM all_indexes
    WHERE owner = g_Prod_Schema
      AND index_name = 'EAM_ASSET_TEXT_U1'
      AND table_name = 'EAM_ASSET_TEXT';

   Log_Line (l_api_name || ': creating STORAGE preference ...',  FND_LOG.LEVEL_EVENT, l_api_name);

   ad_ctx_ddl.create_preference (g_Pref_Owner || '.EAM_ASSET_STORAGE', 'BASIC_STORAGE');

   ad_ctx_ddl.set_attribute (g_Pref_Owner || '.EAM_ASSET_STORAGE',
                             'I_TABLE_CLAUSE', tspace_tbl_param);

   ad_ctx_ddl.set_attribute (g_Pref_Owner || '.EAM_ASSET_STORAGE',
                             'K_TABLE_CLAUSE', tspace_tbl_param);

   ad_ctx_ddl.set_attribute (g_Pref_Owner || '.EAM_ASSET_STORAGE',
                             'R_TABLE_CLAUSE', tspace_tbl_param || ' LOB (data) STORE AS (CACHE)');

   -- Caching the "data" LOB column is the default (at later versions of Oracle Text).
   -- For index specific STORAGE preference, setting the clause "lob (data) (cache reads)"
   -- should be ensured (the "lob .. store as" clause is only for newly added LOB columns).
   -- alter table dr$prd_ctx_index$r modify lob (data) (cache reads);

   ad_ctx_ddl.set_attribute (g_Pref_Owner || '.EAM_ASSET_STORAGE',
                             'N_TABLE_CLAUSE', tspace_tbl_param);

   ad_ctx_ddl.set_attribute (g_Pref_Owner || '.EAM_ASSET_STORAGE',
                             'P_TABLE_CLAUSE', tspace_tbl_param);

   ad_ctx_ddl.set_attribute (g_Pref_Owner || '.EAM_ASSET_STORAGE',
                             'I_INDEX_CLAUSE', tspace_idx_param || ' COMPRESS 2');

   --ad_ctx_ddl.set_attribute (g_Pref_Owner || '.EAM_ASSET_STORAGE',
   --                          'I_ROWID_INDEX_CLAUSE', tspace_idx_param);

   --------------------------------
   -- Create DATASTORE preference
   --------------------------------

   Log_Line (l_api_name || ': creating DATASTORE preference ...',  FND_LOG.LEVEL_EVENT, l_api_name);

   ad_ctx_ddl.Create_Preference (g_Pref_Owner || '.EAM_ASSET_DATASTORE', 'USER_DATASTORE');

   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_ASSET_DATASTORE', 'OUTPUT_TYPE', 'CLOB');
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_ASSET_DATASTORE', 'PROCEDURE', '"EAM_TEXT_CTX_PKG"."Get_Asset_Text_CLOB"');

   --ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_ASSET_DATASTORE', 'OUTPUT_TYPE', 'VARCHAR2');
   --ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_ASSET_DATASTORE', 'PROCEDURE', '"EAM_TEXT_CTX_PKG"."Get_Asset_Text_VARCHAR2"');

   ------------------------------------
   -- Create SECTION GROUP preference
   ------------------------------------

   --Log_Line (l_api_name || ': creating SECTION_GROUP preference ...',  FND_LOG.LEVEL_EVENT, l_api_name);

   ad_ctx_ddl.Create_Section_Group (g_Pref_Owner || '.EAM_ASSET_SECTION_GROUP', 'AUTO_SECTION_GROUP');

   -------------------------------
   -- Create STOPLIST preference
   -------------------------------

   Log_Line (l_api_name || ': creating STOPLIST preference ...',  FND_LOG.LEVEL_EVENT, l_api_name);

   -- This should create stoplist equivalent to CTXSYS.EMPTY_STOPLIST
   ad_ctx_ddl.Create_Stoplist (g_Pref_Owner || '.EAM_ASSET_STOPLIST');

   -------------------------------
   -- Create WORDLIST preference
   -------------------------------

   Log_Line (l_api_name || ': creating WORDLIST preference ...', FND_LOG.LEVEL_EVENT, l_api_name);

   ad_ctx_ddl.Create_Preference (g_Pref_Owner || '.EAM_ASSET_WORDLIST', 'BASIC_WORDLIST');

   -- Enable prefix indexing to improve performance for wildcard searches
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_ASSET_WORDLIST', 'PREFIX_INDEX', 'TRUE');
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_ASSET_WORDLIST', 'PREFIX_MIN_LENGTH', 2);
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_ASSET_WORDLIST', 'PREFIX_MAX_LENGTH', 32);
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_ASSET_WORDLIST', 'WILDCARD_MAXTERMS', 5000);

   -- This option should be TRUE only when left-truncated wildcard searching is expected
   -- to be frequent and needs to be fast (at the cost of increased index time and space).
   --
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_ASSET_WORDLIST', 'SUBSTRING_INDEX', 'FALSE');

   -- WORDLIST attribute defaults: STEMMER: 'ENGLISH'; FUZZY_MATCH: 'GENERIC'
   -- Use automatic language detection for stemming and fuzzy matching
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_ASSET_WORDLIST', 'STEMMER', 'AUTO');
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_ASSET_WORDLIST', 'FUZZY_MATCH', 'AUTO');
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_ASSET_WORDLIST', 'FUZZY_SCORE', 40);
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_ASSET_WORDLIST', 'FUZZY_NUMRESULTS', 120);

   -----------------------------------------------
   -- Create language-specific LEXER preferences
   -----------------------------------------------

   Log_Line (l_api_name || ': creating language-specific LEXER preferences ...', FND_LOG.LEVEL_EVENT, l_api_name);
   Lexer_Name := g_Pref_Owner || '.EAM_ASSET_LEXER_BASIC';

/*
   FOR i IN Lang_Code_List.FIRST .. Lang_Code_List.LAST
   LOOP
      Lexer_Name := g_Pref_Owner || '.EAM_ASSET_LEXER_' || Lang_Code_List(i);

      IF ( Lang_Code_List(i) = 'JA' ) THEN
         -- Use JAPANESE_LEXER if db charset is UTF8, JA16SJIS, or JA16EUC.
         IF ( eam_text_util.get_DB_Version_Num >= 9.0 ) THEN
            ad_ctx_ddl.Create_Preference (Lexer_Name, 'JAPANESE_LEXER');
         ELSE
            ad_ctx_ddl.Create_Preference (Lexer_Name, 'JAPANESE_VGRAM_LEXER');
         END IF;

      ELSIF ( Lang_Code_List(i) = 'KO' ) THEN
         -- Use KOREAN_MORPH_LEXER if db charset is UTF8 or KO16KSC5601.
         IF ( eam_text_util.get_DB_Version_Num >= 9.0 ) THEN
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
         IF ( eam_text_util.get_DB_Version_Num >= 9.2 ) THEN
            ad_ctx_ddl.Create_Preference (Lexer_Name, 'CHINESE_LEXER');
         ELSE
            ad_ctx_ddl.Create_Preference (Lexer_Name, 'CHINESE_VGRAM_LEXER');
         END IF;

      ELSE
         -- All other languages use basic lexer.
*/
	 /* For now we will use basic lexer only */

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
         --IF ( eam_text_util.get_DB_Version_Num >= 9.2 ) THEN
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
/*
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
*/
   ----------------------------------
   -- Create MULTI_LEXER preference
   ----------------------------------
/*
   Log_Line (l_api_name || ': creating MULTI_LEXER preference ...', FND_LOG.LEVEL_EVENT, l_api_name);

   ad_ctx_ddl.Create_Preference (g_Pref_Owner || '.EAM_ASSET_MULTI_LEXER', 'MULTI_LEXER');

   FOR i IN Lang_Code_List.FIRST .. Lang_Code_List.LAST
   LOOP
      Lexer_Name := g_Pref_Owner || '.EAM_ASSET_LEXER_' || Lang_Code_List(i);

      -- The language column is case-independent, and can contain either the NLS name
      -- or abbreviation of the language.  If the table uses some other value for the
      -- language, that alternate value needs to be specified as the fourth argument
      -- when adding the sub lexers:

      IF ( Lang_Code_List(i) = 'US' ) THEN
         -- US English lexer to handle everything else.
         ad_ctx_ddl.Add_Sub_Lexer ( g_Pref_Owner || '.EAM_ASSET_MULTI_LEXER', 'DEFAULT'
                                  , g_Pref_Owner || '.EAM_ASSET_LEXER_US' );
      ELSE
         ad_ctx_ddl.Add_Sub_Lexer
         (  lexer_name    =>  g_Pref_Owner || '.EAM_ASSET_MULTI_LEXER'
         ,  language      =>  Lang_Code_List(i)
         ,  sub_lexer     =>  Lexer_Name
         --,  alt_value     =>  Lang_ISO_List(i)
         );
      END IF;

   END LOOP;*/

   x_return_status := l_return_status;

   Log_Line (l_api_name || ': end',  FND_LOG.LEVEL_EVENT, l_api_name);

EXCEPTION

   WHEN G_EXC_ERROR THEN
      x_return_status := G_STATUS_ERROR;

   WHEN others THEN
      Log_Line (l_api_name || ': Error: ' || SQLERRM,  FND_LOG.LEVEL_EVENT, l_api_name);
      x_return_status := G_STATUS_UNEXP_ERROR;

END Set_Asset_Index_Preferences;



-- -----------------------------------------------------------------------------
--			   Process_Asset_Text_Index
-- -----------------------------------------------------------------------------

PROCEDURE Process_Asset_Text_Index
(
   p_Index_Name		IN           VARCHAR2
,  p_Action		IN           VARCHAR2
,  x_return_status	OUT  NOCOPY  VARCHAR2
)
IS
   l_api_name		CONSTANT  VARCHAR2(30)  :=  'Process_Asset_Text_Index';
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
   sql_stmt			VARCHAR2(32767);
BEGIN

   Log_Line (l_api_name || ': begin: Index_Name=' || p_Index_Name || ' Action=' || p_Action,  FND_LOG.LEVEL_EVENT, l_api_name);

   l_return_status := G_STATUS_SUCCESS;

   IF ( p_Action NOT IN (1,2,4) ) THEN
      Log_Line (l_api_name || ': Error: invalid value for parameter p_Action: ' || p_Action,  FND_LOG.LEVEL_EVENT, l_api_name);
      RAISE G_EXC_ERROR;
   END IF;

   -- Check for existing indexes in the EAM product, APPS Universal, and interMedia schemas.
   --
   FOR index_rec IN ( SELECT owner, index_name, status, domidx_status, domidx_opstatus
                      FROM all_indexes
                      WHERE ( owner = g_Prod_Schema OR owner = USER OR owner = g_Ctx_Schema )
                        AND table_name = 'EAM_ASSET_TEXT'
                        AND index_name = p_Index_Name )
   LOOP
      -- Check index schema
      --
      IF ( index_rec.owner <> g_Index_Owner )
      THEN
         Log_Line (l_api_name || ': Error: index exists in wrong schema: ' || index_rec.owner,  FND_LOG.LEVEL_EVENT, l_api_name);
         BEGIN
            Log_Line (l_api_name || ': dropping index: ' || index_rec.owner || '.' || p_Index_Name,  FND_LOG.LEVEL_EVENT, l_api_name);
            EXECUTE IMMEDIATE 'DROP INDEX ' || index_rec.owner || '.' || p_Index_Name || ' FORCE';
         EXCEPTION
            WHEN others THEN
               Log_Line (l_api_name || ': Error: DROP INDEX ' || index_rec.owner || '.' || p_Index_Name || ' FORCE: ' || SQLERRM,  FND_LOG.LEVEL_EVENT, l_api_name);
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
                      || ' domidx_opstatus=' || index_rec.domidx_opstatus,  FND_LOG.LEVEL_EVENT, l_api_name);
         ELSE
            Log_Line (l_api_name || ': valid index exists: ' || index_rec.owner || '.' || p_Index_Name,  FND_LOG.LEVEL_EVENT, l_api_name);
         END IF;

      END IF;  -- index owner

   END LOOP;  -- check for any existing indexes

   IF ( l_return_status NOT IN (G_STATUS_SUCCESS, G_STATUS_WARNING) ) THEN
      RAISE G_EXC_ERROR;
   END IF;

   --   x_return_status := l_return_status;

   -- Set indexing flags depending on the action and the index status

   IF ( p_Action = 1 ) THEN
      IF ( l_index_exists ) THEN
         IF ( l_index_valid ) THEN
            Log_Line (l_api_name || ': Error: cannot execute Create because the index exists.',  FND_LOG.LEVEL_EVENT, l_api_name);
            Request_Log ('EAM_TEXT_INDEX_EXISTS');
            l_return_status := G_STATUS_WARNING;
            l_create_index := FALSE;
         ELSE
            l_drop_index := TRUE;
         END IF;
      END IF;

   ELSIF ( p_Action = 2 ) THEN
      l_drop_index := l_index_exists;
/*
   ELSIF ( p_Action = 'UPGRADE' ) THEN
      IF ( l_index_exists ) THEN
         IF ( l_index_valid ) THEN
            Log_Line (l_api_name || ': Upgrade: skipping index creation because valid index exists.', FND_LOG.LEVEL_EVENT, l_api_name);
            l_create_index := FALSE;
         ELSE
            l_drop_index := TRUE;
         END IF;
      END IF;
*/
   ELSIF ( p_Action = 4 ) THEN
      l_create_index := FALSE;
      IF ( l_index_exists ) THEN
         l_drop_index := TRUE;
      ELSE
         Log_Line (l_api_name || ': Warning: cannot execute Drop because the index does not exist.', FND_LOG.LEVEL_EVENT, l_api_name);
	 Request_Log ('EAM_TEXT_INDEX_NOT_EXISTS');
         l_return_status := G_STATUS_WARNING;
      END IF;

   END IF;  -- Action

   IF ( l_drop_index ) THEN
      BEGIN
         Log_Line (l_api_name || ': dropping index: ' || g_Index_Owner || '.' || p_Index_Name,  FND_LOG.LEVEL_EVENT, l_api_name);
	 request_log('EAM_TEXT_DROP');
         EXECUTE IMMEDIATE 'DROP INDEX ' || g_Index_Owner || '.' || p_Index_Name || ' FORCE';
         IF ( l_index_valid ) THEN
            Log_Line (l_api_name || ': existing index has been successfully dropped.', FND_LOG.LEVEL_EVENT, l_api_name);
         ELSE
            Log_Line (l_api_name || ': invalid index has been dropped.', FND_LOG.LEVEL_EVENT, l_api_name);
         END IF;
      EXCEPTION
         WHEN others THEN
            Log_Line (l_api_name || ': Error: DROP INDEX ' || g_Index_Owner || '.' || p_Index_Name || ' FORCE: ' || SQLERRM, FND_LOG.LEVEL_EVENT, l_api_name);
            l_return_status := G_STATUS_ERROR;
      END;
   END IF;  -- drop index

   IF ( l_return_status NOT IN (G_STATUS_SUCCESS, G_STATUS_WARNING) ) THEN
      RAISE G_EXC_ERROR;
   END IF;

   -- Build index

   IF ( l_create_index ) THEN

      Log_Line (': calling Set_Asset_Index_Preferences ...', FND_LOG.LEVEL_EVENT, l_api_name);
      request_log('EAM_TEXT_INDEX_PREF');
      Set_Asset_Index_Preferences
      (
	     p_Index_Name     =>  p_Index_Name
	   , x_return_status  =>  l_return_status
      );

      IF ( l_return_status NOT IN (G_STATUS_SUCCESS, G_STATUS_WARNING) ) THEN
	    RAISE G_EXC_ERROR;
      END IF;

      log_Line ('Re-created Text Index preferences.', FND_LOG.LEVEL_EVENT, l_api_name);

      -- Determine index memory parameter value
      --ctxsys.CTX_ADM.Set_Parameter ('MAX_INDEX_MEMORY', l_Index_Memory);
      BEGIN
         SELECT par_value INTO l_Index_Memory_Max
         FROM ctx_parameters
         WHERE par_name = 'MAX_INDEX_MEMORY';
      EXCEPTION
         WHEN no_data_found THEN
            Log_Line (l_api_name || ': Error: MAX_INDEX_MEMORY parameter record not found.', FND_LOG.LEVEL_EVENT, l_api_name);
            RAISE G_EXC_ERROR;
      END;

      IF ( TO_NUMBER(l_Index_Memory) > TO_NUMBER(l_Index_Memory_Max) ) THEN
         l_Index_Memory := l_Index_Memory_Max;
      END IF;

      Log_Line (l_api_name || ': CTX index_memory: ' || l_Index_Memory,  FND_LOG.LEVEL_EVENT, l_api_name);

      -- Decide whether parallel indexing can be used, depending on DB version.

      IF ( eam_text_util.get_DB_Version_Num >= 9.2 ) THEN
         l_index_parallel := c_parallel_clause;
         Log_Line (l_api_name || ': DB version: ' || eam_text_util.get_DB_Version_Str || ', using parallel clause: ' || l_index_parallel,  FND_LOG.LEVEL_EVENT, l_api_name);
      END IF;

      -- Start logging indexing progress

      IF ( g_Log_Dir IS NOT NULL ) THEN
         BEGIN
            Log_Line (l_api_name || ': CTX Log_Directory: ' || g_Log_Dir,  FND_LOG.LEVEL_EVENT, l_api_name);
            ctxsys.CTX_ADM.Set_Parameter ( 'LOG_DIRECTORY', g_Log_Dir );
            Log_Line (l_api_name || ': CTX Start_Log', FND_LOG.LEVEL_EVENT, l_api_name);
            CTX_OUTPUT.Start_Log ( LOWER(p_Index_Name) || '.log' );
            ctx_Log_File_Name := CTX_OUTPUT.LogFileName;
            Log_Line (l_api_name || ': CTX LogFileName:   ' || ctx_Log_File_Name,  FND_LOG.LEVEL_EVENT, l_api_name);
         EXCEPTION
            WHEN others THEN
               Log_Line (l_api_name || ': Warning: CTX Start_Log: ' || SQLERRM,  FND_LOG.LEVEL_EVENT, l_api_name);
               l_return_status := G_STATUS_WARNING;
         END;
      END IF;

      -- Choose indexing method
      --IF ( ) THEN
      --   l_index_populate := 'NOPOPULATE';
      --END IF;

      IF ( l_create_index ) THEN
        BEGIN
          request_log('EAM_TEXT_CREATE');
          eam_text_util.Set_Context ('CREATE_INDEX');

          sql_stmt :=
            'CREATE INDEX ' || g_Index_Owner || '.' || p_Index_Name              ||
            ' ON ' || g_Prod_Schema || '.EAM_ASSET_TEXT (text)               ' ||
            ' INDEXTYPE IS CTXSYS.context                                      ' ||
            ' PARAMETERS                                                       ' ||
            ' (''DATASTORE      ' || g_Pref_Owner || '.EAM_ASSET_DATASTORE      ' ||
            '  WORDLIST         ' || g_Pref_Owner || '.EAM_ASSET_WORDLIST       ' ||
            '  STOPLIST         ' || g_Pref_Owner || '.EAM_ASSET_STOPLIST       ' ||
	    /* For now we will use basic lexer. For using multi lexer we need language column */
            '  LEXER            ' || g_Pref_Owner || '.EAM_ASSET_LEXER_BASIC    ' ||
           -- '  LANGUAGE COLUMN  language                                       ' ||
            '  SECTION GROUP    ' || g_Pref_Owner || '.EAM_ASSET_SECTION_GROUP  ' ||
           -- '  SECTION GROUP    CTXSYS.NULL_SECTION_GROUP  '                     ||
            '  STORAGE          ' || g_Pref_Owner || '.EAM_ASSET_STORAGE        ' ||
            '  MEMORY           ' || l_Index_Memory ||
            --'  ' || l_index_populate ||
            ' '')'
	    || '  ' || l_index_parallel
	    ;

          Log_Line (l_api_name || ': creating index ' || g_Index_Owner || '.' || p_Index_Name || ' ...',  FND_LOG.LEVEL_EVENT, l_api_name);
          --Log_Line (l_api_name || ': sql_stmt = ' || sql_stmt || ' /* End SQL */');

          EXECUTE IMMEDIATE sql_stmt;

          Log_Line (l_api_name || ': done creating index.',  FND_LOG.LEVEL_EVENT, l_api_name);

        EXCEPTION

         WHEN others THEN
            Log_Line (l_api_name || ': Error creating index ' || g_Index_Owner || '.' || p_Index_Name || ': ' || SQLERRM,  FND_LOG.LEVEL_EVENT, l_api_name);

            -- Drop the index in case of an error during index creation to prevent the table lock.
            BEGIN
               EXECUTE IMMEDIATE 'DROP INDEX ' || g_Index_Owner || '.' || p_Index_Name || ' FORCE';
            EXCEPTION
               WHEN others THEN
                  Log_Line (l_api_name || ': Error: DROP INDEX ' || g_Index_Owner || '.' || p_Index_Name || ' FORCE: ' || SQLERRM,  FND_LOG.LEVEL_EVENT, l_api_name);
                  RAISE G_EXC_ERROR;
            END;

            RAISE G_EXC_ERROR;

        END;  -- execute sql
      END IF;  -- create index
/*
      Log_Line (l_api_name || ': calling Incremental_Sync',  FND_LOG.LEVEL_EVENT, l_api_name);

      eam_text_util.Incremental_Sync
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
            Log_Line (l_api_name || ': CTX End_Log',  FND_LOG.LEVEL_EVENT, l_api_name);
         EXCEPTION
            WHEN others THEN
               Log_Line (l_api_name || ': Warning: CTX End_Log: ' || SQLERRM,  FND_LOG.LEVEL_EVENT, l_api_name);
               l_return_status := G_STATUS_WARNING;
         END;
      END IF;

      log_Line ('Completed building Asset Text Index.', FND_LOG.LEVEL_EVENT, l_api_name);

      -- Check the created index status

         SELECT idx_docid_count, idx_status
           INTO l_idx_docid_count, l_idx_status
         FROM ctxsys.ctx_indexes
         WHERE idx_owner = g_Prod_Schema AND idx_name = 'EAM_ASSET_TEXT_CTX1'
           AND idx_table = 'EAM_ASSET_TEXT';

         IF NOT( l_idx_status = 'INDEXED' ) THEN
            Log_Line (l_api_name || ': Error: Index status is ' || l_idx_status || '.',  FND_LOG.LEVEL_EVENT, l_api_name);
            l_return_status := G_STATUS_ERROR;
         END IF;

         IF ( NVL(l_idx_docid_count, 0) = 0 ) THEN
            Log_Line (l_api_name || ': Error: Indexed document count is ' || TO_CHAR(l_idx_docid_count) || '.',  FND_LOG.LEVEL_EVENT, l_api_name);
            l_return_status := G_STATUS_ERROR;
         END IF;

         IF ( l_return_status NOT IN (G_STATUS_SUCCESS, G_STATUS_WARNING) ) THEN
            RAISE G_EXC_ERROR;
         END IF;

   END IF;  -- build index

   x_return_status := l_return_status;
   Log_Line (l_api_name || ': end',  FND_LOG.LEVEL_EVENT, l_api_name);

EXCEPTION

   WHEN G_EXC_ERROR THEN
      x_return_status := G_STATUS_ERROR;

   WHEN others THEN
      Log_Line (l_api_name || ': Error: ' || SQLERRM,  FND_LOG.LEVEL_EVENT, l_api_name);
      x_return_status := G_STATUS_UNEXP_ERROR;

END Process_Asset_Text_Index;



-- -----------------------------------------------------------------------------
--			  Set_Wo_Index_Preferences
-- -----------------------------------------------------------------------------

PROCEDURE Set_Wo_Index_Preferences
(
   p_Index_Name		IN           VARCHAR2
,  x_return_status	OUT  NOCOPY  VARCHAR2
)
IS
   l_api_name	      CONSTANT  VARCHAR2(30)  :=  'Set_Wo_Index_Preferences';
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
   Log_Line (l_api_name || ': begin',  FND_LOG.LEVEL_EVENT, l_api_name);

   l_return_status := G_STATUS_SUCCESS;

   ------------------------------
   -- Drop existing preferences
   ------------------------------

   Log_Line (l_api_name || ': dropping all existing preferences ...', FND_LOG.LEVEL_EVENT, l_api_name);

   FOR multi_lexer_rec IN	( SELECT pre_owner, pre_name
                               	    FROM ctxsys.ctx_preferences
                         	   WHERE pre_name = 'EAM_WORK_ORDER_MULTI_LEXER' )
   LOOP
      ad_ctx_ddl.drop_preference (multi_lexer_rec.pre_owner ||'.'|| multi_lexer_rec.pre_name);
   END LOOP;

   FOR sub_lexer_rec IN		( SELECT pre_owner, pre_name
                       		    FROM ctxsys.ctx_preferences
                       		   WHERE pre_name LIKE 'EAM_WORK_ORDER_LEXER%' )
   LOOP
      ad_ctx_ddl.drop_preference (sub_lexer_rec.pre_owner ||'.'|| sub_lexer_rec.pre_name);
   END LOOP;

   FOR wordlist_rec IN		( SELECT pre_owner, pre_name
                       		    FROM ctxsys.ctx_preferences
                       		   WHERE pre_name = 'EAM_WORK_ORDER_WORDLIST' )
   LOOP
      ad_ctx_ddl.drop_preference (wordlist_rec.pre_owner ||'.'|| wordlist_rec.pre_name);
   END LOOP;

   FOR stoplist_rec IN		( SELECT spl_owner, spl_name
                       		    FROM ctxsys.ctx_stoplists
                       		   WHERE spl_name = 'EAM_WORK_ORDER_STOPLIST' )
   LOOP
      --ad_ctx_ddl.Drop_Stoplist (stoplist_rec.spl_owner || '.EAM_WORK_ORDER_STOPLIST');
      ad_ctx_ddl.Drop_Stoplist (stoplist_rec.spl_owner || '.'|| stoplist_rec.spl_name);
   END LOOP;

   FOR section_group_rec IN	( SELECT sgp_owner, sgp_name
                       		    FROM ctxsys.ctx_section_groups
                       		   WHERE sgp_name = 'EAM_WORK_ORDER_SECTION_GROUP' )
   LOOP
      ad_ctx_ddl.Drop_Section_Group (section_group_rec.sgp_owner ||'.'|| section_group_rec.sgp_name);
   END LOOP;

   FOR datastore_rec IN		( SELECT pre_owner, pre_name
                       		    FROM ctxsys.ctx_preferences
                       		   WHERE pre_name = 'EAM_WORK_ORDER_DATASTORE' )
   LOOP
      ad_ctx_ddl.drop_preference (datastore_rec.pre_owner ||'.'|| datastore_rec.pre_name);
   END LOOP;

   FOR storage_rec IN		( SELECT pre_owner, pre_name
                       		    FROM ctxsys.ctx_preferences
                       		    WHERE pre_name = 'EAM_WORK_ORDER_STORAGE' )
   LOOP
      ad_ctx_ddl.drop_preference (storage_rec.pre_owner ||'.'|| storage_rec.pre_name);
   END LOOP;

   ------------------------------
   -- Create STORAGE preference
   ------------------------------
   -- Index tables use the same tablespaces used by other EAM tables and indexes
   -- or use logical tablespace for indexes (TRANSACTION_INDEXES).

   Log_Line (l_api_name || ': querying tablespace parameters ...', FND_LOG.LEVEL_EVENT, l_api_name);

   SELECT 'tablespace ' || tablespace_name ||
          ' storage (initial 1M next 1M minextents 1 maxextents unlimited pctincrease 0)'
     INTO tspace_tbl_param
     FROM all_tables
    WHERE owner = g_Prod_Schema AND table_name = 'EAM_WORK_ORDER_TEXT';

   SELECT 'tablespace ' || tablespace_name ||
          ' storage (initial 1M next 1M minextents 1 maxextents unlimited pctincrease 0)'
     INTO tspace_idx_param
     FROM all_indexes
    WHERE owner = g_Prod_Schema
      AND index_name = 'EAM_WORK_ORDER_TEXT_U1'
      AND table_name = 'EAM_WORK_ORDER_TEXT';

   Log_Line (l_api_name || ': creating STORAGE preference ...', FND_LOG.LEVEL_EVENT, l_api_name);

   ad_ctx_ddl.create_preference (g_Pref_Owner || '.EAM_WORK_ORDER_STORAGE', 'BASIC_STORAGE');

   ad_ctx_ddl.set_attribute (g_Pref_Owner || '.EAM_WORK_ORDER_STORAGE',
                             'I_TABLE_CLAUSE', tspace_tbl_param);

   ad_ctx_ddl.set_attribute (g_Pref_Owner || '.EAM_WORK_ORDER_STORAGE',
                             'K_TABLE_CLAUSE', tspace_tbl_param);

   ad_ctx_ddl.set_attribute (g_Pref_Owner || '.EAM_WORK_ORDER_STORAGE',
                             'R_TABLE_CLAUSE', tspace_tbl_param || ' LOB (data) STORE AS (CACHE)');

   -- Caching the "data" LOB column is the default (at later versions of Oracle Text).
   -- For index specific STORAGE preference, setting the clause "lob (data) (cache reads)"
   -- should be ensured (the "lob .. store as" clause is only for newly added LOB columns).
   -- alter table dr$prd_ctx_index$r modify lob (data) (cache reads);

   ad_ctx_ddl.set_attribute (g_Pref_Owner || '.EAM_WORK_ORDER_STORAGE',
                             'N_TABLE_CLAUSE', tspace_tbl_param);

   ad_ctx_ddl.set_attribute (g_Pref_Owner || '.EAM_WORK_ORDER_STORAGE',
                             'P_TABLE_CLAUSE', tspace_tbl_param);

   ad_ctx_ddl.set_attribute (g_Pref_Owner || '.EAM_WORK_ORDER_STORAGE',
                             'I_INDEX_CLAUSE', tspace_idx_param || ' COMPRESS 2');

   --ad_ctx_ddl.set_attribute (g_Pref_Owner || '.EAM_WORK_ORDER_STORAGE',
   --                          'I_ROWID_INDEX_CLAUSE', tspace_idx_param);

   --------------------------------
   -- Create DATASTORE preference
   --------------------------------

   Log_Line (l_api_name || ': creating DATASTORE preference ...', FND_LOG.LEVEL_EVENT, l_api_name);

   ad_ctx_ddl.Create_Preference (g_Pref_Owner || '.EAM_WORK_ORDER_DATASTORE', 'USER_DATASTORE');

   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_WORK_ORDER_DATASTORE', 'OUTPUT_TYPE', 'CLOB');
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_WORK_ORDER_DATASTORE', 'PROCEDURE', '"EAM_TEXT_CTX_PKG"."Get_Wo_Text_CLOB"');

   --ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_WORK_ORDER_DATASTORE', 'OUTPUT_TYPE', 'VARCHAR2');
   --ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_WORK_ORDER_DATASTORE', 'PROCEDURE', '"EAM_TEXT_CTX_PKG"."Get_Wo_Text_VARCHAR2"');

   ------------------------------------
   -- Create SECTION GROUP preference
   ------------------------------------

   --Log_Line (l_api_name || ': creating SECTION_GROUP preference ...', FND_LOG.LEVEL_EVENT, l_api_name);

   ad_ctx_ddl.Create_Section_Group (g_Pref_Owner || '.EAM_WORK_ORDER_SECTION_GROUP', 'AUTO_SECTION_GROUP');

   -------------------------------
   -- Create STOPLIST preference
   -------------------------------

   Log_Line (l_api_name || ': creating STOPLIST preference ...', FND_LOG.LEVEL_EVENT, l_api_name);

   -- This should create stoplist equivalent to CTXSYS.EMPTY_STOPLIST
   ad_ctx_ddl.Create_Stoplist (g_Pref_Owner || '.EAM_WORK_ORDER_STOPLIST');

   -------------------------------
   -- Create WORDLIST preference
   -------------------------------

   Log_Line (l_api_name || ': creating WORDLIST preference ...', FND_LOG.LEVEL_EVENT, l_api_name);

   ad_ctx_ddl.Create_Preference (g_Pref_Owner || '.EAM_WORK_ORDER_WORDLIST', 'BASIC_WORDLIST');

   -- Enable prefix indexing to improve performance for wildcard searches
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_WORK_ORDER_WORDLIST', 'PREFIX_INDEX', 'TRUE');
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_WORK_ORDER_WORDLIST', 'PREFIX_MIN_LENGTH', 2);
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_WORK_ORDER_WORDLIST', 'PREFIX_MAX_LENGTH', 32);
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_WORK_ORDER_WORDLIST', 'WILDCARD_MAXTERMS', 5000);

   -- This option should be TRUE only when left-truncated wildcard searching is expected
   -- to be frequent and needs to be fast (at the cost of increased index time and space).
   --
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_WORK_ORDER_WORDLIST', 'SUBSTRING_INDEX', 'FALSE');

   -- WORDLIST attribute defaults: STEMMER: 'ENGLISH'; FUZZY_MATCH: 'GENERIC'
   -- Use automatic language detection for stemming and fuzzy matching
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_WORK_ORDER_WORDLIST', 'STEMMER', 'AUTO');
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_WORK_ORDER_WORDLIST', 'FUZZY_MATCH', 'AUTO');
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_WORK_ORDER_WORDLIST', 'FUZZY_SCORE', 40);
   ad_ctx_ddl.Set_Attribute (g_Pref_Owner || '.EAM_WORK_ORDER_WORDLIST', 'FUZZY_NUMRESULTS', 120);

   -----------------------------------------------
   -- Create language-specific LEXER preferences
   -----------------------------------------------

   Log_Line (l_api_name || ': creating language-specific LEXER preferences ...', FND_LOG.LEVEL_EVENT, l_api_name);
   /* For now we will use basic lexer */
   Lexer_Name := g_Pref_Owner || '.EAM_WORK_ORDER_LEXER_BASIC';

/*
   FOR i IN Lang_Code_List.FIRST .. Lang_Code_List.LAST
   LOOP
      Lexer_Name := g_Pref_Owner || '.EAM_WORK_ORDER_LEXER_' || Lang_Code_List(i);

      IF ( Lang_Code_List(i) = 'JA' ) THEN

         -- Use JAPANESE_LEXER if db charset is UTF8, JA16SJIS, or JA16EUC.
         IF ( eam_text_util.get_DB_Version_Num >= 9.0 ) THEN
            ad_ctx_ddl.Create_Preference (Lexer_Name, 'JAPANESE_LEXER');
         ELSE
            ad_ctx_ddl.Create_Preference (Lexer_Name, 'JAPANESE_VGRAM_LEXER');
         END IF;

      ELSIF ( Lang_Code_List(i) = 'KO' ) THEN

         -- Use KOREAN_MORPH_LEXER if db charset is UTF8 or KO16KSC5601.
         IF ( eam_text_util.get_DB_Version_Num >= 9.0 ) THEN
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

         IF ( eam_text_util.get_DB_Version_Num >= 9.2 ) THEN
            ad_ctx_ddl.Create_Preference (Lexer_Name, 'CHINESE_LEXER');
         ELSE
            ad_ctx_ddl.Create_Preference (Lexer_Name, 'CHINESE_VGRAM_LEXER');
         END IF;

      ELSE
         -- All other languages use basic lexer.  */

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
         --IF ( eam_text_util.get_DB_Version_Num >= 9.2 ) THEN
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
/*
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
*/
   ----------------------------------
   -- Create MULTI_LEXER preference
   ----------------------------------
/*
   Log_Line (l_api_name || ': creating MULTI_LEXER preference ...');

   ad_ctx_ddl.Create_Preference (g_Pref_Owner || '.EAM_WORK_ORDER_MULTI_LEXER', 'MULTI_LEXER');

   FOR i IN Lang_Code_List.FIRST .. Lang_Code_List.LAST
   LOOP
      Lexer_Name := g_Pref_Owner || '.EAM_WORK_ORDER_LEXER_' || Lang_Code_List(i);

      -- The language column is case-independent, and can contain either the NLS name
      -- or abbreviation of the language.  If the table uses some other value for the
      -- language, that alternate value needs to be specified as the fourth argument
      -- when adding the sub lexers:

      IF ( Lang_Code_List(i) = 'US' ) THEN
         -- US English lexer to handle everything else.
         ad_ctx_ddl.Add_Sub_Lexer ( g_Pref_Owner || '.EAM_WORK_ORDER_MULTI_LEXER', 'DEFAULT'
                                  , g_Pref_Owner || '.EAM_WORK_ORDER_LEXER_US' );
      ELSE
         ad_ctx_ddl.Add_Sub_Lexer
         (  lexer_name    =>  g_Pref_Owner || '.EAM_WORK_ORDER_MULTI_LEXER'
         ,  language      =>  Lang_Code_List(i)
         ,  sub_lexer     =>  Lexer_Name
         --,  alt_value     =>  Lang_ISO_List(i)
         );
      END IF;

   END LOOP;*/

   x_return_status := l_return_status;

   Log_Line (l_api_name || ': end', FND_LOG.LEVEL_EVENT, l_api_name);

EXCEPTION

   WHEN G_EXC_ERROR THEN
      x_return_status := G_STATUS_ERROR;

   WHEN others THEN
      Log_Line (l_api_name || ': Error: ' || SQLERRM, FND_LOG.LEVEL_EVENT, l_api_name);
      x_return_status := G_STATUS_UNEXP_ERROR;

END Set_Wo_Index_Preferences;




-- -----------------------------------------------------------------------------
--			   Process_Wo_Text_Index
-- -----------------------------------------------------------------------------

PROCEDURE Process_Wo_Text_Index
(
   p_Index_Name		IN           VARCHAR2
,  p_Action		IN           VARCHAR2
,  x_return_status	OUT  NOCOPY  VARCHAR2
)
IS
   l_api_name		CONSTANT  VARCHAR2(30)  :=  'Process_Wo_Text_Index';
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
   sql_stmt			VARCHAR2(32767);
BEGIN

   Log_Line (l_api_name || ': begin: Index_Name=' || p_Index_Name || ' Action=' || p_Action, FND_LOG.LEVEL_EVENT, l_api_name);

   l_return_status := G_STATUS_SUCCESS;

   IF ( p_Action NOT IN (1,2,4) ) THEN
      Log_Line (l_api_name || ': Error: invalid value for parameter p_Action: ' || p_Action, FND_LOG.LEVEL_EVENT, l_api_name);
      RAISE G_EXC_ERROR;
   END IF;

   -- Check for existing indexes in the EAM product, APPS Universal, and interMedia schemas.
   --
   FOR index_rec IN ( SELECT owner, index_name, status, domidx_status, domidx_opstatus
                      FROM all_indexes
                      WHERE ( owner = g_Prod_Schema OR owner = USER OR owner = g_Ctx_Schema )
                        AND table_name = 'EAM_WORK_ORDER_TEXT'
                        AND index_name = p_Index_Name )
   LOOP
      -- Check index schema
      --
      IF ( index_rec.owner <> g_Index_Owner )
      THEN
         Log_Line (l_api_name || ': Error: index exists in wrong schema: ' || index_rec.owner, FND_LOG.LEVEL_EVENT, l_api_name);
         BEGIN
            Log_Line (l_api_name || ': dropping index: ' || index_rec.owner || '.' || p_Index_Name, FND_LOG.LEVEL_EVENT, l_api_name);
            EXECUTE IMMEDIATE 'DROP INDEX ' || index_rec.owner || '.' || p_Index_Name || ' FORCE';
         EXCEPTION
            WHEN others THEN
               Log_Line (l_api_name || ': Error: DROP INDEX ' || index_rec.owner || '.' || p_Index_Name || ' FORCE: ' || SQLERRM, FND_LOG.LEVEL_EVENT, l_api_name);
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
                      || ' domidx_opstatus=' || index_rec.domidx_opstatus, FND_LOG.LEVEL_EVENT, l_api_name);
         ELSE
            Log_Line (l_api_name || ': valid index exists: ' || index_rec.owner || '.' || p_Index_Name, FND_LOG.LEVEL_EVENT, l_api_name);
         END IF;

      END IF;  -- index owner

   END LOOP;  -- check for any existing indexes

   IF ( l_return_status NOT IN (G_STATUS_SUCCESS, G_STATUS_WARNING) ) THEN
      RAISE G_EXC_ERROR;
   END IF;

   --   x_return_status := l_return_status;

   -- Set indexing flags depending on the action and the index status

   IF ( p_Action = 1 ) THEN
      IF ( l_index_exists ) THEN
         IF ( l_index_valid ) THEN
            Log_Line (l_api_name || ': Error: cannot execute Create because the index exists.', FND_LOG.LEVEL_EVENT, l_api_name);
            Request_Log ('EAM_TEXT_INDEX_EXISTS');
            l_return_status := G_STATUS_WARNING;
            l_create_index := FALSE;
         ELSE
            l_drop_index := TRUE;
         END IF;
      END IF;

   ELSIF ( p_Action = 2 ) THEN
      l_drop_index := l_index_exists;
/*
   ELSIF ( p_Action = 'UPGRADE' ) THEN
      IF ( l_index_exists ) THEN
         IF ( l_index_valid ) THEN
            Log_Line (l_api_name || ': Upgrade: skipping index creation because valid index exists.', FND_LOG.LEVEL_EVENT, l_api_name);
            l_create_index := FALSE;
         ELSE
            l_drop_index := TRUE;
         END IF;
      END IF;
*/
   ELSIF ( p_Action = 4) THEN
      l_create_index := FALSE;
      IF ( l_index_exists ) THEN
         l_drop_index := TRUE;
      ELSE
         Log_Line (l_api_name || ': Warning: cannot execute Drop because the index does not exist.', FND_LOG.LEVEL_EVENT, l_api_name);
	  Request_Log ('EAM_TEXT_INDEX_NOT_EXISTS');
         l_return_status := G_STATUS_WARNING;
      END IF;

   END IF;  -- Action

   IF ( l_drop_index ) THEN
      BEGIN
         Log_Line (l_api_name || ': dropping index: ' || g_Index_Owner || '.' || p_Index_Name, FND_LOG.LEVEL_EVENT, l_api_name);
 	 request_log('EAM_TEXT_DROP');
         EXECUTE IMMEDIATE 'DROP INDEX ' || g_Index_Owner || '.' || p_Index_Name || ' FORCE';
         IF ( l_index_valid ) THEN
            Log_Line (l_api_name || ': existing index has been successfully dropped.', FND_LOG.LEVEL_EVENT, l_api_name);
         ELSE
            Log_Line (l_api_name || ': invalid index has been dropped.', FND_LOG.LEVEL_EVENT, l_api_name);
         END IF;
      EXCEPTION
         WHEN others THEN
            Log_Line (l_api_name || ': Error: DROP INDEX ' || g_Index_Owner || '.' || p_Index_Name || ' FORCE: ' || SQLERRM, FND_LOG.LEVEL_EVENT, l_api_name);
            l_return_status := G_STATUS_ERROR;
      END;
   END IF;  -- drop index

   IF ( l_return_status NOT IN (G_STATUS_SUCCESS, G_STATUS_WARNING) ) THEN
      RAISE G_EXC_ERROR;
   END IF;

   -- Build index

   IF ( l_create_index ) THEN

        Log_Line ('Calling Set_Wo_Index_Preferences ...', FND_LOG.LEVEL_EVENT, l_api_name);
	request_log('EAM_TEXT_INDEX_PREF');
	Set_Wo_Index_Preferences
	(
	     p_Index_Name     =>  p_Index_Name
	   , x_return_status  =>  l_return_status
	);

	IF ( l_return_status NOT IN (G_STATUS_SUCCESS, G_STATUS_WARNING) ) THEN
	   RAISE G_EXC_ERROR;
	END IF;

	log_Line ('Re-created Text Index preferences.', FND_LOG.LEVEL_EVENT, l_api_name);

      -- Determine index memory parameter value
      --ctxsys.CTX_ADM.Set_Parameter ('MAX_INDEX_MEMORY', l_Index_Memory);
      BEGIN
         SELECT par_value INTO l_Index_Memory_Max
         FROM ctx_parameters
         WHERE par_name = 'MAX_INDEX_MEMORY';
      EXCEPTION
         WHEN no_data_found THEN
            Log_Line (l_api_name || ': Error: MAX_INDEX_MEMORY parameter record not found.', FND_LOG.LEVEL_EVENT, l_api_name);
            RAISE G_EXC_ERROR;
      END;

      IF ( TO_NUMBER(l_Index_Memory) > TO_NUMBER(l_Index_Memory_Max) ) THEN
         l_Index_Memory := l_Index_Memory_Max;
      END IF;

      Log_Line (l_api_name || ': CTX index_memory: ' || l_Index_Memory, FND_LOG.LEVEL_EVENT, l_api_name);

      -- Decide whether parallel indexing can be used, depending on DB version.

      IF ( eam_text_util.get_DB_Version_Num >= 9.2 ) THEN
         l_index_parallel := c_parallel_clause;
         Log_Line (l_api_name || ': DB version: ' || eam_text_util.get_DB_Version_Str || ', using parallel clause: ' || l_index_parallel, FND_LOG.LEVEL_EVENT, l_api_name);
      END IF;

      -- Start logging indexing progress

      IF ( g_Log_Dir IS NOT NULL ) THEN
         BEGIN
            Log_Line (l_api_name || ': CTX Log_Directory: ' || g_Log_Dir, FND_LOG.LEVEL_EVENT, l_api_name);
            ctxsys.CTX_ADM.Set_Parameter ( 'LOG_DIRECTORY', g_Log_Dir );
            Log_Line (l_api_name || ': CTX Start_Log', FND_LOG.LEVEL_EVENT, l_api_name);
            CTX_OUTPUT.Start_Log ( LOWER(p_Index_Name) || '.log' );
            ctx_Log_File_Name := CTX_OUTPUT.LogFileName;
            Log_Line (l_api_name || ': CTX LogFileName:   ' || ctx_Log_File_Name, FND_LOG.LEVEL_EVENT, l_api_name);
         EXCEPTION
            WHEN others THEN
               Log_Line (l_api_name || ': Warning: CTX Start_Log: ' || SQLERRM, FND_LOG.LEVEL_EVENT, l_api_name);
               l_return_status := G_STATUS_WARNING;
         END;
      END IF;

      -- Choose indexing method
      --IF ( ) THEN
      --   l_index_populate := 'NOPOPULATE';
      --END IF;

      IF ( l_create_index ) THEN
        BEGIN
          request_log('EAM_TEXT_CREATE');
          eam_text_util.Set_Context ('CREATE_INDEX');

          sql_stmt :=
            'CREATE INDEX ' || g_Index_Owner || '.' || p_Index_Name              ||
            ' ON ' || g_Prod_Schema || '.EAM_WORK_ORDER_TEXT (text)               ' ||
            ' INDEXTYPE IS CTXSYS.context                                      ' ||
            ' PARAMETERS                                                       ' ||
            ' (''DATASTORE      ' || g_Pref_Owner || '.EAM_WORK_ORDER_DATASTORE      ' ||
            '  WORDLIST         ' || g_Pref_Owner || '.EAM_WORK_ORDER_WORDLIST       ' ||
            '  STOPLIST         ' || g_Pref_Owner || '.EAM_WORK_ORDER_STOPLIST       ' ||
	    /* For now we will use basic lexer. For using multi lexer we need language column */
            '  LEXER            ' || g_Pref_Owner || '.EAM_WORK_ORDER_LEXER_BASIC    ' ||
           -- '  LANGUAGE COLUMN  language                                       ' ||
            '  SECTION GROUP    ' || g_Pref_Owner || '.EAM_WORK_ORDER_SECTION_GROUP  ' ||
           -- '  SECTION GROUP    CTXSYS.NULL_SECTION_GROUP  '                     ||
            '  STORAGE          ' || g_Pref_Owner || '.EAM_WORK_ORDER_STORAGE        ' ||
            '  MEMORY           ' || l_Index_Memory ||
            --'  ' || l_index_populate ||
            ' '')'
	    || '  ' || l_index_parallel
	    ;

          Log_Line (l_api_name || ': creating index ' || g_Index_Owner || '.' || p_Index_Name || ' ...', FND_LOG.LEVEL_EVENT, l_api_name);
          --Log_Line (l_api_name || ': sql_stmt = ' || sql_stmt || ' /* End SQL */');

          EXECUTE IMMEDIATE sql_stmt;

          Log_Line (l_api_name || ': done creating index.', FND_LOG.LEVEL_EVENT, l_api_name );

        EXCEPTION

         WHEN others THEN
            Log_Line (l_api_name || ': Error creating index ' || g_Index_Owner || '.' || p_Index_Name || ': ' || SQLERRM, FND_LOG.LEVEL_EVENT, l_api_name);

            -- Drop the index in case of an error during index creation to prevent the table lock.
            BEGIN
               EXECUTE IMMEDIATE 'DROP INDEX ' || g_Index_Owner || '.' || p_Index_Name || ' FORCE';
            EXCEPTION
               WHEN others THEN
                  Log_Line (l_api_name || ': Error: DROP INDEX ' || g_Index_Owner || '.' || p_Index_Name || ' FORCE: ' || SQLERRM, FND_LOG.LEVEL_EVENT, l_api_name);
                  RAISE G_EXC_ERROR;
            END;

            RAISE G_EXC_ERROR;

        END;  -- execute sql
      END IF;  -- create index
/*
      Log_Line (l_api_name || ': calling Incremental_Sync');

      eam_text_util.Incremental_Sync
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
            Log_Line (l_api_name || ': CTX End_Log', FND_LOG.LEVEL_EVENT, l_api_name);
         EXCEPTION
            WHEN others THEN
               Log_Line (l_api_name || ': Warning: CTX End_Log: ' || SQLERRM, FND_LOG.LEVEL_EVENT, l_api_name);
               l_return_status := G_STATUS_WARNING;
         END;
      END IF;

      -- Check the created index status

         SELECT idx_docid_count, idx_status
           INTO l_idx_docid_count, l_idx_status
         FROM ctxsys.ctx_indexes
         WHERE idx_owner = g_Prod_Schema AND idx_name = 'EAM_WORK_ORDER_TEXT_CTX1'
           AND idx_table = 'EAM_WORK_ORDER_TEXT';

         IF NOT( l_idx_status = 'INDEXED' ) THEN
            Log_Line (l_api_name || ': Error: Index status is ' || l_idx_status || '.', FND_LOG.LEVEL_EVENT, l_api_name);
            l_return_status := G_STATUS_ERROR;
         END IF;

         IF ( NVL(l_idx_docid_count, 0) = 0 ) THEN
            Log_Line (l_api_name || ': Error: Indexed document count is ' || TO_CHAR(l_idx_docid_count) || '.', FND_LOG.LEVEL_EVENT, l_api_name);
            l_return_status := G_STATUS_ERROR;
         END IF;

         IF ( l_return_status NOT IN (G_STATUS_SUCCESS, G_STATUS_WARNING) ) THEN
            RAISE G_EXC_ERROR;
         END IF;

   END IF;  -- build index

   x_return_status := l_return_status;
   Log_Line (l_api_name || ': end', FND_LOG.LEVEL_EVENT, l_api_name);

EXCEPTION

   WHEN G_EXC_ERROR THEN
      x_return_status := G_STATUS_ERROR;

   WHEN others THEN
      Log_Line (l_api_name || ': Error: ' || SQLERRM, FND_LOG.LEVEL_EVENT, l_api_name);
      x_return_status := G_STATUS_UNEXP_ERROR;

END Process_Wo_Text_Index;



-- -----------------------------------------------------------------------------
--			     Build_Text_Index
-- -----------------------------------------------------------------------------
/*
   p_text_context :
                    1 - Asset
		    2 - Work Order

   p_action :
                    1 - Create
		    2 - Update / Rebuild
                    3 - Optimize
		    4 - Drop
		    5-  When work order status code is updated from user defined statuses form. The Status_Id which was updated will be passed in p_dummy1 parameter
*/


PROCEDURE Build_Text_Index
(
    ERRBUF		OUT  NOCOPY  VARCHAR2
 ,  RETCODE		OUT  NOCOPY  NUMBER
 ,  p_text_context      IN           NUMBER
 ,  p_Action		IN           NUMBER
 ,  p_dummy1            IN           NUMBER   DEFAULT  NULL
 ,  p_optlevel		IN	     NUMBER   DEFAULT  NULL
 ,  p_dummy2            IN           NUMBER   DEFAULT  NULL
 ,  p_maxtime		IN           NUMBER   DEFAULT  AD_CTX_DDL.Maxtime_Unlimited
)
IS
   l_api_name		CONSTANT VARCHAR2(30)  :=  'Build_Text_Index';
   l_Index_Name			 VARCHAR2(30);
   l_return_status		 VARCHAR2(1);
   l_optim_level		 VARCHAR2(30) := AD_CTX_DDL.Optlevel_Full;
BEGIN

   IF ( g_Log_Mode IS NULL ) THEN
      set_Log_Mode ('FILE');
      --set_Log_Mode ('SQLPLUS');
   END IF;

   Log_Line ('Begin : Action=' || p_Action, FND_LOG.LEVEL_EVENT, l_api_name);

   l_return_status := G_STATUS_SUCCESS;

   IF (p_optlevel IS NOT NULL) THEN
      IF (p_optlevel = 1) THEN
         l_optim_level := AD_CTX_DDL.Optlevel_Fast;
      ELSIF (p_optlevel = 2) THEN
         l_optim_level := AD_CTX_DDL.Optlevel_Full;
      END IF;
   END IF;

   IF p_text_context = 1 THEN
	      l_Index_Name := 'EAM_ASSET_TEXT_CTX1';

	      Log_Line ('Calling Process_Asset_Text_Index ...', FND_LOG.LEVEL_EVENT, l_api_name);

	      IF (p_Action IN (1,2,4)) THEN
		 Process_Asset_Text_Index
		 (
		    p_Index_Name     =>  l_Index_Name
		 ,  p_Action         =>  p_Action
		 ,  x_return_status  =>  l_return_status
		 );
	      ELSIF (p_Action = 3) THEN
                 Log_Line ('Calling Optimize_Index ...', FND_LOG.LEVEL_EVENT, l_api_name);
                 request_log('EAM_TEXT_OPTIMIZE');
		 Optimize_Index
		 (
		   x_return_status => l_return_status
		 , p_optlevel      => l_optim_level
		 , p_maxtime       => p_maxtime
		 , p_index_name	   => l_Index_Name
		 );
	      END IF;
   ELSE   --for workorders

	      l_Index_Name := 'EAM_WORK_ORDER_TEXT_CTX1';

	      Log_Line ('Calling Process_Wo_Text_Index ...', FND_LOG.LEVEL_EVENT, l_api_name);

	      IF (p_Action IN (1,2,4)) THEN
		 Process_Wo_Text_Index
		 (
		    p_Index_Name     =>  l_Index_Name
		 ,  p_Action         =>  p_Action
		 ,  x_return_status  =>  l_return_status
		 );
	      ELSIF (p_Action = 3) THEN
                 Log_Line ('Calling Optimize_Index ...', FND_LOG.LEVEL_EVENT, l_api_name);
	         request_log('EAM_TEXT_OPTIMIZE');
		 Optimize_Index
		 (
		   x_return_status => l_return_status
		 , p_optlevel      => l_optim_level
		 , p_maxtime       => p_maxtime
		 , p_index_name	   => l_Index_Name
		 );
		ELSIF (p_action = 5) THEN
		     Log_Line ('Calling Eam_Text_Util.Process_Status_Update_Event ...', FND_LOG.LEVEL_EVENT, l_api_name);

			 Eam_Text_Util.Process_Status_Update_Event(p_status_id => p_dummy1,    --User Defined Status Id whose status code has been updated
														p_commit  =>   FND_API.G_TRUE,
			                                                                                        x_return_status => l_return_status);

                     Log_Line ('after calling update status event ...Return Status is : '|| l_return_status, FND_LOG.LEVEL_EVENT, l_api_name);
	      END IF;

   END IF;

   IF ( l_return_status NOT IN (G_STATUS_SUCCESS, G_STATUS_WARNING) ) THEN
      RAISE G_EXC_ERROR;
   END IF;

   -- Assign conc request return code

   IF ( l_return_status = G_STATUS_SUCCESS ) THEN
      RETCODE := G_RETCODE_SUCCESS;
      ERRBUF  := FND_MESSAGE.Get_String('EAM', 'EAM_TEXT_INDEX_SUCCESS');
   ELSIF ( l_return_status = G_STATUS_WARNING ) THEN
      RETCODE := G_RETCODE_WARNING;
      ERRBUF  := FND_MESSAGE.Get_String('EAM', 'EAM_TEXT_INDEX_WARNING');
   ELSE
      RETCODE := G_RETCODE_ERROR;
      ERRBUF  := FND_MESSAGE.Get_String('EAM', 'EAM_TEXT_INDEX_FAILURE');
   END IF;

   IF NOT(g_Conc_Req_flag) THEN
      FND_FILE.Close;
   END IF;

   Log_Line (l_api_name || ': end',  FND_LOG.LEVEL_EVENT, l_api_name);

EXCEPTION

   WHEN G_EXC_ERROR THEN
      Log_Line (l_api_name || ': Error.', FND_LOG.LEVEL_EVENT, l_api_name);
      RETCODE := G_RETCODE_ERROR;
      ERRBUF  := FND_MESSAGE.Get_String('EAM', 'EAM_TEXT_INDEX_FAILURE');
      ERRBUF := substr(ERRBUF || '(' || G_PKG_NAME || '.' ||G_PKG_NAME||'):'|| SQLERRM,1,240);
      log_line(ERRBUF, FND_LOG.LEVEL_EVENT, l_api_name);

      IF NOT(g_Conc_Req_flag) THEN
         FND_FILE.Close;
      END IF;

   WHEN others THEN
      Log_Line (l_api_name || ': Unexpected Error: ' || SQLERRM, FND_LOG.LEVEL_EVENT, l_api_name);
      RETCODE := G_RETCODE_ERROR;
      ERRBUF  := FND_MESSAGE.Get_String('EAM', 'EAM_CP_FAILURE');
      ERRBUF := substr(ERRBUF || '(' || G_PKG_NAME || '.' ||G_PKG_NAME||'):'|| SQLERRM,1,240);

      IF NOT(g_Conc_Req_flag) THEN
         FND_FILE.Close;
      END IF;

END Build_Text_Index;


-- -----------------------------------------------------------------------------
--  				Optimize_Index
-- -----------------------------------------------------------------------------

-- Start : Concurrent Program for Optimize Intermedia index
PROCEDURE Optimize_Index
(
   x_return_status OUT NOCOPY VARCHAR2
 , p_optlevel      IN         VARCHAR2 DEFAULT  AD_CTX_DDL.Optlevel_Full
 , p_maxtime       IN         NUMBER   DEFAULT  AD_CTX_DDL.Maxtime_Unlimited
 , p_index_name	   IN         VARCHAR2
)
IS

   l_api_name  CONSTANT  VARCHAR2(30)  := 'Optimize_Index';
   l_maxtime             NUMBER := NVL(p_maxtime,AD_CTX_DDL.Maxtime_Unlimited);

BEGIN

   log_line(l_api_name ||' : Started AD_CTX_DDL.Optimize_Index..',  FND_LOG.LEVEL_EVENT, l_api_name);
   log_line(l_api_name ||' : Optimization Level        :'||p_optlevel,  FND_LOG.LEVEL_EVENT, l_api_name);
   log_line(l_api_name ||' : Maximum Optimization Time :'||p_maxtime,  FND_LOG.LEVEL_EVENT, l_api_name);

   x_return_status := G_STATUS_SUCCESS;

   -- Maxtime should be null for FAST Optimize mode
   IF p_optlevel ='FAST' THEN
      l_maxtime := NULL;
   END IF;

   AD_CTX_DDL.Optimize_Index ( idx_name  =>  g_Index_Owner ||'.'|| p_index_name
                             , optlevel  =>  NVL(p_optlevel,AD_CTX_DDL.Optlevel_Full)
                             , maxtime   =>  l_maxtime);

  log_line(l_api_name ||' : Completed AD_CTX_DDL.Optimize_Index..',  FND_LOG.LEVEL_EVENT, l_api_name);


EXCEPTION
   WHEN OTHERS THEN
      x_return_status := G_STATUS_UNEXP_ERROR;
      log_line(l_api_name ||' : Index optimization has failed ...',  FND_LOG.LEVEL_EVENT, l_api_name);
      -- conc_status := FND_CONCURRENT.set_completion_status('ERROR', l_err_msg);

END Optimize_Index;
-- End : Concurrent Program for Optimize iM index



-- *****************************************************************************
-- **                      Package initialization block                       **
-- *****************************************************************************

BEGIN

   -- Get EAM product schema name
   --
   g_installed := FND_INSTALLATION.Get_App_Info ('EAM', g_inst_status, g_industry, g_Prod_Schema);

   g_Index_Owner := g_Prod_Schema;
   g_Pref_Owner  := g_Prod_Schema;

END EAM_TEXT_INDEX_PVT;

/
