--------------------------------------------------------
--  DDL for Package Body JTF_TAE_SQL_LIB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TAE_SQL_LIB_PVT" AS
/* $Header: jtfvtslb.pls 120.0 2005/06/02 18:23:04 appldev ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TAE_SQL_LIB_PVT
--    ---------------------------------------------------
--    PURPOSE
--      This is to store the commonly used (hand-tuned) SQL
--      used by the TAE Generation Program
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is available for private use only
--
--    HISTORY
--      08/04/02    JDOCHERT  Created
--      09/20/02    SBEHERA  Added for CNR Like to avoid table scan
--      06/19/2003  EIHSU    worker_id added
--      10/20/04    ACHANDA  bug 3966249 fix
--      11/10/04    ACHANDA  bug 4002460 fix
--      12/08/04    ACHANDA  bug 4048033 fix : added qualifer comb 61950277 and 62598971
--      02/24/05    ACHANDA  bug 4192854 fix : added qualifier comb 934313 and 924631
--      04/12/05    ACHANDA  bug 4301045 fix : changed the new mode matching sql for  qualifier comb 61950277 and 62598971
--                                             to refer to jtf_changed_terr_all
--      04/12/05    ACHANDA  Bug 4307593     : remove the worker_id condition from NMC_DYN package
--      05/17/05    ACHANDA  Bug 4385668     : modify the new mode inline view so that it contains NO_MERGE hint and
--                                             DISTINCT clause and also remove wrong hints from new mode matching SQL
--    End of Comments
--

--------------------------------------------------
---     GLOBAL Declarations Starts here      -----
--------------------------------------------------

/*********************************************************
** JDOCHERT: 08/04/02
** Gets the Static pre-built, hand-tuned Index
** Creation Statement for certain Qualifier Combinations
**********************************************************/
PROCEDURE get_qual_comb_index (
      p_rel_prod                  IN   NUMBER,
      p_reverse_flag              IN   VARCHAR2,
      p_source_id                 IN   NUMBER,
      p_trans_object_type_id      IN   NUMBER,
      p_table_name                IN   VARCHAR2,
      -- arpatel: 09/09/03 added run mode flag
      p_run_mode                  IN   VARCHAR2 := 'TAP',
      x_statement                 OUT NOCOPY  VARCHAR2,
      alter_statement             OUT NOCOPY  VARCHAR2) AS

    l_trans_idx_name    varchar2(30);
    l_ora_username      VARCHAR2(100);
BEGIN
   /* ARPATEL 04/26/2004 GSCC error for hardcoded schema name */
   SELECT u.oracle_username
    INTO l_ora_username
    FROM fnd_product_installations i, fnd_application a, fnd_oracle_userid u
    WHERE a.application_short_name = 'JTF'
      AND a.application_id = i.application_id
      AND u.oracle_id = i.oracle_id;

   l_trans_idx_name := 'JTF_TAE_TN' ||
                       TO_CHAR(ABS(p_trans_object_type_id)) || '_' || TO_CHAR(p_rel_prod);

   /* Postal Code + Country Combination */
   IF ( p_rel_prod = 4841  AND p_reverse_flag = 'N' ) THEN

      if p_run_mode = 'OIC_TAP'
      then
      l_trans_idx_name := l_trans_idx_name || '_NDSC';
      elsif p_run_mode = 'NEW_MODE_TAP'
      then
      l_trans_idx_name := l_trans_idx_name || '_NDW';
      else
      l_trans_idx_name := l_trans_idx_name || '_ND';
      end if;

      x_statement := 'CREATE INDEX ' || l_ora_username || '.' || l_trans_idx_name || ' ON ' || p_table_name;
      x_statement := x_statement || ' ( WORKER_ID, SQUAL_CHAR07, SQUAL_CHAR06 ) ';

      /* ARPATEL Bug#3597884 05/10/2004 */
      alter_statement := 'ALTER INDEX ' || l_ora_username || '.' || l_trans_idx_name || ' NOPARALLEL';

   /* Customer Name Range + Postal Code + Country Combination */
   ELSIF ( p_rel_prod = 324347 AND p_reverse_flag = 'N' ) THEN

      if p_run_mode = 'OIC_TAP'
      then
      l_trans_idx_name := l_trans_idx_name || '_NDSC';
      elsif p_run_mode = 'NEW_MODE_TAP'
      then
      l_trans_idx_name := l_trans_idx_name || '_NDW';
      else
      l_trans_idx_name := l_trans_idx_name || '_ND';
      end if;

      x_statement := 'CREATE INDEX '|| l_ora_username ||'.' || l_trans_idx_name || ' ON ' || p_table_name;
      x_statement := x_statement || ' ( WORKER_ID, SQUAL_FC01, SQUAL_CHAR01, SQUAL_CHAR06, SQUAL_CHAR07 ) ';

      /* ARPATEL Bug#3597884 05/10/2004 */
      alter_statement := 'ALTER INDEX ' || l_ora_username || '.' || l_trans_idx_name || ' NOPARALLEL';

   /* REVERSE: Customer Name Range + Postal Code + Country Combination */
   ELSIF ( p_rel_prod = 324347 AND p_reverse_flag = 'Y' ) THEN

      if p_run_mode = 'OIC_TAP'
      then
      l_trans_idx_name := l_trans_idx_name || 'X_NDSC';
      elsif p_run_mode = 'NEW_MODE_TAP'
      then
      l_trans_idx_name := l_trans_idx_name || 'X_NDW';
      else
      l_trans_idx_name := l_trans_idx_name || 'X_ND';
      end if;

      x_statement := 'CREATE INDEX ' || l_ora_username || '.' || l_trans_idx_name || ' ON ' || p_table_name;
      x_statement := x_statement || ' ( WORKER_ID, SQUAL_CHAR07, SQUAL_CHAR06, SQUAL_CHAR01 ) ';

      /* ARPATEL Bug#3597884 05/10/2004 */
      alter_statement := 'ALTER INDEX ' || l_ora_username || '.' || l_trans_idx_name || ' NOPARALLEL';

   END IF;


END;

/*********************************************************
** DBLEE: 08/26/03
** Function to return Static SELECT columns
*********************************************************/
FUNCTION add_SELECT_cols( p_new_mode_fetch  CHAR )
RETURN VARCHAR2 AS

   lx_SELECT_clause     VARCHAR2(2000) := NULL;

BEGIN

   -- dblee: 08/26/03: added switch for new mode TAP
   IF p_new_mode_fetch <> 'Y' THEN

      RETURN lx_SELECT_CLAUSE ||
            G_INDENT || '       trans_object_id ' || g_newline ||
            G_INDENT || '     , trans_detail_object_id ' || g_newline ||
            -- eihsu: 06/19/2003 worker_id
            G_INDENT || '     , worker_id ' || g_newline ||
            G_INDENT || '     , header_id1 ' || g_newline ||
            G_INDENT || '     , header_id2 ' || g_newline ||
            G_INDENT || '     , P_SOURCE_ID ' || g_newline ||
            G_INDENT || '     , P_TRANS_OBJECT_TYPE_ID ' || g_newline ||
            G_INDENT || '     , L_SYSDATE ' || g_newline ||
            G_INDENT || '     , L_USER_ID ' || g_newline ||
            G_INDENT || '     , L_SYSDATE ' || g_newline ||
            G_INDENT || '     , L_USER_ID ' || g_newline ||
            G_INDENT || '     , L_USER_ID ' || g_newline ||
            G_INDENT || '     , L_REQUEST_ID ' || g_newline ||
            G_INDENT || '     , L_PROGRAM_APPL_ID ' || g_newline ||
            G_INDENT || '     , L_PROGRAM_ID ' || g_newline ||
            G_INDENT || '     , L_SYSDATE ' || g_newline ||
            G_INDENT || '     , ILV.terr_id ' || g_newline ||
            G_INDENT || '     , ILV.absolute_rank ' || g_newline ||
            G_INDENT || '     , ILV.top_level_terr_id '|| g_newline ||
            G_INDENT || '     , ILV.num_winners ' || g_newline ||
            G_INDENT || '     , ILV.org_id ' || g_newline;

   ELSE -- p_new_mode_fetch = 'Y'

      RETURN lx_SELECT_CLAUSE ||
            G_INDENT || '       A.TRANS_OBJECT_ID' || g_newline ||
            G_INDENT || '       , A.TRANS_DETAIL_OBJECT_ID' || g_newline ||
            G_INDENT || '       , A.HEADER_ID1' || g_newline ||
            G_INDENT || '       , A.HEADER_ID2' || g_newline ||
            G_INDENT || '       , p_source_id' || g_newline ||
            G_INDENT || '       , p_trans_object_type_id' || g_newline ||
            G_INDENT || '       , l_sysdate' || g_newline ||
            G_INDENT || '       , L_USER_ID' || g_newline ||
            G_INDENT || '       , l_sysdate' || g_newline ||
            G_INDENT || '       , L_USER_ID' || g_newline ||
            G_INDENT || '       , L_USER_ID' || g_newline ||
            G_INDENT || '       , L_REQUEST_ID' || g_newline ||
            G_INDENT || '       , L_PROGRAM_APPL_ID' || g_newline ||
            G_INDENT || '       , L_PROGRAM_ID' || g_newline ||
            G_INDENT || '       , l_sysdate' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC01' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC02' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC03' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC04' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC05' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC01' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC02' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC03' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC04' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC05' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC06' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC07' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC08' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC09' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC10' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR01' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR02' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR03' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR04' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR05' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR06' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR07' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR08' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR09' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR10' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR11' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR12' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR13' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR14' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR15' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR16' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR17' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR18' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR19' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR20' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR21' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR22' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR23' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR24' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR25' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR26' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR27' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR28' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR30' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR31' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR32' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR33' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR34' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR35' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR36' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR37' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR38' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR39' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR40' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR41' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR42' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR43' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR44' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR45' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR46' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR47' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR48' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR49' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR50' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR51' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR52' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR53' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR54' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR55' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR56' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR57' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR58' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR59' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR60' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM01' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM02' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM03' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM04' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM05' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM06' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM07' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM08' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM09' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM10' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM11' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM12' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM13' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM14' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM15' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM16' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM17' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM18' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM19' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM20' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM21' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM22' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM23' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM24' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM25' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM26' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM27' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM28' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM29' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM30' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM31' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM32' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM33' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM34' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM35' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM36' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM37' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM38' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM39' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM40' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM41' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM42' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM43' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM44' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM45' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM46' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM47' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM48' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM49' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM50' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM51' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM52' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM53' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM54' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM55' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM56' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM57' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM58' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM59' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM60' || g_newline ||
            G_INDENT || '       , A.ASSIGNED_FLAG' || g_newline ||
            G_INDENT || '       , A.PROCESSED_FLAG' || g_newline ||
            G_INDENT || '       , A.ORG_ID' || g_newline ||
            G_INDENT || '       , A.SECURITY_GROUP_ID' || g_newline ||
            G_INDENT || '       , A.OBJECT_VERSION_NUMBER' || g_newline ||
            G_INDENT || '       , A.WORKER_ID' || g_newline ;
   END IF; -- p_new_mode_fetch = 'N'

EXCEPTION
WHEN OTHERS THEN
     g_ProgramStatus := 1;
         JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'ERROR: JTF_TAE_SQL_LIBRARY_PVT.add_SELECT_cols');

END add_SELECT_cols;


/*********************************************************
** JDOCHERT: 08/07/02
** Function to return Static SELECT clause SQL
*********************************************************/
FUNCTION add_SELECT_clause( p_new_mode_fetch  CHAR )
RETURN VARCHAR2 AS

   lx_SELECT_clause     VARCHAR2(2000) := NULL;

BEGIN

   RETURN lx_SELECT_CLAUSE ||
         g_newline || g_newline ||
         G_INDENT || ' SELECT DISTINCT  ' || g_newline ||
         -- dblee: 08/26/03 use call to add_SELECT_cols
         add_SELECT_cols(p_new_mode_fetch);

EXCEPTION
WHEN OTHERS THEN
     g_ProgramStatus := 1;
         JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'ERROR: JTF_TAE_SQL_LIBRARY_PVT.add_SELECT_clause');

END add_SELECT_clause;


/*********************************************************
** JDOCHERT: 08/07/02
** Function to return Static Inline view SQL
*********************************************************/
FUNCTION add_ILV(p_input_string      IN   VARCHAR2,
                 p_new_mode_fetch    IN   CHAR)
RETURN VARCHAR2 AS
BEGIN

    -- dblee: 08/26/03: join against jtf_changed_terr_all, if new mode set
    IF p_new_mode_fetch <> 'Y' THEN

       RETURN p_input_string || g_newline || g_newline ||
          G_INDENT || '   /* INLINE VIEW */' || g_newline ||
          G_INDENT || '     ( SELECT         ' || g_newline ||
          G_INDENT || '              jtdr.terr_id                  ' || g_newline ||
          G_INDENT || '            , jtdr.source_id                ' || g_newline ||
          G_INDENT || '            , jtdr.qual_type_id             ' || g_newline ||
          G_INDENT || '            , jtdr.top_level_terr_id        ' || g_newline ||
          G_INDENT || '            , jtdr.absolute_rank            ' || g_newline ||
          G_INDENT || '            , jtdr.num_winners              ' || g_newline ||
          G_INDENT || '            , jtdr.org_id                   ' || g_newline ||
          G_INDENT || '       FROM  jtf_qual_type_usgs_all jqtu    ' || g_newline ||
          G_INDENT || '            ,jtf_terr_qtype_usgs_all jtqu   ' || g_newline ||
          G_INDENT || '            ,jtf_terr_denorm_rules_all jtdr  ' || g_newline ||
          G_INDENT || '       WHERE jtdr.terr_id = jtdr.related_terr_id ' || g_newline ||
          G_INDENT || '         AND jtdr.source_id = p_source_id   ' || g_newline ||
          G_INDENT || '         AND jqtu.source_id = jtdr.source_id    ' || g_newline ||
          G_INDENT || '         AND jqtu.qual_type_id = p_trans_object_type_id ' || g_newline ||
          G_INDENT || '         AND jtdr.terr_id = jtqu.terr_id ' || g_newline ||
          G_INDENT || '         AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id ' || g_newline ||
          G_INDENT || '         AND jtdr.resource_exists_flag = ''Y'' '|| g_newline ||
          G_INDENT || '         AND jtqu.qual_relation_product = lp_qual_combination_tbl(i) ' || g_newline ||
          G_INDENT || '     ) ILV '||g_newline;

    ELSE

       RETURN p_input_string || g_newline || g_newline ||
          G_INDENT || '   /* INLINE VIEW */' || g_newline ||
          G_INDENT || '     ( SELECT DISTINCT        ' || g_newline ||
          G_INDENT || '              jtdr.terr_id                  ' || g_newline ||
          G_INDENT || '            , jtdr.source_id                ' || g_newline ||
          G_INDENT || '            , jtdr.qual_type_id             ' || g_newline ||
          G_INDENT || '            , jtdr.top_level_terr_id        ' || g_newline ||
          G_INDENT || '            , jtdr.absolute_rank            ' || g_newline ||
          G_INDENT || '            , jtdr.num_winners              ' || g_newline ||
          G_INDENT || '            , jtdr.org_id                   ' || g_newline ||
          G_INDENT || '       FROM  jtf_qual_type_usgs_all jqtu    ' || g_newline ||
          G_INDENT || '            ,jtf_terr_qtype_usgs_all jtqu   ' || g_newline ||
          G_INDENT || '            ,jtf_changed_terr_all jct ' || g_newline ||
          G_INDENT || '            ,jtf_terr_denorm_rules_all jtdr  ' || g_newline ||
          G_INDENT || '       WHERE jct.terr_id = jtdr.terr_id     ' || g_newline ||
          G_INDENT || '         AND jtdr.terr_id = jtdr.related_terr_id ' || g_newline ||
          G_INDENT || '         AND jqtu.source_id = p_source_id   ' || g_newline ||
          G_INDENT || '         AND jqtu.source_id = jtdr.source_id    ' || g_newline ||
          G_INDENT || '         AND jqtu.qual_type_id = p_trans_object_type_id ' || g_newline ||
          G_INDENT || '         AND jct.terr_id = jtqu.terr_id ' || g_newline ||
          G_INDENT || '         AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id ' || g_newline ||
          G_INDENT || '         AND jtdr.resource_exists_flag = ''Y'' '|| g_newline ||
          G_INDENT || '         AND jtqu.qual_relation_product = lp_qual_combination_tbl(i) ' || g_newline ||
          G_INDENT || '     ) ILV'||g_newline;
    END IF;

EXCEPTION
WHEN OTHERS THEN
     g_ProgramStatus := 1;
         JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'ERROR: JTF_TAE_SQL_LIBRARY_PVT.add_ILV');

END add_ILV;

/*********************************************************
** JDOCHERT: 08/07/02
** Function to return Static Inline view SQL
*********************************************************/
FUNCTION add_ILV_with_NOMERGE_hint(p_input_string      IN   VARCHAR2,
                                   p_new_mode_fetch    IN   CHAR)
RETURN VARCHAR2 AS
BEGIN

    -- dblee: 08/26/03: join against jtf_changed_terr_all, if new mode set
    IF p_new_mode_fetch <> 'Y' THEN

       RETURN p_input_string || g_newline || g_newline ||
          G_INDENT || '     /* INLINE VIEW */' || g_newline ||
          G_INDENT || '     ( SELECT  /*+ NO_MERGE */              ' || g_newline ||
          G_INDENT || '              jtdr.terr_id                  ' || g_newline ||
          G_INDENT || '            , jtdr.source_id                ' || g_newline ||
          G_INDENT || '            , jtdr.qual_type_id             ' || g_newline ||
          G_INDENT || '            , jtdr.top_level_terr_id        ' || g_newline ||
          G_INDENT || '            , jtdr.absolute_rank            ' || g_newline ||
          G_INDENT || '            , jtdr.num_winners              ' || g_newline ||
          G_INDENT || '            , jtdr.org_id                   ' || g_newline ||
          G_INDENT || '       FROM jtf_terr_denorm_rules_all jtdr  ' || g_newline ||
          G_INDENT || '            ,jtf_terr_qtype_usgs_all jtqu   ' || g_newline ||
          G_INDENT || '            ,jtf_qual_type_usgs_all jqtu    ' || g_newline ||
          G_INDENT || '       WHERE jtdr.terr_id = jtdr.related_terr_id ' || g_newline ||
          G_INDENT || '         AND jtdr.source_id = p_source_id   ' || g_newline ||
          G_INDENT || '         AND jqtu.source_id = jtdr.source_id    ' || g_newline ||
          G_INDENT || '         AND jqtu.qual_type_id = p_trans_object_type_id ' || g_newline ||
          G_INDENT || '         AND jtdr.terr_id = jtqu.terr_id ' || g_newline ||
          G_INDENT || '         AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id ' || g_newline ||
          G_INDENT || '         AND jtdr.resource_exists_flag = ''Y'' '|| g_newline ||
          G_INDENT || '         AND jtqu.qual_relation_product = lp_qual_combination_tbl(i) ' || g_newline ||
          G_INDENT || '     ) ILV'||g_newline;

    ELSE

       RETURN p_input_string || g_newline || g_newline ||
          G_INDENT || '     /* INLINE VIEW */' || g_newline ||
          G_INDENT || '     ( SELECT /*+ NO_MERGE */ DISTINCT      ' || g_newline ||
          G_INDENT || '              jtdr.terr_id                  ' || g_newline ||
          G_INDENT || '            , jtdr.source_id                ' || g_newline ||
          G_INDENT || '            , jtdr.qual_type_id             ' || g_newline ||
          G_INDENT || '            , jtdr.top_level_terr_id        ' || g_newline ||
          G_INDENT || '            , jtdr.absolute_rank            ' || g_newline ||
          G_INDENT || '            , jtdr.num_winners              ' || g_newline ||
          G_INDENT || '            , jtdr.org_id                   ' || g_newline ||
          G_INDENT || '       FROM jtf_changed_terr_all jct ' || g_newline ||
          G_INDENT || '          , jtf_terr_denorm_rules_all jtdr  ' || g_newline ||
          G_INDENT || '            ,jtf_terr_qtype_usgs_all jtqu   ' || g_newline ||
          G_INDENT || '            ,jtf_qual_type_usgs_all jqtu    ' || g_newline ||
          G_INDENT || '       WHERE jct.terr_id = jtdr.terr_id     ' || g_newline ||
          G_INDENT || '         AND jtdr.terr_id = jtdr.related_terr_id ' || g_newline ||
          G_INDENT || '         AND jqtu.source_id = p_source_id   ' || g_newline ||
          G_INDENT || '         AND jqtu.source_id = jtdr.source_id    ' || g_newline ||
          G_INDENT || '         AND jqtu.qual_type_id = p_trans_object_type_id ' || g_newline ||
          G_INDENT || '         AND jct.terr_id = jtqu.terr_id ' || g_newline ||
          G_INDENT || '         AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id ' || g_newline ||
          G_INDENT || '         AND jtdr.resource_exists_flag = ''Y'' '|| g_newline ||
          G_INDENT || '         AND jtqu.qual_relation_product = lp_qual_combination_tbl(i) ' || g_newline ||
          G_INDENT || '     ) ILV'||g_newline;
    END IF;

EXCEPTION
WHEN OTHERS THEN
     g_ProgramStatus := 1;
         JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'ERROR: JTF_TAE_SQL_LIBRARY_PVT.add_ILV');

END add_ILV_with_NOMERGE_hint;

/*********************************************************
** JDOCHERT: 08/07/02
** Function to return Postal Code + Country SQL
** SBEHERA: 08/08/02
*********************************************************/
FUNCTION add_4841_SQL( p_trans_object_type_id   IN   NUMBER
                     , p_table_name             IN   VARCHAR2
                     , p_match_table_name       IN   VARCHAR2
                     -- dblee 08/26/03 added new mode flag
                     , p_new_mode_fetch         IN   CHAR)
RETURN VARCHAR2 AS

   lx_4841_sql       VARCHAR2(32767) := NULL;
   l_sql             VARCHAR2(32767) := NULL;
   l_trans_idx_name  VARCHAR2(40)    := NULL;
BEGIN

   /* Get the index name for 4841 qual comb for the trans table */
   l_trans_idx_name := 'JTF_TAE_TN' || TO_CHAR(ABS(p_trans_object_type_id)) || '_4841';

   if p_table_name = 'JTF_TAE_1001_SC_TRANS' then
      l_trans_idx_name := l_trans_idx_name || '_NDSC';
   elsif ((p_table_name = 'JTF_TAE_1001_ACCOUNT_NM_TRANS') OR (p_table_name = 'JTF_TAE_1001_OPPOR_NM_TRANS') OR
          (p_table_name = 'JTF_TAE_1001_LEAD_NM_TRANS')) then
      l_trans_idx_name := l_trans_idx_name || '_NDW';
   else
      l_trans_idx_name := l_trans_idx_name || '_ND';
   end if;

   /* ARPATEL 03/10/2004 Bug#3489240 */
   lx_4841_sql :=
         '     SELECT COUNT(DISTINCT WORKER_ID) ' || g_newline ||
         '       INTO l_num_workers ' || g_newline ||
         '       FROM JTF_TAE_1001_ACCOUNT_TRANS; ' || g_newline || g_newline ||


         '      IF l_num_workers = 1' || g_newline ||
         '      THEN ' || g_newline;

    IF p_new_mode_fetch = 'Y' THEN
     lx_4841_sql := lx_4841_sql ||
      '         INSERT INTO  '|| p_match_table_name || ' i' || g_newline ||
      '         ('  || g_newline ||
      '            TRANS_OBJECT_ID' || g_newline ||
      '            , TRANS_DETAIL_OBJECT_ID' || g_newline ||
      '            , HEADER_ID1' || g_newline ||
      '            , HEADER_ID2' || g_newline ||
      '            , SOURCE_ID' || g_newline ||
      '            , TRANS_OBJECT_TYPE_ID' || g_newline ||
      '            , LAST_UPDATE_DATE' || g_newline ||
      '            , LAST_UPDATED_BY' || g_newline ||
      '            , CREATION_DATE' || g_newline ||
      '            , CREATED_BY' || g_newline ||
      '            , LAST_UPDATE_LOGIN' || g_newline ||
      '            , REQUEST_ID' || g_newline ||
      '            , PROGRAM_APPLICATION_ID' || g_newline ||
      '            , PROGRAM_ID' || g_newline ||
      '            , PROGRAM_UPDATE_DATE' || g_newline ||
      '            , SQUAL_FC01' || g_newline ||
      '            , SQUAL_FC02' || g_newline ||
      '            , SQUAL_FC03' || g_newline ||
      '            , SQUAL_FC04' || g_newline ||
      '            , SQUAL_FC05' || g_newline ||
      '            , SQUAL_CURC01' || g_newline ||
      '            , SQUAL_CURC02' || g_newline ||
      '            , SQUAL_CURC03' || g_newline ||
      '            , SQUAL_CURC04' || g_newline ||
      '            , SQUAL_CURC05' || g_newline ||
      '            , SQUAL_CURC06' || g_newline ||
      '            , SQUAL_CURC07' || g_newline ||
      '            , SQUAL_CURC08' || g_newline ||
      '            , SQUAL_CURC09' || g_newline ||
      '            , SQUAL_CURC10' || g_newline ||
      '            , SQUAL_CHAR01' || g_newline ||
      '            , SQUAL_CHAR02' || g_newline ||
      '            , SQUAL_CHAR03' || g_newline ||
      '            , SQUAL_CHAR04' || g_newline ||
      '            , SQUAL_CHAR05' || g_newline ||
      '            , SQUAL_CHAR06' || g_newline ||
      '            , SQUAL_CHAR07' || g_newline ||
      '            , SQUAL_CHAR08' || g_newline ||
      '            , SQUAL_CHAR09' || g_newline ||
      '            , SQUAL_CHAR10' || g_newline ||
      '            , SQUAL_CHAR11' || g_newline ||
      '            , SQUAL_CHAR12' || g_newline ||
      '            , SQUAL_CHAR13' || g_newline ||
      '            , SQUAL_CHAR14' || g_newline ||
      '            , SQUAL_CHAR15' || g_newline ||
      '            , SQUAL_CHAR16' || g_newline ||
      '            , SQUAL_CHAR17' || g_newline ||
      '            , SQUAL_CHAR18' || g_newline ||
      '            , SQUAL_CHAR19' || g_newline ||
      '            , SQUAL_CHAR20' || g_newline ||
      '            , SQUAL_CHAR21' || g_newline ||
      '            , SQUAL_CHAR22' || g_newline ||
      '            , SQUAL_CHAR23' || g_newline ||
      '            , SQUAL_CHAR24' || g_newline ||
      '            , SQUAL_CHAR25' || g_newline ||
      '            , SQUAL_CHAR26' || g_newline ||
      '            , SQUAL_CHAR27' || g_newline ||
      '            , SQUAL_CHAR28' || g_newline ||
      '            , SQUAL_CHAR30' || g_newline ||
      '            , SQUAL_CHAR31' || g_newline ||
      '            , SQUAL_CHAR32' || g_newline ||
      '            , SQUAL_CHAR33' || g_newline ||
      '            , SQUAL_CHAR34' || g_newline ||
      '            , SQUAL_CHAR35' || g_newline ||
      '            , SQUAL_CHAR36' || g_newline ||
      '            , SQUAL_CHAR37' || g_newline ||
      '            , SQUAL_CHAR38' || g_newline ||
      '            , SQUAL_CHAR39' || g_newline ||
      '            , SQUAL_CHAR40' || g_newline ||
      '            , SQUAL_CHAR41' || g_newline ||
      '            , SQUAL_CHAR42' || g_newline ||
      '            , SQUAL_CHAR43' || g_newline ||
      '            , SQUAL_CHAR44' || g_newline ||
      '            , SQUAL_CHAR45' || g_newline ||
      '            , SQUAL_CHAR46' || g_newline ||
      '            , SQUAL_CHAR47' || g_newline ||
      '            , SQUAL_CHAR48' || g_newline ||
      '            , SQUAL_CHAR49' || g_newline ||
      '            , SQUAL_CHAR50' || g_newline ||
      '            , SQUAL_CHAR51' || g_newline ||
      '            , SQUAL_CHAR52' || g_newline ||
      '            , SQUAL_CHAR53' || g_newline ||
      '            , SQUAL_CHAR54' || g_newline ||
      '            , SQUAL_CHAR55' || g_newline ||
      '            , SQUAL_CHAR56' || g_newline ||
      '            , SQUAL_CHAR57' || g_newline ||
      '            , SQUAL_CHAR58' || g_newline ||
      '            , SQUAL_CHAR59' || g_newline ||
      '            , SQUAL_CHAR60' || g_newline ||
      '            , SQUAL_NUM01' || g_newline ||
      '            , SQUAL_NUM02' || g_newline ||
      '            , SQUAL_NUM03' || g_newline ||
      '            , SQUAL_NUM04' || g_newline ||
      '            , SQUAL_NUM05' || g_newline ||
      '            , SQUAL_NUM06' || g_newline ||
      '            , SQUAL_NUM07' || g_newline ||
      '            , SQUAL_NUM08' || g_newline ||
      '            , SQUAL_NUM09' || g_newline ||
      '            , SQUAL_NUM10' || g_newline ||
      '            , SQUAL_NUM11' || g_newline ||
      '            , SQUAL_NUM12' || g_newline ||
      '            , SQUAL_NUM13' || g_newline ||
      '            , SQUAL_NUM14' || g_newline ||
      '            , SQUAL_NUM15' || g_newline ||
      '            , SQUAL_NUM16' || g_newline ||
      '            , SQUAL_NUM17' || g_newline ||
      '            , SQUAL_NUM18' || g_newline ||
      '            , SQUAL_NUM19' || g_newline ||
      '            , SQUAL_NUM20' || g_newline ||
      '            , SQUAL_NUM21' || g_newline ||
      '            , SQUAL_NUM22' || g_newline ||
      '            , SQUAL_NUM23' || g_newline ||
      '            , SQUAL_NUM24' || g_newline ||
      '            , SQUAL_NUM25' || g_newline ||
      '            , SQUAL_NUM26' || g_newline ||
      '            , SQUAL_NUM27' || g_newline ||
      '            , SQUAL_NUM28' || g_newline ||
      '            , SQUAL_NUM29' || g_newline ||
      '            , SQUAL_NUM30' || g_newline ||
      '            , SQUAL_NUM31' || g_newline ||
      '            , SQUAL_NUM32' || g_newline ||
      '            , SQUAL_NUM33' || g_newline ||
      '            , SQUAL_NUM34' || g_newline ||
      '            , SQUAL_NUM35' || g_newline ||
      '            , SQUAL_NUM36' || g_newline ||
      '            , SQUAL_NUM37' || g_newline ||
      '            , SQUAL_NUM38' || g_newline ||
      '            , SQUAL_NUM39' || g_newline ||
      '            , SQUAL_NUM40' || g_newline ||
      '            , SQUAL_NUM41' || g_newline ||
      '            , SQUAL_NUM42' || g_newline ||
      '            , SQUAL_NUM43' || g_newline ||
      '            , SQUAL_NUM44' || g_newline ||
      '            , SQUAL_NUM45' || g_newline ||
      '            , SQUAL_NUM46' || g_newline ||
      '            , SQUAL_NUM47' || g_newline ||
      '            , SQUAL_NUM48' || g_newline ||
      '            , SQUAL_NUM49' || g_newline ||
      '            , SQUAL_NUM50' || g_newline ||
      '            , SQUAL_NUM51' || g_newline ||
      '            , SQUAL_NUM52' || g_newline ||
      '            , SQUAL_NUM53' || g_newline ||
      '            , SQUAL_NUM54' || g_newline ||
      '            , SQUAL_NUM55' || g_newline ||
      '            , SQUAL_NUM56' || g_newline ||
      '            , SQUAL_NUM57' || g_newline ||
      '            , SQUAL_NUM58' || g_newline ||
      '            , SQUAL_NUM59' || g_newline ||
      '            , SQUAL_NUM60' || g_newline ||
      '            , ASSIGNED_FLAG' || g_newline ||
      '            , PROCESSED_FLAG' || g_newline ||
      '            , ORG_ID' || g_newline ||
      '            , SECURITY_GROUP_ID' || g_newline ||
      '            , OBJECT_VERSION_NUMBER' || g_newline ||
      '            , WORKER_ID' || g_newline ||
      '         )'  || g_newline ||
     /* Num of workers = 1 then USE_HASH */
       G_INDENT || 'SELECT /*+ USE_HASH(ILV4841 A) */ ' || g_newline;

    ELSE
      lx_4841_sql := lx_4841_sql ||
         '         INSERT INTO  '||p_match_table_name || ' i' || g_newline ||
         '         (' || g_newline ||
         '            trans_object_id' || g_newline ||
         '          , trans_detail_object_id' || g_newline ||
         '          , worker_id' || g_newline ||
         '          , header_id1'|| g_newline ||
         '          , header_id2'|| g_newline ||
         '          , source_id'|| g_newline ||
         '          , trans_object_type_id'|| g_newline ||
         '          , last_update_date'|| g_newline ||
         '          , last_updated_by'|| g_newline ||
         '          , creation_date'|| g_newline ||
         '          , created_by'|| g_newline ||
         '          , last_update_login'|| g_newline ||
         '          , request_id'|| g_newline ||
         '          , program_application_id'|| g_newline ||
         '          , program_id'|| g_newline ||
         '          , program_update_date'|| g_newline ||
         '          , terr_id'|| g_newline ||
         '          , absolute_rank'|| g_newline ||
         '          , top_level_terr_id'|| g_newline ||
         '          , num_winners'|| g_newline ||
         '          , org_id'|| g_newline ||
         '         )' || g_newline ||

         /* Num of workers = 1 then USE_HASH */
         G_INDENT || 'SELECT /*+ USE_HASH(ILV4841 A) */ ' || g_newline;
    END IF;

   -- dblee: 08/26/03: added switch for new mode TAP
   IF p_new_mode_fetch = 'Y' THEN
      lx_4841_sql := lx_4841_sql || add_SELECT_cols(p_new_mode_fetch);
   ELSE
      lx_4841_sql := lx_4841_sql ||
         G_INDENT || '                trans_object_id' || g_newline ||
           G_INDENT || '              , trans_detail_object_id' || g_newline ||
           -- eihsu 06/19/2003 worker_id
           G_INDENT || '              , worker_id' || g_newline ||
           G_INDENT || '              , header_id1' || g_newline ||
           G_INDENT || '              , header_id2' || g_newline ||
           G_INDENT || '              , p_source_id' || g_newline ||
           G_INDENT || '              , p_trans_object_type_id' || g_newline ||
           G_INDENT || '              , l_sysdate' || g_newline ||
           G_INDENT || '              , L_USER_ID' || g_newline ||
           G_INDENT || '              , l_sysdate' || g_newline ||
           G_INDENT || '              , L_USER_ID' || g_newline ||
           G_INDENT || '              , L_USER_ID' || g_newline ||
           G_INDENT || '              , L_REQUEST_ID' || g_newline ||
           G_INDENT || '              , L_PROGRAM_APPL_ID' || g_newline ||
           G_INDENT || '              , L_PROGRAM_ID' || g_newline ||
           G_INDENT || '              , l_sysdate' || g_newline ||
           G_INDENT || '              , ILV.terr_id' || g_newline ||
           G_INDENT || '              , ILV.absolute_rank' || g_newline ||
           G_INDENT || '              , ILV.top_level_terr_id' || g_newline ||
           G_INDENT || '              , ILV.num_winners' || g_newline ||
           G_INDENT || '              , ILV.org_id' || g_newline;
   END IF; -- p_new_mode_fetch = 'Y'

  --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lx_4841_sql
       );

  lx_4841_sql := --lx_4841_sql ||
     G_INDENT || '          FROM  ' || g_newline ||
     /* DYNAMIC BASED ON TRANSACTION TYPE */
     G_INDENT || '    ' || P_TABLE_NAME || ' A ' || g_newline ||

--
     -- JDOCHERT: 16/09/03: BUG#3143516: CHANGE START
     --
     '   , ( SELECT /*+ NO_MERGE */ ' || g_newline ||
     '              ILV4841.terr_id ' || g_newline ||
     '            , ILV4841.absolute_rank ' || g_newline ||
     '            , ILV4841.top_level_terr_id ' || g_newline ||
     '            , ILV4841.num_winners ' || g_newline ||
     '            , ILV4841.org_id ' || g_newline ||
     '            , Q1007R1.high_value_char q1007_high_value_char ' || g_newline ||
     '            , Q1007R1.low_value_char q1007_low_value_char ' || g_newline ||
     '            , Q1003R1.low_value_char q1003_low_value_char ' || g_newline ||
     '            , Q1007R1.comparison_operator q1007_cop ' || g_newline ||
     '            , Q1003R1.comparison_operator q1003_cop ' || g_newline ||
     '       FROM  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||
     '           , jtf_terr_qual_rules_mv Q1007R1 ' || g_newline;

  IF p_new_mode_fetch = 'Y' THEN
     lx_4841_sql := lx_4841_sql ||
       '           , ( SELECT /*+ NO_MERGE */ DISTINCT ' || g_newline;
  ELSE
     lx_4841_sql := lx_4841_sql ||
       '           , ( SELECT ' || g_newline;
  END IF;

   lx_4841_sql := lx_4841_sql ||
     '                      jtdr.terr_id ' || g_newline ||
     '                    , jtdr.source_id ' || g_newline ||
     '                    , jtdr.qual_type_id ' || g_newline ||
     '                    , jtdr.top_level_terr_id ' || g_newline ||
     '                    , jtdr.absolute_rank ' || g_newline ||
     '                    , jtdr.num_winners ' || g_newline ||
     '                    , jtdr.org_id ';

  IF p_new_mode_fetch = 'Y' THEN

     lx_4841_sql := lx_4841_sql ||
        '       FROM jtf_changed_terr_all jct ' || g_newline ||
        '          , jtf_terr_denorm_rules_all jtdr  ' || g_newline ||
        '            ,jtf_terr_qtype_usgs_all jtqu   ' || g_newline ||
        '            ,jtf_qual_type_usgs_all jqtu    ' || g_newline ||
        '       WHERE jct.terr_id = jtdr.terr_id     ' || g_newline ||
        '       AND jtdr.terr_id= jtdr.related_terr_id ' || g_newline ||
        '       AND jqtu.source_id = p_source_id ' || g_newline ||
        '       AND jqtu.source_id = jtdr.source_id    ' || g_newline ||
        '       AND jqtu.qual_type_id = p_trans_object_type_id ' || g_newline ||
        '       AND jct.terr_id = jtqu.terr_id ' || g_newline ||
        '       AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id ' || g_newline ||
        '       AND jtdr.resource_exists_flag = ''Y'' ' || g_newline ||
        '       AND jtqu.qual_relation_product = lp_qual_combination_tbl(i) ' || g_newline ||
        '             ) ILV4841 ' || g_newline;

  ELSE

     lx_4841_sql := lx_4841_sql ||
      '         FROM  jtf_terr_denorm_rules_all jtdr ' || g_newline ||
      '            ,jtf_terr_qtype_usgs_all jtqu   ' || g_newline ||
      '            ,jtf_qual_type_usgs_all jqtu    ' || g_newline ||
      '         WHERE jtdr.terr_id= jtdr.related_terr_id ' || g_newline ||
      '         AND jtdr.source_id = p_source_id ' || g_newline ||
      '         AND jqtu.source_id = jtdr.source_id    ' || g_newline ||
      '         AND jqtu.qual_type_id = p_trans_object_type_id ' || g_newline ||
      '         AND jtdr.terr_id = jtqu.terr_id ' || g_newline ||
      '         AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id ' || g_newline ||
      '         AND jtdr.resource_exists_flag = ''Y'' ' || g_newline ||
      '         AND jtqu.qual_relation_product = lp_qual_combination_tbl(i) ' || g_newline ||
      '             ) ILV4841 ' || g_newline;

  END IF;

   lx_4841_sql := lx_4841_sql ||
     '       WHERE Q1007R1.qual_usg_id = -1007 ' || g_newline ||
     '         AND Q1007R1.terr_id = ILV4841.terr_id ' || g_newline ||
     '         AND Q1007R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||
     '         AND Q1003R1.comparison_operator = ''='' ' || g_newline ||
     '         AND Q1003R1.qual_usg_id = -1003 ' || g_newline ||
     '         AND Q1003R1.terr_id = ILV4841.terr_id ' || g_newline ||
     '       ORDER BY Q1003R1.low_value_char ' || g_newline ||
     '              , Q1007R1.low_value_char ' || g_newline ||
     '              , Q1007R1.high_value_char ' || g_newline ||
     '       ) ILV ' || g_newline ||
     '  WHERE 1 = 1 ' || g_newline;
     --
     -- JDOCHERT: 16/09/03: BUG#3143516: CHANGE END
     --
     IF p_new_mode_fetch <> 'Y' THEN
       lx_4841_sql := lx_4841_sql ||
         '  AND A.worker_id = P_WORKER_ID ' || g_newline;
     END IF;

   lx_4841_sql := lx_4841_sql ||
     '  AND ( ( a.squal_char06 <= ILV.q1007_high_value_char AND ' || g_newline ||
     '          a.squal_char06 >= ILV.q1007_low_value_char AND ' || g_newline ||
     '          ILV.q1007_cop = ''BETWEEN'' ) ' || g_newline ||
     '        OR ' || g_newline ||
     '        ( a.squal_char06 = ILV.q1007_low_value_char AND ' || g_newline ||
     '          ILV.q1007_cop = ''='' ) ' || g_newline ||
     '        OR ' || g_newline ||
     '        ( a.squal_char06 LIKE ILV.q1007_low_value_char AND ' || g_newline ||
     '          ILV.q1007_cop = ''LIKE'' ) ) ' || g_newline ||
     '  AND a.squal_char07 = ILV.q1003_low_value_char ; ' || g_newline ||

        -- else num of workers > 1
     '  ELSE /* Number of Workers > 1 */ ' || g_newline;

        IF p_new_mode_fetch = 'Y' THEN
       lx_4841_sql := lx_4841_sql ||
      '         INSERT INTO  '|| p_match_table_name || ' i' || g_newline ||
      '         ('  || g_newline ||
      '            TRANS_OBJECT_ID' || g_newline ||
      '            , TRANS_DETAIL_OBJECT_ID' || g_newline ||
      '            , HEADER_ID1' || g_newline ||
      '            , HEADER_ID2' || g_newline ||
      '            , SOURCE_ID' || g_newline ||
      '            , TRANS_OBJECT_TYPE_ID' || g_newline ||
      '            , LAST_UPDATE_DATE' || g_newline ||
      '            , LAST_UPDATED_BY' || g_newline ||
      '            , CREATION_DATE' || g_newline ||
      '            , CREATED_BY' || g_newline ||
      '            , LAST_UPDATE_LOGIN' || g_newline ||
      '            , REQUEST_ID' || g_newline ||
      '            , PROGRAM_APPLICATION_ID' || g_newline ||
      '            , PROGRAM_ID' || g_newline ||
      '            , PROGRAM_UPDATE_DATE' || g_newline ||
      '            , SQUAL_FC01' || g_newline ||
      '            , SQUAL_FC02' || g_newline ||
      '            , SQUAL_FC03' || g_newline ||
      '            , SQUAL_FC04' || g_newline ||
      '            , SQUAL_FC05' || g_newline ||
      '            , SQUAL_CURC01' || g_newline ||
      '            , SQUAL_CURC02' || g_newline ||
      '            , SQUAL_CURC03' || g_newline ||
      '            , SQUAL_CURC04' || g_newline ||
      '            , SQUAL_CURC05' || g_newline ||
      '            , SQUAL_CURC06' || g_newline ||
      '            , SQUAL_CURC07' || g_newline ||
      '            , SQUAL_CURC08' || g_newline ||
      '            , SQUAL_CURC09' || g_newline ||
      '            , SQUAL_CURC10' || g_newline ||
      '            , SQUAL_CHAR01' || g_newline ||
      '            , SQUAL_CHAR02' || g_newline ||
      '            , SQUAL_CHAR03' || g_newline ||
      '            , SQUAL_CHAR04' || g_newline ||
      '            , SQUAL_CHAR05' || g_newline ||
      '            , SQUAL_CHAR06' || g_newline ||
      '            , SQUAL_CHAR07' || g_newline ||
      '            , SQUAL_CHAR08' || g_newline ||
      '            , SQUAL_CHAR09' || g_newline ||
      '            , SQUAL_CHAR10' || g_newline ||
      '            , SQUAL_CHAR11' || g_newline ||
      '            , SQUAL_CHAR12' || g_newline ||
      '            , SQUAL_CHAR13' || g_newline ||
      '            , SQUAL_CHAR14' || g_newline ||
      '            , SQUAL_CHAR15' || g_newline ||
      '            , SQUAL_CHAR16' || g_newline ||
      '            , SQUAL_CHAR17' || g_newline ||
      '            , SQUAL_CHAR18' || g_newline ||
      '            , SQUAL_CHAR19' || g_newline ||
      '            , SQUAL_CHAR20' || g_newline ||
      '            , SQUAL_CHAR21' || g_newline ||
      '            , SQUAL_CHAR22' || g_newline ||
      '            , SQUAL_CHAR23' || g_newline ||
      '            , SQUAL_CHAR24' || g_newline ||
      '            , SQUAL_CHAR25' || g_newline ||
      '            , SQUAL_CHAR26' || g_newline ||
      '            , SQUAL_CHAR27' || g_newline ||
      '            , SQUAL_CHAR28' || g_newline ||
      '            , SQUAL_CHAR30' || g_newline ||
      '            , SQUAL_CHAR31' || g_newline ||
      '            , SQUAL_CHAR32' || g_newline ||
      '            , SQUAL_CHAR33' || g_newline ||
      '            , SQUAL_CHAR34' || g_newline ||
      '            , SQUAL_CHAR35' || g_newline ||
      '            , SQUAL_CHAR36' || g_newline ||
      '            , SQUAL_CHAR37' || g_newline ||
      '            , SQUAL_CHAR38' || g_newline ||
      '            , SQUAL_CHAR39' || g_newline ||
      '            , SQUAL_CHAR40' || g_newline ||
      '            , SQUAL_CHAR41' || g_newline ||
      '            , SQUAL_CHAR42' || g_newline ||
      '            , SQUAL_CHAR43' || g_newline ||
      '            , SQUAL_CHAR44' || g_newline ||
      '            , SQUAL_CHAR45' || g_newline ||
      '            , SQUAL_CHAR46' || g_newline ||
      '            , SQUAL_CHAR47' || g_newline ||
      '            , SQUAL_CHAR48' || g_newline ||
      '            , SQUAL_CHAR49' || g_newline ||
      '            , SQUAL_CHAR50' || g_newline ||
      '            , SQUAL_CHAR51' || g_newline ||
      '            , SQUAL_CHAR52' || g_newline ||
      '            , SQUAL_CHAR53' || g_newline ||
      '            , SQUAL_CHAR54' || g_newline ||
      '            , SQUAL_CHAR55' || g_newline ||
      '            , SQUAL_CHAR56' || g_newline ||
      '            , SQUAL_CHAR57' || g_newline ||
      '            , SQUAL_CHAR58' || g_newline ||
      '            , SQUAL_CHAR59' || g_newline ||
      '            , SQUAL_CHAR60' || g_newline ||
      '            , SQUAL_NUM01' || g_newline ||
      '            , SQUAL_NUM02' || g_newline ||
      '            , SQUAL_NUM03' || g_newline ||
      '            , SQUAL_NUM04' || g_newline ||
      '            , SQUAL_NUM05' || g_newline ||
      '            , SQUAL_NUM06' || g_newline ||
      '            , SQUAL_NUM07' || g_newline ||
      '            , SQUAL_NUM08' || g_newline ||
      '            , SQUAL_NUM09' || g_newline ||
      '            , SQUAL_NUM10' || g_newline ||
      '            , SQUAL_NUM11' || g_newline ||
      '            , SQUAL_NUM12' || g_newline ||
      '            , SQUAL_NUM13' || g_newline ||
      '            , SQUAL_NUM14' || g_newline ||
      '            , SQUAL_NUM15' || g_newline ||
      '            , SQUAL_NUM16' || g_newline ||
      '            , SQUAL_NUM17' || g_newline ||
      '            , SQUAL_NUM18' || g_newline ||
      '            , SQUAL_NUM19' || g_newline ||
      '            , SQUAL_NUM20' || g_newline ||
      '            , SQUAL_NUM21' || g_newline ||
      '            , SQUAL_NUM22' || g_newline ||
      '            , SQUAL_NUM23' || g_newline ||
      '            , SQUAL_NUM24' || g_newline ||
      '            , SQUAL_NUM25' || g_newline ||
      '            , SQUAL_NUM26' || g_newline ||
      '            , SQUAL_NUM27' || g_newline ||
      '            , SQUAL_NUM28' || g_newline ||
      '            , SQUAL_NUM29' || g_newline ||
      '            , SQUAL_NUM30' || g_newline ||
      '            , SQUAL_NUM31' || g_newline ||
      '            , SQUAL_NUM32' || g_newline ||
      '            , SQUAL_NUM33' || g_newline ||
      '            , SQUAL_NUM34' || g_newline ||
      '            , SQUAL_NUM35' || g_newline ||
      '            , SQUAL_NUM36' || g_newline ||
      '            , SQUAL_NUM37' || g_newline ||
      '            , SQUAL_NUM38' || g_newline ||
      '            , SQUAL_NUM39' || g_newline ||
      '            , SQUAL_NUM40' || g_newline ||
      '            , SQUAL_NUM41' || g_newline ||
      '            , SQUAL_NUM42' || g_newline ||
      '            , SQUAL_NUM43' || g_newline ||
      '            , SQUAL_NUM44' || g_newline ||
      '            , SQUAL_NUM45' || g_newline ||
      '            , SQUAL_NUM46' || g_newline ||
      '            , SQUAL_NUM47' || g_newline ||
      '            , SQUAL_NUM48' || g_newline ||
      '            , SQUAL_NUM49' || g_newline ||
      '            , SQUAL_NUM50' || g_newline ||
      '            , SQUAL_NUM51' || g_newline ||
      '            , SQUAL_NUM52' || g_newline ||
      '            , SQUAL_NUM53' || g_newline ||
      '            , SQUAL_NUM54' || g_newline ||
      '            , SQUAL_NUM55' || g_newline ||
      '            , SQUAL_NUM56' || g_newline ||
      '            , SQUAL_NUM57' || g_newline ||
      '            , SQUAL_NUM58' || g_newline ||
      '            , SQUAL_NUM59' || g_newline ||
      '            , SQUAL_NUM60' || g_newline ||
      '            , ASSIGNED_FLAG' || g_newline ||
      '            , PROCESSED_FLAG' || g_newline ||
      '            , ORG_ID' || g_newline ||
      '            , SECURITY_GROUP_ID' || g_newline ||
      '            , OBJECT_VERSION_NUMBER' || g_newline ||
      '            , WORKER_ID' || g_newline ||
      '         )'  || g_newline ||
       G_INDENT || 'SELECT /*+ USE_CONCAT */ ' || g_newline;

    ELSE
       lx_4841_sql := lx_4841_sql ||
        '         INSERT INTO  '|| p_match_table_name || ' i' || g_newline ||
         '         (' || g_newline ||
         '            trans_object_id' || g_newline ||
         '          , trans_detail_object_id' || g_newline ||
         '          , worker_id' || g_newline ||
         '          , header_id1'|| g_newline ||
         '          , header_id2'|| g_newline ||
         '          , source_id'|| g_newline ||
         '          , trans_object_type_id'|| g_newline ||
         '          , last_update_date'|| g_newline ||
         '          , last_updated_by'|| g_newline ||
         '          , creation_date'|| g_newline ||
         '          , created_by'|| g_newline ||
         '          , last_update_login'|| g_newline ||
         '          , request_id'|| g_newline ||
         '          , program_application_id'|| g_newline ||
         '          , program_id'|| g_newline ||
         '          , program_update_date'|| g_newline ||
         '          , terr_id'|| g_newline ||
         '          , absolute_rank'|| g_newline ||
         '          , top_level_terr_id'|| g_newline ||
         '          , num_winners'|| g_newline ||
         '          , org_id'|| g_newline ||
         '         )' || g_newline ||
         G_INDENT || 'SELECT /*+ USE_CONCAT INDEX(A ' || l_trans_idx_name || ') */ ' || g_newline;

   END IF;

   -- dblee: 08/26/03: added switch for new mode TAP
   IF p_new_mode_fetch = 'Y' THEN
      lx_4841_sql := lx_4841_sql || add_SELECT_cols(p_new_mode_fetch);
   ELSE
      lx_4841_sql := lx_4841_sql ||
         G_INDENT || '                trans_object_id' || g_newline ||
           G_INDENT || '              , trans_detail_object_id' || g_newline ||
           -- eihsu 06/19/2003 worker_id
           G_INDENT || '              , worker_id' || g_newline ||
           G_INDENT || '              , header_id1' || g_newline ||
           G_INDENT || '              , header_id2' || g_newline ||
           G_INDENT || '              , p_source_id' || g_newline ||
           G_INDENT || '              , p_trans_object_type_id' || g_newline ||
           G_INDENT || '              , l_sysdate' || g_newline ||
           G_INDENT || '              , L_USER_ID' || g_newline ||
           G_INDENT || '              , l_sysdate' || g_newline ||
           G_INDENT || '              , L_USER_ID' || g_newline ||
           G_INDENT || '              , L_USER_ID' || g_newline ||
           G_INDENT || '              , L_REQUEST_ID' || g_newline ||
           G_INDENT || '              , L_PROGRAM_APPL_ID' || g_newline ||
           G_INDENT || '              , L_PROGRAM_ID' || g_newline ||
           G_INDENT || '              , l_sysdate' || g_newline ||
           G_INDENT || '              , ILV.terr_id' || g_newline ||
           G_INDENT || '              , ILV.absolute_rank' || g_newline ||
           G_INDENT || '              , ILV.top_level_terr_id' || g_newline ||
           G_INDENT || '              , ILV.num_winners' || g_newline ||
           G_INDENT || '              , ILV.org_id' || g_newline;
   END IF; -- p_new_mode_fetch = 'Y'

  --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lx_4841_sql
       );

  lx_4841_sql := --lx_4841_sql ||
     G_INDENT || '          FROM  ' || g_newline ||
     /* DYNAMIC BASED ON TRANSACTION TYPE */
     G_INDENT || '    ' || P_TABLE_NAME || ' A ' || g_newline ||

--
     -- JDOCHERT: 16/09/03: BUG#3143516: CHANGE START
     --
     '   , ( SELECT /*+ NO_MERGE */ ' || g_newline ||
     '              ILV4841.terr_id ' || g_newline ||
     '            , ILV4841.absolute_rank ' || g_newline ||
     '            , ILV4841.top_level_terr_id ' || g_newline ||
     '            , ILV4841.num_winners ' || g_newline ||
     '            , ILV4841.org_id ' || g_newline ||
     '            , Q1007R1.high_value_char q1007_high_value_char ' || g_newline ||
     '            , Q1007R1.low_value_char q1007_low_value_char ' || g_newline ||
     '            , Q1003R1.low_value_char q1003_low_value_char ' || g_newline ||
     '            , Q1007R1.comparison_operator q1007_cop ' || g_newline ||
     '            , Q1003R1.comparison_operator q1003_cop ' || g_newline ||
     '       FROM  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||
     '           , jtf_terr_qual_rules_mv Q1007R1 ' || g_newline;

  IF p_new_mode_fetch = 'Y' THEN
     lx_4841_sql := lx_4841_sql ||
       '           , ( SELECT /*+ NO_MERGE */ DISTINCT ' || g_newline;
  ELSE
     lx_4841_sql := lx_4841_sql ||
       '           , ( SELECT ' || g_newline;
  END IF;

  lx_4841_sql := lx_4841_sql ||
     '                      jtdr.terr_id ' || g_newline ||
     '                    , jtdr.source_id ' || g_newline ||
     '                    , jtdr.qual_type_id ' || g_newline ||
     '                    , jtdr.top_level_terr_id ' || g_newline ||
     '                    , jtdr.absolute_rank ' || g_newline ||
     '                    , jtdr.num_winners ' || g_newline ||
     '                    , jtdr.org_id ';

  IF p_new_mode_fetch = 'Y' THEN

     lx_4841_sql := lx_4841_sql ||
        '       FROM jtf_changed_terr_all jct ' || g_newline ||
        '          , jtf_terr_denorm_rules_all jtdr  ' || g_newline ||
        '            ,jtf_terr_qtype_usgs_all jtqu   ' || g_newline ||
        '            ,jtf_qual_type_usgs_all jqtu    ' || g_newline ||
        '       WHERE jct.terr_id = jtdr.terr_id     ' || g_newline ||
        '       AND jtdr.terr_id= jtdr.related_terr_id ' || g_newline ||
        '       AND jqtu.source_id = p_source_id ' || g_newline ||
        '       AND jqtu.source_id = jtdr.source_id    ' || g_newline ||
        '       AND jqtu.qual_type_id = p_trans_object_type_id ' || g_newline ||
        '       AND jct.terr_id = jtqu.terr_id ' || g_newline ||
        '       AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id ' || g_newline ||
        '       AND jtdr.resource_exists_flag = ''Y'' ' || g_newline ||
        '       AND jtqu.qual_relation_product = lp_qual_combination_tbl(i) ' || g_newline ||
        '             ) ILV4841 ' || g_newline;

  ELSE

     lx_4841_sql := lx_4841_sql ||
      '         FROM  jtf_terr_denorm_rules_all jtdr ' || g_newline ||
      '            ,jtf_terr_qtype_usgs_all jtqu   ' || g_newline ||
      '            ,jtf_qual_type_usgs_all jqtu    ' || g_newline ||
      '         WHERE jtdr.terr_id= jtdr.related_terr_id ' || g_newline ||
      '         AND jtdr.source_id = p_source_id ' || g_newline ||
      '         AND jqtu.source_id = jtdr.source_id    ' || g_newline ||
      '         AND jqtu.qual_type_id = p_trans_object_type_id ' || g_newline ||
      '         AND jtdr.terr_id = jtqu.terr_id ' || g_newline ||
      '         AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id ' || g_newline ||
      '         AND jtdr.resource_exists_flag = ''Y'' ' || g_newline ||
      '         AND jtqu.qual_relation_product = lp_qual_combination_tbl(i) ' || g_newline ||
      '             ) ILV4841 ' || g_newline;

  END IF;

   lx_4841_sql := lx_4841_sql ||
     '       WHERE Q1007R1.qual_usg_id = -1007 ' || g_newline ||
     '         AND Q1007R1.terr_id = ILV4841.terr_id ' || g_newline ||
     '         AND Q1007R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||
     '         AND Q1003R1.comparison_operator = ''='' ' || g_newline ||
     '         AND Q1003R1.qual_usg_id = -1003 ' || g_newline ||
     '         AND Q1003R1.terr_id = ILV4841.terr_id ' || g_newline ||
     '       ORDER BY Q1003R1.low_value_char ' || g_newline ||
     '              , Q1007R1.low_value_char ' || g_newline ||
     '              , Q1007R1.high_value_char ' || g_newline ||
     '       ) ILV ' || g_newline ||
     '  WHERE 1 = 1 ' || g_newline;
     --
     -- JDOCHERT: 16/09/03: BUG#3143516: CHANGE END
     --
     IF p_new_mode_fetch <> 'Y' THEN
       lx_4841_sql := lx_4841_sql ||
         '  AND A.worker_id = P_WORKER_ID ' || g_newline;
     END IF;

   lx_4841_sql := lx_4841_sql ||
     '  AND ( ( a.squal_char06 <= ILV.q1007_high_value_char AND ' || g_newline ||
     '          a.squal_char06 >= ILV.q1007_low_value_char AND ' || g_newline ||
     '          ILV.q1007_cop = ''BETWEEN'' ) ' || g_newline ||
     '        OR ' || g_newline ||
     '        ( a.squal_char06 = ILV.q1007_low_value_char AND ' || g_newline ||
     '          ILV.q1007_cop = ''='' ) ' || g_newline ||
     '        OR ' || g_newline ||
     '        ( a.squal_char06 LIKE ILV.q1007_low_value_char AND ' || g_newline ||
     '          ILV.q1007_cop = ''LIKE'' ) ) ' || g_newline ||
     '  AND a.squal_char07 = ILV.q1003_low_value_char ; ' || g_newline ||
     ' END IF; ' || g_newline;

   RETURN lx_4841_sql;

EXCEPTION
WHEN OTHERS THEN
     g_ProgramStatus := 1;
         JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'ERROR: JTF_TAE_SQL_LIBRARY_PVT.add_4841_SQL');

END add_4841_SQL;



/*********************************************************
** JDOCHERT: 08/07/02
** Function to return customer name range + Postal Code + Country SQL
** SBEHERA :08/07/02
*********************************************************/
FUNCTION add_324347_SQL( p_trans_object_type_id   IN   NUMBER
                     , p_table_name               IN   VARCHAR2
                     -- dblee 08/26/03 added new mode flag
                     , p_new_mode_fetch           IN   CHAR)
RETURN VARCHAR2 AS

   lp_close_outermost_ILV      VARCHAR2(255);
   lp_SELECT_cols              VARCHAR2(32767) := NULL;
   lx_324347_sql               VARCHAR2(32767) := NULL;
   lx_324347_sql1              VARCHAR2(32767) := NULL;
   lp_pc_cntry_predicate_eq    VARCHAR2(32767) := NULL;
   lp_pc_cntry_predicate       VARCHAR2(32767) := NULL;
   lp_pc_cntry_predicate_btwn  VARCHAR2(32767) := NULL;
   l_sql                       VARCHAR2(32767) := NULL;
BEGIN

    -- dblee: 08/27/03 new mode support
    IF p_new_mode_fetch = 'Y' THEN
       lp_SELECT_cols :=
          /* ARPATEL: 01/15/2004 bug#3373462 */
          --G_INDENT5 || add_SELECT_cols(p_new_mode_fetch) || g_newline;
           G_INDENT5 || '       A.TRANS_OBJECT_ID' || g_newline ||
            G_INDENT5 || '       , A.TRANS_DETAIL_OBJECT_ID' || g_newline ||
            G_INDENT5 || '       , A.HEADER_ID1' || g_newline ||
            G_INDENT5 || '       , A.HEADER_ID2' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_FC01' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_FC02' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_FC03' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_FC04' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_FC05' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CURC01' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CURC02' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CURC03' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CURC04' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CURC05' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CURC06' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CURC07' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CURC08' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CURC09' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CURC10' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR01' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR02' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR03' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR04' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR05' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR06' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR07' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR08' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR09' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR10' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR11' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR12' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR13' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR14' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR15' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR16' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR17' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR18' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR19' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR20' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR21' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR22' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR23' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR24' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR25' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR26' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR27' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR28' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR30' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR31' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR32' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR33' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR34' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR35' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR36' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR37' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR38' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR39' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR40' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR41' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR42' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR43' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR44' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR45' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR46' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR47' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR48' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR49' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR50' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR51' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR52' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR53' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR54' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR55' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR56' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR57' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR58' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR59' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR60' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM01' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM02' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM03' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM04' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM05' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM06' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM07' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM08' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM09' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM10' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM11' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM12' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM13' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM14' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM15' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM16' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM17' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM18' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM19' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM20' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM21' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM22' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM23' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM24' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM25' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM26' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM27' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM28' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM29' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM30' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM31' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM32' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM33' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM34' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM35' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM36' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM37' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM38' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM39' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM40' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM41' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM42' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM43' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM44' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM45' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM46' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM47' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM48' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM49' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM50' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM51' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM52' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM53' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM54' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM55' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM56' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM57' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM58' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM59' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM60' || g_newline ||
            G_INDENT5 || '       , A.ASSIGNED_FLAG' || g_newline ||
            G_INDENT5 || '       , A.PROCESSED_FLAG' || g_newline ||
            G_INDENT5 || '       , A.ORG_ID' || g_newline ||
            G_INDENT5 || '       , A.SECURITY_GROUP_ID' || g_newline ||
            G_INDENT5 || '       , A.OBJECT_VERSION_NUMBER' || g_newline ||
            G_INDENT5 || '       , A.WORKER_ID' || g_newline ;

       lp_close_outermost_ILV := ') A;  ';
    ELSE
       lp_SELECT_cols :=
          G_INDENT5 || 'A.trans_object_id, A.trans_detail_object_id, ' || g_newline ||
          -- eihsu: 06/19/2003 worker_id
          G_INDENT5 || 'A.worker_id, ' || g_newline ||
          G_INDENT5 || 'A.header_id1, A.header_id2, ' || g_newline ||
          G_INDENT5 || 'ILV.terr_id, ILV.absolute_rank, ' || g_newline ||
          G_INDENT5 || 'ILV.top_level_terr_id, ILV.num_winners, ILV.org_id ';

          lp_close_outermost_ILV := ') ILV; ';
    END IF;

    lp_pc_cntry_predicate := '   1 = 1 ' || g_newline;

         -- eihsu: 06/19/2003 worker_id
     IF p_new_mode_fetch <> 'Y' THEN
       lp_pc_cntry_predicate := lp_pc_cntry_predicate ||
         '  AND A.worker_id = P_WORKER_ID ' || g_newline;
     END IF;

     lp_pc_cntry_predicate := lp_pc_cntry_predicate ||
         G_INDENT5 || '  AND Q1007R1.qual_usg_id = -1007 ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND    ( ' || g_newline ||
         G_INDENT5 || '        ( a.squal_char06 LIKE Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''LIKE'' ) ' || g_newline ||
         G_INDENT5 || '        OR ' || g_newline ||
         G_INDENT5 || '        ( a.squal_char06 = Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '        OR ' || g_newline ||
         G_INDENT5 || '      ( a.squal_char06 <= Q1007R1.high_value_char AND ' || g_newline ||
         G_INDENT5 || '          a.squal_char06 >= Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''BETWEEN'' ) ' || g_newline ||
         G_INDENT5 || '      ) ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.qual_usg_id = -1003 ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.terr_id = ILV.terr_id  ' || g_newline ||
         G_INDENT5 || '  AND ( a.squal_char07 = Q1003R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1003R1.comparison_operator = ''='' ) ' || g_newline;

    lp_pc_cntry_predicate_eq := '   1 = 1 ' || g_newline;

     IF p_new_mode_fetch <> 'Y' THEN
       lp_pc_cntry_predicate_eq := lp_pc_cntry_predicate_eq ||
         '  AND A.worker_id = P_WORKER_ID ' || g_newline;
     END IF;

    lp_pc_cntry_predicate_eq := lp_pc_cntry_predicate_eq ||
         -- eihsu: 06/19/2003 worker_id
         G_INDENT5 || '  AND   ( a.squal_char06 = Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.qual_usg_id = -1007 ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND  Q1007R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||
         G_INDENT5 || '  AND ( a.squal_char07 = Q1003R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1003R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.qual_usg_id = -1003 ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.terr_id = ILV.terr_id  ' || g_newline ;

    lp_pc_cntry_predicate_btwn := '   1 = 1 ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
       lp_pc_cntry_predicate_btwn := lp_pc_cntry_predicate_btwn ||
         '  AND A.worker_id = P_WORKER_ID ' || g_newline;
    END IF;

    lp_pc_cntry_predicate_btwn := lp_pc_cntry_predicate_btwn ||
         -- eihsu: 06/19/2003 worker_id
         G_INDENT5 || '  AND   ( a.squal_char06 <= Q1007R1.high_value_char AND ' || g_newline ||
         G_INDENT5 || '          a.squal_char06 >= Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''BETWEEN'' ) ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.qual_usg_id = -1007 ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND  Q1007R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||
         G_INDENT5 || '  AND ( a.squal_char07 = Q1003R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1003R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.qual_usg_id = -1003 ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.terr_id = ILV.terr_id  ' || g_newline ;

    --ARPATEL 10/14 bug#3194930
    JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => G_INDENT || add_SELECT_clause(p_new_mode_fetch) || g_newline
   );

    lx_324347_sql := lx_324347_sql ||
         --ARPATEL 10/14 bug#3194930
         --G_INDENT || add_SELECT_clause(p_new_mode_fetch) || g_newline ||
         G_INDENT || 'FROM ( ' || g_newline;

         /* START OF INLINE VIEW WITH 4 UNION ALLS */

         /************************/
         /*  = XYZ               */
         /************************/
    IF p_new_mode_fetch <> 'Y' THEN
      lx_324347_sql := lx_324347_sql ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1012R1 A) ' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
                  /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                        '_324347_ND)' || g_newline ||

         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1012R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline;
    ELSE
      lx_324347_sql := lx_324347_sql ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           NO_MERGE ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline;
    END IF;

      lx_324347_sql := lx_324347_sql ||
         /* Add SELECT columns */
         lp_SELECT_cols || g_newline ||

         G_INDENT5 || 'FROM ';

    IF p_new_mode_fetch = 'Y' THEN
       lx_324347_sql := lx_324347_sql ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_324347_sql := lx_324347_sql ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_324347_sql := lx_324347_sql ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1012R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate || g_newline ||
         --G_INDENT5 || '  AND Q1003R1.terr_id = Q1012R1.terr_id ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = Q1012R1.terr_id ' || g_newline ||
         G_INDENT5 || '  AND ( Q1012R1.comparison_operator = ''='' AND ' || g_newline ||
         G_INDENT5 || '        a.squal_fc01 = SUBSTR(Q1012R1.low_value_char, 1, 1) AND ' || g_newline ||
         G_INDENT5 || '        a.squal_char01 = Q1012R1.low_value_char ' || g_newline ||
         G_INDENT5 || '       ) ' || g_newline ||
         G_INDENT5 || '  AND Q1012R1.qual_usg_id = -1012  ' || g_newline ||
         G_INDENT5 || '  AND Q1012R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND  Q1012R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||


         G_INDENT5 || 'UNION ALL ' || g_newline;

         /************************/
         /*  LIKE XYZ%           */
         /************************/
    IF p_new_mode_fetch <> 'Y' THEN
      lx_324347_sql := lx_324347_sql ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1012LK A)  ' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||

         /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                      '_324347_ND)' || g_newline ||
         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1012LK JTF_TERR_CNR_QUAL_LIKE_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline;
    ELSE
      lx_324347_sql := lx_324347_sql ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           NO_MERGE ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline;
    END IF;

    lx_324347_sql := lx_324347_sql ||
         /* Add SELECT columns */
         lp_SELECT_cols || g_newline ||

         G_INDENT5 || 'FROM    ';

    IF p_new_mode_fetch = 'Y' THEN
       lx_324347_sql := lx_324347_sql ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_324347_sql := lx_324347_sql ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_324347_sql := lx_324347_sql ||
         G_INDENT5 || '   ,  jtf_terr_cnr_qual_like_mv Q1012LK ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate || g_newline ||

         G_INDENT5 || '  AND Q1007R1.terr_id = Q1012LK.terr_id ' || g_newline ||
         G_INDENT5 || '  AND      a.squal_char01 LIKE Q1012LK.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        a.squal_fc01 = Q1012LK.first_char ' || g_newline ||
         G_INDENT5 || '  AND      Q1012LK.qual_usg_id = -1012 ' || g_newline ||
         G_INDENT5 || '  AND Q1012LK.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || 'UNION ALL ' || g_newline --||
         ;

        --ARPATEL 10/14 bug#3194930
        JTF_TAE_GEN_PVT.write_buffer_content(
                   l_qual_rules => lx_324347_sql
         );

         /************************/
         /*  LIKE %XYZ           */
         /************************/
    IF p_new_mode_fetch <> 'Y' THEN
      lx_324347_sql1 :=
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1012LK A)  ' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                        '_324347X_ND)' || g_newline ||
         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1012LK JTF_TERR_CNR_QUAL_LIKE_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline;
    ELSE
      lx_324347_sql1 :=
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           NO_MERGE ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline;
    END IF;

    lx_324347_sql1 := lx_324347_sql1 ||
         /* Add SELECT columns */
         lp_SELECT_cols || g_newline ||

         G_INDENT5 || 'FROM   ';

    IF p_new_mode_fetch = 'Y' THEN
       lx_324347_sql1 := lx_324347_sql1 ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_324347_sql1 := lx_324347_sql1 ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_324347_sql1 := lx_324347_sql1 ||
         G_INDENT5 || '   ,  jtf_terr_cnr_qual_like_mv Q1012LK ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate_eq || g_newline ||

         G_INDENT5 || '  AND Q1007R1.terr_id = Q1012LK.terr_id ' || g_newline ||
         G_INDENT5 || '  AND      a.squal_char01 LIKE Q1012LK.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1012LK.first_char = ''%'' ' || g_newline ||
         G_INDENT5 || '  AND Q1012LK.qual_usg_id = -1012 ' || g_newline ||
         G_INDENT5 || '  AND Q1012LK.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || 'UNION ALL ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
      lx_324347_sql1 := lx_324347_sql1 ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1012LK A)  ' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                        '_324347X_ND)' || g_newline ||
         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1012LK JTF_TERR_CNR_QUAL_LIKE_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline;
    ELSE
      lx_324347_sql1 := lx_324347_sql1 ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           NO_MERGE ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline;
    END IF;

    lx_324347_sql1 := lx_324347_sql1 ||
         /* Add SELECT columns */
         lp_SELECT_cols || g_newline ||

         G_INDENT5 || 'FROM   ';

    IF p_new_mode_fetch = 'Y' THEN
       lx_324347_sql1 := lx_324347_sql1 ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_324347_sql1 := lx_324347_sql1 ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_324347_sql1 := lx_324347_sql1 ||
         G_INDENT5 || '   ,  jtf_terr_cnr_qual_like_mv Q1012LK ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate_btwn || g_newline ||

         G_INDENT5 || '  AND Q1007R1.terr_id = Q1012LK.terr_id ' || g_newline ||
         G_INDENT5 || '  AND      a.squal_char01 LIKE Q1012LK.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1012LK.first_char = ''%'' ' || g_newline ||
         G_INDENT5 || '  AND Q1012LK.qual_usg_id = -1012 ' || g_newline ||
         G_INDENT5 || '  AND Q1012LK.terr_id = ILV.terr_id ' || g_newline ||

         G_INDENT5 || 'UNION ALL ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
      lx_324347_sql1 := lx_324347_sql1 ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1012BT A) ' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                        '_324347_ND)' || g_newline ||

         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1012BT JTF_TERR_CNR_QUAL_BTWN_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline;
    ELSE
      lx_324347_sql1 := lx_324347_sql1 ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           NO_MERGE ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline;
    END IF;

    lx_324347_sql1 := lx_324347_sql1 ||
         /* Add SELECT columns */
         lp_SELECT_cols || g_newline ||

         G_INDENT5 || 'FROM   ';

    IF p_new_mode_fetch = 'Y' THEN
       lx_324347_sql1 := lx_324347_sql1 ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_324347_sql1 := lx_324347_sql1 ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_324347_sql1 := lx_324347_sql1 ||
         G_INDENT5 || '   ,  jtf_terr_cnr_qual_btwn_mv Q1012BT ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate || g_newline ||

         G_INDENT5 || '  AND Q1007R1.terr_id = Q1012BT.terr_id ' || g_newline ||
         G_INDENT5 || '  AND      a.squal_char01 <= Q1012BT.high_value_char AND ' || g_newline ||
         G_INDENT5 || '        a.squal_char01 >= Q1012BT.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        a.squal_fc01 >= SUBSTR(Q1012BT.low_value_char, 1, 1) ' || g_newline ||
         G_INDENT5 || '  AND Q1012BT.qual_usg_id = -1012 ' || g_newline ||
         G_INDENT5 || '  AND Q1012BT.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND Q1012BT.terr_id = Q1003R1.terr_id ' || g_newline ||

         /* END OF INLINE VIEW WITH 4 UNION ALLS */
         G_INDENT || lp_close_outermost_ILV || g_newline;

  RETURN lx_324347_sql1;
EXCEPTION
WHEN OTHERS THEN
     g_ProgramStatus := 1;
         JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'ERROR: JTF_TAE_SQL_LIBRARY_PVT.add_324347_SQL');

END add_324347_SQL;

FUNCTION EXP_PURCHASE_UNION_SELECT (p_new_mode_fetch  IN   CHAR)
RETURN VARCHAR2 AS
BEGIN
  --bug#3373462 ARPATEL: 01/30/2004
    IF p_new_mode_fetch = 'Y'
    THEN
      RETURN
            --G_INDENT || 'FROM ( ' || g_newline ||
            G_INDENT || 'SELECT /*+ NO_MERGE(ILV1) NO_MERGE(ILV2) */ ' || g_newline ||
            --G_INDENT || '                 USE_HASH(ILV1 ILV2) */' || g_newline ||
            G_INDENT || '         ILV2.TRANS_OBJECT_ID' || g_newline ||
            G_INDENT || '       , ILV2.TRANS_DETAIL_OBJECT_ID' || g_newline ||
            G_INDENT || '       , ILV2.HEADER_ID1' || g_newline ||
            G_INDENT || '       , ILV2.HEADER_ID2' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_FC01' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_FC02' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_FC03' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_FC04' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_FC05' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CURC01' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CURC02' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CURC03' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CURC04' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CURC05' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CURC06' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CURC07' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CURC08' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CURC09' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CURC10' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR01' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR02' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR03' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR04' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR05' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR06' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR07' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR08' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR09' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR10' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR11' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR12' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR13' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR14' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR15' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR16' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR17' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR18' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR19' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR20' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR21' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR22' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR23' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR24' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR25' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR26' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR27' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR28' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR30' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR31' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR32' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR33' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR34' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR35' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR36' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR37' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR38' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR39' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR40' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR41' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR42' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR43' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR44' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR45' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR46' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR47' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR48' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR49' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR50' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR51' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR52' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR53' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR54' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR55' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR56' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR57' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR58' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR59' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR60' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM01' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM02' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM03' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM04' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM05' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM06' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM07' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM08' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM09' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM10' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM11' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM12' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM13' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM14' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM15' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM16' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM17' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM18' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM19' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM20' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM21' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM22' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM23' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM24' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM25' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM26' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM27' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM28' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM29' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM30' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM31' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM32' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM33' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM34' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM35' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM36' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM37' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM38' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM39' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM40' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM41' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM42' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM43' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM44' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM45' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM46' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM47' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM48' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM49' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM50' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM51' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM52' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM53' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM54' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM55' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM56' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM57' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM58' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM59' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM60' || g_newline ||
            G_INDENT || '       , ILV2.ASSIGNED_FLAG' || g_newline ||
            G_INDENT || '       , ILV2.PROCESSED_FLAG' || g_newline ||
            G_INDENT || '       , ILV2.ORG_ID' || g_newline ||
            G_INDENT || '       , ILV2.SECURITY_GROUP_ID' || g_newline ||
            G_INDENT || '       , ILV2.OBJECT_VERSION_NUMBER' || g_newline ||
            G_INDENT || '       , ILV2.WORKER_ID' || g_newline ||
            G_INDENT || '       , ILV2.TERR_ID' || g_newline ||
            G_INDENT || '       , ILV2.ABSOLUTE_RANK' || g_newline ||
            G_INDENT || '       , ILV2.TOP_LEVEL_TERR_ID' || g_newline ||
            G_INDENT || '       , ILV2.NUM_WINNERS' || g_newline ||
            G_INDENT || '   FROM '|| g_newline;
    ELSE
        RETURN
         G_INDENT || 'SELECT /*+ NO_MERGE(ILV1) NO_MERGE(ILV2) ' || g_newline ||
         G_INDENT || '                 USE_HASH(ILV1 ILV2) */' || g_newline ||
         G_INDENT || '             ILV2.trans_object_id' || g_newline ||
         G_INDENT || '           , ILV2.trans_detail_object_id' || g_newline ||
             -- eihsu 06/19/2003 worker_id
         G_INDENT || '           , ILV2.worker_id' || g_newline ||
         G_INDENT || '           , ILV2.header_id1' || g_newline ||
         G_INDENT || '           , ILV2.header_id2' || g_newline ||
         G_INDENT || '           , ILV2.terr_id' || g_newline ||
         G_INDENT || '           , ILV2.absolute_rank' || g_newline ||
         G_INDENT || '           , ILV2.top_level_terr_id' || g_newline ||
         G_INDENT || '           , ILV2.num_winners' || g_newline ||
         G_INDENT || '           , ILV2.org_id' || g_newline ||
         G_INDENT || '      FROM '|| g_newline; --||
    END IF;
END EXP_PURCHASE_UNION_SELECT;


--** OPPORTUNITY PRODUCT CATEGORY + Country + Postal Code ***
FUNCTION add_934313_SQL( p_trans_object_type_id   IN   NUMBER
                     , p_table_name             IN   VARCHAR2
                     -- dblee 08/26/03 added new mode flag
                     , p_new_mode_fetch         IN   CHAR)
RETURN VARCHAR2 AS

   lp_close_outermost_ILV      VARCHAR2(255);
   l_select_ilv2               VARCHAR2(32767) := NULL;
   lp_SELECT_cols              VARCHAR2(32767) := NULL;
   lx_934313_sql               VARCHAR2(32767) := NULL;
   lx_934313_sql_2             VARCHAR2(32767) := NULL;
   lx_934313_sql_3             VARCHAR2(32767) := NULL;
   lx_934313_sql_4             VARCHAR2(32767) := NULL;
   lx_934313_sql_5             VARCHAR2(32767) := NULL;
   lx_934313_sql_6             VARCHAR2(32767) := NULL;

   lp_pc_cntry_predicate       VARCHAR2(32767) := NULL;
   l_sql                       VARCHAR2(32767) := NULL;

BEGIN
--** OPPORTUNITY EXPECTED PURCHASE + Country + Postal Code ***

    -- dblee: 08/27/03 new mode support
    IF p_new_mode_fetch = 'Y' THEN
       l_select_ilv2 := add_SELECT_clause(p_new_mode_fetch);

       lp_SELECT_cols :=
          --G_INDENT5 || add_SELECT_cols(p_new_mode_fetch) || g_newline;
          /* ARPATEL: bug#3373462 */
	    G_INDENT || '       A.TRANS_OBJECT_ID' || g_newline ||
            G_INDENT || '       , A.TRANS_DETAIL_OBJECT_ID' || g_newline ||
            G_INDENT || '       , A.HEADER_ID1' || g_newline ||
            G_INDENT || '       , A.HEADER_ID2' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC01' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC02' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC03' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC04' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC05' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC01' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC02' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC03' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC04' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC05' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC06' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC07' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC08' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC09' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC10' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR01' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR02' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR03' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR04' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR05' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR06' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR07' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR08' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR09' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR10' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR11' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR12' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR13' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR14' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR15' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR16' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR17' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR18' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR19' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR20' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR21' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR22' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR23' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR24' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR25' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR26' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR27' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR28' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR30' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR31' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR32' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR33' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR34' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR35' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR36' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR37' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR38' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR39' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR40' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR41' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR42' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR43' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR44' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR45' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR46' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR47' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR48' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR49' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR50' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR51' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR52' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR53' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR54' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR55' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR56' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR57' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR58' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR59' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR60' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM01' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM02' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM03' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM04' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM05' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM06' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM07' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM08' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM09' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM10' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM11' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM12' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM13' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM14' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM15' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM16' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM17' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM18' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM19' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM20' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM21' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM22' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM23' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM24' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM25' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM26' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM27' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM28' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM29' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM30' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM31' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM32' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM33' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM34' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM35' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM36' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM37' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM38' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM39' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM40' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM41' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM42' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM43' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM44' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM45' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM46' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM47' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM48' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM49' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM50' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM51' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM52' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM53' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM54' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM55' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM56' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM57' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM58' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM59' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM60' || g_newline ||
            G_INDENT || '       , A.ASSIGNED_FLAG' || g_newline ||
            G_INDENT || '       , A.PROCESSED_FLAG' || g_newline ||
            G_INDENT || '       , A.ORG_ID' || g_newline ||
            G_INDENT || '       , A.SECURITY_GROUP_ID' || g_newline ||
            G_INDENT || '       , A.OBJECT_VERSION_NUMBER' || g_newline ||
            G_INDENT || '       , A.WORKER_ID' || g_newline ||
	        G_INDENT || '     , ILV.terr_id ' || g_newline ||
            G_INDENT || '     , ILV.absolute_rank ' || g_newline ||
            G_INDENT || '     , ILV.top_level_terr_id '|| g_newline ||
            G_INDENT || '     , ILV.num_winners ' || g_newline;


       lp_close_outermost_ILV := ') A; -- jtf_tae_sql_lib_pvt_nm826 line 841 ';
    ELSE
       l_select_ilv2 :=
          G_INDENT5 || 'SELECT DISTINCT ' || g_newline ||
          G_INDENT5 ||'ILV2.trans_object_id' || g_newline ||
          G_INDENT5 ||', ILV2.trans_detail_object_id' || g_newline ||
          -- eihsu 06/19/2003 worker_id
          G_INDENT5 ||', ILV2.worker_id' || g_newline ||
          G_INDENT5 ||',ILV2.header_id1' || g_newline ||
          G_INDENT5 ||',ILV2.header_id2' || g_newline ||
          G_INDENT5 ||', p_source_id' || g_newline ||
          G_INDENT5 ||', p_trans_object_type_id' || g_newline ||
          G_INDENT5 ||', l_sysdate' || g_newline ||
          G_INDENT5 ||', L_USER_ID' || g_newline ||
          G_INDENT5 ||', l_sysdate' || g_newline ||
          G_INDENT5 ||', L_USER_ID' || g_newline ||
          G_INDENT5 ||', L_USER_ID' || g_newline ||
          G_INDENT5 ||', L_REQUEST_ID' || g_newline ||
          G_INDENT5 ||', L_PROGRAM_APPL_ID' || g_newline ||
          G_INDENT5 ||', L_PROGRAM_ID' || g_newline ||
          G_INDENT5 ||', l_sysdate' || g_newline ||
          G_INDENT5 ||', ILV2.terr_id' || g_newline ||
          G_INDENT5 ||', ILV2.absolute_rank' || g_newline ||
          G_INDENT5 ||', ILV2.top_level_terr_id' || g_newline ||
          G_INDENT5 ||', ILV2.num_winners' || g_newline ||
          G_INDENT5 ||', ILV2.org_id' || g_newline ;

       lp_SELECT_cols :=
          G_INDENT5 || 'A.trans_object_id, A.trans_detail_object_id, ' || g_newline ||
          -- eihsu 06/19/2003 worker_id
          G_INDENT5 || 'A.worker_id, ' || g_newline ||
          G_INDENT5 || 'A.header_id1, A.header_id2, ' || g_newline ||
          G_INDENT5 || 'ILV.terr_id, ILV.absolute_rank, ' || g_newline ||
          G_INDENT5 || 'ILV.top_level_terr_id, ILV.num_winners, ILV.org_id ';

       lp_close_outermost_ILV := ') ILV2; ';
    END IF; -- p_new_mode_fetch = 'Y'

    lp_pc_cntry_predicate := '   1 = 1 ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
       lp_pc_cntry_predicate := lp_pc_cntry_predicate ||
         '  AND A.worker_id = P_WORKER_ID ' || g_newline;
    END IF;

    lp_pc_cntry_predicate := lp_pc_cntry_predicate ||
         G_INDENT5 || '  AND  ( ( a.squal_char06 <= Q1007R1.high_value_char AND ' || g_newline ||
         G_INDENT5 || '          a.squal_char06 >= Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''BETWEEN'' ) ' || g_newline ||
         G_INDENT5 || '        OR ' || g_newline ||
         G_INDENT5 || '        ( a.squal_char06 = Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '      ) ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.qual_usg_id = -1007 ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND  Q1007R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||
         G_INDENT5 || '  AND ( a.squal_char07 = Q1003R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1003R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.qual_usg_id = -1003 ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.terr_id = ILV.terr_id  ' || g_newline ;

    --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => l_select_ilv2
       );

      --bug#3373462 ARPATEL: 01/30/2004
    JTF_TAE_GEN_PVT.write_buffer_content(
    G_INDENT5 || 'FROM ( ' || g_newline || EXP_PURCHASE_UNION_SELECT(p_new_mode_fetch)
    );

    lx_934313_sql :=
        -- G_INDENT || l_select_ilv2 || g_newline ||
        -- G_INDENT || 'FROM ( ' || g_newline ||
        -- G_INDENT || 'SELECT /*+ NO_MERGE(ILV1) NO_MERGE(ILV2) ' || g_newline ||
        -- G_INDENT || '                 USE_HASH(ILV1 ILV2) */' || g_newline ||
        -- G_INDENT || '             ILV2.trans_object_id' || g_newline ||
        -- G_INDENT || '           , ILV2.trans_detail_object_id' || g_newline ||
         -- eihsu 06/19/2003 worker_id
       --  G_INDENT || '           , ILV2.worker_id' || g_newline ||
       --  G_INDENT || '           , ILV2.header_id1' || g_newline ||
       --  G_INDENT || '           , ILV2.header_id2' || g_newline ||
       --  G_INDENT || '           , ILV2.terr_id' || g_newline ||
       --  G_INDENT || '           , ILV2.absolute_rank' || g_newline ||
       --  G_INDENT || '           , ILV2.top_level_terr_id' || g_newline ||
       --  G_INDENT || '           , ILV2.num_winners' || g_newline ||
       --  G_INDENT || '           , ILV2.org_id' || g_newline ||
       --  G_INDENT || '      FROM'|| g_newline ||
         /************************/
         /*  = ILV1               */
         /************************/
         G_INDENT5 || '( /* INLINE VIEW1 */' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1142R1 ALLP) ' || g_newline ||
         G_INDENT5 || '           INDEX(ALLP AS_LEAD_LINES_N2)' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ||
         G_INDENT5 || '                      ALLP.lead_id' || g_newline ||
         G_INDENT5 || '                    , ALLP.lead_line_id' || g_newline ||
         G_INDENT5 || '                    , ILV.terr_id ' || g_newline ||
         G_INDENT5 || '                     , ILV.top_level_terr_id ' || g_newline ||
         G_INDENT5 || '                     , ILV.absolute_rank  ' || g_newline ||
         G_INDENT5 || '                     , ILV.num_winners ' || g_newline ||
         G_INDENT5 || '                     , ILV.org_id ' || g_newline ||
         G_INDENT5 || '                 FROM AS_LEAD_LINES ALLP, eni_prod_denorm_hrchy_v prd, ' || g_newline ||
         G_INDENT5 || '                      jtf_terr_qual_rules_mv Q1142R1, ' || g_newline ||

         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch) ||

         G_INDENT5 || '                WHERE  (  Q1142R1.qual_usg_id = -1142 AND Q1142R1.terr_id = ILV.terr_id )' || g_newline ||
         G_INDENT5 || '                AND   Q1142R1.value1_id = PRD.child_id ' || g_newline ||
         G_INDENT5 || '                AND   Q1142R1.value2_id = PRD.category_set_id ' || g_newline ||
         G_INDENT5 || '                AND   PRD.parent_id = ALLP.product_category_id ' || g_newline ||
         G_INDENT5 || '                AND   PRD.category_set_id = ALLP.product_cat_set_id ' || g_newline ||
         G_INDENT5 || '                AND   Q1142R1.comparison_operator = ''=''' || g_newline ||
         G_INDENT5 || '   ) ILV1,' || g_newline ||

          /************************/
         /*  = XYZ  ILV2             */
         /************************/
         G_INDENT5 || '   ( ' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||
         G_INDENT5 || '           NO_MERGE ' || g_newline ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
      lx_934313_sql := lx_934313_sql ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 A) ' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
                  /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                        '_4841_ND)' || g_newline ||

         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline;
    END IF;

      lx_934313_sql := lx_934313_sql ||
         G_INDENT5 || '       */ ' || g_newline ; --||

         /* Add SELECT columns */
         JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lx_934313_sql
       );
         --lp_SELECT_cols || g_newline ; ||

         JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lp_SELECT_cols || g_newline
       );

         lx_934313_sql_2 :=
         G_INDENT5 || 'FROM ';

    IF p_new_mode_fetch = 'Y' THEN
       lx_934313_sql_2 := lx_934313_sql_2 ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_934313_sql_2 := lx_934313_sql_2 ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_934313_sql_2 := lx_934313_sql_2 ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate || g_newline ||
         G_INDENT5 || ') ILV2' || g_newline ||
         G_INDENT5 || 'WHERE ILV1.terr_id = ILV2.terr_id' || g_newline ||
         G_INDENT5 || 'AND ILV1.lead_id = ILV2.trans_object_id' || g_newline ||
         G_INDENT || lp_close_outermost_ILV || g_newline;

    RETURN lx_934313_sql_2;

EXCEPTION
WHEN OTHERS THEN
     g_ProgramStatus := 1;
         JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'ERROR: JTF_TAE_SQL_LIBRARY_PVT.add_934313_SQL');

END add_934313_SQL;


--** OPPORTUNITY PRODUCT CATEGORY + CNR + Country + Postal Code ***
FUNCTION add_62598971_SQL( p_trans_object_type_id   IN   NUMBER
                     , p_table_name             IN   VARCHAR2
                     -- dblee 08/26/03 added new mode flag
                     , p_new_mode_fetch         IN   CHAR)
RETURN VARCHAR2 AS

   lp_close_outermost_ILV      VARCHAR2(255);
   l_select_ilv2               VARCHAR2(32767) := NULL;
   lp_SELECT_cols              VARCHAR2(32767) := NULL;
   lx_62598971_sql             VARCHAR2(32767) := NULL;
   --ARPATEL
   lx_62598971_sql_2           VARCHAR2(32767) := NULL;
   lx_62598971_sql_3           VARCHAR2(32767) := NULL;
   lx_62598971_sql_4           VARCHAR2(32767) := NULL;
   lx_62598971_sql_5           VARCHAR2(32767) := NULL;
   lx_62598971_sql_6           VARCHAR2(32767) := NULL;

   lp_pc_cntry_predicate_eq    VARCHAR2(32767) := NULL;
   lp_pc_cntry_predicate       VARCHAR2(32767) := NULL;
   lp_pc_cntry_predicate_btwn  VARCHAR2(32767) := NULL;
   l_sql                       VARCHAR2(32767) := NULL;

BEGIN
--** OPPORTUNITY EXPECTED PURCHASE + CNR + Country + Postal Code ***

    -- dblee: 08/27/03 new mode support
    IF p_new_mode_fetch = 'Y' THEN
       l_select_ilv2 := add_SELECT_clause(p_new_mode_fetch);

       lp_SELECT_cols :=
          --G_INDENT5 || add_SELECT_cols(p_new_mode_fetch) || g_newline;
          /* ARPATEL: bug#3373462 */
	    G_INDENT || '       A.TRANS_OBJECT_ID' || g_newline ||
            G_INDENT || '       , A.TRANS_DETAIL_OBJECT_ID' || g_newline ||
            G_INDENT || '       , A.HEADER_ID1' || g_newline ||
            G_INDENT || '       , A.HEADER_ID2' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC01' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC02' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC03' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC04' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC05' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC01' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC02' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC03' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC04' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC05' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC06' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC07' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC08' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC09' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC10' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR01' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR02' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR03' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR04' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR05' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR06' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR07' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR08' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR09' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR10' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR11' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR12' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR13' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR14' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR15' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR16' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR17' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR18' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR19' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR20' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR21' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR22' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR23' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR24' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR25' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR26' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR27' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR28' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR30' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR31' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR32' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR33' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR34' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR35' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR36' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR37' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR38' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR39' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR40' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR41' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR42' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR43' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR44' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR45' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR46' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR47' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR48' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR49' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR50' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR51' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR52' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR53' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR54' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR55' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR56' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR57' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR58' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR59' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR60' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM01' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM02' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM03' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM04' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM05' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM06' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM07' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM08' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM09' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM10' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM11' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM12' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM13' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM14' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM15' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM16' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM17' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM18' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM19' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM20' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM21' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM22' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM23' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM24' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM25' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM26' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM27' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM28' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM29' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM30' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM31' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM32' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM33' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM34' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM35' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM36' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM37' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM38' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM39' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM40' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM41' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM42' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM43' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM44' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM45' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM46' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM47' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM48' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM49' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM50' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM51' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM52' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM53' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM54' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM55' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM56' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM57' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM58' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM59' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM60' || g_newline ||
            G_INDENT || '       , A.ASSIGNED_FLAG' || g_newline ||
            G_INDENT || '       , A.PROCESSED_FLAG' || g_newline ||
            G_INDENT || '       , A.ORG_ID' || g_newline ||
            G_INDENT || '       , A.SECURITY_GROUP_ID' || g_newline ||
            G_INDENT || '       , A.OBJECT_VERSION_NUMBER' || g_newline ||
            G_INDENT || '       , A.WORKER_ID' || g_newline ||
	        G_INDENT || '     , ILV.terr_id ' || g_newline ||
            G_INDENT || '     , ILV.absolute_rank ' || g_newline ||
            G_INDENT || '     , ILV.top_level_terr_id '|| g_newline ||
            G_INDENT || '     , ILV.num_winners ' || g_newline;


       lp_close_outermost_ILV := ') A; -- jtf_tae_sql_lib_pvt_nm826 line 841 ';
    ELSE
       l_select_ilv2 :=
          G_INDENT5 || 'SELECT DISTINCT ' || g_newline ||
          G_INDENT5 ||'ILV2.trans_object_id' || g_newline ||
          G_INDENT5 ||', ILV2.trans_detail_object_id' || g_newline ||
          -- eihsu 06/19/2003 worker_id
          G_INDENT5 ||', ILV2.worker_id' || g_newline ||
          G_INDENT5 ||',ILV2.header_id1' || g_newline ||
          G_INDENT5 ||',ILV2.header_id2' || g_newline ||
          G_INDENT5 ||', p_source_id' || g_newline ||
          G_INDENT5 ||', p_trans_object_type_id' || g_newline ||
          G_INDENT5 ||', l_sysdate' || g_newline ||
          G_INDENT5 ||', L_USER_ID' || g_newline ||
          G_INDENT5 ||', l_sysdate' || g_newline ||
          G_INDENT5 ||', L_USER_ID' || g_newline ||
          G_INDENT5 ||', L_USER_ID' || g_newline ||
          G_INDENT5 ||', L_REQUEST_ID' || g_newline ||
          G_INDENT5 ||', L_PROGRAM_APPL_ID' || g_newline ||
          G_INDENT5 ||', L_PROGRAM_ID' || g_newline ||
          G_INDENT5 ||', l_sysdate' || g_newline ||
          G_INDENT5 ||', ILV2.terr_id' || g_newline ||
          G_INDENT5 ||', ILV2.absolute_rank' || g_newline ||
          G_INDENT5 ||', ILV2.top_level_terr_id' || g_newline ||
          G_INDENT5 ||', ILV2.num_winners' || g_newline ||
          G_INDENT5 ||', ILV2.org_id' || g_newline ;

       lp_SELECT_cols :=
          G_INDENT5 || 'A.trans_object_id, A.trans_detail_object_id, ' || g_newline ||
          -- eihsu 06/19/2003 worker_id
          G_INDENT5 || 'A.worker_id, ' || g_newline ||
          G_INDENT5 || 'A.header_id1, A.header_id2, ' || g_newline ||
          G_INDENT5 || 'ILV.terr_id, ILV.absolute_rank, ' || g_newline ||
          G_INDENT5 || 'ILV.top_level_terr_id, ILV.num_winners, ILV.org_id ';

       lp_close_outermost_ILV := ') ILV2; ';
    END IF; -- p_new_mode_fetch = 'Y'

    lp_pc_cntry_predicate := '   1 = 1 ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
       lp_pc_cntry_predicate := lp_pc_cntry_predicate ||
         '  AND A.worker_id = P_WORKER_ID ' || g_newline;
    END IF;

    lp_pc_cntry_predicate := lp_pc_cntry_predicate ||
         G_INDENT5 || '  AND  ( ( a.squal_char06 <= Q1007R1.high_value_char AND ' || g_newline ||
         G_INDENT5 || '          a.squal_char06 >= Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''BETWEEN'' ) ' || g_newline ||
         G_INDENT5 || '        OR ' || g_newline ||
         G_INDENT5 || '        ( a.squal_char06 = Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '      ) ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.qual_usg_id = -1007 ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND  Q1007R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||
         G_INDENT5 || '  AND ( a.squal_char07 = Q1003R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1003R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.qual_usg_id = -1003 ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.terr_id = ILV.terr_id  ' || g_newline ;

    lp_pc_cntry_predicate_eq := '   1 = 1 ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
       lp_pc_cntry_predicate_eq := lp_pc_cntry_predicate_eq ||
         '  AND A.worker_id = P_WORKER_ID ' || g_newline;
    END IF;

    lp_pc_cntry_predicate_eq := lp_pc_cntry_predicate_eq ||
         G_INDENT5 || '  AND   ( a.squal_char06 = Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.qual_usg_id = -1007 ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND  Q1007R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||
         G_INDENT5 || '  AND ( a.squal_char07 = Q1003R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1003R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.qual_usg_id = -1003 ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.terr_id = ILV.terr_id  ' || g_newline ;

    lp_pc_cntry_predicate_btwn := '   1 = 1 ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
       lp_pc_cntry_predicate_btwn := lp_pc_cntry_predicate_btwn ||
         '  AND A.worker_id = P_WORKER_ID ' || g_newline;
    END IF;

    lp_pc_cntry_predicate_btwn := lp_pc_cntry_predicate_btwn ||
         G_INDENT5 || '  AND ( a.squal_char06 <= Q1007R1.high_value_char AND ' || g_newline ||
         G_INDENT5 || '          a.squal_char06 >= Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''BETWEEN'' ) ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.qual_usg_id = -1007 ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND  Q1007R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||
         G_INDENT5 || '  AND ( a.squal_char07 = Q1003R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1003R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.qual_usg_id = -1003 ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.terr_id = ILV.terr_id  ' || g_newline ;

    --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => l_select_ilv2
       );

      --bug#3373462 ARPATEL: 01/30/2004
    JTF_TAE_GEN_PVT.write_buffer_content(
    G_INDENT5 || 'FROM ( ' || g_newline || EXP_PURCHASE_UNION_SELECT(p_new_mode_fetch)
    );

    lx_62598971_sql :=
        -- G_INDENT || l_select_ilv2 || g_newline ||
        -- G_INDENT || 'FROM ( ' || g_newline ||
        -- G_INDENT || 'SELECT /*+ NO_MERGE(ILV1) NO_MERGE(ILV2) ' || g_newline ||
        -- G_INDENT || '                 USE_HASH(ILV1 ILV2) */' || g_newline ||
        -- G_INDENT || '             ILV2.trans_object_id' || g_newline ||
        -- G_INDENT || '           , ILV2.trans_detail_object_id' || g_newline ||
         -- eihsu 06/19/2003 worker_id
       --  G_INDENT || '           , ILV2.worker_id' || g_newline ||
       --  G_INDENT || '           , ILV2.header_id1' || g_newline ||
       --  G_INDENT || '           , ILV2.header_id2' || g_newline ||
       --  G_INDENT || '           , ILV2.terr_id' || g_newline ||
       --  G_INDENT || '           , ILV2.absolute_rank' || g_newline ||
       --  G_INDENT || '           , ILV2.top_level_terr_id' || g_newline ||
       --  G_INDENT || '           , ILV2.num_winners' || g_newline ||
       --  G_INDENT || '           , ILV2.org_id' || g_newline ||
       --  G_INDENT || '      FROM'|| g_newline ||
         /************************/
         /*  = ILV1               */
         /************************/
         G_INDENT5 || '( /* INLINE VIEW1 */' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline;

         IF p_new_mode_fetch = 'Y' THEN
           lx_62598971_sql := lx_62598971_sql || G_INDENT5 || '       ORDERED ' || g_newline;
         END IF;

         lx_62598971_sql := lx_62598971_sql ||

         G_INDENT5 || '           USE_NL(ILV Q1142R1 ALLP) ' || g_newline ||
         G_INDENT5 || '           INDEX(ALLP AS_LEAD_LINES_N2)' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ||
         G_INDENT5 || '                      ALLP.lead_id' || g_newline ||
         G_INDENT5 || '                    , ALLP.lead_line_id' || g_newline ||
         G_INDENT5 || '                    , ILV.terr_id ' || g_newline ||
         G_INDENT5 || '                     , ILV.top_level_terr_id ' || g_newline ||
         G_INDENT5 || '                     , ILV.absolute_rank  ' || g_newline ||
         G_INDENT5 || '                     , ILV.num_winners ' || g_newline ||
         G_INDENT5 || '                     , ILV.org_id ' || g_newline ||

         G_INDENT5 || '                 FROM ' ||  g_newline;

    IF p_new_mode_fetch = 'Y' THEN
       lx_62598971_sql := lx_62598971_sql ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_62598971_sql := lx_62598971_sql ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_62598971_sql := lx_62598971_sql ||
         G_INDENT5 || '                     ,jtf_terr_qual_rules_mv Q1142R1 ' || g_newline ||
         G_INDENT5 || '                 ,ENI_PROD_DENORM_HRCHY_V PRD,AS_LEAD_LINES ALLP ' ||  g_newline ||

         G_INDENT5 || '                WHERE  (  Q1142R1.qual_usg_id = -1142 AND Q1142R1.terr_id = ILV.terr_id )' || g_newline ||
         G_INDENT5 || '                AND   Q1142R1.value1_id = PRD.child_id ' || g_newline ||
         G_INDENT5 || '                AND   Q1142R1.value2_id = PRD.category_set_id ' || g_newline ||
         G_INDENT5 || '                AND   PRD.parent_id = ALLP.product_category_id ' || g_newline ||
         G_INDENT5 || '                AND   PRD.category_set_id = ALLP.product_cat_set_id ' || g_newline ||
         G_INDENT5 || '                AND   Q1142R1.comparison_operator = ''=''' || g_newline ||
         G_INDENT5 || '   ) ILV1,' || g_newline ||

          /************************/
         /*  = XYZ  ILV2             */
         /************************/
         G_INDENT5 || '   ( ' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline;

         IF p_new_mode_fetch <> 'Y' THEN
           lx_62598971_sql := lx_62598971_sql ||
             G_INDENT5 || '           ORDERED ' || g_newline ||
             G_INDENT5 || '           USE_CONCAT ' || g_newline ||
             G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1012R1 A) ' || g_newline ||
             G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
                      /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
             G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                            '_324347_ND)' || g_newline ||

             G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
             G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
             G_INDENT5 || '           INDEX(Q1012R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
             G_INDENT5 || '       */ ' || g_newline ; --||
         ELSE
           lx_62598971_sql := lx_62598971_sql ||
             G_INDENT5 || '           ORDERED ' || g_newline ||
             G_INDENT5 || '           USE_CONCAT ' || g_newline ||
             G_INDENT5 || '           NO_MERGE ' || g_newline ||
             G_INDENT5 || '       */ ' || g_newline ; --||
         END IF;

         /* Add SELECT columns */
         JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lx_62598971_sql
       );
         --lp_SELECT_cols || g_newline ; ||

         JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lp_SELECT_cols || g_newline
       );

         lx_62598971_sql_2 :=
         G_INDENT5 || 'FROM ';

    IF p_new_mode_fetch = 'Y' THEN
       lx_62598971_sql_2 := lx_62598971_sql_2 ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_62598971_sql_2 := lx_62598971_sql_2 ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_62598971_sql_2 := lx_62598971_sql_2 ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1012R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate || g_newline ||
         --G_INDENT5 || '  AND Q1003R1.terr_id = Q1012R1.terr_id ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = Q1012R1.terr_id ' || g_newline ||
         G_INDENT5 || '  AND ( Q1012R1.comparison_operator = ''='' AND ' || g_newline ||
         G_INDENT5 || '        a.squal_fc01 = SUBSTR(Q1012R1.low_value_char, 1, 1) AND ' || g_newline ||
         G_INDENT5 || '        a.squal_char01 = Q1012R1.low_value_char ' || g_newline ||
         G_INDENT5 || '       ) ' || g_newline ||
         G_INDENT5 || '  AND Q1012R1.qual_usg_id = -1012  ' || g_newline ||
         G_INDENT5 || '  AND Q1012R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND  Q1012R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||
         G_INDENT5 || ') ILV2' || g_newline ||
         G_INDENT5 || 'WHERE ILV1.terr_id = ILV2.terr_id' || g_newline ||
         G_INDENT5 || 'AND ILV1.lead_id = ILV2.trans_object_id' || g_newline ||

         G_INDENT5 || 'UNION ALL ' || g_newline ; --||

         --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lx_62598971_sql_2
       );

      --bug#3373462 ARPATEL: 01/30/2004
    JTF_TAE_GEN_PVT.write_buffer_content(
    G_INDENT || EXP_PURCHASE_UNION_SELECT(p_new_mode_fetch)
    );

         lx_62598971_sql_3 :=

         --G_INDENT || 'SELECT /*+ NO_MERGE(ILV1) NO_MERGE(ILV2) ' || g_newline ||
         --G_INDENT || '                 USE_HASH(ILV1 ILV2) */' || g_newline ||
         --G_INDENT || '             ILV2.trans_object_id' || g_newline ||
         --G_INDENT || '           , ILV2.trans_detail_object_id' || g_newline ||
         -- eihsu 06/19/2003 worker_id
         --G_INDENT || '           , ILV2.worker_id' || g_newline ||
         --G_INDENT || '           , ILV2.header_id1' || g_newline ||
         --G_INDENT || '           , ILV2.header_id2' || g_newline ||
         --G_INDENT || '           , ILV2.terr_id' || g_newline ||
         --G_INDENT || '           , ILV2.absolute_rank' || g_newline ||
         --G_INDENT || '           , ILV2.top_level_terr_id' || g_newline ||
         --G_INDENT || '           , ILV2.num_winners' || g_newline ||
         --G_INDENT || '           , ILV2.org_id' || g_newline ||
         --G_INDENT || '      FROM'|| g_newline ||
         /************************/
         /*  = ILV1               */
         /************************/
         G_INDENT5 || '( /* INLINE VIEW1 */' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline;

         IF p_new_mode_fetch = 'Y' THEN
           lx_62598971_sql_3 := lx_62598971_sql_3 || G_INDENT5 || '       ORDERED ' || g_newline;
         END IF;

       lx_62598971_sql_3 := lx_62598971_sql_3 ||
         G_INDENT5 || '           USE_NL(ILV Q1142R1 ALLP) ' || g_newline ||
         G_INDENT5 || '           INDEX(ALLP AS_LEAD_LINES_N2)' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ||
         G_INDENT5 || '                      ALLP.lead_id' || g_newline ||
         G_INDENT5 || '                    , ALLP.lead_line_id' || g_newline ||
         G_INDENT5 || '                    , ILV.terr_id ' || g_newline ||
         G_INDENT5 || '                     , ILV.top_level_terr_id ' || g_newline ||
         G_INDENT5 || '                     , ILV.absolute_rank  ' || g_newline ||
         G_INDENT5 || '                     , ILV.num_winners ' || g_newline ||
         G_INDENT5 || '                     , ILV.org_id ' || g_newline ||

         G_INDENT5 || '                 FROM ' ||  g_newline;

    IF p_new_mode_fetch = 'Y' THEN
       lx_62598971_sql_3 := lx_62598971_sql_3 ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_62598971_sql_3 := lx_62598971_sql_3 ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_62598971_sql_3 := lx_62598971_sql_3 ||
         G_INDENT5 || '                     ,jtf_terr_qual_rules_mv Q1142R1 ' || g_newline ||
         G_INDENT5 || '                 ,ENI_PROD_DENORM_HRCHY_V PRD,AS_LEAD_LINES ALLP ' ||  g_newline ||

         G_INDENT5 || '                WHERE  (  Q1142R1.qual_usg_id = -1142 AND Q1142R1.terr_id = ILV.terr_id )' || g_newline ||
         G_INDENT5 || '                AND   Q1142R1.value1_id = PRD.child_id ' || g_newline ||
         G_INDENT5 || '                AND   Q1142R1.value2_id = PRD.category_set_id ' || g_newline ||
         G_INDENT5 || '                AND   PRD.parent_id = ALLP.product_category_id ' || g_newline ||
         G_INDENT5 || '                AND   PRD.category_set_id = ALLP.product_cat_set_id ' || g_newline ||
         G_INDENT5 || '                AND   Q1142R1.comparison_operator = ''=''' || g_newline ||
         G_INDENT5 || '   ) ILV1,' || g_newline ||


         /************************/
         /*  LIKE XYZ%           */
         /************************/
         G_INDENT5 || '   ( ' || g_newline ||
          G_INDENT5 || 'SELECT /*+ ' || g_newline;

         IF p_new_mode_fetch <> 'Y' THEN
           lx_62598971_sql_3 := lx_62598971_sql_3 ||
             G_INDENT5 || '           ORDERED ' || g_newline ||
             G_INDENT5 || '           USE_CONCAT ' || g_newline ||
             G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1012LK A)  ' || g_newline ||
             G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||

             /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
             G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                          '_324347_ND)' || g_newline ||
             G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
             G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
             G_INDENT5 || '           INDEX(Q1012LK JTF_TERR_CNR_QUAL_LIKE_MV_N10) ' || g_newline ||
             G_INDENT5 || '       */ ' || g_newline ; -- ||
         ELSE
           lx_62598971_sql_3 := lx_62598971_sql_3 ||
             G_INDENT5 || '           ORDERED ' || g_newline ||
             G_INDENT5 || '           USE_CONCAT ' || g_newline ||
             G_INDENT5 || '           NO_MERGE ' || g_newline ||
             G_INDENT5 || '       */ ' || g_newline ; -- ||
         END IF;

         JTF_TAE_GEN_PVT.write_buffer_content(
           l_qual_rules => lx_62598971_sql_3
         );

         /* Add SELECT columns */
         JTF_TAE_GEN_PVT.write_buffer_content(
           l_qual_rules => lp_SELECT_cols || g_newline
         );
         --lp_SELECT_cols || g_newline ||

         lx_62598971_sql_4 :=
         G_INDENT5 || 'FROM    ';

    IF p_new_mode_fetch = 'Y' THEN
       lx_62598971_sql_4 := lx_62598971_sql_4 ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_62598971_sql_4 := lx_62598971_sql_4 ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_62598971_sql_4 := lx_62598971_sql_4 ||
         G_INDENT5 || '   ,  jtf_terr_cnr_qual_like_mv Q1012LK ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate || g_newline ||

         G_INDENT5 || '  AND Q1007R1.terr_id = Q1012LK.terr_id ' || g_newline ||
         G_INDENT5 || '  AND      a.squal_char01 LIKE Q1012LK.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        a.squal_fc01 = Q1012LK.first_char ' || g_newline ||
         G_INDENT5 || '  AND      Q1012LK.qual_usg_id = -1012 ' || g_newline ||
         G_INDENT5 || '  AND Q1012LK.terr_id = ILV.terr_id ' || g_newline ||
          G_INDENT5 || ') ILV2' || g_newline ||
         G_INDENT5 || 'WHERE ILV1.terr_id = ILV2.terr_id' || g_newline ||
         G_INDENT5 || 'AND ILV1.lead_id = ILV2.trans_object_id' || g_newline ||

         G_INDENT5 || 'UNION ALL ' || g_newline;

         --ARPATEL 10/14 bug#3207518
         JTF_TAE_GEN_PVT.write_buffer_content(
          l_qual_rules => lx_62598971_sql_4
         );

         --bug#3373462 ARPATEL: 01/30/2004
          JTF_TAE_GEN_PVT.write_buffer_content(
            G_INDENT || EXP_PURCHASE_UNION_SELECT(p_new_mode_fetch)
          );

         --G_INDENT || 'SELECT /*+ NO_MERGE(ILV1) NO_MERGE(ILV2) ' || g_newline ||
         --G_INDENT || '                 USE_HASH(ILV1 ILV2) */' || g_newline ||
         --G_INDENT || '             ILV2.trans_object_id' || g_newline ||
         --G_INDENT || '           , ILV2.trans_detail_object_id' || g_newline ||
         -- eihsu 06/19/2003 worker_id
         --G_INDENT || '           , ILV2.worker_id' || g_newline ||
         --G_INDENT || '           , ILV2.header_id1' || g_newline ||
         --G_INDENT || '           , ILV2.header_id2' || g_newline ||
         --G_INDENT || '           , ILV2.terr_id' || g_newline ||
         --G_INDENT || '           , ILV2.absolute_rank' || g_newline ||
         --G_INDENT || '           , ILV2.top_level_terr_id' || g_newline ||
         --G_INDENT || '           , ILV2.num_winners' || g_newline ||
         --G_INDENT || '           , ILV2.org_id' || g_newline ||
         --G_INDENT || '      FROM'|| g_newline ||
         /************************/
         /*  = ILV1               */
         /************************/
         lx_62598971_sql_5 :=
         G_INDENT5 || '( /* INLINE VIEW1 */' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline;

         IF p_new_mode_fetch = 'Y' THEN
           lx_62598971_sql_5 := lx_62598971_sql_5 || G_INDENT5 || '       ORDERED ' || g_newline;
         END IF;

       lx_62598971_sql_5 := lx_62598971_sql_5 ||
         G_INDENT5 || '           USE_NL(ILV Q1142R1 ALLP) ' || g_newline ||
         G_INDENT5 || '           INDEX(ALLP AS_LEAD_LINES_N2)' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ||
         G_INDENT5 || '                      ALLP.lead_id' || g_newline ||
         G_INDENT5 || '                    , ALLP.lead_line_id' || g_newline ||
         G_INDENT5 || '                    , ILV.terr_id ' || g_newline ||
         G_INDENT5 || '                     , ILV.top_level_terr_id ' || g_newline ||
         G_INDENT5 || '                     , ILV.absolute_rank  ' || g_newline ||
         G_INDENT5 || '                     , ILV.num_winners ' || g_newline ||
         G_INDENT5 || '                     , ILV.org_id ' || g_newline ||

         G_INDENT5 || '                 FROM ' ||  g_newline;

    IF p_new_mode_fetch = 'Y' THEN
       lx_62598971_sql_5 := lx_62598971_sql_5 ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_62598971_sql_5 := lx_62598971_sql_5 ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_62598971_sql_5 := lx_62598971_sql_5 ||
         G_INDENT5 || '                     ,jtf_terr_qual_rules_mv Q1142R1 ' || g_newline ||
         G_INDENT5 || '                 ,ENI_PROD_DENORM_HRCHY_V PRD,AS_LEAD_LINES ALLP ' ||  g_newline ||
         G_INDENT5 || '                WHERE  (  Q1142R1.qual_usg_id = -1142 AND Q1142R1.terr_id = ILV.terr_id )' || g_newline ||
         G_INDENT5 || '                AND   Q1142R1.value1_id = PRD.child_id ' || g_newline ||
         G_INDENT5 || '                AND   Q1142R1.value2_id = PRD.category_set_id ' || g_newline ||
         G_INDENT5 || '                AND   PRD.parent_id = ALLP.product_category_id ' || g_newline ||
         G_INDENT5 || '                AND   PRD.category_set_id = ALLP.product_cat_set_id ' || g_newline ||
         G_INDENT5 || '                AND   Q1142R1.comparison_operator = ''=''' || g_newline ||
         G_INDENT5 || '   ) ILV1,' || g_newline ||

         /************************/
         /*  LIKE %XYZ           */
         /************************/
         G_INDENT5 || '   ( ' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline;

       IF p_new_mode_fetch <> 'Y' THEN
         lx_62598971_sql_5 := lx_62598971_sql_5 ||
           G_INDENT5 || '           ORDERED ' || g_newline ||
           G_INDENT5 || '           USE_CONCAT ' || g_newline ||
           G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1012LK A)  ' || g_newline ||
           G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
           /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
           G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                          '_324347X_ND)' || g_newline ||
           G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
           G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
           G_INDENT5 || '           INDEX(Q1012LK JTF_TERR_CNR_QUAL_LIKE_MV_N10) ' || g_newline ||
           G_INDENT5 || '       */ ' || g_newline;
       ELSE
         lx_62598971_sql_5 := lx_62598971_sql_5 ||
           G_INDENT5 || '           ORDERED ' || g_newline ||
           G_INDENT5 || '           USE_CONCAT ' || g_newline ||
           G_INDENT5 || '           NO_MERGE ' || g_newline ||
           G_INDENT5 || '       */ ' || g_newline;
       END IF;

       lx_62598971_sql_5 := lx_62598971_sql_5 ||
         /* Add SELECT columns */
         lp_SELECT_cols || g_newline ||

         G_INDENT5 || 'FROM   ';

    IF p_new_mode_fetch = 'Y' THEN
       lx_62598971_sql_5 := lx_62598971_sql_5 ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_62598971_sql_5 := lx_62598971_sql_5 ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_62598971_sql_5 := lx_62598971_sql_5 ||
         G_INDENT5 || '   ,  jtf_terr_cnr_qual_like_mv Q1012LK ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate_eq || g_newline ||

         G_INDENT5 || '  AND Q1007R1.terr_id = Q1012LK.terr_id ' || g_newline ||
         G_INDENT5 || '  AND      a.squal_char01 LIKE Q1012LK.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1012LK.first_char = ''%'' ' || g_newline ||
         G_INDENT5 || '  AND Q1012LK.qual_usg_id = -1012 ' || g_newline ||
         G_INDENT5 || '  AND Q1012LK.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || 'UNION ALL ' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline;

       IF p_new_mode_fetch <> 'Y' THEN
         lx_62598971_sql_5 := lx_62598971_sql_5 ||
           G_INDENT5 || '           ORDERED ' || g_newline ||
           G_INDENT5 || '           USE_CONCAT ' || g_newline ||
           G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1012LK A)  ' || g_newline ||
           G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
           /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
           G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                          '_324347X_ND)' || g_newline ||
           G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
           G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
           G_INDENT5 || '           INDEX(Q1012LK JTF_TERR_CNR_QUAL_LIKE_MV_N10) ' || g_newline ||
           G_INDENT5 || '       */ ' || g_newline;
       ELSE
         lx_62598971_sql_5 := lx_62598971_sql_5 ||
           G_INDENT5 || '           ORDERED ' || g_newline ||
           G_INDENT5 || '           USE_CONCAT ' || g_newline ||
           G_INDENT5 || '           NO_MERGE ' || g_newline ||
           G_INDENT5 || '       */ ' || g_newline;
       END IF;

       lx_62598971_sql_5 := lx_62598971_sql_5 ||
         /* Add SELECT columns */
         lp_SELECT_cols || g_newline ||

         G_INDENT5 || 'FROM   ';

    IF p_new_mode_fetch = 'Y' THEN
       lx_62598971_sql_5 := lx_62598971_sql_5 ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_62598971_sql_5 := lx_62598971_sql_5 ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_62598971_sql_5 := lx_62598971_sql_5 ||
         G_INDENT5 || '   ,  jtf_terr_cnr_qual_like_mv Q1012LK ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate_btwn || g_newline ||

         G_INDENT5 || '  AND Q1007R1.terr_id = Q1012LK.terr_id ' || g_newline ||
         G_INDENT5 || '  AND      a.squal_char01 LIKE Q1012LK.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1012LK.first_char = ''%'' ' || g_newline ||
         G_INDENT5 || '  AND Q1012LK.qual_usg_id = -1012 ' || g_newline ||
         G_INDENT5 || '  AND Q1012LK.terr_id = ILV.terr_id ' || g_newline ||

         G_INDENT5 || ') ILV2' || g_newline ||
         G_INDENT5 || 'WHERE ILV1.terr_id = ILV2.terr_id' || g_newline ||
         G_INDENT5 || 'AND ILV1.lead_id = ILV2.trans_object_id' || g_newline ||

         G_INDENT5 || 'UNION ALL ' || g_newline ;--||

         --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lx_62598971_sql_5
       );

          --bug#3373462 ARPATEL: 01/30/2004
          JTF_TAE_GEN_PVT.write_buffer_content(
            G_INDENT || EXP_PURCHASE_UNION_SELECT(p_new_mode_fetch)
          );

         lx_62598971_sql_6 :=
         --G_INDENT || 'SELECT /*+ NO_MERGE(ILV1) NO_MERGE(ILV2) ' || g_newline ||
         --G_INDENT || '                 USE_HASH(ILV1 ILV2) */' || g_newline ||
         --G_INDENT || '             ILV2.trans_object_id' || g_newline ||
         --G_INDENT || '           , ILV2.trans_detail_object_id' || g_newline ||
         -- eihsu 06/19/2003 worker_id
         --G_INDENT || '           , ILV2.worker_id' || g_newline ||
         --G_INDENT || '           , ILV2.header_id1' || g_newline ||
         --G_INDENT || '           , ILV2.header_id2' || g_newline ||
         --G_INDENT || '           , ILV2.terr_id' || g_newline ||
         --G_INDENT || '           , ILV2.absolute_rank' || g_newline ||
         --G_INDENT || '           , ILV2.top_level_terr_id' || g_newline ||
         --G_INDENT || '           , ILV2.num_winners' || g_newline ||
         --G_INDENT || '           , ILV2.org_id' || g_newline ||
         --G_INDENT || '      FROM'|| g_newline ||
         /************************/
         /*  = ILV1               */
         /************************/
         G_INDENT5 || '( /* INLINE VIEW1 */' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline;

         IF p_new_mode_fetch = 'Y' THEN
           lx_62598971_sql_6 := lx_62598971_sql_6 || G_INDENT5 || '       ORDERED ' || g_newline;
         END IF;

       lx_62598971_sql_6 := lx_62598971_sql_6 ||
         G_INDENT5 || '           USE_NL(ILV Q1142R1 ALLP) ' || g_newline ||
         G_INDENT5 || '           INDEX(ALLP AS_LEAD_LINES_N2)' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ||
         G_INDENT5 || '                      ALLP.lead_id' || g_newline ||
         G_INDENT5 || '                    , ALLP.lead_line_id' || g_newline ||
         G_INDENT5 || '                    , ILV.terr_id ' || g_newline ||
         G_INDENT5 || '                     , ILV.top_level_terr_id ' || g_newline ||
         G_INDENT5 || '                     , ILV.absolute_rank  ' || g_newline ||
         G_INDENT5 || '                     , ILV.num_winners ' || g_newline ||
         G_INDENT5 || '                     , ILV.org_id ' || g_newline ||

         G_INDENT5 || '                 FROM ' ||  g_newline;

    IF p_new_mode_fetch = 'Y' THEN
       lx_62598971_sql_6 := lx_62598971_sql_6 ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_62598971_sql_6 := lx_62598971_sql_6 ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_62598971_sql_6 := lx_62598971_sql_6 ||
         G_INDENT5 || '                     ,jtf_terr_qual_rules_mv Q1142R1 ' || g_newline ||
         G_INDENT5 || '                 ,ENI_PROD_DENORM_HRCHY_V PRD,AS_LEAD_LINES ALLP ' ||  g_newline ||
         G_INDENT5 || '                WHERE  (  Q1142R1.qual_usg_id = -1142 AND Q1142R1.terr_id = ILV.terr_id )' || g_newline ||
         G_INDENT5 || '                AND   Q1142R1.value1_id = PRD.child_id ' || g_newline ||
         G_INDENT5 || '                AND   Q1142R1.value2_id = PRD.category_set_id ' || g_newline ||
         G_INDENT5 || '                AND   PRD.parent_id = ALLP.product_category_id ' || g_newline ||
         G_INDENT5 || '                AND   PRD.category_set_id = ALLP.product_cat_set_id ' || g_newline ||
         G_INDENT5 || '                AND   Q1142R1.comparison_operator = ''=''' || g_newline ||
         G_INDENT5 || '   ) ILV1,' || g_newline ||

         G_INDENT5 || '   ( ' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline;

       IF p_new_mode_fetch <> 'Y' THEN
         lx_62598971_sql_6 := lx_62598971_sql_6 ||
           G_INDENT5 || '           ORDERED ' || g_newline ||
           G_INDENT5 || '           USE_CONCAT ' || g_newline ||
           G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1012BT A) ' || g_newline ||
           G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
           /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
           G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                          '_324347_ND)' || g_newline ||

           G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
           G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
           G_INDENT5 || '           INDEX(Q1012BT JTF_TERR_CNR_QUAL_BTWN_MV_N10) ' || g_newline ||
           G_INDENT5 || '       */ ' || g_newline;
       ELSE
         lx_62598971_sql_6 := lx_62598971_sql_6 ||
           G_INDENT5 || '           ORDERED ' || g_newline ||
           G_INDENT5 || '           USE_CONCAT ' || g_newline ||
           G_INDENT5 || '           NO_MERGE ' || g_newline ||
           G_INDENT5 || '       */ ' || g_newline;
       END IF;


       lx_62598971_sql_6 := lx_62598971_sql_6 ||
         /* Add SELECT columns */
         lp_SELECT_cols || g_newline ||

         G_INDENT5 || 'FROM   ';

    IF p_new_mode_fetch = 'Y' THEN
       lx_62598971_sql_6 := lx_62598971_sql_6 ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_62598971_sql_6 := lx_62598971_sql_6 ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_62598971_sql_6 := lx_62598971_sql_6 ||
         G_INDENT5 || '   ,  jtf_terr_cnr_qual_btwn_mv Q1012BT ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate || g_newline ||

         G_INDENT5 || '  AND Q1007R1.terr_id = Q1012BT.terr_id ' || g_newline ||
         G_INDENT5 || '  AND      a.squal_char01 <= Q1012BT.high_value_char AND ' || g_newline ||
         G_INDENT5 || '        a.squal_char01 >= Q1012BT.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        a.squal_fc01 >= SUBSTR(Q1012BT.low_value_char, 1, 1) ' || g_newline ||
         G_INDENT5 || '  AND Q1012BT.qual_usg_id = -1012 ' || g_newline ||
         G_INDENT5 || '  AND Q1012BT.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND Q1012BT.terr_id = Q1003R1.terr_id ' || g_newline ||
         G_INDENT5 || ') ILV2' || g_newline ||
         G_INDENT5 || 'WHERE ILV1.terr_id = ILV2.terr_id' || g_newline ||
         G_INDENT5 || 'AND ILV1.lead_id = ILV2.trans_object_id' || g_newline ||
         G_INDENT || lp_close_outermost_ILV || g_newline;

    RETURN lx_62598971_sql_6;

EXCEPTION
WHEN OTHERS THEN
     g_ProgramStatus := 1;
         JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'ERROR: JTF_TAE_SQL_LIBRARY_PVT.add_62598971_SQL');

END add_62598971_SQL;


--** OPPORTUNITY EXPECTED PURCHASE ***
FUNCTION add_45084233_SQL( p_trans_object_type_id   IN   NUMBER
                     , p_table_name             IN   VARCHAR2
                     -- dblee 08/26/03 added new mode flag
                     , p_new_mode_fetch         IN   CHAR)
RETURN VARCHAR2 AS

   lp_close_outermost_ILV      VARCHAR2(255);
   l_select_ilv2               VARCHAR2(32767) := NULL;
   lp_SELECT_cols              VARCHAR2(32767) := NULL;
   lx_45084233_sql             VARCHAR2(32767) := NULL;
   --ARPATEL
   lx_45084233_sql_2           VARCHAR2(32767) := NULL;
   lx_45084233_sql_3           VARCHAR2(32767) := NULL;
   lx_45084233_sql_4           VARCHAR2(32767) := NULL;
   lx_45084233_sql_5           VARCHAR2(32767) := NULL;
   lx_45084233_sql_6           VARCHAR2(32767) := NULL;

   lp_pc_cntry_predicate_eq    VARCHAR2(32767) := NULL;
   lp_pc_cntry_predicate       VARCHAR2(32767) := NULL;
   lp_pc_cntry_predicate_btwn  VARCHAR2(32767) := NULL;
   l_sql                       VARCHAR2(32767) := NULL;

BEGIN
--** OPPORTUNITY EXPECTED PURCHASE ***

    -- dblee: 08/27/03 new mode support
    IF p_new_mode_fetch = 'Y' THEN
       l_select_ilv2 := add_SELECT_clause(p_new_mode_fetch);

       lp_SELECT_cols :=
          --G_INDENT5 || add_SELECT_cols(p_new_mode_fetch) || g_newline;
          /* ARPATEL: bug#3373462 */
	    G_INDENT || '       A.TRANS_OBJECT_ID' || g_newline ||
            G_INDENT || '       , A.TRANS_DETAIL_OBJECT_ID' || g_newline ||
            G_INDENT || '       , A.HEADER_ID1' || g_newline ||
            G_INDENT || '       , A.HEADER_ID2' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC01' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC02' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC03' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC04' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC05' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC01' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC02' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC03' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC04' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC05' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC06' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC07' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC08' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC09' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC10' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR01' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR02' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR03' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR04' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR05' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR06' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR07' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR08' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR09' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR10' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR11' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR12' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR13' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR14' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR15' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR16' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR17' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR18' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR19' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR20' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR21' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR22' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR23' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR24' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR25' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR26' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR27' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR28' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR30' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR31' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR32' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR33' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR34' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR35' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR36' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR37' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR38' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR39' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR40' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR41' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR42' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR43' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR44' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR45' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR46' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR47' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR48' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR49' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR50' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR51' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR52' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR53' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR54' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR55' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR56' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR57' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR58' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR59' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR60' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM01' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM02' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM03' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM04' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM05' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM06' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM07' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM08' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM09' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM10' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM11' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM12' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM13' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM14' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM15' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM16' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM17' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM18' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM19' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM20' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM21' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM22' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM23' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM24' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM25' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM26' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM27' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM28' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM29' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM30' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM31' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM32' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM33' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM34' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM35' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM36' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM37' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM38' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM39' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM40' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM41' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM42' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM43' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM44' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM45' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM46' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM47' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM48' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM49' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM50' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM51' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM52' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM53' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM54' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM55' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM56' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM57' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM58' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM59' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM60' || g_newline ||
            G_INDENT || '       , A.ASSIGNED_FLAG' || g_newline ||
            G_INDENT || '       , A.PROCESSED_FLAG' || g_newline ||
            G_INDENT || '       , A.ORG_ID' || g_newline ||
            G_INDENT || '       , A.SECURITY_GROUP_ID' || g_newline ||
            G_INDENT || '       , A.OBJECT_VERSION_NUMBER' || g_newline ||
            G_INDENT || '       , A.WORKER_ID' || g_newline ||
	        G_INDENT || '     , ILV.terr_id ' || g_newline ||
            G_INDENT || '     , ILV.absolute_rank ' || g_newline ||
            G_INDENT || '     , ILV.top_level_terr_id '|| g_newline ||
            G_INDENT || '     , ILV.num_winners ' || g_newline;


       lp_close_outermost_ILV := ') A; -- jtf_tae_sql_lib_pvt_nm826 line 841 ';
    ELSE
       l_select_ilv2 :=
          G_INDENT5 || 'SELECT DISTINCT ' || g_newline ||
          G_INDENT5 ||'ILV2.trans_object_id' || g_newline ||
          G_INDENT5 ||', ILV2.trans_detail_object_id' || g_newline ||
          -- eihsu 06/19/2003 worker_id
          G_INDENT5 ||', ILV2.worker_id' || g_newline ||
          G_INDENT5 ||',ILV2.header_id1' || g_newline ||
          G_INDENT5 ||',ILV2.header_id2' || g_newline ||
          G_INDENT5 ||', p_source_id' || g_newline ||
          G_INDENT5 ||', p_trans_object_type_id' || g_newline ||
          G_INDENT5 ||', l_sysdate' || g_newline ||
          G_INDENT5 ||', L_USER_ID' || g_newline ||
          G_INDENT5 ||', l_sysdate' || g_newline ||
          G_INDENT5 ||', L_USER_ID' || g_newline ||
          G_INDENT5 ||', L_USER_ID' || g_newline ||
          G_INDENT5 ||', L_REQUEST_ID' || g_newline ||
          G_INDENT5 ||', L_PROGRAM_APPL_ID' || g_newline ||
          G_INDENT5 ||', L_PROGRAM_ID' || g_newline ||
          G_INDENT5 ||', l_sysdate' || g_newline ||
          G_INDENT5 ||', ILV2.terr_id' || g_newline ||
          G_INDENT5 ||', ILV2.absolute_rank' || g_newline ||
          G_INDENT5 ||', ILV2.top_level_terr_id' || g_newline ||
          G_INDENT5 ||', ILV2.num_winners' || g_newline ||
          G_INDENT5 ||', ILV2.org_id' || g_newline ;

       lp_SELECT_cols :=
          G_INDENT5 || 'A.trans_object_id, A.trans_detail_object_id, ' || g_newline ||
          -- eihsu 06/19/2003 worker_id
          G_INDENT5 || 'A.worker_id, ' || g_newline ||
          G_INDENT5 || 'A.header_id1, A.header_id2, ' || g_newline ||
          G_INDENT5 || 'ILV.terr_id, ILV.absolute_rank, ' || g_newline ||
          G_INDENT5 || 'ILV.top_level_terr_id, ILV.num_winners, ILV.org_id ';

       lp_close_outermost_ILV := ') ILV2; ';
    END IF; -- p_new_mode_fetch = 'Y'

    lp_pc_cntry_predicate := '   1 = 1 ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
       lp_pc_cntry_predicate := lp_pc_cntry_predicate ||
         '  AND A.worker_id = P_WORKER_ID ' || g_newline;
    END IF;

    lp_pc_cntry_predicate := lp_pc_cntry_predicate ||
         G_INDENT5 || '  AND  ( ( a.squal_char06 <= Q1007R1.high_value_char AND ' || g_newline ||
         G_INDENT5 || '          a.squal_char06 >= Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''BETWEEN'' ) ' || g_newline ||
         G_INDENT5 || '        OR ' || g_newline ||
         G_INDENT5 || '        ( a.squal_char06 = Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '      ) ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.qual_usg_id = -1007 ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND  Q1007R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||
         G_INDENT5 || '  AND ( a.squal_char07 = Q1003R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1003R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.qual_usg_id = -1003 ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.terr_id = ILV.terr_id  ' || g_newline ;

    lp_pc_cntry_predicate_eq := '   1 = 1 ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
       lp_pc_cntry_predicate_eq := lp_pc_cntry_predicate_eq ||
         '  AND A.worker_id = P_WORKER_ID ' || g_newline;
    END IF;

    lp_pc_cntry_predicate_eq := lp_pc_cntry_predicate_eq ||
         G_INDENT5 || '  AND   ( a.squal_char06 = Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.qual_usg_id = -1007 ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND  Q1007R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||
         G_INDENT5 || '  AND ( a.squal_char07 = Q1003R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1003R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.qual_usg_id = -1003 ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.terr_id = ILV.terr_id  ' || g_newline ;

    lp_pc_cntry_predicate_btwn := '   1 = 1 ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
       lp_pc_cntry_predicate_btwn := lp_pc_cntry_predicate_btwn ||
         '  AND A.worker_id = P_WORKER_ID ' || g_newline;
    END IF;

    lp_pc_cntry_predicate_btwn := lp_pc_cntry_predicate_btwn ||
         G_INDENT5 || '  AND ( a.squal_char06 <= Q1007R1.high_value_char AND ' || g_newline ||
         G_INDENT5 || '          a.squal_char06 >= Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''BETWEEN'' ) ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.qual_usg_id = -1007 ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND  Q1007R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||
         G_INDENT5 || '  AND ( a.squal_char07 = Q1003R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1003R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.qual_usg_id = -1003 ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.terr_id = ILV.terr_id  ' || g_newline ;

    --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => l_select_ilv2
       );

      --bug#3373462 ARPATEL: 01/30/2004
    JTF_TAE_GEN_PVT.write_buffer_content(
    G_INDENT5 || 'FROM ( ' || g_newline || EXP_PURCHASE_UNION_SELECT(p_new_mode_fetch)
    );

    lx_45084233_sql :=
        -- G_INDENT || l_select_ilv2 || g_newline ||
        -- G_INDENT || 'FROM ( ' || g_newline ||
        -- G_INDENT || 'SELECT /*+ NO_MERGE(ILV1) NO_MERGE(ILV2) ' || g_newline ||
        -- G_INDENT || '                 USE_HASH(ILV1 ILV2) */' || g_newline ||
        -- G_INDENT || '             ILV2.trans_object_id' || g_newline ||
        -- G_INDENT || '           , ILV2.trans_detail_object_id' || g_newline ||
         -- eihsu 06/19/2003 worker_id
       --  G_INDENT || '           , ILV2.worker_id' || g_newline ||
       --  G_INDENT || '           , ILV2.header_id1' || g_newline ||
       --  G_INDENT || '           , ILV2.header_id2' || g_newline ||
       --  G_INDENT || '           , ILV2.terr_id' || g_newline ||
       --  G_INDENT || '           , ILV2.absolute_rank' || g_newline ||
       --  G_INDENT || '           , ILV2.top_level_terr_id' || g_newline ||
       --  G_INDENT || '           , ILV2.num_winners' || g_newline ||
       --  G_INDENT || '           , ILV2.org_id' || g_newline ||
       --  G_INDENT || '      FROM'|| g_newline ||
         /************************/
         /*  = ILV1               */
         /************************/
         G_INDENT5 || '( /* INLINE VIEW1 */' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1023R1 ALLP) ' || g_newline ||
         G_INDENT5 || '           INDEX(ALLP AS_LEAD_LINES_N2)' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1023R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ||
         G_INDENT5 || '                      ALLP.lead_id' || g_newline ||
         G_INDENT5 || '                    , ALLP.lead_line_id' || g_newline ||
         G_INDENT5 || '                    , ILV.terr_id ' || g_newline ||
         G_INDENT5 || '                     , ILV.top_level_terr_id ' || g_newline ||
         G_INDENT5 || '                     , ILV.absolute_rank  ' || g_newline ||
         G_INDENT5 || '                     , ILV.num_winners ' || g_newline ||
         G_INDENT5 || '                     , ILV.org_id ' || g_newline ||
         G_INDENT5 || '                 FROM AS_LEAD_LINES ALLP, jtf_terr_qual_rules_mv Q1023R1' || g_newline ||
         G_INDENT5 || '                     , /* INLINE VIEW */' || g_newline ||
         G_INDENT5 || '                     ( SELECT /*+ NO_MERGE */' || g_newline ||
         G_INDENT5 || '                             jtdr.terr_id ' || g_newline ||
         G_INDENT5 || '                           , jtdr.source_id' || g_newline ||
         G_INDENT5 || '                             , jtdr.qual_type_id' || g_newline ||
         G_INDENT5 || '                            , jtdr.top_level_terr_id' || g_newline ||
         G_INDENT5 || '                             , jtdr.absolute_rank ' || g_newline ||
         G_INDENT5 || '                            , jtdr.num_winners ' || g_newline ||
         G_INDENT5 || '                            , jtdr.org_id' || g_newline ||
         G_INDENT5 || '                        FROM  jtf_terr_denorm_rules_all jtdr' || g_newline ||
         G_INDENT5 || '                             ,jtf_terr_qtype_usgs_all jtqu   ' || g_newline ||
         G_INDENT5 || '                             ,jtf_qual_type_usgs_all jqtu    ' || g_newline ||
         G_INDENT5 || '                        WHERE jtdr.source_id = p_source_id' || g_newline ||
         G_INDENT5 || '                         AND jtdr.terr_id= jtdr.related_terr_id' || g_newline ||
         G_INDENT5 || '                         AND jqtu.source_id = jtdr.source_id    ' || g_newline ||
         G_INDENT5 || '                         AND jqtu.qual_type_id = p_trans_object_type_id ' || g_newline ||
         G_INDENT5 || '                         AND jtdr.terr_id = jtqu.terr_id ' || g_newline ||
         G_INDENT5 || '                         AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id ' || g_newline ||
         G_INDENT5 || '                         AND jtdr.resource_exists_flag = ''Y''' || g_newline ||
         G_INDENT5 || '                         AND jtqu.qual_relation_product = lp_qual_combination_tbl(i)' || g_newline ||
         G_INDENT5 || '                    ) ILV' || g_newline ||
         G_INDENT5 || '                WHERE  (  Q1023R1.qual_usg_id = -1023 AND Q1023R1.terr_id = ILV.terr_id )' || g_newline ||
         G_INDENT5 || '    AND ( Q1023R1.secondary_interest_code_id IS NULL' || g_newline ||
         G_INDENT5 || '    OR (ALLP.secondary_interest_code_id = Q1023R1.secondary_interest_code_id))' || g_newline ||
         G_INDENT5 || '   AND ( Q1023R1.primary_interest_code_id IS NULL' || g_newline ||
         G_INDENT5 || '   OR ( ALLP.primary_interest_code_id = Q1023R1.primary_interest_code_id ))' || g_newline ||
         G_INDENT5 || '   AND ALLP.interest_type_id =  Q1023R1.interest_type_id' || g_newline ||
         G_INDENT5 || '    AND Q1023R1.comparison_operator = ''=''' || g_newline ||
         G_INDENT5 || '   ) ILV1,' || g_newline ||

          /************************/
         /*  = XYZ  ILV2             */
         /************************/
         G_INDENT5 || '   ( ' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1012R1 A) ' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
                  /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                        '_324347_ND)' || g_newline ||

         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1012R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ; --||

         /* Add SELECT columns */
         JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lx_45084233_sql
       );
         --lp_SELECT_cols || g_newline ; ||

         JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lp_SELECT_cols || g_newline
       );

         lx_45084233_sql_2 :=
         G_INDENT5 || 'FROM ' ||

         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch) ||

         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1012R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate || g_newline ||
         --G_INDENT5 || '  AND Q1003R1.terr_id = Q1012R1.terr_id ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = Q1012R1.terr_id ' || g_newline ||
         G_INDENT5 || '  AND ( Q1012R1.comparison_operator = ''='' AND ' || g_newline ||
         G_INDENT5 || '        a.squal_fc01 = SUBSTR(Q1012R1.low_value_char, 1, 1) AND ' || g_newline ||
         G_INDENT5 || '        a.squal_char01 = Q1012R1.low_value_char ' || g_newline ||
         G_INDENT5 || '       ) ' || g_newline ||
         G_INDENT5 || '  AND Q1012R1.qual_usg_id = -1012  ' || g_newline ||
         G_INDENT5 || '  AND Q1012R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND  Q1012R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||
         G_INDENT5 || ') ILV2' || g_newline ||
         G_INDENT5 || 'WHERE ILV1.terr_id = ILV2.terr_id' || g_newline ||
         G_INDENT5 || 'AND ILV1.lead_id = ILV2.trans_object_id' || g_newline ||

         G_INDENT5 || 'UNION ALL ' || g_newline ; --||

         --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lx_45084233_sql_2
       );

      --bug#3373462 ARPATEL: 01/30/2004
    JTF_TAE_GEN_PVT.write_buffer_content(
    G_INDENT || EXP_PURCHASE_UNION_SELECT(p_new_mode_fetch)
    );

         lx_45084233_sql_3 :=

         --G_INDENT || 'SELECT /*+ NO_MERGE(ILV1) NO_MERGE(ILV2) ' || g_newline ||
         --G_INDENT || '                 USE_HASH(ILV1 ILV2) */' || g_newline ||
         --G_INDENT || '             ILV2.trans_object_id' || g_newline ||
         --G_INDENT || '           , ILV2.trans_detail_object_id' || g_newline ||
         -- eihsu 06/19/2003 worker_id
         --G_INDENT || '           , ILV2.worker_id' || g_newline ||
         --G_INDENT || '           , ILV2.header_id1' || g_newline ||
         --G_INDENT || '           , ILV2.header_id2' || g_newline ||
         --G_INDENT || '           , ILV2.terr_id' || g_newline ||
         --G_INDENT || '           , ILV2.absolute_rank' || g_newline ||
         --G_INDENT || '           , ILV2.top_level_terr_id' || g_newline ||
         --G_INDENT || '           , ILV2.num_winners' || g_newline ||
         --G_INDENT || '           , ILV2.org_id' || g_newline ||
         --G_INDENT || '      FROM'|| g_newline ||
         /************************/
         /*  = ILV1               */
         /************************/
         G_INDENT5 || '( /* INLINE VIEW1 */' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1023R1 ALLP) ' || g_newline ||
         G_INDENT5 || '           INDEX(ALLP AS_LEAD_LINES_N2)' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1023R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ||
         G_INDENT5 || '                      ALLP.lead_id' || g_newline ||
         G_INDENT5 || '                    , ALLP.lead_line_id' || g_newline ||
         G_INDENT5 || '                    , ILV.terr_id ' || g_newline ||
         G_INDENT5 || '                     , ILV.top_level_terr_id ' || g_newline ||
         G_INDENT5 || '                     , ILV.absolute_rank  ' || g_newline ||
         G_INDENT5 || '                     , ILV.num_winners ' || g_newline ||
         G_INDENT5 || '                     , ILV.org_id ' || g_newline ||
         G_INDENT5 || '                 FROM AS_LEAD_LINES ALLP, jtf_terr_qual_rules_mv Q1023R1' || g_newline ||
         G_INDENT5 || '                     , /* INLINE VIEW */' || g_newline ||
         G_INDENT5 || '                     ( SELECT /*+ NO_MERGE */' || g_newline ||
         G_INDENT5 || '                             jtdr.terr_id ' || g_newline ||
         G_INDENT5 || '                           , jtdr.source_id' || g_newline ||
         G_INDENT5 || '                             , jtdr.qual_type_id' || g_newline ||
         G_INDENT5 || '                            , jtdr.top_level_terr_id' || g_newline ||
         G_INDENT5 || '                             , jtdr.absolute_rank ' || g_newline ||
         G_INDENT5 || '                            , jtdr.num_winners ' || g_newline ||
         G_INDENT5 || '                            , jtdr.org_id' || g_newline ||
         G_INDENT5 || '                        FROM  jtf_terr_denorm_rules_all jtdr' || g_newline ||
         G_INDENT5 || '                             ,jtf_terr_qtype_usgs_all jtqu   ' || g_newline ||
         G_INDENT5 || '                             ,jtf_qual_type_usgs_all jqtu    ' || g_newline ||
         G_INDENT5 || '                        WHERE jtdr.source_id = p_source_id' || g_newline ||
         G_INDENT5 || '                         AND jtdr.terr_id= jtdr.related_terr_id' || g_newline ||
         G_INDENT5 || '                         AND jqtu.source_id = jtdr.source_id    ' || g_newline ||
         G_INDENT5 || '                         AND jqtu.qual_type_id = p_trans_object_type_id ' || g_newline ||
         G_INDENT5 || '                         AND jtdr.terr_id = jtqu.terr_id ' || g_newline ||
         G_INDENT5 || '                         AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id ' || g_newline ||
         G_INDENT5 || '                         AND jtdr.resource_exists_flag = ''Y''' || g_newline ||
         G_INDENT5 || '                         AND jtqu.qual_relation_product = lp_qual_combination_tbl(i)' || g_newline ||
         G_INDENT5 || '                    ) ILV' || g_newline ||
         G_INDENT5 || '                WHERE  (  Q1023R1.qual_usg_id = -1023 AND Q1023R1.terr_id = ILV.terr_id )' || g_newline ||
         G_INDENT5 || '    AND ( Q1023R1.secondary_interest_code_id IS NULL' || g_newline ||
         G_INDENT5 || '    OR (ALLP.secondary_interest_code_id = Q1023R1.secondary_interest_code_id))' || g_newline ||
         G_INDENT5 || '   AND ( Q1023R1.primary_interest_code_id IS NULL' || g_newline ||
         G_INDENT5 || '   OR ( ALLP.primary_interest_code_id = Q1023R1.primary_interest_code_id ))' || g_newline ||
         G_INDENT5 || '   AND ALLP.interest_type_id =  Q1023R1.interest_type_id' || g_newline ||
         G_INDENT5 || '    AND Q1023R1.comparison_operator = ''=''' || g_newline ||
         G_INDENT5 || '   ) ILV1,' || g_newline ||


         /************************/
         /*  LIKE XYZ%           */
         /************************/
         G_INDENT5 || '   ( ' || g_newline ||
          G_INDENT5 || 'SELECT /*+ ' || g_newline ||

         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1012LK A)  ' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||

         /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                      '_324347_ND)' || g_newline ||
         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1012LK JTF_TERR_CNR_QUAL_LIKE_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ; -- ||

         JTF_TAE_GEN_PVT.write_buffer_content(
           l_qual_rules => lx_45084233_sql_3
         );

         /* Add SELECT columns */
         JTF_TAE_GEN_PVT.write_buffer_content(
           l_qual_rules => lp_SELECT_cols || g_newline
         );
         --lp_SELECT_cols || g_newline ||

         lx_45084233_sql_4 :=
         G_INDENT5 || 'FROM    '||

         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch) ||

         G_INDENT5 || '   ,  jtf_terr_cnr_qual_like_mv Q1012LK ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate || g_newline ||

         G_INDENT5 || '  AND Q1007R1.terr_id = Q1012LK.terr_id ' || g_newline ||
         G_INDENT5 || '  AND      a.squal_char01 LIKE Q1012LK.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        a.squal_fc01 = Q1012LK.first_char ' || g_newline ||
         G_INDENT5 || '  AND      Q1012LK.qual_usg_id = -1012 ' || g_newline ||
         G_INDENT5 || '  AND Q1012LK.terr_id = ILV.terr_id ' || g_newline ||
          G_INDENT5 || ') ILV2' || g_newline ||
         G_INDENT5 || 'WHERE ILV1.terr_id = ILV2.terr_id' || g_newline ||
         G_INDENT5 || 'AND ILV1.lead_id = ILV2.trans_object_id' || g_newline ||

         G_INDENT5 || 'UNION ALL ' || g_newline;

         --ARPATEL 10/14 bug#3207518
         JTF_TAE_GEN_PVT.write_buffer_content(
          l_qual_rules => lx_45084233_sql_4
         );

         --bug#3373462 ARPATEL: 01/30/2004
          JTF_TAE_GEN_PVT.write_buffer_content(
            G_INDENT || EXP_PURCHASE_UNION_SELECT(p_new_mode_fetch)
          );

         --G_INDENT || 'SELECT /*+ NO_MERGE(ILV1) NO_MERGE(ILV2) ' || g_newline ||
         --G_INDENT || '                 USE_HASH(ILV1 ILV2) */' || g_newline ||
         --G_INDENT || '             ILV2.trans_object_id' || g_newline ||
         --G_INDENT || '           , ILV2.trans_detail_object_id' || g_newline ||
         -- eihsu 06/19/2003 worker_id
         --G_INDENT || '           , ILV2.worker_id' || g_newline ||
         --G_INDENT || '           , ILV2.header_id1' || g_newline ||
         --G_INDENT || '           , ILV2.header_id2' || g_newline ||
         --G_INDENT || '           , ILV2.terr_id' || g_newline ||
         --G_INDENT || '           , ILV2.absolute_rank' || g_newline ||
         --G_INDENT || '           , ILV2.top_level_terr_id' || g_newline ||
         --G_INDENT || '           , ILV2.num_winners' || g_newline ||
         --G_INDENT || '           , ILV2.org_id' || g_newline ||
         --G_INDENT || '      FROM'|| g_newline ||
         /************************/
         /*  = ILV1               */
         /************************/
         lx_45084233_sql_5 :=
         G_INDENT5 || '( /* INLINE VIEW1 */' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1023R1 ALLP) ' || g_newline ||
         G_INDENT5 || '           INDEX(ALLP AS_LEAD_LINES_N2)' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1023R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ||
         G_INDENT5 || '                      ALLP.lead_id' || g_newline ||
         G_INDENT5 || '                    , ALLP.lead_line_id' || g_newline ||
         G_INDENT5 || '                    , ILV.terr_id ' || g_newline ||
         G_INDENT5 || '                     , ILV.top_level_terr_id ' || g_newline ||
         G_INDENT5 || '                     , ILV.absolute_rank  ' || g_newline ||
         G_INDENT5 || '                     , ILV.num_winners ' || g_newline ||
         G_INDENT5 || '                     , ILV.org_id ' || g_newline ||
         G_INDENT5 || '                 FROM AS_LEAD_LINES ALLP, jtf_terr_qual_rules_mv Q1023R1' || g_newline ||
         G_INDENT5 || '                     , /* INLINE VIEW */' || g_newline ||
         G_INDENT5 || '                     ( SELECT /*+ NO_MERGE */' || g_newline ||
         G_INDENT5 || '                             jtdr.terr_id ' || g_newline ||
         G_INDENT5 || '                           , jtdr.source_id' || g_newline ||
         G_INDENT5 || '                             , jtdr.qual_type_id' || g_newline ||
         G_INDENT5 || '                            , jtdr.top_level_terr_id' || g_newline ||
         G_INDENT5 || '                             , jtdr.absolute_rank ' || g_newline ||
         G_INDENT5 || '                            , jtdr.num_winners ' || g_newline ||
         G_INDENT5 || '                            , jtdr.org_id' || g_newline ||
         G_INDENT5 || '                        FROM  jtf_terr_denorm_rules_all jtdr' || g_newline ||
         G_INDENT5 || '                             ,jtf_terr_qtype_usgs_all jtqu   ' || g_newline ||
         G_INDENT5 || '                             ,jtf_qual_type_usgs_all jqtu    ' || g_newline ||
         G_INDENT5 || '                        WHERE jtdr.source_id = p_source_id' || g_newline ||
         G_INDENT5 || '                         AND jtdr.terr_id= jtdr.related_terr_id' || g_newline ||
         G_INDENT5 || '                         AND jqtu.source_id = jtdr.source_id    ' || g_newline ||
         G_INDENT5 || '                         AND jqtu.qual_type_id = p_trans_object_type_id ' || g_newline ||
         G_INDENT5 || '                         AND jtdr.terr_id = jtqu.terr_id ' || g_newline ||
         G_INDENT5 || '                         AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id ' || g_newline ||
         G_INDENT5 || '                         AND jtdr.resource_exists_flag = ''Y''' || g_newline ||
         G_INDENT5 || '                         AND jtqu.qual_relation_product = lp_qual_combination_tbl(i)' || g_newline ||
         G_INDENT5 || '                    ) ILV' || g_newline ||
         G_INDENT5 || '                WHERE  (  Q1023R1.qual_usg_id = -1023 AND Q1023R1.terr_id = ILV.terr_id )' || g_newline ||
         G_INDENT5 || '    AND ( Q1023R1.secondary_interest_code_id IS NULL' || g_newline ||
         G_INDENT5 || '    OR (ALLP.secondary_interest_code_id = Q1023R1.secondary_interest_code_id))' || g_newline ||
         G_INDENT5 || '   AND ( Q1023R1.primary_interest_code_id IS NULL' || g_newline ||
         G_INDENT5 || '   OR ( ALLP.primary_interest_code_id = Q1023R1.primary_interest_code_id ))' || g_newline ||
         G_INDENT5 || '   AND ALLP.interest_type_id =  Q1023R1.interest_type_id' || g_newline ||
         G_INDENT5 || '    AND Q1023R1.comparison_operator = ''=''' || g_newline ||
         G_INDENT5 || '   ) ILV1,' || g_newline ||

         /************************/
         /*  LIKE %XYZ           */
         /************************/
         G_INDENT5 || '   ( ' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||

         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1012LK A)  ' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                        '_324347X_ND)' || g_newline ||
         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1012LK JTF_TERR_CNR_QUAL_LIKE_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ||

         /* Add SELECT columns */
         lp_SELECT_cols || g_newline ||

         G_INDENT5 || 'FROM   '||

         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch) ||

         G_INDENT5 || '   ,  jtf_terr_cnr_qual_like_mv Q1012LK ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate_eq || g_newline ||

         G_INDENT5 || '  AND Q1007R1.terr_id = Q1012LK.terr_id ' || g_newline ||
         G_INDENT5 || '  AND      a.squal_char01 LIKE Q1012LK.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1012LK.first_char = ''%'' ' || g_newline ||
         G_INDENT5 || '  AND Q1012LK.qual_usg_id = -1012 ' || g_newline ||
         G_INDENT5 || '  AND Q1012LK.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || 'UNION ALL ' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||

         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1012LK A)  ' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                        '_324347X_ND)' || g_newline ||
         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1012LK JTF_TERR_CNR_QUAL_LIKE_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ||

         /* Add SELECT columns */
         lp_SELECT_cols || g_newline ||

         G_INDENT5 || 'FROM   '||

         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch) ||

         G_INDENT5 || '   ,  jtf_terr_cnr_qual_like_mv Q1012LK ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate_btwn || g_newline ||

         G_INDENT5 || '  AND Q1007R1.terr_id = Q1012LK.terr_id ' || g_newline ||
         G_INDENT5 || '  AND      a.squal_char01 LIKE Q1012LK.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1012LK.first_char = ''%'' ' || g_newline ||
         G_INDENT5 || '  AND Q1012LK.qual_usg_id = -1012 ' || g_newline ||
         G_INDENT5 || '  AND Q1012LK.terr_id = ILV.terr_id ' || g_newline ||

         G_INDENT5 || ') ILV2' || g_newline ||
         G_INDENT5 || 'WHERE ILV1.terr_id = ILV2.terr_id' || g_newline ||
         G_INDENT5 || 'AND ILV1.lead_id = ILV2.trans_object_id' || g_newline ||

         G_INDENT5 || 'UNION ALL ' || g_newline ;--||

         --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lx_45084233_sql_5
       );

          --bug#3373462 ARPATEL: 01/30/2004
          JTF_TAE_GEN_PVT.write_buffer_content(
            G_INDENT || EXP_PURCHASE_UNION_SELECT(p_new_mode_fetch)
          );

         lx_45084233_sql_6 :=
         --G_INDENT || 'SELECT /*+ NO_MERGE(ILV1) NO_MERGE(ILV2) ' || g_newline ||
         --G_INDENT || '                 USE_HASH(ILV1 ILV2) */' || g_newline ||
         --G_INDENT || '             ILV2.trans_object_id' || g_newline ||
         --G_INDENT || '           , ILV2.trans_detail_object_id' || g_newline ||
         -- eihsu 06/19/2003 worker_id
         --G_INDENT || '           , ILV2.worker_id' || g_newline ||
         --G_INDENT || '           , ILV2.header_id1' || g_newline ||
         --G_INDENT || '           , ILV2.header_id2' || g_newline ||
         --G_INDENT || '           , ILV2.terr_id' || g_newline ||
         --G_INDENT || '           , ILV2.absolute_rank' || g_newline ||
         --G_INDENT || '           , ILV2.top_level_terr_id' || g_newline ||
         --G_INDENT || '           , ILV2.num_winners' || g_newline ||
         --G_INDENT || '           , ILV2.org_id' || g_newline ||
         --G_INDENT || '      FROM'|| g_newline ||
         /************************/
         /*  = ILV1               */
         /************************/
         G_INDENT5 || '( /* INLINE VIEW1 */' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1023R1 ALLP) ' || g_newline ||
         G_INDENT5 || '           INDEX(ALLP AS_LEAD_LINES_N2)' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1023R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ||
         G_INDENT5 || '                      ALLP.lead_id' || g_newline ||
         G_INDENT5 || '                    , ALLP.lead_line_id' || g_newline ||
         G_INDENT5 || '                    , ILV.terr_id ' || g_newline ||
         G_INDENT5 || '                     , ILV.top_level_terr_id ' || g_newline ||
         G_INDENT5 || '                     , ILV.absolute_rank  ' || g_newline ||
         G_INDENT5 || '                     , ILV.num_winners ' || g_newline ||
         G_INDENT5 || '                     , ILV.org_id ' || g_newline ||
         G_INDENT5 || '                 FROM AS_LEAD_LINES ALLP, jtf_terr_qual_rules_mv Q1023R1' || g_newline ||
         G_INDENT5 || '                     , /* INLINE VIEW */' || g_newline ||
         G_INDENT5 || '                     ( SELECT /*+ NO_MERGE */' || g_newline ||
         G_INDENT5 || '                             jtdr.terr_id ' || g_newline ||
         G_INDENT5 || '                           , jtdr.source_id' || g_newline ||
         G_INDENT5 || '                             , jtdr.qual_type_id' || g_newline ||
         G_INDENT5 || '                            , jtdr.top_level_terr_id' || g_newline ||
         G_INDENT5 || '                             , jtdr.absolute_rank ' || g_newline ||
         G_INDENT5 || '                            , jtdr.num_winners ' || g_newline ||
         G_INDENT5 || '                            , jtdr.org_id' || g_newline ||
         G_INDENT5 || '                        FROM  jtf_terr_denorm_rules_all jtdr' || g_newline ||
         G_INDENT5 || '                             ,jtf_terr_qtype_usgs_all jtqu   ' || g_newline ||
         G_INDENT5 || '                             ,jtf_qual_type_usgs_all jqtu    ' || g_newline ||
         G_INDENT5 || '                        WHERE jtdr.source_id = p_source_id' || g_newline ||
         G_INDENT5 || '                         AND jtdr.terr_id= jtdr.related_terr_id' || g_newline ||
         G_INDENT5 || '                         AND jqtu.source_id = jtdr.source_id    ' || g_newline ||
         G_INDENT5 || '                         AND jqtu.qual_type_id = p_trans_object_type_id ' || g_newline ||
         G_INDENT5 || '                         AND jtdr.terr_id = jtqu.terr_id ' || g_newline ||
         G_INDENT5 || '                         AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id ' || g_newline ||
         G_INDENT5 || '                         AND jtdr.resource_exists_flag = ''Y''' || g_newline ||
         G_INDENT5 || '                         AND jtqu.qual_relation_product = lp_qual_combination_tbl(i)' || g_newline ||
         G_INDENT5 || '                    ) ILV' || g_newline ||
         G_INDENT5 || '                WHERE  (  Q1023R1.qual_usg_id = -1023 AND Q1023R1.terr_id = ILV.terr_id )' || g_newline ||
         G_INDENT5 || '    AND ( Q1023R1.secondary_interest_code_id IS NULL' || g_newline ||
         G_INDENT5 || '    OR (ALLP.secondary_interest_code_id = Q1023R1.secondary_interest_code_id))' || g_newline ||
         G_INDENT5 || '   AND ( Q1023R1.primary_interest_code_id IS NULL' || g_newline ||
         G_INDENT5 || '   OR ( ALLP.primary_interest_code_id = Q1023R1.primary_interest_code_id ))' || g_newline ||
         G_INDENT5 || '   AND ALLP.interest_type_id =  Q1023R1.interest_type_id' || g_newline ||
         G_INDENT5 || '    AND Q1023R1.comparison_operator = ''=''' || g_newline ||
         G_INDENT5 || '   ) ILV1,' || g_newline ||

         G_INDENT5 || '   ( ' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1012BT A) ' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                        '_324347_ND)' || g_newline ||

         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1012BT JTF_TERR_CNR_QUAL_BTWN_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ||

         /* Add SELECT columns */
         lp_SELECT_cols || g_newline ||

         G_INDENT5 || 'FROM   '||

         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch) ||

         G_INDENT5 || '   ,  jtf_terr_cnr_qual_btwn_mv Q1012BT ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate || g_newline ||

         G_INDENT5 || '  AND Q1007R1.terr_id = Q1012BT.terr_id ' || g_newline ||
         G_INDENT5 || '  AND      a.squal_char01 <= Q1012BT.high_value_char AND ' || g_newline ||
         G_INDENT5 || '        a.squal_char01 >= Q1012BT.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        a.squal_fc01 >= SUBSTR(Q1012BT.low_value_char, 1, 1) ' || g_newline ||
         G_INDENT5 || '  AND Q1012BT.qual_usg_id = -1012 ' || g_newline ||
         G_INDENT5 || '  AND Q1012BT.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND Q1012BT.terr_id = Q1003R1.terr_id ' || g_newline ||
         G_INDENT5 || ') ILV2' || g_newline ||
         G_INDENT5 || 'WHERE ILV1.terr_id = ILV2.terr_id' || g_newline ||
         G_INDENT5 || 'AND ILV1.lead_id = ILV2.trans_object_id' || g_newline ||
         G_INDENT || lp_close_outermost_ILV || g_newline;

    RETURN lx_45084233_sql_6;

EXCEPTION
WHEN OTHERS THEN
     g_ProgramStatus := 1;
         JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'ERROR: JTF_TAE_SQL_LIBRARY_PVT.add_45084233_SQL');

END add_45084233_SQL;


--** LEAD PRODUCT CATEGORY + COUNTRY + POSTAL CODE ***
FUNCTION add_924631_SQL( p_trans_object_type_id   IN   NUMBER
                       , p_table_name             IN   VARCHAR2
                       , p_new_mode_fetch         IN   CHAR)

RETURN VARCHAR2 AS

   lp_close_outermost_ILV      VARCHAR2(255);
   l_select_ilv2               VARCHAR2(32767) := NULL;
   lp_SELECT_cols              VARCHAR2(32767) := NULL;
   lp_pc_cntry_predicate       VARCHAR2(32767) := NULL;
   lx_924631_sql               VARCHAR2(32767) := NULL;
   lx_924631_sql_1             VARCHAR2(32767) := NULL;
   lx_924631_sql_2             VARCHAR2(32767) := NULL;
   lx_924631_sql_3             VARCHAR2(32767) := NULL;
   lx_924631_sql_4             VARCHAR2(32767) := NULL;
   lx_924631_sql_5             VARCHAR2(32767) := NULL;
   lx_924631_sql_A             VARCHAR2(32767) := NULL;
   lx_924631_sql_B             VARCHAR2(32767) := NULL;
   lx_924631_sql_C             VARCHAR2(32767) := NULL;
   l_sql                       VARCHAR2(32767) := NULL;

BEGIN
--** LEAD PRODUCT CATEGORY + COUNTRY + POSTAL CODE ***

    IF p_new_mode_fetch = 'Y' THEN
       l_select_ilv2 := add_SELECT_clause(p_new_mode_fetch);
       lp_close_outermost_ILV := ') A;  ';

       lp_SELECT_cols :=
          --G_INDENT5 || add_SELECT_cols(p_new_mode_fetch) || g_newline;

	  /* ARPATEL: bug#3373462 */
	    G_INDENT || '       A.TRANS_OBJECT_ID' || g_newline ||
            G_INDENT || '       , A.TRANS_DETAIL_OBJECT_ID' || g_newline ||
            G_INDENT || '       , A.HEADER_ID1' || g_newline ||
            G_INDENT || '       , A.HEADER_ID2' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC01' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC02' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC03' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC04' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC05' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC01' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC02' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC03' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC04' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC05' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC06' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC07' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC08' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC09' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC10' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR01' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR02' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR03' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR04' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR05' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR06' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR07' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR08' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR09' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR10' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR11' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR12' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR13' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR14' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR15' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR16' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR17' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR18' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR19' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR20' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR21' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR22' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR23' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR24' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR25' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR26' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR27' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR28' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR30' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR31' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR32' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR33' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR34' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR35' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR36' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR37' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR38' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR39' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR40' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR41' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR42' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR43' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR44' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR45' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR46' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR47' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR48' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR49' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR50' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR51' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR52' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR53' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR54' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR55' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR56' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR57' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR58' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR59' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR60' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM01' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM02' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM03' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM04' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM05' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM06' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM07' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM08' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM09' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM10' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM11' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM12' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM13' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM14' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM15' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM16' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM17' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM18' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM19' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM20' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM21' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM22' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM23' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM24' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM25' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM26' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM27' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM28' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM29' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM30' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM31' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM32' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM33' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM34' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM35' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM36' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM37' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM38' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM39' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM40' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM41' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM42' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM43' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM44' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM45' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM46' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM47' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM48' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM49' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM50' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM51' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM52' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM53' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM54' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM55' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM56' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM57' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM58' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM59' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM60' || g_newline ||
            G_INDENT || '       , A.ASSIGNED_FLAG' || g_newline ||
            G_INDENT || '       , A.PROCESSED_FLAG' || g_newline ||
            G_INDENT || '       , A.ORG_ID' || g_newline ||
            G_INDENT || '       , A.SECURITY_GROUP_ID' || g_newline ||
            G_INDENT || '       , A.OBJECT_VERSION_NUMBER' || g_newline ||
            G_INDENT || '       , A.WORKER_ID' || g_newline ||
	        G_INDENT || '       , ILV.terr_id ' || g_newline ||
            G_INDENT || '       , ILV.absolute_rank ' || g_newline ||
            G_INDENT || '       , ILV.top_level_terr_id '|| g_newline ||
            G_INDENT || '       , ILV.num_winners ' || g_newline;



    ELSE
       l_select_ilv2 :=
          G_INDENT5 || 'SELECT DISTINCT ' || g_newline ||
          G_INDENT5 ||'ILV2.trans_object_id' || g_newline ||
          G_INDENT5 ||', ILV2.trans_detail_object_id' || g_newline ||
         -- eihsu 06/19/2003 worker_id
          G_INDENT5 ||',ILV2.worker_id' || g_newline ||
          G_INDENT5 ||',ILV2.header_id1' || g_newline ||
          G_INDENT5 ||',ILV2.header_id2' || g_newline ||
          G_INDENT5 ||', p_source_id' || g_newline ||
          G_INDENT5 ||', p_trans_object_type_id' || g_newline ||
          G_INDENT5 ||', l_sysdate' || g_newline ||
          G_INDENT5 ||', L_USER_ID' || g_newline ||
          G_INDENT5 ||', l_sysdate' || g_newline ||
          G_INDENT5 ||', L_USER_ID' || g_newline ||
          G_INDENT5 ||', L_USER_ID' || g_newline ||
          G_INDENT5 ||', L_REQUEST_ID' || g_newline ||
          G_INDENT5 ||', L_PROGRAM_APPL_ID' || g_newline ||
          G_INDENT5 ||', L_PROGRAM_ID' || g_newline ||
          G_INDENT5 ||', l_sysdate' || g_newline ||
          G_INDENT5 ||', ILV2.terr_id' || g_newline ||
          G_INDENT5 ||', ILV2.absolute_rank' || g_newline ||
          G_INDENT5 ||', ILV2.top_level_terr_id' || g_newline ||
          G_INDENT5 ||', ILV2.num_winners' || g_newline ||
          G_INDENT5 ||', ILV2.org_id' || g_newline ;

       lp_close_outermost_ILV := ' ; ';

       lp_SELECT_cols :=
          G_INDENT5 || 'A.trans_object_id, A.trans_detail_object_id, ' || g_newline ||
          -- eihsu 06/19/2003 worker_id
          G_INDENT5 || 'A.worker_id, ' || g_newline ||
          G_INDENT5 || 'A.header_id1, A.header_id2, ' || g_newline ||
          G_INDENT5 || 'ILV.terr_id, ILV.absolute_rank, ' || g_newline ||
          G_INDENT5 || 'ILV.top_level_terr_id, ILV.num_winners, ILV.org_id ';
    END IF;

    lp_pc_cntry_predicate := '   1 = 1 ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
       lp_pc_cntry_predicate := lp_pc_cntry_predicate ||
         '  AND A.worker_id = P_WORKER_ID ' || g_newline;
    END IF;

    lp_pc_cntry_predicate := lp_pc_cntry_predicate ||
         G_INDENT5 || '  AND ( ( a.squal_char06 <= Q1007R1.high_value_char AND ' || g_newline ||
         G_INDENT5 || '          a.squal_char06 >= Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''BETWEEN'' ) ' || g_newline ||
         G_INDENT5 || '        OR ' || g_newline ||
         G_INDENT5 || '        ( a.squal_char06 = Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '      ) ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.qual_usg_id = -1007 ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND  Q1007R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||
         G_INDENT5 || '  AND ( a.squal_char07 = Q1003R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1003R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.qual_usg_id = -1003 ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.terr_id = ILV.terr_id  ' || g_newline ;

    --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => l_select_ilv2
       );

    --bug#3373462 ARPATEL: 01/30/2004
    IF p_new_mode_fetch = 'Y'
    THEN
    JTF_TAE_GEN_PVT.write_buffer_content(
    G_INDENT5 || 'FROM ( ' || g_newline || EXP_PURCHASE_UNION_SELECT(p_new_mode_fetch)
    );
    ELSE
    JTF_TAE_GEN_PVT.write_buffer_content(
    G_INDENT5 || 'FROM ' || g_newline
    );
    END IF;

    lx_924631_sql_1 :=

          /************************/
         /*  = XYZ  ILV2 1        */
         /************************/
         G_INDENT5 || '   ( ' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline;

    IF p_new_mode_fetch = 'Y' THEN
      lx_924631_sql_1 := lx_924631_sql_1 ||
         G_INDENT5 || '           NO_MERGE ' || g_newline ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ; --||
    ELSE
      lx_924631_sql_1 := lx_924631_sql_1 ||
         G_INDENT5 || '           NO_MERGE ' || g_newline ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 A) ' || g_newline ||
                  /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                        '_4841_ND)' || g_newline ||

         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ; --||
    END IF;


         --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lx_924631_sql_1
       );

         /* Add SELECT columns */
         --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lp_SELECT_cols || g_newline
       );
         --lp_SELECT_cols || g_newline

         lx_924631_sql :=
         G_INDENT5 || 'FROM ';

    IF p_new_mode_fetch = 'Y' THEN
       lx_924631_sql := lx_924631_sql ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_924631_sql := lx_924631_sql ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_924631_sql := lx_924631_sql ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate || g_newline ||

         G_INDENT5 || '  ) ILV2,' || g_newline ||

         /************************/
         /*  = ILV1               */
         /************************/
         G_INDENT5 || '( ' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline;

         IF p_new_mode_fetch = 'Y' THEN
           lx_924631_sql := lx_924631_sql || G_INDENT5 || '       ORDERED ' || g_newline;
         END IF;

       lx_924631_sql := lx_924631_sql ||
         G_INDENT5 || '           USE_NL(ILV Q1131R1 ASLLP) ' || g_newline ||
         G_INDENT5 || '           USE_HASH(Q1131R1 ASLLP) ' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ||

         G_INDENT5 || '                      ASLLP.sales_lead_id' || g_newline ||
         G_INDENT5 || '                    , ASLLP.sales_lead_line_id' || g_newline ||
         G_INDENT5 || '                    , ILV.terr_id ' || g_newline ||
         G_INDENT5 || '                     , ILV.top_level_terr_id ' || g_newline ||
         G_INDENT5 || '                     , ILV.absolute_rank  ' || g_newline ||
         G_INDENT5 || '                     , ILV.num_winners ' || g_newline ||
         G_INDENT5 || '                     , ILV.org_id ' || g_newline ||
         G_INDENT5 || '                 FROM ' || g_newline;

    IF p_new_mode_fetch = 'Y' THEN
       lx_924631_sql := lx_924631_sql ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_924631_sql := lx_924631_sql ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_924631_sql := lx_924631_sql ||
         G_INDENT5 || '                     ,jtf_terr_qual_rules_mv Q1131R1 ' || g_newline ||
         G_INDENT5 || '                 ,ENI_PROD_DENORM_HRCHY_V PRD,AS_SALES_LEAD_LINES ASLLP ' ||  g_newline ||
         G_INDENT5 || '                WHERE  (  Q1131R1.qual_usg_id = -1131 AND Q1131R1.terr_id = ILV.terr_id )' || g_newline ||
         G_INDENT5 || '    AND   Q1131R1.value1_id = PRD.child_id ' || g_newline ||
         G_INDENT5 || '    AND   Q1131R1.value2_id = PRD.category_set_id ' || g_newline ||
         G_INDENT5 || '    AND   PRD.parent_id = ASLLP.category_id ' || g_newline ||
         G_INDENT5 || '    AND   PRD.category_set_id = ASLLP.category_set_id ' || g_newline ||
         G_INDENT5 || '    AND   Q1131R1.comparison_operator = ''=''' || g_newline ||
         G_INDENT5 || '   ) ILV1 ' || g_newline ||
         G_INDENT5 || '  WHERE ILV1.terr_id = ILV2.terr_id ' || g_newline ||
         G_INDENT5 || '  AND ILV1.sales_lead_id = ILV2.trans_object_id ' || g_newline ||
         G_INDENT5 || lp_close_outermost_ILV || g_newline;

      RETURN lx_924631_sql;

EXCEPTION
WHEN OTHERS THEN
     g_ProgramStatus := 1;
         JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'ERROR: JTF_TAE_SQL_LIBRARY_PVT.add_924631_SQL');

END add_924631_SQL;

--** LEAD PRODUCT CATEGORY + CNR + Country + Postal Code ***
FUNCTION add_61950277_SQL( p_trans_object_type_id   IN   NUMBER
                     , p_table_name             IN   VARCHAR2
                     -- dblee: 08/26/03 added new mode flag
                     , p_new_mode_fetch         IN   CHAR)

RETURN VARCHAR2 AS

   lp_close_outermost_ILV      VARCHAR2(255);
   l_select_ilv2               VARCHAR2(32767) := NULL;
   lp_SELECT_cols              VARCHAR2(32767) := NULL;
   lp_pc_cntry_predicate_eq    VARCHAR2(32767) := NULL;
   lp_pc_cntry_predicate       VARCHAR2(32767) := NULL;
   lp_pc_cntry_predicate_btwn  VARCHAR2(32767) := NULL;
   lx_61950277_sql             VARCHAR2(32767) := NULL;
   lx_61950277_sql_1           VARCHAR2(32767) := NULL;
   lx_61950277_sql_2           VARCHAR2(32767) := NULL;
   lx_61950277_sql_3           VARCHAR2(32767) := NULL;
   lx_61950277_sql_4           VARCHAR2(32767) := NULL;
   lx_61950277_sql_5           VARCHAR2(32767) := NULL;
   lx_61950277_sql_A           VARCHAR2(32767) := NULL;
   lx_61950277_sql_B           VARCHAR2(32767) := NULL;
   lx_61950277_sql_C           VARCHAR2(32767) := NULL;
   l_sql                       VARCHAR2(32767) := NULL;

BEGIN
--** LEAD PRODUCT CATEGORY +  CNR + Country + Postal Code ***

    -- dblee: 08/27/03 new mode support
    IF p_new_mode_fetch = 'Y' THEN
       l_select_ilv2 := add_SELECT_clause(p_new_mode_fetch);
       lp_close_outermost_ILV := ') A;  ';

       lp_SELECT_cols :=
          --G_INDENT5 || add_SELECT_cols(p_new_mode_fetch) || g_newline;

	  /* ARPATEL: bug#3373462 */
	    G_INDENT || '       A.TRANS_OBJECT_ID' || g_newline ||
            G_INDENT || '       , A.TRANS_DETAIL_OBJECT_ID' || g_newline ||
            G_INDENT || '       , A.HEADER_ID1' || g_newline ||
            G_INDENT || '       , A.HEADER_ID2' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC01' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC02' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC03' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC04' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC05' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC01' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC02' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC03' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC04' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC05' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC06' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC07' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC08' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC09' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC10' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR01' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR02' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR03' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR04' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR05' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR06' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR07' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR08' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR09' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR10' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR11' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR12' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR13' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR14' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR15' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR16' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR17' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR18' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR19' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR20' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR21' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR22' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR23' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR24' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR25' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR26' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR27' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR28' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR30' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR31' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR32' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR33' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR34' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR35' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR36' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR37' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR38' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR39' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR40' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR41' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR42' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR43' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR44' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR45' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR46' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR47' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR48' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR49' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR50' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR51' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR52' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR53' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR54' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR55' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR56' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR57' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR58' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR59' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR60' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM01' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM02' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM03' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM04' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM05' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM06' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM07' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM08' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM09' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM10' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM11' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM12' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM13' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM14' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM15' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM16' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM17' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM18' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM19' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM20' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM21' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM22' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM23' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM24' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM25' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM26' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM27' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM28' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM29' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM30' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM31' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM32' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM33' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM34' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM35' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM36' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM37' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM38' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM39' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM40' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM41' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM42' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM43' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM44' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM45' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM46' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM47' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM48' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM49' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM50' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM51' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM52' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM53' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM54' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM55' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM56' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM57' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM58' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM59' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM60' || g_newline ||
            G_INDENT || '       , A.ASSIGNED_FLAG' || g_newline ||
            G_INDENT || '       , A.PROCESSED_FLAG' || g_newline ||
            G_INDENT || '       , A.ORG_ID' || g_newline ||
            G_INDENT || '       , A.SECURITY_GROUP_ID' || g_newline ||
            G_INDENT || '       , A.OBJECT_VERSION_NUMBER' || g_newline ||
            G_INDENT || '       , A.WORKER_ID' || g_newline ||
	        G_INDENT || '     , ILV.terr_id ' || g_newline ||
            G_INDENT || '     , ILV.absolute_rank ' || g_newline ||
            G_INDENT || '     , ILV.top_level_terr_id '|| g_newline ||
            G_INDENT || '     , ILV.num_winners ' || g_newline;



    ELSE
       l_select_ilv2 :=
          G_INDENT5 || 'SELECT DISTINCT ' || g_newline ||
          G_INDENT5 ||'ILV2.trans_object_id' || g_newline ||
          G_INDENT5 ||', ILV2.trans_detail_object_id' || g_newline ||
         -- eihsu 06/19/2003 worker_id
          G_INDENT5 ||',ILV2.worker_id' || g_newline ||
          G_INDENT5 ||',ILV2.header_id1' || g_newline ||
          G_INDENT5 ||',ILV2.header_id2' || g_newline ||
          G_INDENT5 ||', p_source_id' || g_newline ||
          G_INDENT5 ||', p_trans_object_type_id' || g_newline ||
          G_INDENT5 ||', l_sysdate' || g_newline ||
          G_INDENT5 ||', L_USER_ID' || g_newline ||
          G_INDENT5 ||', l_sysdate' || g_newline ||
          G_INDENT5 ||', L_USER_ID' || g_newline ||
          G_INDENT5 ||', L_USER_ID' || g_newline ||
          G_INDENT5 ||', L_REQUEST_ID' || g_newline ||
          G_INDENT5 ||', L_PROGRAM_APPL_ID' || g_newline ||
          G_INDENT5 ||', L_PROGRAM_ID' || g_newline ||
          G_INDENT5 ||', l_sysdate' || g_newline ||
          G_INDENT5 ||', ILV2.terr_id' || g_newline ||
          G_INDENT5 ||', ILV2.absolute_rank' || g_newline ||
          G_INDENT5 ||', ILV2.top_level_terr_id' || g_newline ||
          G_INDENT5 ||', ILV2.num_winners' || g_newline ||
          G_INDENT5 ||', ILV2.org_id' || g_newline ;

       lp_close_outermost_ILV := ' ; ';

       lp_SELECT_cols :=
          G_INDENT5 || 'A.trans_object_id, A.trans_detail_object_id, ' || g_newline ||
          -- eihsu 06/19/2003 worker_id
          G_INDENT5 || 'A.worker_id, ' || g_newline ||
          G_INDENT5 || 'A.header_id1, A.header_id2, ' || g_newline ||
          G_INDENT5 || 'ILV.terr_id, ILV.absolute_rank, ' || g_newline ||
          G_INDENT5 || 'ILV.top_level_terr_id, ILV.num_winners, ILV.org_id ';
    END IF;

    lp_pc_cntry_predicate := '   1 = 1 ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
       lp_pc_cntry_predicate := lp_pc_cntry_predicate ||
         '  AND A.worker_id = P_WORKER_ID ' || g_newline;
    END IF;

    lp_pc_cntry_predicate := lp_pc_cntry_predicate ||
         G_INDENT5 || '  AND ( ( a.squal_char06 <= Q1007R1.high_value_char AND ' || g_newline ||
         G_INDENT5 || '          a.squal_char06 >= Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''BETWEEN'' ) ' || g_newline ||
         G_INDENT5 || '        OR ' || g_newline ||
         G_INDENT5 || '        ( a.squal_char06 = Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '      ) ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.qual_usg_id = -1007 ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND  Q1007R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||
         G_INDENT5 || '  AND ( a.squal_char07 = Q1003R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1003R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.qual_usg_id = -1003 ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.terr_id = ILV.terr_id  ' || g_newline ;

    lp_pc_cntry_predicate_eq := '   1 = 1 ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
       lp_pc_cntry_predicate_eq := lp_pc_cntry_predicate_eq ||
         '  AND A.worker_id = P_WORKER_ID ' || g_newline;
    END IF;

    lp_pc_cntry_predicate_eq := lp_pc_cntry_predicate_eq ||
         G_INDENT5 || '  AND   ( a.squal_char06 = Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.qual_usg_id = -1007 ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND  Q1007R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||
         G_INDENT5 || '  AND ( a.squal_char07 = Q1003R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1003R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.qual_usg_id = -1003 ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.terr_id = ILV.terr_id  ' || g_newline ;

    lp_pc_cntry_predicate_btwn := '   1 = 1 ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
       lp_pc_cntry_predicate_btwn := lp_pc_cntry_predicate_btwn ||
         '  AND A.worker_id = P_WORKER_ID ' || g_newline;
    END IF;

    lp_pc_cntry_predicate_btwn := lp_pc_cntry_predicate_btwn ||
         G_INDENT5 || '  AND ( a.squal_char06 <= Q1007R1.high_value_char AND ' || g_newline ||
         G_INDENT5 || '          a.squal_char06 >= Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''BETWEEN'' ) ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.qual_usg_id = -1007 ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND  Q1007R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||
         G_INDENT5 || '  AND ( a.squal_char07 = Q1003R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1003R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.qual_usg_id = -1003 ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.terr_id = ILV.terr_id ' || g_newline ;

    --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => l_select_ilv2
       );

    --bug#3373462 ARPATEL: 01/30/2004
    IF p_new_mode_fetch = 'Y'
    THEN
    JTF_TAE_GEN_PVT.write_buffer_content(
    G_INDENT5 || 'FROM ( ' || g_newline || EXP_PURCHASE_UNION_SELECT(p_new_mode_fetch)
    );
    ELSE
    JTF_TAE_GEN_PVT.write_buffer_content(
    G_INDENT5 || 'FROM ' || g_newline
    );
    END IF;

    lx_61950277_sql_1 :=

          /************************/
         /*  = XYZ  ILV2 1        */
         /************************/
         G_INDENT5 || '   ( ' || g_newline;

    IF p_new_mode_fetch = 'Y' THEN
      lx_61950277_sql_1 := lx_61950277_sql_1 ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           NO_MERGE ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ; --||
    ELSE
      lx_61950277_sql_1 := lx_61950277_sql_1 ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1012R1 A) ' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
                  /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                        '_324347_ND)' || g_newline ||

         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1012R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ; --||
    END IF;


         --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lx_61950277_sql_1
       );

         /* Add SELECT columns */
         --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lp_SELECT_cols || g_newline
       );
         --lp_SELECT_cols || g_newline

         lx_61950277_sql :=
         G_INDENT5 || 'FROM ';

    IF p_new_mode_fetch = 'Y' THEN
       lx_61950277_sql := lx_61950277_sql ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_61950277_sql := lx_61950277_sql ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_61950277_sql := lx_61950277_sql ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1012R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = Q1012R1.terr_id ' || g_newline ||
         G_INDENT5 || '  AND ( Q1012R1.comparison_operator = ''='' AND ' || g_newline ||
         G_INDENT5 || '        a.squal_fc01 = SUBSTR(Q1012R1.low_value_char, 1, 1) AND ' || g_newline ||
         G_INDENT5 || '        a.squal_char01 = Q1012R1.low_value_char ' || g_newline ||
         G_INDENT5 || '       ) ' || g_newline ||
         G_INDENT5 || '  AND Q1012R1.qual_usg_id = -1012  ' || g_newline ||
         G_INDENT5 || '  AND Q1012R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND  Q1012R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||

         G_INDENT5 || ' UNION ALL ' || g_newline ||

         /************************/
         /*  LIKE XYZ%  2        */
         /************************/
         G_INDENT5 || 'SELECT /*+ ' || g_newline;

    IF p_new_mode_fetch = 'Y' THEN
      lx_61950277_sql := lx_61950277_sql ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           NO_MERGE ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ; --||
    ELSE
      lx_61950277_sql := lx_61950277_sql ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1012LK A)  ' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||

         /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                      '_324347_ND)' || g_newline ||
         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1012LK JTF_TERR_CNR_QUAL_LIKE_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ; --||
    END IF;

          --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lx_61950277_sql
       );

         /* Add SELECT columns */
         --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lp_SELECT_cols || g_newline
       );
         --lp_SELECT_cols || g_newline ||

         lx_61950277_sql_2 :=
         G_INDENT5 || 'FROM    ';

    IF p_new_mode_fetch = 'Y' THEN
       lx_61950277_sql_2 := lx_61950277_sql_2 ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_61950277_sql_2 := lx_61950277_sql_2 ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_61950277_sql_2 := lx_61950277_sql_2 ||
         G_INDENT5 || '   ,  jtf_terr_cnr_qual_like_mv Q1012LK ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate || g_newline ||

         G_INDENT5 || '  AND Q1007R1.terr_id = Q1012LK.terr_id ' || g_newline ||
         G_INDENT5 || '  AND      a.squal_char01 LIKE Q1012LK.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        a.squal_fc01 = Q1012LK.first_char ' || g_newline ||
         G_INDENT5 || '  AND      Q1012LK.qual_usg_id = -1012 ' || g_newline ||
         G_INDENT5 || '  AND Q1012LK.terr_id = ILV.terr_id ' || g_newline ||

         G_INDENT5 || ' UNION ALL ' || g_newline ||

         /************************/
         /*  LIKE %XYZ   3       */
         /************************/
         G_INDENT5 || 'SELECT /*+ ' || g_newline;

    IF p_new_mode_fetch = 'Y' THEN
      lx_61950277_sql_2 := lx_61950277_sql_2 ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           NO_MERGE ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ; --||
    ELSE
      lx_61950277_sql_2 := lx_61950277_sql_2 ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1012LK A)  ' || g_newline ||

         /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                        '_324347X_ND)' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1012LK JTF_TERR_CNR_QUAL_LIKE_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ; --||
    END IF;


         --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lx_61950277_sql_2
       );

         /* Add SELECT columns */
         --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lp_SELECT_cols || g_newline
       );
         --lp_SELECT_cols || g_newline ||

         lx_61950277_sql_3 :=
         G_INDENT5 || 'FROM   ';

    IF p_new_mode_fetch = 'Y' THEN
       lx_61950277_sql_3 := lx_61950277_sql_3 ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_61950277_sql_3 := lx_61950277_sql_3 ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_61950277_sql_3 := lx_61950277_sql_3 ||
         G_INDENT5 || '   ,  jtf_terr_cnr_qual_like_mv Q1012LK ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate_eq || g_newline ||

         G_INDENT5 || '  AND Q1007R1.terr_id = Q1012LK.terr_id ' || g_newline ||
         G_INDENT5 || '  AND (  ' || g_newline ||
         G_INDENT5 || '        a.squal_char01 LIKE Q1012LK.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1012LK.low_value_char = ''%'' ' || g_newline ||
         G_INDENT5 || '       ) ' || g_newline ||
         G_INDENT5 || '  AND Q1012LK.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || 'UNION ALL' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline;

    IF p_new_mode_fetch = 'Y' THEN
      lx_61950277_sql_3 := lx_61950277_sql_3 ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           NO_MERGE ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ; --||
    ELSE
      lx_61950277_sql_3 := lx_61950277_sql_3 ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1012LK A)  ' || g_newline ||

         /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                        '_324347X_ND)' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1012LK JTF_TERR_CNR_QUAL_LIKE_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ; --||
    END IF;

         --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lx_61950277_sql_3
       );

         /* Add SELECT columns */
         --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lp_SELECT_cols || g_newline
       );
         --lp_SELECT_cols || g_newline ||

         lx_61950277_sql_4 :=
         G_INDENT5 || 'FROM   ';

    IF p_new_mode_fetch = 'Y' THEN
       lx_61950277_sql_4 := lx_61950277_sql_4 ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_61950277_sql_4 := lx_61950277_sql_4 ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_61950277_sql_4 := lx_61950277_sql_4 ||
         G_INDENT5 || '   ,  jtf_terr_cnr_qual_like_mv Q1012LK ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate_btwn || g_newline ||

         G_INDENT5 || '  AND Q1007R1.terr_id = Q1012LK.terr_id ' || g_newline ||
         G_INDENT5 || '  AND (  ' || g_newline ||
         G_INDENT5 || '        a.squal_char01 LIKE Q1012LK.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1012LK.low_value_char = ''%'' ' || g_newline ||
         G_INDENT5 || '       ) ' || g_newline ||
         G_INDENT5 || '  AND Q1012LK.terr_id = ILV.terr_id ' || g_newline ||

         G_INDENT5 || ' UNION ALL ' || g_newline ||

         G_INDENT5 || 'SELECT /*+ ' || g_newline;

    IF p_new_mode_fetch = 'Y' THEN
      lx_61950277_sql_4 := lx_61950277_sql_4 ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           NO_MERGE ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ; --||
    ELSE
      lx_61950277_sql_4 := lx_61950277_sql_4 ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1012BT A) ' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                        '_324347_ND)' || g_newline ||

         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1012BT JTF_TERR_CNR_QUAL_BTWN_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ; --||
    END IF;

         --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lx_61950277_sql_4
       );

         /* Add SELECT columns */
         --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lp_SELECT_cols || g_newline
       );
         /* Add SELECT columns */
         --lp_SELECT_cols || g_newline ||

         lx_61950277_sql_5 :=
         G_INDENT5 || 'FROM   ';

    IF p_new_mode_fetch = 'Y' THEN
       lx_61950277_sql_5 := lx_61950277_sql_5 ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_61950277_sql_5 := lx_61950277_sql_5 ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_61950277_sql_5 := lx_61950277_sql_5 ||
         G_INDENT5 || '   ,  jtf_terr_cnr_qual_btwn_mv Q1012BT ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate || g_newline ||

         G_INDENT5 || '  AND Q1007R1.terr_id = Q1012BT.terr_id ' || g_newline ||
         G_INDENT5 || '  AND      a.squal_char01 <= Q1012BT.high_value_char AND ' || g_newline ||
         G_INDENT5 || '        a.squal_char01 >= Q1012BT.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        a.squal_fc01 >= SUBSTR(Q1012BT.low_value_char, 1, 1) ' || g_newline ||
         G_INDENT5 || '  AND Q1012BT.qual_usg_id = -1012 ' || g_newline ||
         G_INDENT5 || '  AND Q1012BT.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND Q1012BT.terr_id = Q1003R1.terr_id ) ILV2,' || g_newline ||

         /************************/
         /*  = ILV1               */
         /************************/
         G_INDENT5 || '( ' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline;

         IF p_new_mode_fetch = 'Y' THEN
           lx_61950277_sql_5 := lx_61950277_sql_5 || G_INDENT5 || '       ORDERED ' || g_newline;
         END IF;

         lx_61950277_sql_5 := lx_61950277_sql_5 ||

         G_INDENT5 || '           USE_NL(ILV Q1131R1 ASLLP) ' || g_newline ||
         G_INDENT5 || '           USE_HASH(Q1131R1 ASLLP) ' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ||

         G_INDENT5 || '                      ASLLP.sales_lead_id' || g_newline ||
         G_INDENT5 || '                    , ASLLP.sales_lead_line_id' || g_newline ||
         G_INDENT5 || '                    , ILV.terr_id ' || g_newline ||
         G_INDENT5 || '                     , ILV.top_level_terr_id ' || g_newline ||
         G_INDENT5 || '                     , ILV.absolute_rank  ' || g_newline ||
         G_INDENT5 || '                     , ILV.num_winners ' || g_newline ||
         G_INDENT5 || '                     , ILV.org_id ' || g_newline ||
         G_INDENT5 || '                 FROM ' ||  g_newline;

    IF p_new_mode_fetch = 'Y' THEN
       lx_61950277_sql_5 := lx_61950277_sql_5 ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_61950277_sql_5 := lx_61950277_sql_5 ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_61950277_sql_5 := lx_61950277_sql_5 ||
         G_INDENT5 || '                     ,jtf_terr_qual_rules_mv Q1131R1 ' || g_newline ||
         G_INDENT5 || '                 ,ENI_PROD_DENORM_HRCHY_V PRD,AS_SALES_LEAD_LINES ASLLP ' ||  g_newline ||
         G_INDENT5 || '                WHERE  (  Q1131R1.qual_usg_id = -1131 AND Q1131R1.terr_id = ILV.terr_id )' || g_newline ||
         G_INDENT5 || '    AND   Q1131R1.value1_id = PRD.child_id ' || g_newline ||
         G_INDENT5 || '    AND   Q1131R1.value2_id = PRD.category_set_id ' || g_newline ||
         G_INDENT5 || '    AND   PRD.parent_id = ASLLP.category_id ' || g_newline ||
         G_INDENT5 || '    AND   PRD.category_set_id = ASLLP.category_set_id ' || g_newline ||
         G_INDENT5 || '    AND   Q1131R1.comparison_operator = ''=''' || g_newline ||
         G_INDENT5 || '   ) ILV1 ' || g_newline ||
         G_INDENT5 || '  WHERE ILV1.terr_id = ILV2.terr_id ' || g_newline ||
         G_INDENT5 || '  AND ILV1.sales_lead_id = ILV2.trans_object_id ' || g_newline ||
         G_INDENT5 || lp_close_outermost_ILV || g_newline;

      RETURN lx_61950277_sql_5;

EXCEPTION
WHEN OTHERS THEN
     g_ProgramStatus := 1;
         JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'ERROR: JTF_TAE_SQL_LIBRARY_PVT.add_61950277_SQL');

END add_61950277_SQL;


--** LEAD EXPECTED PURCHASE ***
FUNCTION add_44435539_SQL( p_trans_object_type_id   IN   NUMBER
                     , p_table_name             IN   VARCHAR2
                     -- dblee: 08/26/03 added new mode flag
                     , p_new_mode_fetch         IN   CHAR)

RETURN VARCHAR2 AS

   lp_close_outermost_ILV      VARCHAR2(255);
   l_select_ilv2               VARCHAR2(32767) := NULL;
   lp_SELECT_cols              VARCHAR2(32767) := NULL;
   lp_pc_cntry_predicate_eq    VARCHAR2(32767) := NULL;
   lp_pc_cntry_predicate       VARCHAR2(32767) := NULL;
   lp_pc_cntry_predicate_btwn  VARCHAR2(32767) := NULL;
   lx_44435539_sql             VARCHAR2(32767) := NULL;
   lx_44435539_sql_1           VARCHAR2(32767) := NULL;
   lx_44435539_sql_2           VARCHAR2(32767) := NULL;
   lx_44435539_sql_3           VARCHAR2(32767) := NULL;
   lx_44435539_sql_4           VARCHAR2(32767) := NULL;
   lx_44435539_sql_5           VARCHAR2(32767) := NULL;
   lx_44435539_sql_A           VARCHAR2(32767) := NULL;
   lx_44435539_sql_B           VARCHAR2(32767) := NULL;
   lx_44435539_sql_C           VARCHAR2(32767) := NULL;
   l_sql                       VARCHAR2(32767) := NULL;

BEGIN
--** LEAD EXPECTED PURCHASE ***

    -- dblee: 08/27/03 new mode support
    IF p_new_mode_fetch = 'Y' THEN
       l_select_ilv2 := add_SELECT_clause(p_new_mode_fetch);
       lp_close_outermost_ILV := ') A;  ';

       lp_SELECT_cols :=
          --G_INDENT5 || add_SELECT_cols(p_new_mode_fetch) || g_newline;

	  /* ARPATEL: bug#3373462 */
	    G_INDENT || '       A.TRANS_OBJECT_ID' || g_newline ||
            G_INDENT || '       , A.TRANS_DETAIL_OBJECT_ID' || g_newline ||
            G_INDENT || '       , A.HEADER_ID1' || g_newline ||
            G_INDENT || '       , A.HEADER_ID2' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC01' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC02' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC03' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC04' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC05' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC01' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC02' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC03' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC04' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC05' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC06' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC07' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC08' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC09' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC10' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR01' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR02' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR03' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR04' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR05' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR06' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR07' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR08' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR09' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR10' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR11' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR12' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR13' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR14' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR15' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR16' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR17' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR18' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR19' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR20' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR21' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR22' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR23' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR24' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR25' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR26' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR27' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR28' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR30' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR31' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR32' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR33' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR34' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR35' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR36' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR37' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR38' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR39' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR40' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR41' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR42' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR43' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR44' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR45' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR46' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR47' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR48' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR49' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR50' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR51' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR52' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR53' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR54' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR55' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR56' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR57' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR58' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR59' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR60' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM01' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM02' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM03' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM04' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM05' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM06' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM07' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM08' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM09' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM10' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM11' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM12' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM13' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM14' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM15' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM16' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM17' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM18' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM19' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM20' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM21' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM22' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM23' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM24' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM25' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM26' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM27' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM28' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM29' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM30' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM31' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM32' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM33' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM34' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM35' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM36' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM37' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM38' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM39' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM40' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM41' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM42' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM43' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM44' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM45' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM46' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM47' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM48' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM49' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM50' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM51' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM52' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM53' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM54' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM55' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM56' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM57' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM58' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM59' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM60' || g_newline ||
            G_INDENT || '       , A.ASSIGNED_FLAG' || g_newline ||
            G_INDENT || '       , A.PROCESSED_FLAG' || g_newline ||
            G_INDENT || '       , A.ORG_ID' || g_newline ||
            G_INDENT || '       , A.SECURITY_GROUP_ID' || g_newline ||
            G_INDENT || '       , A.OBJECT_VERSION_NUMBER' || g_newline ||
            G_INDENT || '       , A.WORKER_ID' || g_newline ||
	        G_INDENT || '     , ILV.terr_id ' || g_newline ||
            G_INDENT || '     , ILV.absolute_rank ' || g_newline ||
            G_INDENT || '     , ILV.top_level_terr_id '|| g_newline ||
            G_INDENT || '     , ILV.num_winners ' || g_newline;



    ELSE
       l_select_ilv2 :=
          G_INDENT5 || 'SELECT DISTINCT ' || g_newline ||
          G_INDENT5 ||'ILV2.trans_object_id' || g_newline ||
          G_INDENT5 ||', ILV2.trans_detail_object_id' || g_newline ||
         -- eihsu 06/19/2003 worker_id
          G_INDENT5 ||',ILV2.worker_id' || g_newline ||
          G_INDENT5 ||',ILV2.header_id1' || g_newline ||
          G_INDENT5 ||',ILV2.header_id2' || g_newline ||
          G_INDENT5 ||', p_source_id' || g_newline ||
          G_INDENT5 ||', p_trans_object_type_id' || g_newline ||
          G_INDENT5 ||', l_sysdate' || g_newline ||
          G_INDENT5 ||', L_USER_ID' || g_newline ||
          G_INDENT5 ||', l_sysdate' || g_newline ||
          G_INDENT5 ||', L_USER_ID' || g_newline ||
          G_INDENT5 ||', L_USER_ID' || g_newline ||
          G_INDENT5 ||', L_REQUEST_ID' || g_newline ||
          G_INDENT5 ||', L_PROGRAM_APPL_ID' || g_newline ||
          G_INDENT5 ||', L_PROGRAM_ID' || g_newline ||
          G_INDENT5 ||', l_sysdate' || g_newline ||
          G_INDENT5 ||', ILV2.terr_id' || g_newline ||
          G_INDENT5 ||', ILV2.absolute_rank' || g_newline ||
          G_INDENT5 ||', ILV2.top_level_terr_id' || g_newline ||
          G_INDENT5 ||', ILV2.num_winners' || g_newline ||
          G_INDENT5 ||', ILV2.org_id' || g_newline ;

       lp_close_outermost_ILV := ' ; ';

       lp_SELECT_cols :=
          G_INDENT5 || 'A.trans_object_id, A.trans_detail_object_id, ' || g_newline ||
          -- eihsu 06/19/2003 worker_id
          G_INDENT5 || 'A.worker_id, ' || g_newline ||
          G_INDENT5 || 'A.header_id1, A.header_id2, ' || g_newline ||
          G_INDENT5 || 'ILV.terr_id, ILV.absolute_rank, ' || g_newline ||
          G_INDENT5 || 'ILV.top_level_terr_id, ILV.num_winners, ILV.org_id ';
    END IF;

    lp_pc_cntry_predicate := '   1 = 1 ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
       lp_pc_cntry_predicate := lp_pc_cntry_predicate ||
         '  AND A.worker_id = P_WORKER_ID ' || g_newline;
    END IF;

    lp_pc_cntry_predicate := lp_pc_cntry_predicate ||
         G_INDENT5 || '  AND ( ( a.squal_char06 <= Q1007R1.high_value_char AND ' || g_newline ||
         G_INDENT5 || '          a.squal_char06 >= Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''BETWEEN'' ) ' || g_newline ||
         G_INDENT5 || '        OR ' || g_newline ||
         G_INDENT5 || '        ( a.squal_char06 = Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '      ) ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.qual_usg_id = -1007 ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND  Q1007R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||
         G_INDENT5 || '  AND ( a.squal_char07 = Q1003R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1003R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.qual_usg_id = -1003 ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.terr_id = ILV.terr_id  ' || g_newline ;

    lp_pc_cntry_predicate_eq := '   1 = 1 ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
       lp_pc_cntry_predicate_eq := lp_pc_cntry_predicate_eq ||
         '  AND A.worker_id = P_WORKER_ID ' || g_newline;
    END IF;

    lp_pc_cntry_predicate_eq := lp_pc_cntry_predicate_eq ||
         G_INDENT5 || '  AND   ( a.squal_char06 = Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.qual_usg_id = -1007 ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND  Q1007R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||
         G_INDENT5 || '  AND ( a.squal_char07 = Q1003R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1003R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.qual_usg_id = -1003 ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.terr_id = ILV.terr_id  ' || g_newline ;

    lp_pc_cntry_predicate_btwn := '   1 = 1 ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
       lp_pc_cntry_predicate_btwn := lp_pc_cntry_predicate_btwn ||
         '  AND A.worker_id = P_WORKER_ID ' || g_newline;
    END IF;

    lp_pc_cntry_predicate_btwn := lp_pc_cntry_predicate_btwn ||
         G_INDENT5 || '  AND ( a.squal_char06 <= Q1007R1.high_value_char AND ' || g_newline ||
         G_INDENT5 || '          a.squal_char06 >= Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''BETWEEN'' ) ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.qual_usg_id = -1007 ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND  Q1007R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||
         G_INDENT5 || '  AND ( a.squal_char07 = Q1003R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1003R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.qual_usg_id = -1003 ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.terr_id = ILV.terr_id ' || g_newline ;

    --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => l_select_ilv2
       );

    --bug#3373462 ARPATEL: 01/30/2004
    IF p_new_mode_fetch = 'Y'
    THEN
    JTF_TAE_GEN_PVT.write_buffer_content(
    G_INDENT5 || 'FROM ( ' || g_newline || EXP_PURCHASE_UNION_SELECT(p_new_mode_fetch)
    );
    ELSE
    JTF_TAE_GEN_PVT.write_buffer_content(
    G_INDENT5 || 'FROM ' || g_newline
    );
    END IF;

    lx_44435539_sql_1 :=

          /************************/
         /*  = XYZ  ILV2 1        */
         /************************/
         G_INDENT5 || '   ( ' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1012R1 A) ' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
                  /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                        '_324347_ND)' || g_newline ||

         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1012R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ; --||


         --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lx_44435539_sql_1
       );

         /* Add SELECT columns */
         --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lp_SELECT_cols || g_newline
       );
         --lp_SELECT_cols || g_newline

         lx_44435539_sql :=
         G_INDENT5 || 'FROM ' ||

         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch) ||

         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1012R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = Q1012R1.terr_id ' || g_newline ||
         G_INDENT5 || '  AND ( Q1012R1.comparison_operator = ''='' AND ' || g_newline ||
         G_INDENT5 || '        a.squal_fc01 = SUBSTR(Q1012R1.low_value_char, 1, 1) AND ' || g_newline ||
         G_INDENT5 || '        a.squal_char01 = Q1012R1.low_value_char ' || g_newline ||
         G_INDENT5 || '       ) ' || g_newline ||
         G_INDENT5 || '  AND Q1012R1.qual_usg_id = -1012  ' || g_newline ||
         G_INDENT5 || '  AND Q1012R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND  Q1012R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||

         G_INDENT5 || ' UNION ALL ' || g_newline ||

         /************************/
         /*  LIKE XYZ%  2        */
         /************************/
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||

         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1012LK A)  ' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||

         /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                      '_324347_ND)' || g_newline ||
         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1012LK JTF_TERR_CNR_QUAL_LIKE_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ; --||

          --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lx_44435539_sql
       );

         /* Add SELECT columns */
         --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lp_SELECT_cols || g_newline
       );
         --lp_SELECT_cols || g_newline ||

         lx_44435539_sql_2 :=
         G_INDENT5 || 'FROM    '||

         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch) ||

         G_INDENT5 || '   ,  jtf_terr_cnr_qual_like_mv Q1012LK ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate || g_newline ||

         G_INDENT5 || '  AND Q1007R1.terr_id = Q1012LK.terr_id ' || g_newline ||
         G_INDENT5 || '  AND      a.squal_char01 LIKE Q1012LK.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        a.squal_fc01 = Q1012LK.first_char ' || g_newline ||
         G_INDENT5 || '  AND      Q1012LK.qual_usg_id = -1012 ' || g_newline ||
         G_INDENT5 || '  AND Q1012LK.terr_id = ILV.terr_id ' || g_newline ||

         G_INDENT5 || ' UNION ALL ' || g_newline ||

         /************************/
         /*  LIKE %XYZ   3       */
         /************************/
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||

         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1012LK A)  ' || g_newline ||

         /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                        '_324347X_ND)' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1012LK JTF_TERR_CNR_QUAL_LIKE_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ; --||


         --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lx_44435539_sql_2
       );

         /* Add SELECT columns */
         --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lp_SELECT_cols || g_newline
       );
         --lp_SELECT_cols || g_newline ||

         lx_44435539_sql_3 :=
         G_INDENT5 || 'FROM   '||

         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch) ||

         G_INDENT5 || '   ,  jtf_terr_cnr_qual_like_mv Q1012LK ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate_eq || g_newline ||

         G_INDENT5 || '  AND Q1007R1.terr_id = Q1012LK.terr_id ' || g_newline ||
         G_INDENT5 || '  AND (  ' || g_newline ||
         G_INDENT5 || '        a.squal_char01 LIKE Q1012LK.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1012LK.low_value_char = ''%'' ' || g_newline ||
         G_INDENT5 || '       ) ' || g_newline ||
         G_INDENT5 || '  AND Q1012LK.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || 'UNION ALL' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||

         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1012LK A)  ' || g_newline ||

         /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                        '_324347X_ND)' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1012LK JTF_TERR_CNR_QUAL_LIKE_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ; --||

         --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lx_44435539_sql_3
       );

         /* Add SELECT columns */
         --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lp_SELECT_cols || g_newline
       );
         --lp_SELECT_cols || g_newline ||

         lx_44435539_sql_4 :=
         G_INDENT5 || 'FROM   '||

         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch) ||

         G_INDENT5 || '   ,  jtf_terr_cnr_qual_like_mv Q1012LK ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate_btwn || g_newline ||

         G_INDENT5 || '  AND Q1007R1.terr_id = Q1012LK.terr_id ' || g_newline ||
         G_INDENT5 || '  AND (  ' || g_newline ||
         G_INDENT5 || '        a.squal_char01 LIKE Q1012LK.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1012LK.low_value_char = ''%'' ' || g_newline ||
         G_INDENT5 || '       ) ' || g_newline ||
         G_INDENT5 || '  AND Q1012LK.terr_id = ILV.terr_id ' || g_newline ||

         G_INDENT5 || ' UNION ALL ' || g_newline ||

         G_INDENT5 || 'SELECT /*+ ' || g_newline ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1012BT A) ' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                        '_324347_ND)' || g_newline ||

         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1012BT JTF_TERR_CNR_QUAL_BTWN_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ; --||

         --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lx_44435539_sql_4
       );

         /* Add SELECT columns */
         --ARPATEL 10/14 bug#3207518
      JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => lp_SELECT_cols || g_newline
       );
         /* Add SELECT columns */
         --lp_SELECT_cols || g_newline ||

         lx_44435539_sql_5 :=
         G_INDENT5 || 'FROM   '||

         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch) ||

         G_INDENT5 || '   ,  jtf_terr_cnr_qual_btwn_mv Q1012BT ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate || g_newline ||

         G_INDENT5 || '  AND Q1007R1.terr_id = Q1012BT.terr_id ' || g_newline ||
         G_INDENT5 || '  AND      a.squal_char01 <= Q1012BT.high_value_char AND ' || g_newline ||
         G_INDENT5 || '        a.squal_char01 >= Q1012BT.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        a.squal_fc01 >= SUBSTR(Q1012BT.low_value_char, 1, 1) ' || g_newline ||
         G_INDENT5 || '  AND Q1012BT.qual_usg_id = -1012 ' || g_newline ||
         G_INDENT5 || '  AND Q1012BT.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND Q1012BT.terr_id = Q1003R1.terr_id ) ILV2,' || g_newline ||

         /************************/
         /*  = ILV1               */
         /************************/
         G_INDENT5 || '( ' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1018R1 ASLLP) ' || g_newline ||
         G_INDENT5 || '           USE_HASH(Q1018R1 ASLLP) ' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1018R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline ||

         G_INDENT5 || '                      ASLLP.sales_lead_id' || g_newline ||
         G_INDENT5 || '                    , ASLLP.sales_lead_line_id' || g_newline ||
         G_INDENT5 || '                    , ILV.terr_id ' || g_newline ||
         G_INDENT5 || '                     , ILV.top_level_terr_id ' || g_newline ||
         G_INDENT5 || '                     , ILV.absolute_rank  ' || g_newline ||
         G_INDENT5 || '                     , ILV.num_winners ' || g_newline ||
         G_INDENT5 || '                     , ILV.org_id ' || g_newline ||
         G_INDENT5 || '                 FROM AS_SALES_LEAD_LINES ASLLP, jtf_terr_qual_rules_mv Q1018R1' || g_newline ||
         G_INDENT5 || '                     , /* INLINE VIEW */' || g_newline ||
         G_INDENT5 || '                     ( SELECT /*+ NO_MERGE */' || g_newline ||
         G_INDENT5 || '                             jtdr.terr_id ' || g_newline ||
         G_INDENT5 || '                           , jtdr.source_id' || g_newline ||
         G_INDENT5 || '                             , jtdr.qual_type_id' || g_newline ||
         G_INDENT5 || '                            , jtdr.top_level_terr_id' || g_newline ||
         G_INDENT5 || '                             , jtdr.absolute_rank ' || g_newline ||
         G_INDENT5 || '                            , jtdr.num_winners ' || g_newline ||
         G_INDENT5 || '                            , jtdr.org_id' || g_newline ||
         G_INDENT5 || '                        FROM  jtf_terr_denorm_rules_all jtdr' || g_newline ||
         G_INDENT5 || '                             ,jtf_terr_qtype_usgs_all jtqu   ' || g_newline ||
         G_INDENT5 || '                             ,jtf_qual_type_usgs_all jqtu    ' || g_newline ||
         G_INDENT5 || '                        WHERE jtdr.source_id = p_source_id' || g_newline ||
         G_INDENT5 || '                         AND jtdr.terr_id= jtdr.related_terr_id' || g_newline ||
         G_INDENT5 || '                         AND jqtu.source_id = jtdr.source_id    ' || g_newline ||
         G_INDENT5 || '                         AND jqtu.qual_type_id = p_trans_object_type_id ' || g_newline ||
         G_INDENT5 || '                         AND jtdr.terr_id = jtqu.terr_id ' || g_newline ||
         G_INDENT5 || '                         AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id ' || g_newline ||
         G_INDENT5 || '                         AND jtdr.resource_exists_flag = ''Y''' || g_newline ||
         G_INDENT5 || '                         AND jtqu.qual_relation_product = lp_qual_combination_tbl(i)' || g_newline ||
         G_INDENT5 || '                    ) ILV' || g_newline ||
	 /* ARPATEL BUG#3531955 03/24/2004 change 1023 to 1018 */
         G_INDENT5 || '                WHERE  (  Q1018R1.qual_usg_id = -1018 AND Q1018R1.terr_id = ILV.terr_id )' || g_newline ||
         G_INDENT5 || '    AND ( Q1018R1.secondary_interest_code_id IS NULL' || g_newline ||
         G_INDENT5 || '    OR (ASLLP.secondary_interest_code_id = Q1018R1.secondary_interest_code_id))' || g_newline ||
         G_INDENT5 || '   AND ( Q1018R1.primary_interest_code_id IS NULL' || g_newline ||
         G_INDENT5 || '   OR ( ASLLP.primary_interest_code_id = Q1018R1.primary_interest_code_id ))' || g_newline ||
         G_INDENT5 || '   AND ASLLP.interest_type_id =  Q1018R1.interest_type_id' || g_newline ||
         G_INDENT5 || '    AND Q1018R1.comparison_operator = ''=''' || g_newline ||
         G_INDENT5 || '   ) ILV1 ' || g_newline ||
         G_INDENT5 || '  WHERE ILV1.terr_id = ILV2.terr_id ' || g_newline ||
         G_INDENT5 || '    AND ILV1.sales_lead_id = ILV2.trans_object_id ' || g_newline ||
         G_INDENT5 || lp_close_outermost_ILV || g_newline;

      RETURN lx_44435539_sql_5;

EXCEPTION
WHEN OTHERS THEN
     g_ProgramStatus := 1;
         JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'ERROR: JTF_TAE_SQL_LIBRARY_PVT.add_44435539_SQL');

END add_44435539_SQL;


--** LEAD INTEREST TYPE *** /* ARPATEL BUG#3508485 03/18/2004 */
FUNCTION add_663217_SQL( p_trans_object_type_id   IN   NUMBER
                     , p_table_name             IN   VARCHAR2
                     -- dblee: 08/26/03 added new mode flag
                     , p_new_mode_fetch         IN   CHAR)

RETURN VARCHAR2 AS
lx_663217_sql             VARCHAR2(32767) := NULL;
lx_663217_sql_1           VARCHAR2(32767) := NULL;
lx_663217_sql_2           VARCHAR2(32767) := NULL;
l_select_ilv2             VARCHAR2(32767) := NULL;
lp_SELECT_cols            VARCHAR2(32767) := NULL;
l_sql                     VARCHAR2(32767) := NULL;
BEGIN

    IF p_new_mode_fetch = 'Y' THEN
       l_select_ilv2 := --add_SELECT_clause(p_new_mode_fetch);
                       G_INDENT || ' SELECT DISTINCT  ' || g_newline ||
            G_INDENT || '       ILV2.TRANS_OBJECT_ID' || g_newline ||
            G_INDENT || '       , ILV2.TRANS_DETAIL_OBJECT_ID' || g_newline ||
            G_INDENT || '       , ILV2.HEADER_ID1' || g_newline ||
            G_INDENT || '       , ILV2.HEADER_ID2' || g_newline ||
            G_INDENT || '       , p_source_id' || g_newline ||
            G_INDENT || '       , p_trans_object_type_id' || g_newline ||
            G_INDENT || '       , l_sysdate' || g_newline ||
            G_INDENT || '       , L_USER_ID' || g_newline ||
            G_INDENT || '       , l_sysdate' || g_newline ||
            G_INDENT || '       , L_USER_ID' || g_newline ||
            G_INDENT || '       , L_USER_ID' || g_newline ||
            G_INDENT || '       , L_REQUEST_ID' || g_newline ||
            G_INDENT || '       , L_PROGRAM_APPL_ID' || g_newline ||
            G_INDENT || '       , L_PROGRAM_ID' || g_newline ||
            G_INDENT || '       , l_sysdate' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_FC01' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_FC02' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_FC03' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_FC04' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_FC05' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CURC01' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CURC02' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CURC03' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CURC04' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CURC05' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CURC06' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CURC07' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CURC08' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CURC09' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CURC10' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR01' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR02' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR03' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR04' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR05' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR06' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR07' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR08' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR09' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR10' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR11' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR12' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR13' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR14' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR15' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR16' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR17' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR18' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR19' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR20' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR21' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR22' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR23' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR24' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR25' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR26' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR27' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR28' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR30' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR31' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR32' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR33' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR34' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR35' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR36' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR37' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR38' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR39' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR40' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR41' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR42' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR43' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR44' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR45' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR46' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR47' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR48' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR49' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR50' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR51' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR52' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR53' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR54' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR55' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR56' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR57' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR58' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR59' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_CHAR60' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM01' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM02' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM03' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM04' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM05' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM06' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM07' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM08' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM09' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM10' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM11' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM12' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM13' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM14' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM15' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM16' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM17' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM18' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM19' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM20' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM21' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM22' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM23' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM24' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM25' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM26' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM27' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM28' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM29' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM30' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM31' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM32' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM33' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM34' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM35' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM36' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM37' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM38' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM39' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM40' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM41' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM42' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM43' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM44' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM45' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM46' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM47' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM48' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM49' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM50' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM51' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM52' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM53' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM54' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM55' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM56' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM57' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM58' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM59' || g_newline ||
            G_INDENT || '       , ILV2.SQUAL_NUM60' || g_newline ||
            G_INDENT || '       , ILV2.ASSIGNED_FLAG' || g_newline ||
            G_INDENT || '       , ILV2.PROCESSED_FLAG' || g_newline ||
            G_INDENT || '       , ILV2.ORG_ID' || g_newline ||
            G_INDENT || '       , ILV2.SECURITY_GROUP_ID' || g_newline ||
            G_INDENT || '       , ILV2.OBJECT_VERSION_NUMBER' || g_newline ||
            G_INDENT || '       , ILV2.WORKER_ID' || g_newline ;

       lp_SELECT_cols :=
          --G_INDENT5 || add_SELECT_cols(p_new_mode_fetch) || g_newline;

	  /* ARPATEL: bug#3373462 */
	    G_INDENT || '       A.TRANS_OBJECT_ID' || g_newline ||
            G_INDENT || '       , A.TRANS_DETAIL_OBJECT_ID' || g_newline ||
            G_INDENT || '       , A.HEADER_ID1' || g_newline ||
            G_INDENT || '       , A.HEADER_ID2' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC01' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC02' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC03' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC04' || g_newline ||
            G_INDENT || '       , A.SQUAL_FC05' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC01' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC02' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC03' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC04' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC05' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC06' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC07' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC08' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC09' || g_newline ||
            G_INDENT || '       , A.SQUAL_CURC10' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR01' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR02' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR03' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR04' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR05' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR06' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR07' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR08' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR09' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR10' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR11' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR12' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR13' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR14' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR15' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR16' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR17' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR18' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR19' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR20' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR21' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR22' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR23' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR24' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR25' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR26' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR27' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR28' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR30' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR31' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR32' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR33' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR34' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR35' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR36' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR37' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR38' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR39' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR40' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR41' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR42' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR43' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR44' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR45' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR46' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR47' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR48' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR49' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR50' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR51' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR52' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR53' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR54' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR55' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR56' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR57' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR58' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR59' || g_newline ||
            G_INDENT || '       , A.SQUAL_CHAR60' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM01' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM02' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM03' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM04' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM05' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM06' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM07' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM08' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM09' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM10' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM11' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM12' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM13' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM14' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM15' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM16' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM17' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM18' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM19' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM20' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM21' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM22' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM23' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM24' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM25' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM26' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM27' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM28' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM29' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM30' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM31' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM32' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM33' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM34' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM35' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM36' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM37' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM38' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM39' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM40' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM41' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM42' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM43' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM44' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM45' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM46' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM47' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM48' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM49' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM50' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM51' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM52' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM53' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM54' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM55' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM56' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM57' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM58' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM59' || g_newline ||
            G_INDENT || '       , A.SQUAL_NUM60' || g_newline ||
            G_INDENT || '       , A.ASSIGNED_FLAG' || g_newline ||
            G_INDENT || '       , A.PROCESSED_FLAG' || g_newline ||
            G_INDENT || '       , A.ORG_ID' || g_newline ||
            G_INDENT || '       , A.SECURITY_GROUP_ID' || g_newline ||
            G_INDENT || '       , A.OBJECT_VERSION_NUMBER' || g_newline ||
            G_INDENT || '       , A.WORKER_ID' || g_newline ||
	        G_INDENT || '     , ILV.terr_id ' || g_newline ||
            G_INDENT || '     , ILV.absolute_rank ' || g_newline ||
            G_INDENT || '     , ILV.top_level_terr_id '|| g_newline ||
            G_INDENT || '     , ILV.num_winners ' || g_newline;



    ELSE
       l_select_ilv2 :=
          G_INDENT5 || 'SELECT /*+ USE_HASH(ILV2 ASLLP) */ ' || g_newline ||
	  G_INDENT5 || '       DISTINCT ' || g_newline ||
          G_INDENT5 ||'ILV2.trans_object_id' || g_newline ||
          G_INDENT5 ||', ILV2.trans_detail_object_id' || g_newline ||
         -- eihsu 06/19/2003 worker_id
          G_INDENT5 ||',ILV2.worker_id' || g_newline ||
          G_INDENT5 ||',ILV2.header_id1' || g_newline ||
          G_INDENT5 ||',ILV2.header_id2' || g_newline ||
          G_INDENT5 ||', p_source_id' || g_newline ||
          G_INDENT5 ||', p_trans_object_type_id' || g_newline ||
          G_INDENT5 ||', l_sysdate' || g_newline ||
          G_INDENT5 ||', L_USER_ID' || g_newline ||
          G_INDENT5 ||', l_sysdate' || g_newline ||
          G_INDENT5 ||', L_USER_ID' || g_newline ||
          G_INDENT5 ||', L_USER_ID' || g_newline ||
          G_INDENT5 ||', L_REQUEST_ID' || g_newline ||
          G_INDENT5 ||', L_PROGRAM_APPL_ID' || g_newline ||
          G_INDENT5 ||', L_PROGRAM_ID' || g_newline ||
          G_INDENT5 ||', l_sysdate' || g_newline ||
          G_INDENT5 ||', ILV2.terr_id' || g_newline ||
          G_INDENT5 ||', ILV2.absolute_rank' || g_newline ||
          G_INDENT5 ||', ILV2.top_level_terr_id' || g_newline ||
          G_INDENT5 ||', ILV2.num_winners' || g_newline ||
          G_INDENT5 ||', ILV2.org_id' || g_newline ;

       lp_SELECT_cols :=
          G_INDENT5 || 'A.trans_object_id, A.trans_detail_object_id, ' || g_newline ||
          -- eihsu 06/19/2003 worker_id
          G_INDENT5 || 'A.worker_id, ' || g_newline ||
          G_INDENT5 || 'A.header_id1, A.header_id2, ' || g_newline ||
          G_INDENT5 || 'ILV.terr_id, ILV.absolute_rank, ' || g_newline ||
          G_INDENT5 || 'ILV.top_level_terr_id, ILV.num_winners, ILV.org_id ';
    END IF;


      JTF_TAE_GEN_PVT.write_buffer_content(
        l_qual_rules => l_select_ilv2 || ' FROM ' ||g_newline ||
        G_INDENT5 || '( SELECT /*+ NO_MERGE USE_CONCAT */ ' || g_newline
       );

      lx_663217_sql := lp_SELECT_cols || g_newline ||
        G_INDENT5 || '    FROM  JTF_TAE_1001_LEAD_TRANS  A, ' || g_newline ||
        G_INDENT5 || '   jtf_terr_qual_rules_mv Q1007R1, ' || g_newline ||
        G_INDENT5 || '   jtf_terr_qual_rules_mv Q1003R1, ' || g_newline ||

         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);

      JTF_TAE_GEN_PVT.write_buffer_content(
        l_qual_rules => lx_663217_sql
       );

       lx_663217_sql_1 :=
         G_INDENT5 || 'WHERE 1 = 1 ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
       lx_663217_sql_1 := lx_663217_sql_1 ||
         '  AND A.worker_id = P_WORKER_ID ' || g_newline;
    END IF;

    lx_663217_sql_1 := lx_663217_sql_1 ||
         G_INDENT5 || '      AND         ( Q1007R1.qual_usg_id = -1007 AND' || g_newline ||
         G_INDENT5 || '   Q1007R1.terr_id = ILV.terr_id )' || g_newline ||
         G_INDENT5 || '   AND (         ( a.squal_char06 = Q1007R1.low_value_char AND' || g_newline ||
         G_INDENT5 || '   Q1007R1.comparison_operator = ''='' )' || g_newline ||
         G_INDENT5 || '    OR' || g_newline ||
         G_INDENT5 || '           ( a.squal_char06 LIKE Q1007R1.low_value_char AND' || g_newline ||
         G_INDENT5 || '   Q1007R1.comparison_operator = ''LIKE'' )' || g_newline ||
         G_INDENT5 || '    OR' || g_newline ||
         G_INDENT5 || '           ( a.squal_char06 <= Q1007R1.high_value_char AND' || g_newline ||
         G_INDENT5 || '   a.squal_char06 >= Q1007R1.low_value_char AND' || g_newline ||
         G_INDENT5 || '   Q1007R1.comparison_operator = ''BETWEEN'' )' || g_newline ||
         G_INDENT5 || '        )' || g_newline ||
         G_INDENT5 || '   AND         ( Q1003R1.qual_usg_id = -1003 AND' || g_newline ||
         G_INDENT5 || '   Q1003R1.terr_id = ILV.terr_id )' || g_newline ||
         G_INDENT5 || '   AND (         ( a.squal_char07 = Q1003R1.low_value_char AND' || g_newline ||
         G_INDENT5 || '   Q1003R1.comparison_operator = ''='' )' || g_newline ||
         G_INDENT5 || '        ) ) ILV2,' || g_newline ||
         G_INDENT5 || '    AS_SALES_LEAD_LINES ASLLP,' || g_newline ||
         G_INDENT5 || '   (SELECT /*+ NO_MERGE */' || g_newline ||
         G_INDENT5 || '           Q1018R1.secondary_interest_code_id,' || g_newline ||
         G_INDENT5 || '                      Q1018R1.primary_interest_code_id,' || g_newline ||
         G_INDENT5 || '                      Q1018R1.interest_type_id' || g_newline ||
         G_INDENT5 || '                    , ILV.terr_id' || g_newline ||
         G_INDENT5 || '                    , ILV.top_level_terr_id' || g_newline ||
         G_INDENT5 || '                    , ILV.absolute_rank' || g_newline ||
         G_INDENT5 || '                    , ILV.num_winners' || g_newline ||
         G_INDENT5 || '                    , ILV.org_id' || g_newline ||
         G_INDENT5 || '               FROM  jtf_terr_qual_rules_mv Q1018R1, ' || g_newline;

       JTF_TAE_GEN_PVT.write_buffer_content(
        l_qual_rules => lx_663217_sql_1
       );

         /* STATIC INLINE VIEW */
         JTF_TAE_GEN_PVT.write_buffer_content(
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch)
         );

       lx_663217_sql_2 :=
         G_INDENT5 || '         WHERE 1 = 1 ' || g_newline ||

         G_INDENT5 || '           AND Q1018R1.qual_usg_id = -1018' || g_newline ||
         G_INDENT5 || '           AND Q1018R1.terr_id = ILV.terr_id' || g_newline ||
         G_INDENT5 || '           AND Q1018R1.comparison_operator = ''='' ) ILV_INTEREST' || g_newline ||
         G_INDENT5 || 'WHERE asllp.sales_lead_id = ILV2.trans_object_id' || g_newline ||
         G_INDENT5 || '  AND ( ILV_INTEREST.secondary_interest_code_id IS NULL' || g_newline ||
         G_INDENT5 || '        OR (ASLLP.secondary_interest_code_id = ILV_INTEREST.secondary_interest_code_id)' || g_newline ||
         G_INDENT5 || '       )' || g_newline ||
         G_INDENT5 || '  AND ( ILV_INTEREST.primary_interest_code_id IS NULL' || g_newline ||
         G_INDENT5 || '        OR (ASLLP.primary_interest_code_id = ILV_INTEREST.primary_interest_code_id )' || g_newline ||
         G_INDENT5 || '       )' || g_newline ||
         G_INDENT5 || '  AND ASLLP.interest_type_id =  ILV_INTEREST.interest_type_id' || g_newline ||
         G_INDENT5 || '  AND ILV_INTEREST.terr_id = ILV2.terr_id ;' || g_newline;


RETURN lx_663217_sql_2;
EXCEPTION
WHEN OTHERS THEN
     g_ProgramStatus := 1;
         JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'ERROR: JTF_TAE_SQL_LIBRARY_PVT.add_663217_SQL');

END add_663217_SQL;


/*********************************************************
** ARPATEL: 04/15/2004
** Function to return customer name range GROUP + Postal Code + Country SQL
*********************************************************/
FUNCTION add_353393_SQL( p_trans_object_type_id   IN   NUMBER
                     , p_table_name               IN   VARCHAR2
                     -- dblee 08/26/03 added new mode flag
                     , p_new_mode_fetch           IN   CHAR)
RETURN VARCHAR2 AS

   lp_close_outermost_ILV      VARCHAR2(255);
   lp_SELECT_cols              VARCHAR2(32767) := NULL;
   lx_353393_sql               VARCHAR2(32767) := NULL;
   lx_353393_sql_1             VARCHAR2(32767) := NULL;
   lx_353393_sql_2             VARCHAR2(32767) := NULL;
   lx_353393_sql_3             VARCHAR2(32767) := NULL;
   lp_pc_cntry_predicate_eq    VARCHAR2(32767) := NULL;
   lp_pc_cntry_predicate       VARCHAR2(32767) := NULL;
   lp_pc_cntry_predicate_btwn  VARCHAR2(32767) := NULL;
   l_sql                       VARCHAR2(32767) := NULL;
BEGIN

    -- dblee: 08/27/03 new mode support
    IF p_new_mode_fetch = 'Y' THEN
       lp_SELECT_cols :=
          /* ARPATEL: 01/15/2004 bug#3373462 */
           G_INDENT5 || '       A.TRANS_OBJECT_ID' || g_newline ||
            G_INDENT5 || '       , A.TRANS_DETAIL_OBJECT_ID' || g_newline ||
            G_INDENT5 || '       , A.HEADER_ID1' || g_newline ||
            G_INDENT5 || '       , A.HEADER_ID2' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_FC01' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_FC02' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_FC03' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_FC04' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_FC05' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CURC01' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CURC02' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CURC03' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CURC04' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CURC05' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CURC06' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CURC07' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CURC08' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CURC09' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CURC10' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR01' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR02' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR03' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR04' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR05' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR06' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR07' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR08' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR09' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR10' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR11' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR12' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR13' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR14' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR15' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR16' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR17' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR18' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR19' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR20' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR21' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR22' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR23' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR24' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR25' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR26' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR27' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR28' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR30' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR31' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR32' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR33' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR34' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR35' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR36' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR37' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR38' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR39' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR40' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR41' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR42' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR43' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR44' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR45' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR46' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR47' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR48' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR49' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR50' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR51' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR52' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR53' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR54' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR55' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR56' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR57' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR58' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR59' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_CHAR60' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM01' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM02' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM03' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM04' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM05' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM06' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM07' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM08' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM09' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM10' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM11' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM12' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM13' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM14' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM15' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM16' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM17' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM18' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM19' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM20' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM21' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM22' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM23' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM24' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM25' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM26' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM27' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM28' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM29' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM30' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM31' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM32' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM33' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM34' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM35' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM36' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM37' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM38' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM39' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM40' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM41' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM42' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM43' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM44' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM45' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM46' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM47' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM48' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM49' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM50' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM51' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM52' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM53' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM54' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM55' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM56' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM57' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM58' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM59' || g_newline ||
            G_INDENT5 || '       , A.SQUAL_NUM60' || g_newline ||
            G_INDENT5 || '       , A.ASSIGNED_FLAG' || g_newline ||
            G_INDENT5 || '       , A.PROCESSED_FLAG' || g_newline ||
            G_INDENT5 || '       , A.ORG_ID' || g_newline ||
            G_INDENT5 || '       , A.SECURITY_GROUP_ID' || g_newline ||
            G_INDENT5 || '       , A.OBJECT_VERSION_NUMBER' || g_newline ||
            G_INDENT5 || '       , A.WORKER_ID' || g_newline ;

       lp_close_outermost_ILV := ') A;  ';
    ELSE
       lp_SELECT_cols :=
          G_INDENT5 || 'A.trans_object_id, A.trans_detail_object_id, ' || g_newline ||
          -- eihsu: 06/19/2003 worker_id
          G_INDENT5 || 'A.worker_id, ' || g_newline ||
          G_INDENT5 || 'A.header_id1, A.header_id2, ' || g_newline ||
          G_INDENT5 || 'ILV.terr_id, ILV.absolute_rank, ' || g_newline ||
          G_INDENT5 || 'ILV.top_level_terr_id, ILV.num_winners, ILV.org_id ';

          lp_close_outermost_ILV := ') ILV; ';
    END IF;

    lp_pc_cntry_predicate := '   1 = 1 ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
       lp_pc_cntry_predicate := lp_pc_cntry_predicate ||
         '  AND A.worker_id = P_WORKER_ID ' || g_newline;
    END IF;

    lp_pc_cntry_predicate := lp_pc_cntry_predicate ||
         G_INDENT5 || '  AND Q1007R1.qual_usg_id = -1007 ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND    ( ' || g_newline ||
         G_INDENT5 || '        ( a.squal_char06 LIKE Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''LIKE'' ) ' || g_newline ||
         G_INDENT5 || '        OR ' || g_newline ||
         G_INDENT5 || '        ( a.squal_char06 = Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '        OR ' || g_newline ||
         G_INDENT5 || '      ( a.squal_char06 <= Q1007R1.high_value_char AND ' || g_newline ||
         G_INDENT5 || '          a.squal_char06 >= Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''BETWEEN'' ) ' || g_newline ||
         G_INDENT5 || '      ) ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.qual_usg_id = -1003 ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.terr_id = ILV.terr_id  ' || g_newline ||
         G_INDENT5 || '  AND ( a.squal_char07 = Q1003R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1003R1.comparison_operator = ''='' ) ' || g_newline;

    lp_pc_cntry_predicate_eq := '   1 = 1 ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
       lp_pc_cntry_predicate_eq := lp_pc_cntry_predicate_eq ||
         '  AND A.worker_id = P_WORKER_ID ' || g_newline;
    END IF;

    lp_pc_cntry_predicate_eq := lp_pc_cntry_predicate_eq ||
         G_INDENT5 || '  AND   ( a.squal_char06 = Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.qual_usg_id = -1007 ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND  Q1007R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||
         G_INDENT5 || '  AND ( a.squal_char07 = Q1003R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1003R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.qual_usg_id = -1003 ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.terr_id = ILV.terr_id  ' || g_newline ;

    lp_pc_cntry_predicate_btwn := '   1 = 1 ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
       lp_pc_cntry_predicate_btwn := lp_pc_cntry_predicate_btwn ||
         '  AND A.worker_id = P_WORKER_ID ' || g_newline;
    END IF;

    lp_pc_cntry_predicate_btwn := lp_pc_cntry_predicate_btwn ||
         G_INDENT5 || '  AND   ( a.squal_char06 <= Q1007R1.high_value_char AND ' || g_newline ||
         G_INDENT5 || '          a.squal_char06 >= Q1007R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '          Q1007R1.comparison_operator = ''BETWEEN'' ) ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.qual_usg_id = -1007 ' || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND  Q1007R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||
         G_INDENT5 || '  AND ( a.squal_char07 = Q1003R1.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1003R1.comparison_operator = ''='' ) ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.qual_usg_id = -1003 ' || g_newline ||
         G_INDENT5 || '  AND  Q1003R1.terr_id = ILV.terr_id  ' || g_newline ;

    --ARPATEL 10/14 bug#3194930
    JTF_TAE_GEN_PVT.write_buffer_content(
      l_qual_rules => G_INDENT || add_SELECT_clause(p_new_mode_fetch) || g_newline
   );

    lx_353393_sql := lx_353393_sql ||
         --ARPATEL 10/14 bug#3194930
         --G_INDENT || add_SELECT_clause(p_new_mode_fetch) || g_newline ||
         G_INDENT || 'FROM ( ' || g_newline;

         /* START OF INLINE VIEW WITH 4 UNION ALLS */

         /************************/
         /*  = XYZ               */
         /************************/
    IF p_new_mode_fetch <> 'Y' THEN
      lx_353393_sql := lx_353393_sql ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1102R1 A) ' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
                  /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                        '_324347_ND)' || g_newline ||

         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1102R1 JTF_TERR_CNRG_EQUAL_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline;
    ELSE
      lx_353393_sql := lx_353393_sql ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           NO_MERGE ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline;
    END IF;

      lx_353393_sql := lx_353393_sql ||
         /* Add SELECT columns */
         lp_SELECT_cols || g_newline ||

         G_INDENT5 || 'FROM ';

    IF p_new_mode_fetch = 'Y' THEN
       lx_353393_sql := lx_353393_sql ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_353393_sql := lx_353393_sql ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_353393_sql := lx_353393_sql ||
         G_INDENT5 || '   ,  JTF_TERR_CNRG_EQUAL_MV Q1102R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate || g_newline ||
         G_INDENT5 || '  AND Q1007R1.terr_id = Q1102R1.terr_id ' || g_newline ||
         G_INDENT5 || '  AND ( Q1102R1.comparison_operator = ''='' AND ' || g_newline ||
         G_INDENT5 || '        a.squal_fc01 = SUBSTR(Q1102R1.low_value_char, 1, 1) AND ' || g_newline ||
         G_INDENT5 || '        a.squal_char01 = Q1102R1.low_value_char ' || g_newline ||
         G_INDENT5 || '       ) ' || g_newline ||
         G_INDENT5 || '  AND Q1102R1.qual_usg_id = -1102  ' || g_newline ||
         G_INDENT5 || '  AND Q1102R1.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND  Q1102R1.TERR_ID = Q1003R1.TERR_ID ' || g_newline ||


         G_INDENT5 || 'UNION ALL ' || g_newline ||

         /************************/
         /*  LIKE XYZ%           */
         /************************/

         G_INDENT5 || 'SELECT /*+ ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
      lx_353393_sql := lx_353393_sql ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1102LK A)  ' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||

         /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                      '_324347_ND)' || g_newline ||
         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1102LK JTF_TERR_CNRG_LIKE_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline;
    ELSE
      lx_353393_sql := lx_353393_sql ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           NO_MERGE ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline;
    END IF;

      lx_353393_sql := lx_353393_sql ||
         /* Add SELECT columns */
         lp_SELECT_cols || g_newline ||

         G_INDENT5 || 'FROM    ';

    IF p_new_mode_fetch = 'Y' THEN
       lx_353393_sql := lx_353393_sql ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_353393_sql := lx_353393_sql ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_353393_sql := lx_353393_sql ||
         G_INDENT5 || '   ,  jtf_terr_cnrg_like_mv Q1102LK ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate || g_newline ||

         G_INDENT5 || '  AND Q1007R1.terr_id = Q1102LK.terr_id ' || g_newline ||
         G_INDENT5 || '  AND      a.squal_char01 LIKE Q1102LK.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        a.squal_fc01 = Q1102LK.first_char ' || g_newline ||
         G_INDENT5 || '  AND      Q1102LK.qual_usg_id = -1102 ' || g_newline ||
         G_INDENT5 || '  AND Q1102LK.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || 'UNION ALL ' || g_newline --||
         ;

        --ARPATEL 10/14 bug#3194930
        JTF_TAE_GEN_PVT.write_buffer_content(
                   l_qual_rules => lx_353393_sql
         );

         /************************/
         /*  LIKE %XYZ           */
         /************************/

      lx_353393_sql_1 :=
         G_INDENT5 || 'SELECT /*+ ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
      lx_353393_sql_1 := lx_353393_sql_1 ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1102LK A)  ' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                        '_324347X_ND)' || g_newline ||
         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1102LK JTF_TERR_CNRG_LIKE_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline;
    ELSE
      lx_353393_sql_1 := lx_353393_sql_1 ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           NO_MERGE ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline;
    END IF;

      lx_353393_sql_1 := lx_353393_sql_1 ||
         /* Add SELECT columns */
         lp_SELECT_cols || g_newline ||

         G_INDENT5 || 'FROM   ';

    IF p_new_mode_fetch = 'Y' THEN
       lx_353393_sql_1 := lx_353393_sql_1 ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_353393_sql_1 := lx_353393_sql_1 ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_353393_sql_1 := lx_353393_sql_1 ||
         G_INDENT5 || '   ,  jtf_terr_cnrg_like_mv Q1102LK ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate_eq || g_newline ||

         G_INDENT5 || '  AND Q1007R1.terr_id = Q1102LK.terr_id ' || g_newline ||
         G_INDENT5 || '  AND      a.squal_char01 LIKE Q1102LK.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1102LK.first_char = ''%'' ' || g_newline ||
         G_INDENT5 || '  AND Q1102LK.qual_usg_id = -1102 ' || g_newline ||
         G_INDENT5 || '  AND Q1102LK.terr_id = ILV.terr_id ' || g_newline;

        JTF_TAE_GEN_PVT.write_buffer_content(
                   l_qual_rules => lx_353393_sql_1
         );

    lx_353393_sql_2 :=
         G_INDENT5 || 'UNION ALL ' || g_newline ||
         G_INDENT5 || 'SELECT /*+ ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
      lx_353393_sql_2 := lx_353393_sql_2 ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1102LK A)  ' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                        '_324347X_ND)' || g_newline ||
         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1102LK JTF_TERR_CNRG_LIKE_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline;
    ELSE
      lx_353393_sql_2 := lx_353393_sql_2 ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           NO_MERGE ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline;
    END IF;

      lx_353393_sql_2 := lx_353393_sql_2 ||
         /* Add SELECT columns */
         lp_SELECT_cols || g_newline ||

         G_INDENT5 || 'FROM   ';

    IF p_new_mode_fetch = 'Y' THEN
       lx_353393_sql_2 := lx_353393_sql_2 ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_353393_sql_2 := lx_353393_sql_2 ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_353393_sql_2 := lx_353393_sql_2 ||
         G_INDENT5 || '   ,  jtf_terr_cnrg_like_mv Q1102LK ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate_btwn || g_newline ||

         G_INDENT5 || '  AND Q1007R1.terr_id = Q1102LK.terr_id ' || g_newline ||
         G_INDENT5 || '  AND      a.squal_char01 LIKE Q1102LK.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        Q1102LK.first_char = ''%'' ' || g_newline ||
         G_INDENT5 || '  AND Q1102LK.qual_usg_id = -1102 ' || g_newline ||
         G_INDENT5 || '  AND Q1102LK.terr_id = ILV.terr_id ' || g_newline;

        JTF_TAE_GEN_PVT.write_buffer_content(
                   l_qual_rules => lx_353393_sql_2
         );

    lx_353393_sql_3 :=
         G_INDENT5 || 'UNION ALL ' || g_newline ||

         G_INDENT5 || 'SELECT /*+ ' || g_newline;

    IF p_new_mode_fetch <> 'Y' THEN
      lx_353393_sql_3 := lx_353393_sql_3 ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           USE_NL(ILV Q1003R1 Q1007R1 Q1102BT A) ' || g_newline ||
         G_INDENT5 || '           INDEX(ILV JTF_TERR_DENORM_RULES_N4) ' || g_newline ||
         /* DYNAMIC HINT BASED ON TRANSACTION TYPE */
         G_INDENT5 || '           INDEX(A JTF_TAE_TN' || ABS(p_trans_object_type_id) ||
                                                        '_324347_ND)' || g_newline ||

         G_INDENT5 || '           INDEX(Q1003R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1007R1 JTF_TERR_QUAL_RULES_MV_N10) ' || g_newline ||
         G_INDENT5 || '           INDEX(Q1102BT JTF_TERR_CNRG_BTWN_MV_N10) ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline;
    ELSE
      lx_353393_sql_3 := lx_353393_sql_3 ||
         G_INDENT5 || '           ORDERED ' || g_newline ||
         G_INDENT5 || '           USE_CONCAT ' || g_newline ||
         G_INDENT5 || '           NO_MERGE ' || g_newline ||
         G_INDENT5 || '       */ ' || g_newline;
    END IF;

      lx_353393_sql_3 := lx_353393_sql_3 ||
         /* Add SELECT columns */
         lp_SELECT_cols || g_newline ||

         G_INDENT5 || 'FROM   ';

    IF p_new_mode_fetch = 'Y' THEN
       lx_353393_sql_3 := lx_353393_sql_3 ||
         /* STATIC INLINE VIEW */
         add_ILV_with_NOMERGE_hint(l_sql, p_new_mode_fetch);
    ELSE
       lx_353393_sql_3 := lx_353393_sql_3 ||
         /* STATIC INLINE VIEW */
         add_ILV(l_sql, p_new_mode_fetch);
    END IF;

    lx_353393_sql_3 := lx_353393_sql_3 ||
         G_INDENT5 || '   ,  jtf_terr_cnrg_btwn_mv Q1102BT ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1007R1 ' || g_newline ||
         G_INDENT5 || '   ,  jtf_terr_qual_rules_mv Q1003R1 ' || g_newline ||

         /* DYNAMIC BASED ON TRANSACTION TYPE */
         G_INDENT || '    ,' || P_TABLE_NAME || ' A ' || g_newline ||

         G_INDENT5 || 'WHERE ' || g_newline ||

         lp_pc_cntry_predicate || g_newline ||

         G_INDENT5 || '  AND Q1007R1.terr_id = Q1102BT.terr_id ' || g_newline ||
         G_INDENT5 || '  AND      a.squal_char01 <= Q1102BT.high_value_char AND ' || g_newline ||
         G_INDENT5 || '        a.squal_char01 >= Q1102BT.low_value_char AND ' || g_newline ||
         G_INDENT5 || '        a.squal_fc01 >= SUBSTR(Q1102BT.low_value_char, 1, 1) ' || g_newline ||
         G_INDENT5 || '  AND Q1102BT.qual_usg_id = -1102 ' || g_newline ||
         G_INDENT5 || '  AND Q1102BT.terr_id = ILV.terr_id ' || g_newline ||
         G_INDENT5 || '  AND Q1102BT.terr_id = Q1003R1.terr_id ' || g_newline ||

         /* END OF INLINE VIEW WITH 4 UNION ALLS */
         G_INDENT || lp_close_outermost_ILV || g_newline;

  return lx_353393_sql_3;
EXCEPTION
WHEN OTHERS THEN
     g_ProgramStatus := 1;
         JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'ERROR: JTF_TAE_SQL_LIBRARY_PVT.add_353393_SQL');

END add_353393_SQL;


/*************************************************
** Gets the Static pre-built, hand-tuned SQL
** for certain Qualifier Combinations
**************************************************/
PROCEDURE get_qual_comb_sql (
      p_rel_prod                  IN   NUMBER,
      p_source_id                 IN   NUMBER,
      p_trans_object_type_id      IN   NUMBER,
      p_table_name                IN   VARCHAR2,
      /* ARPATEL 03/11/2004 BUG#3489240 */
      p_match_table_name          IN   VARCHAR2 := NULL,
      -- dblee: 08/26/03 added new mode flag
      p_new_mode_fetch            IN   CHAR := 'N',
      x_sql                       OUT NOCOPY  VARCHAR2)  AS

   l_sql        VARCHAR2(32767);

BEGIN

   /* Postal Code + Country Combination */
   IF ( p_rel_prod = 4841 ) THEN

      x_sql := add_4841_SQL( p_trans_object_type_id => p_trans_object_type_id
                           , p_table_name           => p_table_name
                           /* ARPATEL 03/11/2004 BUG#3489240 */
                           , p_match_table_name     => p_match_table_name
                           -- dblee: 08/26/03 added new mode flag
                           , p_new_mode_fetch       => p_new_mode_fetch );

   /* Customer Name Range + Postal Code + Country Combination */
   ELSIF ( p_rel_prod = 324347 ) THEN

      x_sql := add_324347_SQL( p_trans_object_type_id => p_trans_object_type_id
                             , p_table_name           => p_table_name
                             -- dblee: 08/26/03 added new mode flag
                             , p_new_mode_fetch       => p_new_mode_fetch );

    /* oppor exp. purchase + Customer Name Range + Postal Code + Country Combination */
   ELSIF ( p_rel_prod = 45084233 ) THEN

      x_sql := add_45084233_SQL( p_trans_object_type_id => p_trans_object_type_id
                             , p_table_name           => p_table_name
                             -- dblee: 08/26/03 added new mode flag
                             , p_new_mode_fetch       => p_new_mode_fetch );

    /* oppor product category + Customer Name Range + Postal Code + Country Combination */
   ELSIF ( p_rel_prod = 62598971 ) THEN

      x_sql := add_62598971_SQL( p_trans_object_type_id => p_trans_object_type_id
                             , p_table_name           => p_table_name
                             -- dblee: 08/26/03 added new mode flag
                             , p_new_mode_fetch       => p_new_mode_fetch );

   /* opportunity product category + Postal Code + Country Combination */
   ELSIF ( p_rel_prod = 934313 ) THEN

      x_sql := add_934313_SQL( p_trans_object_type_id => p_trans_object_type_id
                             , p_table_name           => p_table_name
                             , p_new_mode_fetch       => p_new_mode_fetch );

   /* lead exp. purchase +Customer Name Range + Postal Code + Country Combination */
   ELSIF ( p_rel_prod = 44435539 ) THEN

      x_sql := add_44435539_SQL( p_trans_object_type_id => p_trans_object_type_id
                             , p_table_name           => p_table_name
                             -- dblee: 08/26/03 added new mode flag
                             , p_new_mode_fetch       => p_new_mode_fetch );

   /* lead product category + Customer Name Range + Postal Code + Country Combination */
   ELSIF ( p_rel_prod = 61950277 ) THEN

      x_sql := add_61950277_SQL( p_trans_object_type_id => p_trans_object_type_id
                             , p_table_name           => p_table_name
                             -- dblee: 08/26/03 added new mode flag
                             , p_new_mode_fetch       => p_new_mode_fetch );

   /* lead product category + Postal Code + Country Combination */
   ELSIF ( p_rel_prod = 924631 ) THEN

      x_sql := add_924631_SQL( p_trans_object_type_id => p_trans_object_type_id
                             , p_table_name           => p_table_name
                             -- dblee: 08/26/03 added new mode flag
                             , p_new_mode_fetch       => p_new_mode_fetch );

   /* lead interest type + Postal Code + Country Combination */
   ELSIF ( p_rel_prod = 663217 ) THEN

      x_sql := add_663217_SQL( p_trans_object_type_id => p_trans_object_type_id
                             , p_table_name           => p_table_name
                             -- dblee: 08/26/03 added new mode flag
                             , p_new_mode_fetch       => p_new_mode_fetch );

   /* Customer Name Range GROUP + Postal Code + Country Combination */
   ELSIF ( p_rel_prod = 353393 ) THEN

      x_sql := add_353393_SQL( p_trans_object_type_id => p_trans_object_type_id
                             , p_table_name           => p_table_name
                             -- dblee: 08/26/03 added new mode flag
                             , p_new_mode_fetch       => p_new_mode_fetch );

   END IF;



EXCEPTION
      WHEN OTHERS THEN
         g_ProgramStatus := 1;
         JTF_TAE_CONTROL_PVT.WRITE_LOG(2, 'ERROR: JTF_TAE_SQL_LIBRARY_PVT.get_qual_comb_sql');

END get_qual_comb_sql;


END JTF_TAE_SQL_LIB_PVT;

/
