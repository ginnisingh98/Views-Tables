--------------------------------------------------------
--  DDL for Package Body JTF_TAE_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TAE_GEN_PVT" AS
/* $Header: jtfvtaeb.pls 120.0 2005/06/02 18:22:34 appldev ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TAE_GEN_PVT
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager public api's.
--      This package is used to generate the complete territory
--      Engine based on tha data setup in the JTF TAE tables
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is available for private use only
--
--    HISTORY
--      02/25/02    SBEHERA  Created
--      04/09/02    SBEHERA changed spec  for generate_api
--      04/16/02    SBEHERA added distinct
--      05/02/02    SBEHERA added AND in the statement
--      05/15/02    SBEHERA append was modified
--      06/03/02    SBEHERA added code for relation_product 73(cnr group)
--      06/03/03    EIHSU   worker_id conditions added
--      06/04/03    EIHSU   worker_id removed from ILV1
--      06/20/03    EIHSU   worker_id order in sel
--      03/08/04    ACHANDA Bug 3380047
--      04/15/04    ARPATEL Added static SQL for qual_relation_product=353393
--      06/25/04    ACHANDA Bug 3718223
--      08/17/04    ACHANDA Bug 3835831
--      12/08/04    ACHANDA Bug 4048033 : added special processing for qual comb 61950277 and 62598971
--      02/24/05    ACHANDA Bug 4192854 : added special processing for qual comb 934313 and 924631
--      04/12/05    ACHANDA Bug 4307593 : remove the worker_id condition from NMC_DYN package
--      05/17/05    ACHANDA Bug 4385668 : modify the procedure append_inline_view so that new mode inline view
--                                        contains NO_MERGE hint and DISTINCT clause
--    End of Comments
--

/*------------------------------------------------------

---------------------------------------------------------*/

--------------------------------------------------
---     GLOBAL Declarations Starts here      -----
--------------------------------------------------

-- Stores the org_id for use in package Names
   g_cached_org_append           VARCHAR2(15);
--
-- Identifies the Package associated a
-- a territory with child nodes
   g_terr_pkgspec                terr_pkgspec_tbl_type;

-- Stores the position with the table spec
   g_stack_pointer               NUMBER := 0;

-- Store the information passed as
-- Concurrent program parameters
-- Module that uses Territories
   g_source_id                   NUMBER := 0;

   g_abs_source_id               NUMBER := 0;

-- Type of transaction for which the
-- the package is being generated
   g_qualifier_type              VARCHAR2(60);

-- Id of the corresponding transaction type
   g_qual_type_id                NUMBER := 0;

   TYPE t_pkgname IS TABLE OF VARCHAR2(256)
      INDEX BY BINARY_INTEGER;

   g_pkgname_tbl                 t_pkgname;
   g_Pointer                     NUMBER   := 0;
   G_Debug                       BOOLEAN  := FALSE;
   g_ProgramStatus               NUMBER   := 0;

   /* jdochert: 05/01/02 */
   G_DYN_PKG_NAME VARCHAR2(30) := NULL;

   /* jdochert: 07/31/02 */
   G_NEWLINE        VARCHAR2(30) := FND_GLOBAL.Local_Chr(10);
   G_INDENT         VARCHAR2(30) := '            ';
   G_INDENT1        VARCHAR2(30) := '    ';

   /* dblee: 08/20/03 - define global variable for holding select clause which differs
        between 'full' mode and 'new mode' TAP */
   k_select_list_fm  CONSTANT VARCHAR2(240) :=
       'SELECT a.trans_object_id,a.trans_detail_object_id,a.worker_id,a.header_id1,a.header_id2,'
          || 'ILV.terr_id,ILV.absolute_rank,ILV.top_level_terr_id ,ILV.num_winners,ILV.org_id ';

   k_select_list_nm  CONSTANT VARCHAR2(240) :=
       'SELECT A.*,ILV.terr_id,ILV.absolute_rank,ILV.top_level_terr_id ,ILV.num_winners  ';

   g_select_list_1   VARCHAR2(240) := k_select_list_fm;

   --------------------------------------------------------------------
   --                  Logging PROCEDURE
   --
   --     which = 1. write to log
   --     which = 2, write to output
   --------------------------------------------------------------------
   --
   PROCEDURE Write_Log(which number, mssg  varchar2 )
   IS
   BEGIN
   --
       --dbms_output.put_line(' LOG: ' || mssg );
       FND_FILE.put(which, mssg);
       FND_FILE.NEW_LINE(which, 1);
       --
       -- If the output message and if debug flag is set then also write
       -- to the log file
       --
       IF Which = 2 THEN
          IF G_Debug THEN
             FND_FILE.put(1, mssg);
             FND_FILE.NEW_LINE(1, 1);
          END IF;
       END IF;
   --
   END Write_Log;

   FUNCTION build_predicate_for_operator(
                 op_common_where VARCHAR2
                ,op_eql VARCHAR2
                ,op_lss_thn VARCHAR2
                ,op_lss_thn_eql VARCHAR2
                ,op_grtr_thn VARCHAR2
                ,op_grtr_thn_eql VARCHAR2
                ,op_like VARCHAR2
                ,op_between VARCHAR2
                ,l_newline VARCHAR2)
      RETURN VARCHAR2
   AS
      l_result         VARCHAR2(32767);

   BEGIN
      --dbms_output.put_line('Inside Call_Create_Package PACKAGE_NAME - ' || 'x' || ' g_pointer - ' || to_char(g_pointer - 1) || 'x' || 'x');
      IF G_Debug THEN
         Write_Log(1, 'INSIDE function JTF_TAE_GEN_PVT.build_predicate_for_operator: ' );
      END IF;

      l_result := op_common_where;

      IF op_eql IS NOT NULL THEN
         l_result := 'AND ' || l_result || l_newline || 'AND ( ' || op_eql;
      END IF;

      IF op_lss_thn IS NOT NULL THEN
         IF l_result = op_common_where THEN
            l_result := 'AND  ' || l_result || l_newline || 'AND ( ' || op_lss_thn;
         ELSE
            l_result := l_result || l_newline || ' OR ' || l_newline || op_lss_thn;
         END IF;
      END IF;

      IF op_lss_thn_eql IS NOT NULL THEN
         IF l_result = op_common_where THEN
            l_result := 'AND ' || l_result || l_newline || 'AND ( ' || op_lss_thn_eql;
         ELSE
            l_result := l_result || l_newline || ' OR ' || l_newline || op_lss_thn_eql;
         END IF;
      END IF;

      IF op_grtr_thn IS NOT NULL THEN
         IF l_result = op_common_where THEN
            l_result := 'AND ' || l_result || l_newline ||  'AND ( ' || op_grtr_thn;
         ELSE
            l_result := l_result || l_newline || ' OR ' || l_newline || op_grtr_thn;
         END IF;
      END IF;

      IF op_grtr_thn_eql IS NOT NULL THEN
         IF l_result = op_common_where THEN
            l_result := 'AND  ' || l_result || l_newline || 'AND ( ' || op_grtr_thn_eql;
         ELSE
            l_result := l_result || l_newline || ' OR ' || l_newline || op_grtr_thn_eql;
         END IF;
      END IF;

      IF op_like IS NOT NULL THEN
         IF  l_result = op_common_where THEN
            l_result := 'AND ' || l_result || l_newline ||  'AND ( ' || op_like;
         ELSE
            l_result := l_result || l_newline || ' OR ' || l_newline|| op_like;
         END IF;
      END IF;

      IF op_between IS NOT NULL THEN
         IF l_result = op_common_where THEN
            l_result := 'AND ' ||  l_result || l_newline || 'AND ( ' || op_between;
         ELSE
            l_result := l_result || l_newline || ' OR ' || l_newline || op_between;
         END IF;
      END IF;

      l_result := l_result || l_newline || '     )' || l_newline;

      RETURN l_result;

   EXCEPTION
      WHEN OTHERS THEN
         IF G_Debug THEN
            g_ProgramStatus := 1;
            Write_Log(2, 'Program terminated with OTHERS exception. ' || SQLERRM);
         END IF;
   END build_predicate_for_operator;


   ----------------------------------------------------------------
   --         Store the Line for the package to a table
   ----------------------------------------------------------------
   PROCEDURE Add_To_PackageTable(p_statement IN VARCHAR2)
   AS
   BEGIN
      --dbms_output.put_line( p_statement );

      ad_ddl.build_package(p_statement, g_pointer);

      --Increment the counters
      g_pointer := g_pointer + 1;

   EXCEPTION
      WHEN Others THEN
         NULL;
   END Add_To_PackageTable;


   ----------------------------------------------------------------
   --             Create the package using AD_DDL command
   ----------------------------------------------------------------
   FUNCTION Call_Create_Package(
         is_package_body  VARCHAR2,
         package_name     VARCHAR2)
      RETURN BOOLEAN
   AS
      l_result         BOOLEAN;
      l_status         VARCHAR2(10);
      l_industry       VARCHAR2(10);
      l_applsys_schema VARCHAR2(30);

   BEGIN

      --dbms_output.put_line('Inside Call_Create_Package PACKAGE_NAME - ' || package_name || ' g_pointer - ' || to_char(g_pointer - 1) || is_package_body || is_package_body);
      IF G_Debug THEN
         Write_Log(1, 'INSIDE PROCEDURE JTF_TAE_GEN_PVT.Call_Create_Package: PACKAGE_NAME = ' || package_name );
      END IF;

      l_result := fnd_installation.get_app_info('FND',
                                                l_status,
                                                l_industry,
                                                l_applsys_schema);

      ad_ddl.create_package(l_applsys_schema,
                            'JTF',
                            package_name,
                            is_package_body,
                            0,
                            (g_pointer - 1));

      -- Reset the global pointer.
      g_Pointer := 0;

      RETURN TRUE;

   EXCEPTION
       WHEN OTHERS THEN
         /* ACHANDA 03/08/2004 : Bug 3380047 : if the package is not created successfully */
         /* because of lock , the program should write an informative message to the log  */
         /* file but it should not error out                                              */
         write_log(1, 'Package ' || package_name || ' NOT CREATED SUCCESSFULLY ');
         write_log(1, SQLERRM);
         g_pointer := 0;
         RETURN FALSE;
         /* the following code is commented out as the logic should be executed */
         /* irrespective of the fact whether the debug is set to Yes or No      */
         /*
           If G_Debug Then
              g_ProgramStatus := 1;
              Write_Log(2, 'Program terminated with OTHERS exception. ' || SQLERRM);
              g_Pointer := 0;
              RETURN FALSE;
           End If;
         */
   END Call_Create_Package;


   /*---------------------------------------------------------------
    This procedure will generate the PACKAGE
    SPEC or BODY controlled by a parameter

    eg: CREATE OR REPLACE PACKAGE      JTF_TERR_1001_LEAD_1_240 or
        CREATE OR REPLACE PACKAGE BODY JTF_TERR_1001_LEAD_1_240
   ---------------------------------------------------------------*/
   PROCEDURE generate_package_header(
      p_package_name   VARCHAR2,
      p_description    VARCHAR2,
      p_object_type    VARCHAR2
   )
   AS
      v_package_name   VARCHAR2(100);
   BEGIN

      v_package_name := LOWER(p_package_name);

      IF G_Debug THEN
         Write_Log(1, 'INSIDE PROCEDURE JTF_TAE_GEN_PVT.generate_package_header: v_package_name = ' || v_package_name );
      END IF;

      /* -- The description was commented out as part of AD_DDL error
         -- that caused others exception.
         -- ORA-20000: Unknown or unsupported object type in create_plsql_object()
         --
         -- Add_To_PackageTable (p_description);
      */

      IF p_object_type = 'PKS' THEN

         /* create package spec */
         --Add_To_PackageTable (p_description);
         Add_To_PackageTable (
            'CREATE OR REPLACE PACKAGE ' || v_package_name || ' AS '
         );
         Add_To_PackageTable (' ');

      ELSE

         /* create package body */
         --Add_To_PackageTable (p_description);
         Add_To_PackageTable (
            'CREATE OR REPLACE PACKAGE BODY ' || v_package_name || ' AS '
         );
         Add_To_PackageTable ('--');
         Add_To_PackageTable (' ');

      END IF;

   END generate_package_header;

   /*----------------------------------------------------------
     This procedure will add the the END package
     statement for the package name passed in as
     parameter

     eg:     END JTF_TERR_1001_LEAD_1_240;
     Note:   1001 - Source Id
             1    - Package Count
             240  - Org Id
    ----------------------------------------------------------*/
   PROCEDURE generate_end_of_package(p_package_name VARCHAR2, is_package_body VARCHAR2)
   AS
      v_package_name                VARCHAR2(100);
      l_Status                      BOOLEAN;
   BEGIN

      v_package_name := LOWER (p_package_name);

      IF G_Debug THEN
         Write_Log(1, 'INSIDE PROCEDURE JTF_TAE_GEN_PVT.generate_end_of_package: v_package_name = ' || v_package_name );
      END IF;

      Add_To_PackageTable (' ' );
      Add_To_PackageTable ('END ' || v_package_name || ';');
      Add_To_PackageTable ('/* End of package ' || v_package_name || ' */');

      /* Call the procedure to create the package using AD_DDL */
      l_Status := Call_Create_Package(is_package_body, v_package_name);

   END generate_end_of_package;

/*----------------------------------------------------------
  This procedure will add the END procedure
  statement for the procedure name passed in as
  parameter, e.g., END SEARCH_TERR_RULES;
 ----------------------------------------------------------*/
   PROCEDURE generate_end_of_procedure ( p_procedure_name    VARCHAR2
                                       , p_source_id         NUMBER
                                       , p_target_type       VARCHAR2)

   AS

      lp_pkg_name     VARCHAR2(30);

   BEGIN

      IF G_Debug THEN
         Write_Log(1, 'INSIDE PROCEDURE JTF_TAE_GEN_PVT.generate_end_of_procedure: p_procedure_name = ' || p_procedure_name );
      END IF;

      lp_pkg_name := 'JTF_TAE_'|| TO_CHAR(ABS(p_source_id)) ||'_' || p_target_type || '_DYN';

      --Add_To_PackageTable ('  ');
      --Add_To_PackageTable ('   /*--------------------------------------');
      --Add_To_PackageTable ('   ** When no territories, have NULL ');
      --Add_To_PackageTable ('   ** so that package is not invalid' );
      --Add_To_PackageTable ('   ** when it is created ');
      --Add_To_PackageTable ('   **--------------------------------------*/ ');
      --Add_To_PackageTable ('   NULL;');
      Add_To_PackageTable ('  ');
      Add_To_PackageTable ('EXCEPTION  ');
      Add_To_PackageTable ('  ');
      Add_To_PackageTable ('   WHEN VALUE_ERROR THEN  ');
      Add_To_PackageTable ('      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;');
      Add_To_PackageTable ('      FND_MSG_PUB.Add_Exc_Msg(''' || lp_pkg_name || ''', ''' || p_procedure_name || ''', ''EXCEPTION: VALUE_ERROR''); ');
      Add_To_PackageTable ('      FND_MSG_PUB.Add_Exc_Msg(''' || lp_pkg_name || ''', ''' || p_procedure_name || ''', SQLERRM); ');
      Add_To_PackageTable ('      JTF_TAE_CONTROL_PVT.WRITE_LOG(2, x_Msg_Data);');
      Add_To_PackageTable ('      ROLLBACK TO JTF_TAE_MATCHING_TRANSACTION; ');
      Add_To_PackageTable ('      RAISE; ');
      Add_To_PackageTable ('  ');
      Add_To_PackageTable ('   WHEN NO_DATA_FOUND THEN  ');
      Add_To_PackageTable ('      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;');
      Add_To_PackageTable ('      FND_MSG_PUB.Add_Exc_Msg(''' || lp_pkg_name || ''', ''' || p_procedure_name || ''', ''EXCEPTION: NO_DATA_FOUND''); ');
      Add_To_PackageTable ('      FND_MSG_PUB.Add_Exc_Msg(''' || lp_pkg_name || ''', ''' || p_procedure_name || ''', SQLERRM); ');
      Add_To_PackageTable ('      JTF_TAE_CONTROL_PVT.WRITE_LOG(2, x_Msg_Data);');
      Add_To_PackageTable ('      ROLLBACK TO JTF_TAE_MATCHING_TRANSACTION; ');
      Add_To_PackageTable ('      RAISE; ');
      Add_To_PackageTable ('  ');
      Add_To_PackageTable ('   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN  ');
      Add_To_PackageTable ('      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;');
      Add_To_PackageTable ('      FND_MSG_PUB.Add_Exc_Msg(''' || lp_pkg_name || ''', ''' || p_procedure_name || ''', ''EXCEPTION: FND_API.G_RET_STS_UNEXP_ERROR''); ');
      Add_To_PackageTable ('      FND_MSG_PUB.Add_Exc_Msg(''' || lp_pkg_name || ''', ''' || p_procedure_name || ''', SQLERRM); ');
      Add_To_PackageTable ('      JTF_TAE_CONTROL_PVT.WRITE_LOG(2, x_Msg_Data);');
      Add_To_PackageTable ('      ROLLBACK TO JTF_TAE_MATCHING_TRANSACTION; ');
      Add_To_PackageTable ('      RAISE; ');
      Add_To_PackageTable ('  ');

      Add_To_PackageTable ('   WHEN OTHERS THEN  ');
      Add_To_PackageTable ('      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;');
      Add_To_PackageTable ('      FND_MSG_PUB.Add_Exc_Msg(''' || lp_pkg_name || ''', ''' || p_procedure_name || ''', ''EXCEPTION: OTHERS''); ');
      Add_To_PackageTable ('      FND_MSG_PUB.Add_Exc_Msg(''' || lp_pkg_name || ''', ''' || p_procedure_name || ''', SQLERRM); ');
      Add_To_PackageTable ('      JTF_TAE_CONTROL_PVT.WRITE_LOG(2, x_Msg_Data);');
      Add_To_PackageTable ('      ROLLBACK TO JTF_TAE_MATCHING_TRANSACTION; ');
      Add_To_PackageTable ('      RAISE; ');

      Add_To_PackageTable ('  ');
      Add_To_PackageTable ('END ' || p_procedure_name || ';');
      Add_To_PackageTable ('/* End of procedure  ' || p_procedure_name || ' */');
      Add_To_PackageTable ('  ');

   END generate_end_of_procedure;

/*----------------------------------------------------------
  This procedure will create the SPEC and BODY
  for PROCEDURE/FUNCTION

  eg:   PROCEDURE TERR_RULE_1;
  Note: 1 is the Territory Id
 ----------------------------------------------------------*/
PROCEDURE generate_object_definition (
      procedure_name   VARCHAR2,
      description      VARCHAR2,
      parameter_list1  VARCHAR2,
      parameter_list2  VARCHAR2,
      procedure_type   VARCHAR2,
      return_type      VARCHAR2,
      object_type      VARCHAR2
   )
   IS
   BEGIN

      IF G_Debug THEN
         Write_Log(1, 'INSIDE PROCEDURE JTF_TAE_GEN_PVT.generate_object_definition: procedure_name = ' || procedure_name );
      END IF;

      -- Generate procedure header and parameters in both spec and body
      IF (procedure_type = 'P')
      THEN
         Add_To_PackageTable ('PROCEDURE ' || LOWER (procedure_name));
      ELSIF (procedure_type = 'F')
      THEN
         Add_To_PackageTable ('FUNCTION ' || LOWER (procedure_name));
      END IF;

      IF (parameter_list1 IS NOT NULL)
      THEN
         Add_To_PackageTable (' (' || parameter_list1 );
         Add_To_PackageTable ( parameter_list2 || ')');
      END IF;

      IF (procedure_type = 'F')
      THEN
         Add_To_PackageTable (' RETURN ' || return_type);
      END IF;

      IF (object_type = 'PKS')
      THEN
         Add_To_PackageTable (';');
      ELSE
         Add_To_PackageTable (' AS');
      END IF;
   END generate_object_definition;


   /* dblee/eihsu: 08/15/03 added p_new_mode_fetch flag */
   FUNCTION append_inlineview(p_input_string   IN VARCHAR2,
                              p_new_mode_fetch IN CHAR)
   RETURN VARCHAR2 AS
   BEGIN
       IF p_new_mode_fetch <> 'Y' THEN

           RETURN p_input_string || g_newline || g_newline ||
           G_INDENT || '   , /* INLINE VIEW */' || g_newline ||
           G_INDENT || '     ( SELECT /*+ NO_MERGE */               ' || g_newline ||
           G_INDENT || '              jtdr.terr_id                  ' || g_newline ||
           G_INDENT || '            , jtdr.source_id                ' || g_newline ||
           G_INDENT || '            , jtdr.qual_type_id             ' || g_newline ||
           G_INDENT || '            , jtdr.top_level_terr_id        ' || g_newline ||
           G_INDENT || '            , jtdr.absolute_rank            ' || g_newline ||
           G_INDENT || '            , jtdr.num_winners              ' || g_newline ||
           G_INDENT || '            , jtdr.org_id                   ' || g_newline ||
           G_INDENT || '       FROM  jtf_terr_denorm_rules_all jtdr ' || g_newline ||
           G_INDENT || '            ,jtf_terr_qtype_usgs_all jtqu   ' || g_newline ||
           G_INDENT || '            ,jtf_qual_type_usgs_all jqtu    ' || g_newline ||
           G_INDENT || '       WHERE jtdr.source_id = p_source_id    ' || g_newline ||
           G_INDENT || '         AND jtdr.terr_id= jtdr.related_terr_id' || g_newline ||

           G_INDENT || '         AND jqtu.source_id = jtdr.source_id    ' || g_newline ||
           G_INDENT || '         AND jqtu.qual_type_id = p_trans_object_type_id ' || g_newline ||
           G_INDENT || '         AND jtdr.terr_id = jtqu.terr_id ' || g_newline ||
           G_INDENT || '         AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id ' || g_newline ||

           G_INDENT || '         AND jtdr.resource_exists_flag = ''Y'' '|| g_newline ||
           G_INDENT || '         AND jtqu.qual_relation_product = lp_qual_combination_tbl(i) ' || g_newline ||
           G_INDENT || '     ) ILV'||g_newline;

       ELSE

          RETURN p_input_string || g_newline || g_newline ||
          G_INDENT || '   , /* INLINE VIEW */' || g_newline ||
          G_INDENT || '     ( SELECT /*+ NO_MERGE */ DISTINCT      ' || g_newline ||
          G_INDENT || '              jtdr.terr_id                  ' || g_newline ||
          G_INDENT || '            , jtdr.source_id                ' || g_newline ||
          G_INDENT || '            , jtdr.qual_type_id             ' || g_newline ||
          G_INDENT || '            , jtdr.top_level_terr_id        ' || g_newline ||
          G_INDENT || '            , jtdr.absolute_rank            ' || g_newline ||
          G_INDENT || '            , jtdr.num_winners              ' || g_newline ||
          G_INDENT || '            , jtdr.org_id                   ' || g_newline ||
          G_INDENT || '       FROM  jtf_terr_denorm_rules_all jtdr ' || g_newline ||
          G_INDENT || '            ,jtf_changed_terr_all jct       ' || g_newline ||
          G_INDENT || '            ,jtf_terr_qtype_usgs_all jtqu   ' || g_newline ||
          G_INDENT || '            ,jtf_qual_type_usgs_all jqtu    ' || g_newline ||
          G_INDENT || '       WHERE jqtu.source_id = p_source_id   ' || g_newline ||
          G_INDENT || '         AND jtdr.terr_id= jct.terr_id      ' || g_newline ||
          G_INDENT || '         AND jtdr.terr_id= jtdr.related_terr_id' || g_newline ||

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
        Add_To_PackageTable ('-- Program failed in inlineview procedure ');

   END append_inlineview;

    /* dblee: 08/15/03 */
   PROCEDURE add_insert_nmtrans(p_match_table_name  IN   VARCHAR2)
   AS
   BEGIN

      Add_To_PackageTable ('         INSERT INTO  '|| p_match_table_name || ' i');
      Add_To_PackageTable ('         (' );
      Add_To_PackageTable ('            TRANS_OBJECT_ID');
      Add_To_PackageTable ('            , TRANS_DETAIL_OBJECT_ID');
      Add_To_PackageTable ('            , HEADER_ID1');
      Add_To_PackageTable ('            , HEADER_ID2');
      Add_To_PackageTable ('            , SOURCE_ID');
      Add_To_PackageTable ('            , TRANS_OBJECT_TYPE_ID');
      Add_To_PackageTable ('            , LAST_UPDATE_DATE');
      Add_To_PackageTable ('            , LAST_UPDATED_BY');
      Add_To_PackageTable ('            , CREATION_DATE');
      Add_To_PackageTable ('            , CREATED_BY');
      Add_To_PackageTable ('            , LAST_UPDATE_LOGIN');
      Add_To_PackageTable ('            , REQUEST_ID');
      Add_To_PackageTable ('            , PROGRAM_APPLICATION_ID');
      Add_To_PackageTable ('            , PROGRAM_ID');
      Add_To_PackageTable ('            , PROGRAM_UPDATE_DATE');
      Add_To_PackageTable ('            , SQUAL_FC01');
      Add_To_PackageTable ('            , SQUAL_FC02');
      Add_To_PackageTable ('            , SQUAL_FC03');
      Add_To_PackageTable ('            , SQUAL_FC04');
      Add_To_PackageTable ('            , SQUAL_FC05');
      Add_To_PackageTable ('            , SQUAL_CURC01');
      Add_To_PackageTable ('            , SQUAL_CURC02');
      Add_To_PackageTable ('            , SQUAL_CURC03');
      Add_To_PackageTable ('            , SQUAL_CURC04');
      Add_To_PackageTable ('            , SQUAL_CURC05');
      Add_To_PackageTable ('            , SQUAL_CURC06');
      Add_To_PackageTable ('            , SQUAL_CURC07');
      Add_To_PackageTable ('            , SQUAL_CURC08');
      Add_To_PackageTable ('            , SQUAL_CURC09');
      Add_To_PackageTable ('            , SQUAL_CURC10');
      Add_To_PackageTable ('            , SQUAL_CHAR01');
      Add_To_PackageTable ('            , SQUAL_CHAR02');
      Add_To_PackageTable ('            , SQUAL_CHAR03');
      Add_To_PackageTable ('            , SQUAL_CHAR04');
      Add_To_PackageTable ('            , SQUAL_CHAR05');
      Add_To_PackageTable ('            , SQUAL_CHAR06');
      Add_To_PackageTable ('            , SQUAL_CHAR07');
      Add_To_PackageTable ('            , SQUAL_CHAR08');
      Add_To_PackageTable ('            , SQUAL_CHAR09');
      Add_To_PackageTable ('            , SQUAL_CHAR10');
      Add_To_PackageTable ('            , SQUAL_CHAR11');
      Add_To_PackageTable ('            , SQUAL_CHAR12');
      Add_To_PackageTable ('            , SQUAL_CHAR13');
      Add_To_PackageTable ('            , SQUAL_CHAR14');
      Add_To_PackageTable ('            , SQUAL_CHAR15');
      Add_To_PackageTable ('            , SQUAL_CHAR16');
      Add_To_PackageTable ('            , SQUAL_CHAR17');
      Add_To_PackageTable ('            , SQUAL_CHAR18');
      Add_To_PackageTable ('            , SQUAL_CHAR19');
      Add_To_PackageTable ('            , SQUAL_CHAR20');
      Add_To_PackageTable ('            , SQUAL_CHAR21');
      Add_To_PackageTable ('            , SQUAL_CHAR22');
      Add_To_PackageTable ('            , SQUAL_CHAR23');
      Add_To_PackageTable ('            , SQUAL_CHAR24');
      Add_To_PackageTable ('            , SQUAL_CHAR25');
      Add_To_PackageTable ('            , SQUAL_CHAR26');
      Add_To_PackageTable ('            , SQUAL_CHAR27');
      Add_To_PackageTable ('            , SQUAL_CHAR28');
      Add_To_PackageTable ('            , SQUAL_CHAR30');
      Add_To_PackageTable ('            , SQUAL_CHAR31');
      Add_To_PackageTable ('            , SQUAL_CHAR32');
      Add_To_PackageTable ('            , SQUAL_CHAR33');
      Add_To_PackageTable ('            , SQUAL_CHAR34');
      Add_To_PackageTable ('            , SQUAL_CHAR35');
      Add_To_PackageTable ('            , SQUAL_CHAR36');
      Add_To_PackageTable ('            , SQUAL_CHAR37');
      Add_To_PackageTable ('            , SQUAL_CHAR38');
      Add_To_PackageTable ('            , SQUAL_CHAR39');
      Add_To_PackageTable ('            , SQUAL_CHAR40');
      Add_To_PackageTable ('            , SQUAL_CHAR41');
      Add_To_PackageTable ('            , SQUAL_CHAR42');
      Add_To_PackageTable ('            , SQUAL_CHAR43');
      Add_To_PackageTable ('            , SQUAL_CHAR44');
      Add_To_PackageTable ('            , SQUAL_CHAR45');
      Add_To_PackageTable ('            , SQUAL_CHAR46');
      Add_To_PackageTable ('            , SQUAL_CHAR47');
      Add_To_PackageTable ('            , SQUAL_CHAR48');
      Add_To_PackageTable ('            , SQUAL_CHAR49');
      Add_To_PackageTable ('            , SQUAL_CHAR50');
      Add_To_PackageTable ('            , SQUAL_CHAR51');
      Add_To_PackageTable ('            , SQUAL_CHAR52');
      Add_To_PackageTable ('            , SQUAL_CHAR53');
      Add_To_PackageTable ('            , SQUAL_CHAR54');
      Add_To_PackageTable ('            , SQUAL_CHAR55');
      Add_To_PackageTable ('            , SQUAL_CHAR56');
      Add_To_PackageTable ('            , SQUAL_CHAR57');
      Add_To_PackageTable ('            , SQUAL_CHAR58');
      Add_To_PackageTable ('            , SQUAL_CHAR59');
      Add_To_PackageTable ('            , SQUAL_CHAR60');
      Add_To_PackageTable ('            , SQUAL_NUM01');
      Add_To_PackageTable ('            , SQUAL_NUM02');
      Add_To_PackageTable ('            , SQUAL_NUM03');
      Add_To_PackageTable ('            , SQUAL_NUM04');
      Add_To_PackageTable ('            , SQUAL_NUM05');
      Add_To_PackageTable ('            , SQUAL_NUM06');
      Add_To_PackageTable ('            , SQUAL_NUM07');
      Add_To_PackageTable ('            , SQUAL_NUM08');
      Add_To_PackageTable ('            , SQUAL_NUM09');
      Add_To_PackageTable ('            , SQUAL_NUM10');
      Add_To_PackageTable ('            , SQUAL_NUM11');
      Add_To_PackageTable ('            , SQUAL_NUM12');
      Add_To_PackageTable ('            , SQUAL_NUM13');
      Add_To_PackageTable ('            , SQUAL_NUM14');
      Add_To_PackageTable ('            , SQUAL_NUM15');
      Add_To_PackageTable ('            , SQUAL_NUM16');
      Add_To_PackageTable ('            , SQUAL_NUM17');
      Add_To_PackageTable ('            , SQUAL_NUM18');
      Add_To_PackageTable ('            , SQUAL_NUM19');
      Add_To_PackageTable ('            , SQUAL_NUM20');
      Add_To_PackageTable ('            , SQUAL_NUM21');
      Add_To_PackageTable ('            , SQUAL_NUM22');
      Add_To_PackageTable ('            , SQUAL_NUM23');
      Add_To_PackageTable ('            , SQUAL_NUM24');
      Add_To_PackageTable ('            , SQUAL_NUM25');
      Add_To_PackageTable ('            , SQUAL_NUM26');
      Add_To_PackageTable ('            , SQUAL_NUM27');
      Add_To_PackageTable ('            , SQUAL_NUM28');
      Add_To_PackageTable ('            , SQUAL_NUM29');
      Add_To_PackageTable ('            , SQUAL_NUM30');
      Add_To_PackageTable ('            , SQUAL_NUM31');
      Add_To_PackageTable ('            , SQUAL_NUM32');
      Add_To_PackageTable ('            , SQUAL_NUM33');
      Add_To_PackageTable ('            , SQUAL_NUM34');
      Add_To_PackageTable ('            , SQUAL_NUM35');
      Add_To_PackageTable ('            , SQUAL_NUM36');
      Add_To_PackageTable ('            , SQUAL_NUM37');
      Add_To_PackageTable ('            , SQUAL_NUM38');
      Add_To_PackageTable ('            , SQUAL_NUM39');
      Add_To_PackageTable ('            , SQUAL_NUM40');
      Add_To_PackageTable ('            , SQUAL_NUM41');
      Add_To_PackageTable ('            , SQUAL_NUM42');
      Add_To_PackageTable ('            , SQUAL_NUM43');
      Add_To_PackageTable ('            , SQUAL_NUM44');
      Add_To_PackageTable ('            , SQUAL_NUM45');
      Add_To_PackageTable ('            , SQUAL_NUM46');
      Add_To_PackageTable ('            , SQUAL_NUM47');
      Add_To_PackageTable ('            , SQUAL_NUM48');
      Add_To_PackageTable ('            , SQUAL_NUM49');
      Add_To_PackageTable ('            , SQUAL_NUM50');
      Add_To_PackageTable ('            , SQUAL_NUM51');
      Add_To_PackageTable ('            , SQUAL_NUM52');
      Add_To_PackageTable ('            , SQUAL_NUM53');
      Add_To_PackageTable ('            , SQUAL_NUM54');
      Add_To_PackageTable ('            , SQUAL_NUM55');
      Add_To_PackageTable ('            , SQUAL_NUM56');
      Add_To_PackageTable ('            , SQUAL_NUM57');
      Add_To_PackageTable ('            , SQUAL_NUM58');
      Add_To_PackageTable ('            , SQUAL_NUM59');
      Add_To_PackageTable ('            , SQUAL_NUM60');
      Add_To_PackageTable ('            , ASSIGNED_FLAG');
      Add_To_PackageTable ('            , PROCESSED_FLAG');
      Add_To_PackageTable ('            , ORG_ID');
      Add_To_PackageTable ('            , SECURITY_GROUP_ID');
      Add_To_PackageTable ('            , OBJECT_VERSION_NUMBER');
      Add_To_PackageTable ('            , WORKER_ID');
      Add_To_PackageTable ('         )' );

   EXCEPTION
   WHEN OTHERS THEN
        g_ProgramStatus := 1;
        Add_To_PackageTable ('-- Program failed in add_insert_nmtrans procedure ');

   END add_insert_nmtrans;

    /* dblee: 08/15/03 */
   PROCEDURE add_select_nmtrans(p_match_table_name  IN   VARCHAR2)
   AS
   BEGIN

      Add_To_PackageTable ('         SELECT DISTINCT ');
      Add_To_PackageTable ('              A.TRANS_OBJECT_ID');
      Add_To_PackageTable ('            , A.TRANS_DETAIL_OBJECT_ID');
      Add_To_PackageTable ('            , A.HEADER_ID1');
      Add_To_PackageTable ('            , A.HEADER_ID2');
      Add_To_PackageTable ('            , p_source_id');
      Add_To_PackageTable ('            , p_trans_object_type_id');
      Add_To_PackageTable ('            , l_sysdate');
      Add_To_PackageTable ('            , L_USER_ID');
      Add_To_PackageTable ('            , l_sysdate');
      Add_To_PackageTable ('            , L_USER_ID');
      Add_To_PackageTable ('            , L_USER_ID');
      Add_To_PackageTable ('            , L_REQUEST_ID');
      Add_To_PackageTable ('            , L_PROGRAM_APPL_ID');
      Add_To_PackageTable ('            , L_PROGRAM_ID');
      Add_To_PackageTable ('            , l_sysdate');
      Add_To_PackageTable ('            , A.SQUAL_FC01');
      Add_To_PackageTable ('            , A.SQUAL_FC02');
      Add_To_PackageTable ('            , A.SQUAL_FC03');
      Add_To_PackageTable ('            , A.SQUAL_FC04');
      Add_To_PackageTable ('            , A.SQUAL_FC05');
      Add_To_PackageTable ('            , A.SQUAL_CURC01');
      Add_To_PackageTable ('            , A.SQUAL_CURC02');
      Add_To_PackageTable ('            , A.SQUAL_CURC03');
      Add_To_PackageTable ('            , A.SQUAL_CURC04');
      Add_To_PackageTable ('            , A.SQUAL_CURC05');
      Add_To_PackageTable ('            , A.SQUAL_CURC06');
      Add_To_PackageTable ('            , A.SQUAL_CURC07');
      Add_To_PackageTable ('            , A.SQUAL_CURC08');
      Add_To_PackageTable ('            , A.SQUAL_CURC09');
      Add_To_PackageTable ('            , A.SQUAL_CURC10');
      Add_To_PackageTable ('            , A.SQUAL_CHAR01');
      Add_To_PackageTable ('            , A.SQUAL_CHAR02');
      Add_To_PackageTable ('            , A.SQUAL_CHAR03');
      Add_To_PackageTable ('            , A.SQUAL_CHAR04');
      Add_To_PackageTable ('            , A.SQUAL_CHAR05');
      Add_To_PackageTable ('            , A.SQUAL_CHAR06');
      Add_To_PackageTable ('            , A.SQUAL_CHAR07');
      Add_To_PackageTable ('            , A.SQUAL_CHAR08');
      Add_To_PackageTable ('            , A.SQUAL_CHAR09');
      Add_To_PackageTable ('            , A.SQUAL_CHAR10');
      Add_To_PackageTable ('            , A.SQUAL_CHAR11');
      Add_To_PackageTable ('            , A.SQUAL_CHAR12');
      Add_To_PackageTable ('            , A.SQUAL_CHAR13');
      Add_To_PackageTable ('            , A.SQUAL_CHAR14');
      Add_To_PackageTable ('            , A.SQUAL_CHAR15');
      Add_To_PackageTable ('            , A.SQUAL_CHAR16');
      Add_To_PackageTable ('            , A.SQUAL_CHAR17');
      Add_To_PackageTable ('            , A.SQUAL_CHAR18');
      Add_To_PackageTable ('            , A.SQUAL_CHAR19');
      Add_To_PackageTable ('            , A.SQUAL_CHAR20');
      Add_To_PackageTable ('            , A.SQUAL_CHAR21');
      Add_To_PackageTable ('            , A.SQUAL_CHAR22');
      Add_To_PackageTable ('            , A.SQUAL_CHAR23');
      Add_To_PackageTable ('            , A.SQUAL_CHAR24');
      Add_To_PackageTable ('            , A.SQUAL_CHAR25');
      Add_To_PackageTable ('            , A.SQUAL_CHAR26');
      Add_To_PackageTable ('            , A.SQUAL_CHAR27');
      Add_To_PackageTable ('            , A.SQUAL_CHAR28');
      Add_To_PackageTable ('            , A.SQUAL_CHAR30');
      Add_To_PackageTable ('            , A.SQUAL_CHAR31');
      Add_To_PackageTable ('            , A.SQUAL_CHAR32');
      Add_To_PackageTable ('            , A.SQUAL_CHAR33');
      Add_To_PackageTable ('            , A.SQUAL_CHAR34');
      Add_To_PackageTable ('            , A.SQUAL_CHAR35');
      Add_To_PackageTable ('            , A.SQUAL_CHAR36');
      Add_To_PackageTable ('            , A.SQUAL_CHAR37');
      Add_To_PackageTable ('            , A.SQUAL_CHAR38');
      Add_To_PackageTable ('            , A.SQUAL_CHAR39');
      Add_To_PackageTable ('            , A.SQUAL_CHAR40');
      Add_To_PackageTable ('            , A.SQUAL_CHAR41');
      Add_To_PackageTable ('            , A.SQUAL_CHAR42');
      Add_To_PackageTable ('            , A.SQUAL_CHAR43');
      Add_To_PackageTable ('            , A.SQUAL_CHAR44');
      Add_To_PackageTable ('            , A.SQUAL_CHAR45');
      Add_To_PackageTable ('            , A.SQUAL_CHAR46');
      Add_To_PackageTable ('            , A.SQUAL_CHAR47');
      Add_To_PackageTable ('            , A.SQUAL_CHAR48');
      Add_To_PackageTable ('            , A.SQUAL_CHAR49');
      Add_To_PackageTable ('            , A.SQUAL_CHAR50');
      Add_To_PackageTable ('            , A.SQUAL_CHAR51');
      Add_To_PackageTable ('            , A.SQUAL_CHAR52');
      Add_To_PackageTable ('            , A.SQUAL_CHAR53');
      Add_To_PackageTable ('            , A.SQUAL_CHAR54');
      Add_To_PackageTable ('            , A.SQUAL_CHAR55');
      Add_To_PackageTable ('            , A.SQUAL_CHAR56');
      Add_To_PackageTable ('            , A.SQUAL_CHAR57');
      Add_To_PackageTable ('            , A.SQUAL_CHAR58');
      Add_To_PackageTable ('            , A.SQUAL_CHAR59');
      Add_To_PackageTable ('            , A.SQUAL_CHAR60');
      Add_To_PackageTable ('            , A.SQUAL_NUM01');
      Add_To_PackageTable ('            , A.SQUAL_NUM02');
      Add_To_PackageTable ('            , A.SQUAL_NUM03');
      Add_To_PackageTable ('            , A.SQUAL_NUM04');
      Add_To_PackageTable ('            , A.SQUAL_NUM05');
      Add_To_PackageTable ('            , A.SQUAL_NUM06');
      Add_To_PackageTable ('            , A.SQUAL_NUM07');
      Add_To_PackageTable ('            , A.SQUAL_NUM08');
      Add_To_PackageTable ('            , A.SQUAL_NUM09');
      Add_To_PackageTable ('            , A.SQUAL_NUM10');
      Add_To_PackageTable ('            , A.SQUAL_NUM11');
      Add_To_PackageTable ('            , A.SQUAL_NUM12');
      Add_To_PackageTable ('            , A.SQUAL_NUM13');
      Add_To_PackageTable ('            , A.SQUAL_NUM14');
      Add_To_PackageTable ('            , A.SQUAL_NUM15');
      Add_To_PackageTable ('            , A.SQUAL_NUM16');
      Add_To_PackageTable ('            , A.SQUAL_NUM17');
      Add_To_PackageTable ('            , A.SQUAL_NUM18');
      Add_To_PackageTable ('            , A.SQUAL_NUM19');
      Add_To_PackageTable ('            , A.SQUAL_NUM20');
      Add_To_PackageTable ('            , A.SQUAL_NUM21');
      Add_To_PackageTable ('            , A.SQUAL_NUM22');
      Add_To_PackageTable ('            , A.SQUAL_NUM23');
      Add_To_PackageTable ('            , A.SQUAL_NUM24');
      Add_To_PackageTable ('            , A.SQUAL_NUM25');
      Add_To_PackageTable ('            , A.SQUAL_NUM26');
      Add_To_PackageTable ('            , A.SQUAL_NUM27');
      Add_To_PackageTable ('            , A.SQUAL_NUM28');
      Add_To_PackageTable ('            , A.SQUAL_NUM29');
      Add_To_PackageTable ('            , A.SQUAL_NUM30');
      Add_To_PackageTable ('            , A.SQUAL_NUM31');
      Add_To_PackageTable ('            , A.SQUAL_NUM32');
      Add_To_PackageTable ('            , A.SQUAL_NUM33');
      Add_To_PackageTable ('            , A.SQUAL_NUM34');
      Add_To_PackageTable ('            , A.SQUAL_NUM35');
      Add_To_PackageTable ('            , A.SQUAL_NUM36');
      Add_To_PackageTable ('            , A.SQUAL_NUM37');
      Add_To_PackageTable ('            , A.SQUAL_NUM38');
      Add_To_PackageTable ('            , A.SQUAL_NUM39');
      Add_To_PackageTable ('            , A.SQUAL_NUM40');
      Add_To_PackageTable ('            , A.SQUAL_NUM41');
      Add_To_PackageTable ('            , A.SQUAL_NUM42');
      Add_To_PackageTable ('            , A.SQUAL_NUM43');
      Add_To_PackageTable ('            , A.SQUAL_NUM44');
      Add_To_PackageTable ('            , A.SQUAL_NUM45');
      Add_To_PackageTable ('            , A.SQUAL_NUM46');
      Add_To_PackageTable ('            , A.SQUAL_NUM47');
      Add_To_PackageTable ('            , A.SQUAL_NUM48');
      Add_To_PackageTable ('            , A.SQUAL_NUM49');
      Add_To_PackageTable ('            , A.SQUAL_NUM50');
      Add_To_PackageTable ('            , A.SQUAL_NUM51');
      Add_To_PackageTable ('            , A.SQUAL_NUM52');
      Add_To_PackageTable ('            , A.SQUAL_NUM53');
      Add_To_PackageTable ('            , A.SQUAL_NUM54');
      Add_To_PackageTable ('            , A.SQUAL_NUM55');
      Add_To_PackageTable ('            , A.SQUAL_NUM56');
      Add_To_PackageTable ('            , A.SQUAL_NUM57');
      Add_To_PackageTable ('            , A.SQUAL_NUM58');
      Add_To_PackageTable ('            , A.SQUAL_NUM59');
      Add_To_PackageTable ('            , A.SQUAL_NUM60');
      Add_To_PackageTable ('            , A.ASSIGNED_FLAG');
      Add_To_PackageTable ('            , A.PROCESSED_FLAG');
      Add_To_PackageTable ('            , A.ORG_ID');
      Add_To_PackageTable ('            , A.SECURITY_GROUP_ID');
      Add_To_PackageTable ('            , A.OBJECT_VERSION_NUMBER');
      Add_To_PackageTable ('            , A.WORKER_ID');
      Add_To_PackageTable ('          FROM  ');

   EXCEPTION
      WHEN OTHERS THEN
         g_ProgramStatus := 1;
         Add_To_PackageTable ('-- Program failed in add_select_nmtrans procedure ');

   END add_select_nmtrans;


   PROCEDURE write_buffer_content(
      l_qual_rules   VARCHAR2
   )
   IS
      l_str_len            NUMBER;
      l_start              NUMBER;
      l_get_nchar          NUMBER;
      l_next_newline       NUMBER;
      l_rule_str           VARCHAR2(256);
      l_newline            VARCHAR2(2);
      l_indent             VARCHAR2(30);

   BEGIN

      l_newline := FND_GLOBAL.Local_Chr(10); /* newline character */
      l_indent  := '            ';
      l_start := 1;
      l_next_newline := 0;

      WHILE (TRUE) LOOP

         l_next_newline := INSTR(l_qual_rules, l_newline, l_start, 1);

         IF l_next_newline = 0 THEN
            /* no new line characters => end of string */
            l_get_nchar := l_str_len;

         ELSE
            /* set of characters up to next newline */
            l_get_nchar := l_next_newline - l_start;
         END IF;

         l_rule_str := substr(l_qual_rules, l_start, l_get_nchar);

         --dbms_output.put_line(l_rule_str);
         Add_To_PackageTable(l_indent || l_rule_str);

         EXIT WHEN l_next_newline = 0;

         l_rule_str := NULL;
         l_start := l_next_newline + 1;

      END LOOP;

   EXCEPTION
      WHEN OTHERS THEN
         g_ProgramStatus := 1;
         Add_To_PackageTable ('-- Program failed in write_buffer_content ');
         Add_To_PackageTable (substr(sqlerrm,1,200));

   END write_buffer_content;

   PROCEDURE build_ilv1(
      p_source_id         IN          NUMBER,
      p_qual_type_id      IN          NUMBER,
      p_relation_product  IN          NUMBER,
      p_relation_factor   IN          NUMBER,
	  -- dblee 08/26/03 added p_new_mode_fetch flag argument
      p_new_mode_fetch    IN          CHAR,
      p_ilv1sql           OUT NOCOPY  VARCHAR2)
   IS
      l_from_str       VARCHAR2(32767);
      l_where_str      VARCHAR2(32767);
      l_predicate      VARCHAR2(32767);
      l_select         VARCHAR2(32767);

      l_newline        VARCHAR2(2);
      l_idx_hint       VARCHAR2(255);

      CURSOR c_rel_prod_detail IS
         SELECT distinct jtqp.relation_product
                ,jtqf.qual_usg_id
                ,jqu.alias_rule1
                ,jqu.alias_op_like
                ,jqu.alias_op_between
                ,jqu.op_eql
                ,jqu.op_not_eql
                ,jqu.op_lss_thn
                ,jqu.op_lss_thn_eql
                ,jqu.op_grtr_thn
                ,jqu.op_grtr_thn_eql
                ,jqu.op_like
                ,jqu.op_not_like
                ,jqu.op_between
                ,jqu.op_not_between
                ,jqu.op_common_where
          FROM jtf_qual_usgs_all jqu,
               jtf_tae_qual_factors jtqf,
               jtf_tae_qual_products jtqp,
               jtf_tae_qual_prod_factors jtpf
          WHERE jqu.org_id = -3113
          AND jqu.qual_usg_id = jtqf.qual_usg_id
            and jtpf.qual_factor_id = jtqf.qual_factor_id
            and jtqf.relation_factor = p_relation_factor
            and jtqp.qual_product_id = jtpf.qual_product_id
            and jtqp.relation_product = p_relation_product
            and jtqp.source_id = p_source_id
            and jtqp.trans_object_type_id = p_qual_type_id
            and jqu.op_not_eql IS NULL
            and jqu.op_not_like IS NULL
            and jqu.op_not_between IS NULL
          ORDER BY jtqf.qual_usg_id;

   BEGIN

      l_newline := FND_GLOBAL.Local_Chr(10);

      FOR JTF_csr IN c_rel_prod_detail LOOP

         --l_idx_hint := '/*+ INDEX(' || JTF_csr.alias_rule1 ||' JTF_TERR_QUAL_RULES_MV_N10) */';

         IF mod(JTF_csr.relation_product,79) = 0 THEN
             l_select := G_INDENT || 'SELECT ' || l_idx_hint || G_NEWLINE ||
                         G_INDENT || '       AI.customer_id' || l_newline ||
                         G_INDENT || '     , AI.address_id'  || l_newline;
         ELSIF mod(JTF_csr.relation_product,137) = 0 THEN
             l_select := G_INDENT || 'SELECT ' || l_idx_hint || G_NEWLINE ||
                         G_INDENT || '       ASLLP.sales_lead_id' || l_newline ||
                         G_INDENT || '     , ASLLP.sales_lead_line_id'  || l_newline;
         ELSIF mod(JTF_csr.relation_product,113) = 0 THEN
             l_select := G_INDENT || 'SELECT ' || l_idx_hint || G_NEWLINE ||
                         G_INDENT || '       ASLL.sales_lead_id' || l_newline ||
                         G_INDENT || '     , ASLL.sales_lead_line_id'  || l_newline;
         ELSIF mod(JTF_csr.relation_product,131) = 0 THEN
             l_select := G_INDENT || 'SELECT ' || l_idx_hint || G_NEWLINE ||
                         G_INDENT || '       ASLLI.sales_lead_id' || l_newline ||
                         G_INDENT || '     , ASLLI.sales_lead_line_id'  || l_newline;
         ELSIF mod(JTF_csr.relation_product,139) = 0 THEN
              l_select := G_INDENT || 'SELECT ' || l_idx_hint || G_NEWLINE ||
                          G_INDENT || '       ALLP.lead_id' || l_newline ||
                          G_INDENT || '     , ALLP.lead_line_id' || l_newline;
         ELSIF mod(JTF_csr.relation_product,163) = 0 THEN
              l_select := G_INDENT || 'SELECT ' || l_idx_hint || G_NEWLINE ||
                          G_INDENT || '       ALLI.lead_id' || l_newline ||
                          G_INDENT || '     , ALLI.lead_line_id' || l_newline;
         ELSIF mod(JTF_csr.relation_product,167) = 0 THEN
              l_select := G_INDENT || 'SELECT ' || l_idx_hint || G_NEWLINE ||
                          G_INDENT || '       OAI.lead_id' || l_newline ;
                          --G_INDENT || '     , ALLI.lead_line_id' || l_newline;
         END IF;

         l_select := l_select ||
            G_INDENT || '     , ILV.terr_id                  ' || l_newline ||
            G_INDENT || '     , ILV.top_level_terr_id        ' || l_newline ||
            G_INDENT || '     , ILV.absolute_rank            ' || l_newline ||
            G_INDENT || '     , ILV.num_winners              ' || l_newline ||
            G_INDENT || '     , ILV.org_id                   ' || l_newline;

         l_from_str := G_INDENT || 'FROM ' || JTF_csr.alias_rule1 ;

         -- dblee/eihsu: 08/15/03 added p_new_mode_fetch flag
         l_from_str := append_inlineview(l_from_str, p_new_mode_fetch);

         l_where_str := l_newline || G_INDENT || 'WHERE 1 = 1 ' ;
         -- eihsu: worker_id added 06/09/2003
         l_where_str := l_where_str  || l_newline || '--AND a.worker_id = p_worker_id ';

         l_predicate := l_newline
               || build_predicate_for_operator(JTF_csr.op_common_where
                   ,JTF_csr.op_eql
                   ,JTF_csr.op_lss_thn
                   ,JTF_csr.op_lss_thn_eql
                   ,JTF_csr.op_grtr_thn
                   ,JTF_csr.op_grtr_thn_eql
                   ,JTF_csr.op_like
                   ,JTF_csr.op_between
                   ,l_newline);

         IF  mod(JTF_csr.relation_product,79) = 0 THEN
            l_predicate := replace(l_predicate,'(  A.SQUAL_NUM02 IS NULL AND AI.address_id IS NULL )','');
            l_predicate := replace(l_predicate,'OR ( A.SQUAL_NUM02 = AI.address_id )'       , '1=1');
            l_predicate := replace(l_predicate,'A.SQUAL_NUM01 = AI.customer_id','1=1');
         ELSIF mod(JTF_csr.relation_product,137) = 0 THEN
            l_predicate := replace(l_predicate,'A.TRANS_OBJECT_ID = ASLLP.SALES_LEAD_ID','1=1');
         ELSIF mod(JTF_csr.relation_product,113) = 0 THEN
            l_predicate := replace(l_predicate,'ASLL.SALES_LEAD_ID = A.TRANS_OBJECT_ID','1=1');
            l_predicate := replace(l_predicate,'a.squal_curc03 = Q1022R1.currency_code','1=1');
         ELSIF mod(JTF_csr.relation_product,131) = 0 THEN
            l_predicate := replace(l_predicate,'A.TRANS_OBJECT_ID = ASLLI.SALES_LEAD_ID','1=1');
         ELSIF mod(JTF_csr.relation_product,139) = 0 THEN
            l_predicate := replace(l_predicate,'A.TRANS_OBJECT_ID = ALLP.LEAD_ID','1=1');
         ELSIF mod(JTF_csr.relation_product,163) = 0 THEN
            l_predicate := replace(l_predicate,'A.TRANS_OBJECT_ID = ALLI.LEAD_ID','1=1');
         ELSIF mod(JTF_csr.relation_product,167) = 0 THEN
            l_predicate := replace(l_predicate,'A.TRANS_OBJECT_ID = OAI.LEAD_ID','1=1');
         END IF;

         p_ilv1sql :=
            l_select || l_newline ||
               l_from_str || l_newline ||
               l_where_str || l_newline ||
                  l_predicate;

         EXIT;
      END LOOP;

   EXCEPTION
      WHEN OTHERS THEN
         g_ProgramStatus := 1;
         Add_To_PackageTable ('-- Program failed in build_ilv1 ');

   END build_ilv1;

   PROCEDURE build_ilv2(
      p_source_id         IN          NUMBER,
      p_qual_type_id      IN          NUMBER,
      p_relation_product  IN          NUMBER,
      p_relation_factor   IN          NUMBER,
      p_input_table_name  IN          VARCHAR2,
      -- dblee/eihsu: 08/15/03 added p_new_mode_fetch flag
      p_new_mode_fetch    IN          CHAR,
      p_sql               OUT NOCOPY  VARCHAR2,
      p_ilv2eq            OUT NOCOPY  VARCHAR2,
      p_ilv2lk            OUT NOCOPY  VARCHAR2,
      p_ilv2lkp           OUT NOCOPY  VARCHAR2,
      p_ilv2btwn          OUT NOCOPY  VARCHAR2)
   AS

      CURSOR c_rel_prod_detail
      IS
         SELECT DISTINCT jtqp.relation_product
               ,jtqf.qual_usg_id
               ,jqu.alias_rule1
               ,jqu.alias_op_like
               ,jqu.alias_op_between
               ,jqu.op_eql
               ,jqu.op_not_eql
               ,jqu.op_lss_thn
               ,jqu.op_lss_thn_eql
               ,jqu.op_grtr_thn
               ,jqu.op_grtr_thn_eql
               ,jqu.op_like
               ,jqu.op_not_like
               ,jqu.op_between
               ,jqu.op_not_between
               ,jqu.op_common_where
         FROM jtf_qual_usgs_all jqu,
               jtf_tae_qual_factors jtqf,
               jtf_tae_qual_products jtqp,
               jtf_tae_qual_prod_factors jtpf
         WHERE jqu.org_id = -3113
            AND jqu.qual_usg_id = jtqf.qual_usg_id
            AND jtpf.qual_factor_id= jtqf.qual_factor_id
            AND jtqf.relation_factor <> p_relation_factor
            AND jtqp.qual_product_id = jtpf.qual_product_id
            AND jtqp.relation_product = p_relation_product
            AND jtqp.source_id = p_source_id
            AND jtqp.trans_object_type_id= p_qual_type_id
            AND jqu.op_not_eql IS NULL
            AND jqu.op_not_like IS NULL
            AND jqu.op_not_between IS NULL
         ORDER BY jtqf.qual_usg_id;

      l_qual_usg_id        NUMBER;
      l_qual_rules         VARCHAR2(32767);
      l_rule               VARCHAR2(32767);
      l_counter            NUMBER := 1;
      l_newline            VARCHAR2(2);
      l_indent             VARCHAR2(30);
      l_sysdate            DATE;
      l_str_len            NUMBER;
      l_start              NUMBER;
      l_get_nchar          NUMBER;
      l_next_newline       NUMBER;
      l_rule_str           VARCHAR2(256);
      l_from_str           VARCHAR2(32767);
      l_from_str_eq        VARCHAR2(32767);
      l_from_str_like      VARCHAR2(32767);
      l_from_str_btw       VARCHAR2(32767);
      l_where_str          VARCHAR2(32767);
      l_predicate          VARCHAR2(32767);
      l_predicate_eq       VARCHAR2(32767);
      l_predicate_like     VARCHAR2(32767);
      l_predicate_btw      VARCHAR2(32767);
      l_select_eq          VARCHAR2(32767);
      l_select_like        VARCHAR2(32767);
      l_select_btw         VARCHAR2(32767);
      l_ilv2eq             VARCHAR2(32767);
      l_ilv2lk             VARCHAR2(32767);
      l_ilv2lkp            VARCHAR2(32767);
      l_ilv2btwn           VARCHAR2(32767);
      l_relation_product   number;

   BEGIN

      --dbms_output.put_line('Inside build_rule_expression ');
      l_relation_product := p_relation_product/p_relation_factor;

      l_newline := FND_GLOBAL.Local_Chr(10); /* newline character */
      l_sysdate := SYSDATE;

      FOR JTF_csr IN c_rel_prod_detail LOOP

         IF mod(l_relation_product,67) <> 0 and mod(l_relation_product,73) <> 0 THEN
            IF l_counter = 1 THEN
                l_from_str := l_newline || G_INDENT || ' FROM '|| p_input_table_name || '  A' || l_newline
    			       || ',' || JTF_csr.alias_rule1;
                l_where_str := l_newline || G_INDENT || 'WHERE 1 = 1' ;
                -- eihsu: worker_id added 06/09/2003
                -- bug # 4213107 : worker_id condition should not be added to NMC packages
                IF (p_new_mode_fetch <> 'Y') THEN
                  l_where_str := l_where_str  || l_newline || 'AND a.worker_id = p_worker_id ';
                END IF;
                l_predicate := l_newline
                    || build_predicate_for_operator(JTF_csr.op_common_where
                        ,JTF_csr.op_eql
                        ,JTF_csr.op_lss_thn
                        ,JTF_csr.op_lss_thn_eql
                        ,JTF_csr.op_grtr_thn
                        ,JTF_csr.op_grtr_thn_eql
                        ,JTF_csr.op_like
                        ,JTF_csr.op_between
                        ,l_newline);
            ELSE -- l_counter <> 1
                l_from_str := l_from_str || l_newline || ',' || JTF_csr.alias_rule1;
                l_predicate := l_predicate || l_newline
                    || build_predicate_for_operator(JTF_csr.op_common_where
                        ,JTF_csr.op_eql
                        ,JTF_csr.op_lss_thn
                        ,JTF_csr.op_lss_thn_eql
                        ,JTF_csr.op_grtr_thn
                        ,JTF_csr.op_grtr_thn_eql
                        ,JTF_csr.op_like
                        ,JTF_csr.op_between
                        ,l_newline);
            END IF;
         ELSE
            IF (l_counter = 1) THEN
                IF (JTF_csr.qual_usg_id = -1012 or JTF_csr.qual_usg_id = -1102) THEN
                    -- dblee: 08/20/03 replaced select clause literal w/ g_select_list_1 variable
					l_select_eq := l_newline || g_select_list_1;
                    l_select_like := l_newline || g_select_list_1;
    		        l_select_btw := l_newline || g_select_list_1;
                    /* bug 3835831 */
                    IF ((mod(p_relation_product, 79) = 0) AND (p_new_mode_fetch <> 'Y')) THEN
                      l_select_eq := l_select_eq || ' ,A.SQUAL_NUM01, A.SQUAL_NUM02 ';
                      l_select_like := l_select_like || ' ,A.SQUAL_NUM01, A.SQUAL_NUM02 ';
                      l_select_btw := l_select_btw || ' ,A.SQUAL_NUM01, A.SQUAL_NUM02 ';
                    END IF;

                    l_from_str_eq := l_newline || 'FROM '|| p_input_table_name ||' A' ||  l_newline ||
                          ',' || JTF_csr.alias_rule1;

                    l_from_str_like := l_newline || 'FROM '|| p_input_table_name ||' A'||  l_newline ||
                          ',' || JTF_csr.alias_op_like;

                    l_from_str_btw := l_newline || 'FROM '|| p_input_table_name ||' A' ||  l_newline ||
                          ',' || JTF_csr.alias_op_between;

                    l_where_str := l_newline || 'WHERE 1 = 1 ' ;
                    -- eihsu: worker_id added 06/09/2003
                    -- bug # 4213107 : worker_id condition should not be added to NMC packages
                    IF (p_new_mode_fetch <> 'Y') THEN
                      l_where_str := l_where_str  || l_newline || 'AND a.worker_id = p_worker_id ';
                    END IF;

                    l_predicate_eq := l_newline || 'AND ' || JTF_csr.op_eql;
                    l_predicate_like := l_newline ||'AND ' || JTF_csr.op_like;
                    l_predicate_btw := l_newline || 'AND ' || JTF_csr.op_between;
                ELSE -- JTF_csr.qual_usg_id NOT IN (-1012, -1102)
                    l_from_str_eq := l_newline || 'FROM '|| p_input_table_name ||'  A' ||  l_newline
 				       || ',' || JTF_csr.alias_rule1;
                    l_where_str := l_newline || 'WHERE 1 = 1' ;
                    -- eihsu: worker_id added 06/09/2003
                    -- bug # 4213107 : worker_id condition should not be added to NMC packages
                    IF (p_new_mode_fetch <> 'Y') THEN
                      l_where_str := l_where_str  || l_newline || 'AND a.worker_id = p_worker_id ';
                    END IF;
                    l_predicate_eq := l_newline
                        || build_predicate_for_operator(JTF_csr.op_common_where
                            ,JTF_csr.op_eql
                            ,JTF_csr.op_lss_thn
                            ,JTF_csr.op_lss_thn_eql
                            ,JTF_csr.op_grtr_thn
                            ,JTF_csr.op_grtr_thn_eql
                            ,JTF_csr.op_like
                            ,JTF_csr.op_between
                            ,l_newline);
                END IF; -- JTF_csr.qual_usg_id = -1012 or JTF_csr.qual_usg_id = -1102

            ELSE /* counter > 1*/
                IF (JTF_csr.qual_usg_id = -1012 or JTF_csr.qual_usg_id = -1102) THEN
                    -- dblee: 08/20/03 replaced select clause literal w/ g_select_list_1 variable
					l_select_eq := l_newline || g_select_list_1;
                    l_select_like := l_newline || g_select_list_1;
                    l_select_btw := l_newline || g_select_list_1;
                    /* bug 3835831 */
                    IF ((mod(p_relation_product, 79) = 0) AND (p_new_mode_fetch <> 'Y')) THEN
                      l_select_eq := l_select_eq || ' ,A.SQUAL_NUM01, A.SQUAL_NUM02 ';
                      l_select_like := l_select_like || ' ,A.SQUAL_NUM01, A.SQUAL_NUM02 ';
                      l_select_btw := l_select_btw || ' ,A.SQUAL_NUM01, A.SQUAL_NUM02 ';
                    END IF;

                    l_from_str_like := l_from_str_eq || l_newline || ',' || JTF_csr.alias_op_like;
                    l_from_str_btw := l_from_str_eq ||  l_newline || ',' || JTF_csr.alias_op_between;
                    l_from_str_eq := l_from_str_eq ||l_newline || ',' ||  JTF_csr.alias_rule1;

                    l_where_str := l_newline || 'WHERE 1 = 1' ;
                    -- eihsu: worker_id added 06/09/2003
                    -- bug # 4213107 : worker_id condition should not be added to NMC packages
                    IF (p_new_mode_fetch <> 'Y') THEN
                      l_where_str := l_where_str  || l_newline || 'AND a.worker_id = p_worker_id ';
                    END IF;
                    /* sbehera added AND 05/02/2002 */

                    l_predicate_like := l_predicate_eq || l_newline || 'AND '|| JTF_csr.op_like;
                    l_predicate_btw := l_predicate_eq || l_newline || 'AND '|| JTF_csr.op_between;
                    l_predicate_eq := l_predicate_eq || l_newline || 'AND '|| JTF_csr.op_eql;

                ELSE -- JTF_csr.qual_usg_id not in (-1012 or -1102)
                    l_from_str_eq := l_from_str_eq || l_newline || ',' || JTF_csr.alias_rule1;
                    l_from_str_like := l_from_str_like || l_newline || ',' || JTF_csr.alias_rule1;
                    l_from_str_btw := l_from_str_btw || l_newline || ',' || JTF_csr.alias_rule1;

                    l_predicate_eq := l_predicate_eq || l_newline
                        || build_predicate_for_operator(JTF_csr.op_common_where
                            ,JTF_csr.op_eql
                            ,JTF_csr.op_lss_thn
                            ,JTF_csr.op_lss_thn_eql
                            ,JTF_csr.op_grtr_thn
                            ,JTF_csr.op_grtr_thn_eql
                            ,JTF_csr.op_like
                            ,JTF_csr.op_between
                            ,l_newline);

                    l_predicate_like := l_predicate_like || l_newline
                        || build_predicate_for_operator(JTF_csr.op_common_where
                            ,JTF_csr.op_eql
                            ,JTF_csr.op_lss_thn
                            ,JTF_csr.op_lss_thn_eql
                            ,JTF_csr.op_grtr_thn
                            ,JTF_csr.op_grtr_thn_eql
                            ,JTF_csr.op_like
                            ,JTF_csr.op_between
                            ,l_newline);

                    l_predicate_btw := l_predicate_btw || l_newline
                        || build_predicate_for_operator(JTF_csr.op_common_where
                           ,JTF_csr.op_eql
                           ,JTF_csr.op_lss_thn
                           ,JTF_csr.op_lss_thn_eql
                           ,JTF_csr.op_grtr_thn
                           ,JTF_csr.op_grtr_thn_eql
                           ,JTF_csr.op_like
                           ,JTF_csr.op_between
                           ,l_newline);
                END IF; -- JTF_csr.qual_usg_id = -1012 or JTF_csr.qual_usg_id = -1102

            END IF; /* counter */

         END IF; /* mod */

         l_counter := l_counter + 1;
      END LOOP;

      /* for account classification we need to add AS_INTERESTS in the from clause */
      IF mod(l_relation_product,79) = 0 and mod(l_relation_product,67) <> 0 THEN
         l_from_str := l_from_str || l_newline; /* jdochert 04/24/02 ||', AS_INTERESTS ai ' ;*/
      ELSIF mod(l_relation_product,79) = 0 and mod(l_relation_product,67) = 0 THEN
         l_from_str := l_from_str || l_newline; /* jdochert 04/24/02 ||', AS_INTERESTS ai ' ;*/
         l_from_str_like := l_from_str_like || l_newline; /* jdochert 04/24/02 ||', AS_INTERESTS ai ' ;*/
         l_from_str_btw  := l_from_str_btw || l_newline; /* jdochert 04/24/02 ||', AS_INTERESTS ai ' ;*/
      END IF;

      /* for lead expected purchase we need to add AS_SALES_LEAD_LINES in the from clause */
      IF mod(l_relation_product,137) = 0 and mod(l_relation_product,67) <> 0 THEN
         l_from_str := l_from_str || l_newline; /* jdochert 04/24/02   ||', AS_SALES_LEAD_LINES asl ' ; */
      ELSIF mod(l_relation_product,137) = 0 and mod(l_relation_product,67) = 0 THEN
         l_from_str := l_from_str || l_newline; /* jdochert 04/24/02   ||', AS_SALES_LEAD_LINES asl ' ; */
         l_from_str_like := l_from_str_like || l_newline; /* jdochert 04/24/02   ||', AS_SALES_LEAD_LINES asl ' ; */
         l_from_str_btw  := l_from_str_btw || l_newline; /* jdochert 04/24/02   ||', AS_SALES_LEAD_LINES asl ' ; */
      END IF;

       /* for opportunity expected purchase we need to add AS_SALES_LEAD_LINES in the from clause */
      IF mod(l_relation_product,139) = 0 and mod(l_relation_product,67) <> 0 THEN
         l_from_str := l_from_str || l_newline; /* jdochert 04/24/02  ||', AS_LEAD_LINES al ' ; */
      ELSIF mod(l_relation_product,139) = 0 and mod(l_relation_product,67) = 0 THEN
         l_from_str := l_from_str || l_newline; /* jdochert 04/24/02  ||', AS_LEAD_LINES al ' ; */
         l_from_str_like := l_from_str_like || l_newline; /* jdochert 04/24/02  ||', AS_LEAD_LINES al ' ; */
         l_from_str_btw  := l_from_str_btw || l_newline; /* jdochert 04/24/02  ||', AS_LEAD_LINES al ' ; */
      END IF;

      /* construct union statement for qual_usg_id=-1012 */
      IF mod(l_relation_product, 67) = 0 or mod(l_relation_product, 73) = 0 THEN
         -- dblee/eihsu: 08/15/03 added p_new_mode_fetch flag
		 l_from_str_eq := append_inlineview(l_from_str_eq, p_new_mode_fetch);
         l_from_str_like := append_inlineview(l_from_str_like, p_new_mode_fetch);
         l_from_str_btw := append_inlineview(l_from_str_btw, p_new_mode_fetch);

         IF l_relation_product <> 324347 THEN
            l_qual_rules :=
               l_select_eq || l_newline ||
                  l_from_str_eq || l_newline ||
                  l_where_str || l_newline ||
                     l_predicate_eq || l_newline ||
               'UNION ALL' || l_newline ||
               l_select_like || l_newline ||
                  l_from_str_like || l_newline ||
                  l_where_str || l_newline
                     || l_predicate_like || l_newline ||
               'UNION ALL' || l_newline ||
               l_select_like || l_newline ||
                  l_from_str_like || l_newline ||
                  l_where_str || l_newline ||
                     replace(l_predicate_like,'a.squal_fc01 = Q1012LK.first_char',
                           'Q1012LK.first_char= ''%''') || l_newline ||
               'UNION ALL' || l_newline ||
               l_select_btw || l_newline ||
                  l_from_str_btw || l_newline ||
                  l_where_str || l_newline ||
                     l_predicate_btw || l_newline;

            l_ilv2eq :=
               l_select_eq || l_newline ||
                  l_from_str_eq || l_newline ||
                  l_where_str || l_newline ||
                     l_predicate_eq|| l_newline;

            l_ilv2lk := l_newline ||
               l_select_like || l_newline ||
                  l_from_str_like || l_newline ||
                  l_where_str || l_newline ||
                     l_predicate_like || l_newline;

            l_ilv2lkp := l_newline ||
               l_select_like || l_newline ||
                  l_from_str_like || l_newline ||
                  l_where_str || l_newline ||
                     replace(l_predicate_like,'a.squal_fc01 = Q1012LK.first_char',
                           'Q1012LK.first_char= ''%''') || l_newline;

            l_ilv2btwn := l_newline ||
               l_select_btw || l_newline ||
                  l_from_str_btw || l_newline ||
                  l_where_str || l_newline ||
                     l_predicate_btw || l_newline;

         ELSE
        /* added the join condition for tables */
            -- dblee: 08/20/03 replace select clause literal w/ g_select_list_1 variable
		    l_select_like := l_newline || g_select_list_1;

            l_qual_rules :=
               l_select_eq || l_newline ||
                  l_from_str_eq || l_newline ||
                  l_where_str || l_newline ||
                     l_predicate_eq || l_newline ||
                     'and Q1012R1.terr_id = Q1003R1.terr_id' || l_newline ||
               'UNION ALL' || l_newline ||
               l_select_like || l_newline ||
                  l_from_str_like || l_newline ||
                  l_where_str || l_newline ||
                     l_predicate_like ||  l_newline ||
                     'and Q1012LK.terr_id = Q1007R1.terr_id' || l_newline ||
               'UNION ALL' || l_newline ||
               l_select_like || l_newline ||
                  l_from_str_like || l_newline ||
                  l_where_str || l_newline ||
                     replace(l_predicate_like,'a.squal_fc01 = Q1012LK.first_char',
                           'Q1012LK.first_char= ''%''') || l_newline ||
               'UNION ALL' || l_newline ||
               l_select_btw || l_newline ||
                  l_from_str_btw || l_newline ||
                  l_where_str || l_newline ||
                     l_predicate_btw || l_newline ||
                     'and Q1012BT.terr_id = Q1003R1.terr_id' || l_newline;

            l_ilv2eq :=
               l_select_eq || l_newline ||
                  l_from_str_eq || l_newline ||
                  l_where_str || l_newline ||
                     l_predicate_eq || l_newline ||
                     'and Q1012R1.terr_id = Q1003R1.terr_id' || l_newline ||
                     'and Q1012R1.terr_id = Q1007R1.terr_id'|| l_newline;

            l_ilv2lk := l_newline ||
               l_select_like || l_newline ||
                  l_from_str_like || l_newline ||
                  l_where_str || l_newline ||
                     l_predicate_like || l_newline ||
                     'and Q1012LK.terr_id = Q1003R1.terr_id' || l_newline ||
                     'and Q1012LK.terr_id = Q1007R1.terr_id'|| l_newline;

            l_ilv2lkp := l_newline ||
               l_select_like || l_newline ||
                  l_from_str_like || l_newline ||
                  l_where_str || l_newline ||
                     replace(l_predicate_like,'a.squal_fc01 = Q1012LK.first_char',
                           'Q1012LK.first_char= ''%''') || l_newline ||
                     'and Q1012LK.terr_id = Q1003R1.terr_id' || l_newline ||
                     'and Q1012LK.terr_id = Q1007R1.terr_id'|| l_newline;

            l_ilv2btwn := l_newline ||
               l_select_btw || l_newline ||
                  l_from_str_btw || l_newline ||
                  l_where_str || l_newline ||
                     l_predicate_btw || l_newline || l_newline ||
                     'and Q1012BT.terr_id = Q1003R1.terr_id' || l_newline ||
                     'and Q1012BT.terr_id = Q1007R1.terr_id' || l_newline;

         END IF;

      ELSE
         -- dblee/eihsu: 08/15/03 added p_new_mode_fetch flag
         l_from_str := append_inlineview(l_from_str, p_new_mode_fetch);

         IF l_relation_product <> 382439 THEN
            l_qual_rules :=
               l_from_str || l_newline ||
               l_where_str || l_newline ||
                  l_predicate || l_newline || ';' ;

              -- dblee: 08/20/03 replaced select clause literal w/ g_select_list_1 variable

           /* ARPATEL BUG#3455772 03/11/2004 */
            IF p_relation_product = 672899
            THEN
              IF p_new_mode_fetch = 'Y'
              THEN
               p_sql :=
               'SELECT /*+ use_concat no_merge */ A.*,ILV.terr_id,ILV.absolute_rank,ILV.top_level_terr_id ,ILV.num_winners ';

              ELSE
                p_sql :=
               'SELECT /*+ use_concat no_merge */ a.trans_object_id,a.trans_detail_object_id,a.worker_id,a.header_id1,a.header_id2,' ||
	       'ILV.terr_id,ILV.absolute_rank,ILV.top_level_terr_id ,ILV.num_winners,ILV.org_id ' ;
                /* bug 3835831 */
                IF (mod(p_relation_product, 79) = 0) THEN
                  p_sql := p_sql || ' ,A.SQUAL_NUM01, A.SQUAL_NUM02 ';
                END IF;
            END IF;

         p_sql := p_sql ||
                  l_from_str || l_newline ||
                  l_where_str || l_newline ||
                     l_predicate || l_newline;
            ELSE
             p_sql := g_select_list_1;

             /* bug 3835831 */
             IF ((mod(p_relation_product, 79) = 0) AND (p_new_mode_fetch <> 'Y')) THEN
               p_sql := p_sql || ' ,A.SQUAL_NUM01, A.SQUAL_NUM02 ';
             END IF;

             p_sql := p_sql || l_newline ||
                  l_from_str || l_newline ||
                  l_where_str || l_newline ||
                     l_predicate || l_newline;

            END IF;

         ELSE
            /* table join condition for 382439 relation_product */
            l_qual_rules :=
			   l_from_str || l_newline ||
               l_where_str || l_newline ||
                  l_predicate || l_newline ||
                  'AND Q1004R1.terr_id = Q1003R1.terr_id AND Q1004R1.terr_id = Q1007R1.terr_id'
                  || l_newline || ';';

            -- dblee: 08/20/03 - replaced select clause literal w/ g_select_list_1 variable
            p_sql := g_select_list_1;

             /* bug 3835831 */
             IF ((mod(p_relation_product, 79) = 0) AND (p_new_mode_fetch <> 'Y')) THEN
               p_sql := p_sql || ' ,A.SQUAL_NUM01, A.SQUAL_NUM02 ';
             END IF;

            p_sql := p_sql || l_newline ||
                  l_from_str || l_newline || -- dblee: 08/23/03 added from clause
                  l_where_str || l_newline ||
                     l_predicate || l_newline ||
                     'AND Q1004R1.terr_id = Q1003R1.terr_id AND Q1004R1.terr_id = Q1007R1.terr_id' || l_newline;

         END IF;
      END IF;

      p_ilv2eq := l_ilv2eq;
      p_ilv2lk := l_ilv2lk;
      p_ilv2lkp := l_ilv2lkp;
      p_ilv2btwn := l_ilv2btwn;

   EXCEPTION
      WHEN OTHERS THEN
         g_ProgramStatus := 1;
         Add_To_PackageTable ('-- Program failed in build_ilv2 ');

   END build_ilv2;


   /*************************************************
   ** Gets all the qualifier combinations that are used by this
   ** Usage and builds the SQL statement to check the
   ** qualifier rules
   **************************************************/
   PROCEDURE build_qualifier_rules(
      p_source_id         IN          NUMBER,
      p_qual_type_id      IN          NUMBER,
      p_relation_product  IN          NUMBER,
      p_input_table_name  IN          VARCHAR2,
      p_print_flag        IN          VARCHAR2,
      -- dblee/eihsu 08/15/03 added new mode flag
	  p_new_mode_fetch    IN          CHAR,
      p_sql               OUT NOCOPY  VARCHAR2,
      p_ilv2eq            OUT NOCOPY  VARCHAR2,
      p_ilv2lk            OUT NOCOPY  VARCHAR2,
      p_ilv2lkp           OUT NOCOPY  VARCHAR2,
      p_ilv2btwn          OUT NOCOPY  VARCHAR2)
   AS

      CURSOR c_rel_prod_detail
      IS
         SELECT DISTINCT jtqp.relation_product
               ,jtqf.qual_usg_id
               ,jqu.alias_rule1
               ,jqu.alias_op_like
               ,jqu.alias_op_between
               ,jqu.op_eql
               ,jqu.op_not_eql
               ,jqu.op_lss_thn
               ,jqu.op_lss_thn_eql
               ,jqu.op_grtr_thn
               ,jqu.op_grtr_thn_eql
               ,jqu.op_like
               ,jqu.op_not_like
               ,jqu.op_between
               ,jqu.op_not_between
               ,jqu.op_common_where
         FROM jtf_qual_usgs_all jqu,
               jtf_tae_qual_factors jtqf,
               jtf_tae_qual_products jtqp,
               jtf_tae_qual_prod_factors jtpf
         WHERE jqu.org_id = -3113
            AND jqu.qual_usg_id = jtqf.qual_usg_id
            and jtpf.qual_factor_id= jtqf.qual_factor_id
            and jtqp.qual_product_id = jtpf.qual_product_id
            and jtqp.relation_product = p_relation_product
            and jtqp.source_id = p_source_id
            and jtqp.trans_object_type_id= p_qual_type_id
            and jqu.op_not_eql is NULL
            and jqu.op_not_like is NULL
            and jqu.op_not_between is NULL
         ORDER BY jtqf.qual_usg_id;

      l_qual_usg_id        NUMBER;
      l_qual_rules         VARCHAR2(32767);
      l_rule               VARCHAR2(32767);
      l_counter            NUMBER := 1;
      l_newline            VARCHAR2(2);
      l_indent             VARCHAR2(30);
      l_sysdate            DATE;
      l_str_len            NUMBER;
      l_start              NUMBER;
      l_get_nchar          NUMBER;
      l_next_newline       NUMBER;
      l_rule_str           VARCHAR2(256);
      l_from_str           VARCHAR2(32767);
      l_from_str_eq        VARCHAR2(32767);
      l_from_str_like      VARCHAR2(32767);
      l_from_str_btw       VARCHAR2(32767);
      l_where_str          VARCHAR2(32767);
      l_predicate          VARCHAR2(32767);
      l_predicate_eq       VARCHAR2(32767);
      l_predicate_like     VARCHAR2(32767);
      l_predicate_btw      VARCHAR2(32767);
      l_select_eq          VARCHAR2(32767);
      l_select_like        VARCHAR2(32767);
      l_select_btw         VARCHAR2(32767);
      l_ilv2eq             VARCHAR2(32767);
      l_ilv2lk             VARCHAR2(32767);
      l_ilv2lkp            VARCHAR2(32767);
      l_ilv2btwn           VARCHAR2(32767);

   BEGIN

      --dbms_output.put_line('Inside build_rule_expression ');

      l_newline := FND_GLOBAL.Local_Chr(10); /* newline character */
      l_sysdate := SYSDATE;

      FOR JTF_csr IN c_rel_prod_detail LOOP

         IF G_Debug THEN
            Write_Log(2, ' ');
            Write_Log(2, '/*----------------------------------------*/');
            Write_Log(2, 'PACKAGE RULE #' || l_counter );
            Write_Log(2, 'QUAL_USG_ID: ' || TO_CHAR(JTF_csr.qual_usg_id) );
            Write_Log(2, ' ');

            Write_Log(2, '/*----------------------------------------*/');
            Write_Log(2, ' ');
         END IF;

         --IF (l_counter > 1) THEN
         --    l_qual_rules := l_newline || l_qual_rules || l_newline ||
         --                    ' UNION ALL ';
         --END IF;
         IF mod(p_relation_product,67) <> 0 and mod(p_relation_product,73) <> 0 THEN

            IF l_counter = 1 THEN

               --l_from_str := l_newline || 'jtf_tae_trans_objs A' ||  l_newline || ',' || JTF_csr.alias_rule1;
               l_from_str := l_newline
                  || p_input_table_name || '  A' || l_newline
                  || ',' || JTF_csr.alias_rule1;

               l_where_str := l_newline || 'WHERE 1 = 1' ;
               -- eihsu: worker_id added 06/09/2003
               -- bug # 4213107 : worker_id condition should not be added to NMC packages
               IF (p_new_mode_fetch <> 'Y') THEN
                 l_where_str := l_where_str  || l_newline || 'AND a.worker_id = p_worker_id ';
               END IF;

               l_predicate := l_newline
                  || build_predicate_for_operator(JTF_csr.op_common_where
                        ,JTF_csr.op_eql
                        ,JTF_csr.op_lss_thn
                        ,JTF_csr.op_lss_thn_eql
                        ,JTF_csr.op_grtr_thn
                        ,JTF_csr.op_grtr_thn_eql
                        ,JTF_csr.op_like
                        ,JTF_csr.op_between
                        ,l_newline);

            ELSE -- l_counter > 1

               l_from_str := l_from_str || l_newline ||',' || JTF_csr.alias_rule1;
               l_predicate := l_predicate || l_newline
                  || build_predicate_for_operator(JTF_csr.op_common_where
                        ,JTF_csr.op_eql
                        ,JTF_csr.op_lss_thn
                        ,JTF_csr.op_lss_thn_eql
                        ,JTF_csr.op_grtr_thn
                        ,JTF_csr.op_grtr_thn_eql
                        ,JTF_csr.op_like
                        ,JTF_csr.op_between
                        ,l_newline);
            END IF; -- l_counter = 1

         ELSE -- mod(p_relation_product,67) = 0 or mod(p_relation_product,73) = 0

            IF l_counter = 1 THEN

                IF JTF_csr.qual_usg_id = -1012 or JTF_csr.qual_usg_id = -1102 THEN
                   -- dblee: 08/20/03 replaced select clause literal w/ g_select_list_1 variable
                   l_select_eq := l_newline || g_select_list_1;
                   l_select_like := l_newline || g_select_list_1;
   		           l_select_btw := l_newline || g_select_list_1;

                   l_from_str_eq := l_newline || 'FROM '|| p_input_table_name ||' A' || l_newline
                      || ',' || JTF_csr.alias_rule1;
                   l_from_str_like := l_newline || 'FROM '|| p_input_table_name ||' A'|| l_newline
                      || ',' || JTF_csr.alias_op_like;
                   l_from_str_btw := l_newline || 'FROM '|| p_input_table_name ||' A' || l_newline
                      || ',' || JTF_csr.alias_op_between;

                   l_where_str := l_newline || 'WHERE 1 = 1 ' ;
                   -- eihsu: worker_id added 06/09/2003
                   -- bug # 4213107 : worker_id condition should not be added to NMC packages
                   IF (p_new_mode_fetch <> 'Y') THEN
                     l_where_str := l_where_str  || l_newline || 'AND a.worker_id = p_worker_id ';
                   END IF;

                   l_predicate_eq := l_newline || 'AND ' || JTF_csr.op_eql;
                   l_predicate_like := l_newline ||'AND ' || JTF_csr.op_like;
                   l_predicate_btw := l_newline || 'AND ' || JTF_csr.op_between;

                ELSE

                   l_from_str_eq := l_newline || 'FROM '|| p_input_table_name ||'  A' ||  l_newline
                                        || ',' || JTF_csr.alias_rule1;
                   l_where_str := l_newline || 'WHERE 1 = 1' ;
                   -- eihsu: worker_id added 06/09/2003
                   -- bug # 4213107 : worker_id condition should not be added to NMC packages
                   IF (p_new_mode_fetch <> 'Y') THEN
                     l_where_str := l_where_str  || l_newline || 'AND a.worker_id = p_worker_id ';
                   END IF;
                   l_predicate_eq := l_newline
                   || build_predicate_for_operator(JTF_csr.op_common_where
                   ,JTF_csr.op_eql
                   ,JTF_csr.op_lss_thn
                   ,JTF_csr.op_lss_thn_eql
                   ,JTF_csr.op_grtr_thn
                   ,JTF_csr.op_grtr_thn_eql
                   ,JTF_csr.op_like
                   ,JTF_csr.op_between
                   ,l_newline);

                END IF; -- JTF_csr.qual_usg_id = -1012 or JTF_csr.qual_usg_id = -1102

            ELSE /* counter > 1*/

               IF JTF_csr.qual_usg_id = -1012 or JTF_csr.qual_usg_id = -1102 THEN
                  -- dblee: 08/20/03 replaced select clause literal w/ g_select_list_1 variable
                  l_select_eq := l_newline || g_select_list_1;
                  l_select_like := l_newline || g_select_list_1;
                  l_select_btw := l_newline || g_select_list_1;

                  l_from_str_like := l_from_str_eq || l_newline || ',' || JTF_csr.alias_op_like;
                  l_from_str_btw := l_from_str_eq ||  l_newline || ',' || JTF_csr.alias_op_between;
                  l_from_str_eq := l_from_str_eq ||l_newline || ',' || JTF_csr.alias_rule1;

                  l_where_str := l_newline || 'WHERE 1 = 1' ;
                  -- eihsu: worker_id added 06/09/2003
                  -- bug # 4213107 : worker_id condition should not be added to NMC packages
                  IF (p_new_mode_fetch <> 'Y') THEN
                    l_where_str := l_where_str  || l_newline || 'AND a.worker_id = p_worker_id ';
                  END IF;

                  /* sbehera added AND 05/02/2002 */
                  l_predicate_like := l_predicate_eq|| l_newline || 'AND '|| JTF_csr.op_like;
                  l_predicate_btw := l_predicate_eq || l_newline || 'AND '|| JTF_csr.op_between;
                  l_predicate_eq := l_predicate_eq || l_newline || 'AND '|| JTF_csr.op_eql;

               ELSE -- JTF_csr.qual_usg_id not in (-1012, -1102)
                  l_from_str_eq := l_from_str_eq || l_newline || ',' || JTF_csr.alias_rule1;
                  l_from_str_like := l_from_str_like || l_newline || ',' || JTF_csr.alias_rule1;
                  l_from_str_btw := l_from_str_btw || l_newline || ',' || JTF_csr.alias_rule1;

                  l_predicate_eq := l_predicate_eq || l_newline
                     || build_predicate_for_operator(JTF_csr.op_common_where
                           ,JTF_csr.op_eql
                           ,JTF_csr.op_lss_thn
                           ,JTF_csr.op_lss_thn_eql
                           ,JTF_csr.op_grtr_thn
                           ,JTF_csr.op_grtr_thn_eql
                           ,JTF_csr.op_like
                           ,JTF_csr.op_between
                           ,l_newline);

                  l_predicate_like := l_predicate_like || l_newline
                     || build_predicate_for_operator(JTF_csr.op_common_where
                           ,JTF_csr.op_eql
                           ,JTF_csr.op_lss_thn
                           ,JTF_csr.op_lss_thn_eql
                           ,JTF_csr.op_grtr_thn
                           ,JTF_csr.op_grtr_thn_eql
                           ,JTF_csr.op_like
                           ,JTF_csr.op_between
                           ,l_newline);

                  l_predicate_btw := l_predicate_btw || l_newline
                     || build_predicate_for_operator(JTF_csr.op_common_where
                           ,JTF_csr.op_eql
                           ,JTF_csr.op_lss_thn
                           ,JTF_csr.op_lss_thn_eql
                           ,JTF_csr.op_grtr_thn
                           ,JTF_csr.op_grtr_thn_eql
                           ,JTF_csr.op_like
                           ,JTF_csr.op_between
                           ,l_newline);
               END IF; -- JTF_csr.qual_usg_id = -1012 or JTF_csr.qual_usg_id = -1102

            END IF; /* counter */

         END IF; /* mod */

         l_counter := l_counter + 1;
      END LOOP;

      /* for account classification we need to add AS_INTERESTS in the from clause */
      IF (mod(p_relation_product,79) = 0 and mod(p_relation_product,67) <> 0) THEN
         l_from_str := l_from_str || l_newline; /* jdochert 04/24/02 ||', AS_INTERESTS ai ' ;*/
      ELSIF (mod(p_relation_product,79) = 0 and mod(p_relation_product,67) = 0) THEN
          l_from_str := l_from_str || l_newline; /* jdochert 04/24/02 ||', AS_INTERESTS ai ' ;*/
          l_from_str_like := l_from_str_like || l_newline; /* jdochert 04/24/02 ||', AS_INTERESTS ai ' ;*/
          l_from_str_btw  := l_from_str_btw || l_newline; /* jdochert 04/24/02 ||', AS_INTERESTS ai ' ;*/
      END IF;

      /* for lead expected purchase we need to add AS_SALES_LEAD_LINES in the from clause */
      IF (mod(p_relation_product,137) = 0 and mod(p_relation_product,67) <> 0) THEN
         l_from_str := l_from_str || l_newline; /* jdochert 04/24/02   ||', AS_SALES_LEAD_LINES asl ' ; */
      ELSIF (mod(p_relation_product,137) = 0 and mod(p_relation_product,67) = 0) THEN
          l_from_str := l_from_str || l_newline; /* jdochert 04/24/02   ||', AS_SALES_LEAD_LINES asl ' ; */
          l_from_str_like := l_from_str_like || l_newline; /* jdochert 04/24/02   ||', AS_SALES_LEAD_LINES asl ' ; */
          l_from_str_btw  := l_from_str_btw || l_newline; /* jdochert 04/24/02   ||', AS_SALES_LEAD_LINES asl ' ; */
      END IF;

      /* for opportunity expected purchase we need to add AS_SALES_LEAD_LINES in the from clause */
      IF (mod(p_relation_product,139) = 0 and mod(p_relation_product,67) <> 0) THEN
         l_from_str := l_from_str || l_newline; /* jdochert 04/24/02  ||', AS_LEAD_LINES al ' ; */
      ELSIF (mod(p_relation_product,139) = 0 and mod(p_relation_product,67) = 0) THEN
          l_from_str := l_from_str || l_newline; /* jdochert 04/24/02  ||', AS_LEAD_LINES al ' ; */
          l_from_str_like := l_from_str_like || l_newline; /* jdochert 04/24/02  ||', AS_LEAD_LINES al ' ; */
          l_from_str_btw  := l_from_str_btw || l_newline; /* jdochert 04/24/02  ||', AS_LEAD_LINES al ' ; */
      END IF;

      /* construct union statement for qual_usg_id = -1012 */
      IF mod(p_relation_product,67) = 0 or mod(p_relation_product,73) = 0 THEN

         -- dblee/eihsu: 08/15/03 added p_new_mode_fetch flag
		  l_from_str_eq := append_inlineview(l_from_str_eq, p_new_mode_fetch);
          l_from_str_like := append_inlineview(l_from_str_like, p_new_mode_fetch);
          l_from_str_btw := append_inlineview(l_from_str_btw, p_new_mode_fetch);

         IF p_relation_product <> 324347 THEN
            l_qual_rules :=
               l_select_eq || l_newline ||
                  l_from_str_eq || l_newline ||
                  l_where_str || l_newline ||
                     l_predicate_eq ||  l_newline ||
               'UNION ALL' || l_newline ||
               l_select_like || l_newline ||
                  l_from_str_like || l_newline ||
                  l_where_str || l_newline ||
                     l_predicate_like || l_newline ||
               'UNION ALL' || l_newline ||
               l_select_like || l_newline ||
                  l_from_str_like || l_newline ||
                  l_where_str || l_newline ||
                     replace(l_predicate_like,'a.squal_fc01 = Q1012LK.first_char',
                           'Q1012LK.first_char= ''%''') || l_newline ||
               'UNION ALL' || l_newline ||
               l_select_btw || l_newline ||
                  l_from_str_btw || l_newline ||
                  l_where_str || l_newline ||
                     l_predicate_btw || l_newline;

            l_ilv2eq :=
               l_select_eq || l_newline ||
                  l_from_str_eq || l_newline ||
                  l_where_str || l_newline ||
                     l_predicate_eq|| l_newline;

            l_ilv2lk := l_newline ||
               l_select_like || l_newline ||
                  l_from_str_like || l_newline ||
                  l_where_str || l_newline ||
                     l_predicate_like || l_newline;

            l_ilv2lkp := l_newline ||
               l_select_like || l_newline ||
                  l_from_str_like || l_newline ||
                  l_where_str || l_newline ||
                     replace(l_predicate_like,'a.squal_fc01 = Q1012LK.first_char',
                           'Q1012LK.first_char= ''%''') || l_newline;

            l_ilv2btwn := l_newline ||
               l_select_btw || l_newline ||
                  l_from_str_btw || l_newline ||
                  l_where_str || l_newline ||
                     l_predicate_btw || l_newline;

         ELSE -- p_relation_product = 324347
            /* added the join condition for tables */
            -- dblee: 08/20/03 replaced select clause literal w/ g_select_list_1 variable
		    l_select_like := l_newline || g_select_list_1;

            l_qual_rules :=
               l_select_eq || l_newline ||
                  l_from_str_eq || l_newline ||
                  l_where_str || l_newline ||
                     l_predicate_eq || l_newline ||
                     'and Q1012R1.terr_id = Q1003R1.terr_id' || l_newline ||
               'UNION ALL' || l_newline ||
               l_select_like ||l_newline ||
                  l_from_str_like || l_newline ||
                  l_where_str || l_newline ||
                     l_predicate_like || l_newline ||
                     'and Q1012LK.terr_id = Q1007R1.terr_id' || l_newline ||
               'UNION ALL' || l_newline ||
               l_select_like || l_newline ||
                  l_from_str_like || l_newline ||
                  l_where_str || l_newline ||
                     replace(l_predicate_like,'a.squal_fc01 = Q1012LK.first_char',
                           'Q1012LK.first_char= ''%''') || l_newline ||
               'UNION ALL' || l_newline ||
               l_select_btw || l_newline ||
                  l_from_str_btw || l_newline ||
                  l_where_str || l_newline ||
                     l_predicate_btw || l_newline ||
                     'and Q1012BT.terr_id = Q1003R1.terr_id' || l_newline;

            l_ilv2eq :=
               l_select_eq || l_newline ||
                  l_from_str_eq || l_newline ||
                  l_where_str || l_newline ||
                     l_predicate_eq || l_newline ||
                     'and Q1012R1.terr_id = Q1003R1.terr_id' || l_newline ||
                     'and Q1012R1.terr_id = Q1007R1.terr_id'|| l_newline;

            l_ilv2lk := l_newline ||
               l_select_like || l_newline ||
                  l_from_str_like || l_newline ||
                  l_where_str || l_newline ||
                     l_predicate_like || l_newline ||
                     'and Q1012LK.terr_id = Q1003R1.terr_id' || l_newline ||
                     'and Q1012LK.terr_id = Q1007R1.terr_id' || l_newline;

            l_ilv2lkp := l_newline ||
               l_select_like || l_newline ||
                  l_from_str_like || l_newline ||
                  l_where_str || l_newline ||
                     replace(l_predicate_like,'a.squal_fc01 = Q1012LK.first_char',
                           'Q1012LK.first_char= ''%''') || l_newline ||
                     'and Q1012LK.terr_id = Q1003R1.terr_id' || l_newline ||
                     'and Q1012LK.terr_id = Q1007R1.terr_id'||l_newline ;

            l_ilv2btwn := l_newline ||
               l_select_btw || l_newline ||
                  l_from_str_btw || l_newline ||
                  l_where_str || l_newline ||
                     l_predicate_btw || l_newline || l_newline ||
                     'and Q1012BT.terr_id = Q1003R1.terr_id' || l_newline  ||
                     'and Q1012BT.terr_id = Q1007R1.terr_id'|| l_newline;

         END IF; -- p_relation_product <> 324347

      ELSE -- p_relation_product not divisible by 67 or 73

         -- dblee/eihsu: 08/15/03 added p_new_mode_fetch flag
		 l_from_str := append_inlineview(l_from_str, p_new_mode_fetch);

         IF p_relation_product <> 382439 THEN
            l_qual_rules := -- where's the 'select' clause?
               l_from_str || l_newline ||
               l_where_str || l_newline ||
                  l_predicate || l_newline || ';' ;

            -- dblee: 08/20/03 replaced select clause literal w/ g_select_list_1 variable
            p_sql :=
               g_select_list_1 ||
               l_from_str || l_newline ||
               l_where_str || l_newline ||
                  l_predicate || l_newline;
         ELSE /* table join condition for 382439 relation_product */
            l_qual_rules := -- where's the 'select' clause?
               l_from_str || l_newline ||
               l_where_str || l_newline ||
                  l_predicate || l_newline ||
                  'AND Q1004R1.terr_id = Q1003R1.terr_id AND Q1004R1.terr_id = Q1007R1.terr_id'
                  || l_newline || ';';

            -- dblee: 08/20/03 replaced select clause literal w/ g_select_list_1 variable
		    p_sql :=
               g_select_list_1 || l_newline || -- where's the 'from' clause?
               l_where_str || l_newline ||
                  l_predicate || l_newline ||
                  'AND Q1004R1.terr_id = Q1003R1.terr_id AND Q1004R1.terr_id = Q1007R1.terr_id'
                  || l_newline;
         END IF; -- p_relation_product <> 382439

      END IF; -- p_relation_product divisible by 67 or 73

      IF p_print_flag= 'N' THEN
         write_buffer_content(l_qual_rules);
      ELSE
         p_ilv2eq := l_ilv2eq;
         p_ilv2lk := l_ilv2lk;
         p_ilv2lkp := l_ilv2lkp;
         p_ilv2btwn := l_ilv2btwn;
         --p_sql := l_qual_rules;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         g_ProgramStatus := 1;
         Add_To_PackageTable ('-- Program encountered invalid territory ');

   END build_qualifier_rules;


   /*************************************************
   ** Gets all the qualifier combinations that are used by this
   ** Usage and builds the SQL statement to check the
   ** qualifier rules. This is applicable for
   ** account qualifier,opportunutiy expected purchase and lead expected purchase
   ** but no customer name range
   ** opp inventort item
   **************************************************/
   PROCEDURE build_qualifier_rules1(
      p_source_id         IN          NUMBER,
      p_qual_type_id      IN          NUMBER,
      p_relation_product  IN          NUMBER,
      p_input_table_name  IN          VARCHAR2,
      p_print_flag        IN          VARCHAR2,
      -- dblee: 08/26/03 added p_new_mode_fetch flag argument
	  p_new_mode_fetch    IN          CHAR,
      p_sql               OUT NOCOPY  VARCHAR2)
   AS
      l_ilv1sql           VARCHAR2(32767);
      l_rel_prod1         NUMBER;
      l_rel_prod2         NUMBER;
      l_ilv2eq            VARCHAR2(32767);
      l_ilv2lk            VARCHAR2(32767);
      l_ilv2lkp           VARCHAR2(32767);
      l_ilv2btwn          VARCHAR2(32767);
      l_sql               VARCHAR2(32767);

   BEGIN

      IF mod(p_relation_product,79) = 0 THEN
         l_rel_prod1 := 79;
      ELSIF  mod(p_relation_product,137) = 0 THEN
         l_rel_prod1 := 137;
      ELSIF  mod(p_relation_product,113) = 0 THEN
         l_rel_prod1 := 113;
      ELSIF  mod(p_relation_product,131) = 0 THEN
         l_rel_prod1 := 131;
      ELSIF  mod(p_relation_product,139) = 0 THEN
         l_rel_prod1 := 139;
      ELSIF  mod(p_relation_product,163) = 0 THEN
         l_rel_prod1 := 163;
      ELSIF  mod(p_relation_product,167) = 0 THEN
         l_rel_prod1 := 167;
      END IF;

    IF p_new_mode_fetch = 'Y'
    THEN
                   Add_To_PackageTable (G_INDENT || 'SELECT /*+ NO_MERGE(ILV1) NO_MERGE(ILV2) ' );
             Add_To_PackageTable (G_INDENT || '                 USE_HASH(ILV1 ILV2) */' );
             Add_To_PackageTable (G_INDENT || '         ILV2.TRANS_OBJECT_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.TRANS_DETAIL_OBJECT_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.HEADER_ID1' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.HEADER_ID2' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_FC01' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_FC02' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_FC03' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_FC04' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_FC05' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC01' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC02' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC03' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC04' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC05' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC06' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC07' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC08' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC09' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC10' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR01' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR02' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR03' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR04' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR05' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR06' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR07' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR08' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR09' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR10' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR11' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR12' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR13' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR14' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR15' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR16' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR17' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR18' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR19' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR20' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR21' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR22' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR23' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR24' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR25' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR26' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR27' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR28' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR30' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR31' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR32' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR33' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR34' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR35' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR36' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR37' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR38' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR39' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR40' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR41' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR42' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR43' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR44' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR45' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR46' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR47' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR48' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR49' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR50' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR51' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR52' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR53' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR54' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR55' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR56' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR57' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR58' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR59' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR60' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM01' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM02' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM03' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM04' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM05' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM06' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM07' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM08' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM09' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM10' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM11' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM12' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM13' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM14' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM15' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM16' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM17' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM18' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM19' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM20' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM21' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM22' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM23' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM24' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM25' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM26' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM27' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM28' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM29' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM30' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM31' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM32' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM33' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM34' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM35' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM36' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM37' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM38' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM39' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM40' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM41' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM42' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM43' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM44' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM45' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM46' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM47' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM48' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM49' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM50' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM51' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM52' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM53' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM54' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM55' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM56' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM57' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM58' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM59' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM60' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.ASSIGNED_FLAG' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.PROCESSED_FLAG' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.ORG_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SECURITY_GROUP_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.OBJECT_VERSION_NUMBER' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.WORKER_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.TERR_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.ABSOLUTE_RANK' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.TOP_LEVEL_TERR_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.NUM_WINNERS' );

    ELSE
      Add_To_PackageTable (G_INDENT || '   SELECT /*+ NO_MERGE(ILV1) NO_MERGE(ILV2) ');
      Add_To_PackageTable (G_INDENT || '              USE_HASH(ILV1 ILV2) */');
      Add_To_PackageTable (G_INDENT || '          ILV2.trans_object_id');
      Add_To_PackageTable (G_INDENT || '        , ILV2.trans_detail_object_id');
      -- eihsu 06/19/2003 worker_id
      Add_To_PackageTable (G_INDENT || '        , ILV2.worker_id');
      Add_To_PackageTable (G_INDENT || '        , ILV2.header_id1');
      Add_To_PackageTable (G_INDENT || '        , ILV2.header_id2');
      Add_To_PackageTable (G_INDENT || '        , ILV2.terr_id');
      Add_To_PackageTable (G_INDENT || '        , ILV2.absolute_rank');
      Add_To_PackageTable (G_INDENT || '        , ILV2.top_level_terr_id ');
      Add_To_PackageTable (G_INDENT || '        , ILV2.num_winners');
      Add_To_PackageTable (G_INDENT || '        , ILV2.org_id');
    END IF;

      Add_To_PackageTable (G_INDENT || '   FROM');
      Add_To_PackageTable (G_INDENT || '       ( /* INLINE VIEW1 */');

      --get the content of ILV1
      -- dblee: 08/26/03 added p_new_mode_fetch flag argument
      build_ilv1(p_source_id, p_qual_type_id, p_relation_product, l_rel_prod1, p_new_mode_fetch, l_ilv1sql);
      write_buffer_content(l_ilv1sql);

      Add_To_PackageTable (G_INDENT || '       ) ILV1, ');
      Add_To_PackageTable (' ');
      Add_To_PackageTable (G_INDENT || '       ( /* INLINE VIEW2 */');

      --get the content of ILV2
      -- dblee/eihsu: 08/26/03 added p_new_mode_fetch flag argument
      Build_ilv2(p_source_id, p_qual_type_id, p_relation_product, l_rel_prod1,
                  p_input_table_name, p_new_mode_fetch, l_sql, l_ilv2eq, l_ilv2lk, l_ilv2lkp, l_ilv2btwn);

      write_buffer_content(l_sql);

      Add_To_PackageTable (G_INDENT || '       ) ILV2 ');
      Add_To_PackageTable (G_INDENT || '       WHERE ILV1.terr_id = ILV2.terr_id ');

      IF l_rel_prod1 = 79 THEN
         /* bug 3835831 */
         Add_To_PackageTable(G_INDENT || '         AND ILV1.customer_id = ILV2.squal_num01');
         Add_To_PackageTable(G_INDENT || '         AND ( (ILV1.address_id IS NULL )');
         Add_To_PackageTable(G_INDENT || '               OR ');
         Add_To_PackageTable(G_INDENT || '               (ILV1.address_id= ILV2.squal_num02)');
         Add_To_PackageTable(G_INDENT || '             )');
/*
         Add_To_PackageTable(G_INDENT || '         AND ILV1.customer_id = ILV2.trans_object_id');
         Add_To_PackageTable(G_INDENT || '         AND ( (ILV1.address_id IS NULL AND ILV2.trans_detail_object_id IS NULL)');
         Add_To_PackageTable(G_INDENT || '               OR ');
         Add_To_PackageTable(G_INDENT || '               (ILV1.address_id= ILV2.trans_detail_object_id)');
         Add_To_PackageTable(G_INDENT || '             )');
*/
      ELSIF l_rel_prod1 = 137 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.sales_lead_id = ILV2.trans_object_id');
      ELSIF l_rel_prod1 = 113 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.sales_lead_id = ILV2.trans_object_id');
      ELSIF l_rel_prod1 = 131 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.sales_lead_id = ILV2.trans_object_id');
      ELSIF l_rel_prod1 = 139 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.lead_id = ILV2.trans_object_id');
      ELSIF l_rel_prod1 = 163 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.lead_id = ILV2.trans_object_id');
      ELSIF l_rel_prod1 = 167 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.lead_id = ILV2.trans_object_id');
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         g_ProgramStatus := 1;
         Add_To_PackageTable ('-- Program encountered invalid territory ');

   END build_qualifier_rules1;


   /*************************************************
   ** Gets all the qualifier combinations that are used by this
   ** Usage and builds the SQL statement to check the
   ** qualifier rules. This is applicable for customer namerange with
   ** account qualifier,opportunutiy expected purchase and lead expected purchase
   ** opp inventory item
   **************************************************/
   PROCEDURE build_qualifier_rules2(
      p_source_id         IN          NUMBER,
      p_qual_type_id      IN          NUMBER,
      p_relation_product  IN          NUMBER,
      p_input_table_name  IN          VARCHAR2,
      p_print_flag        IN          VARCHAR2,
      -- dblee: 08/26/03: added p_new_mode_fetch flag argument
	  p_new_mode_fetch    IN          CHAR,
      p_sql               OUT NOCOPY  VARCHAR2)
   AS
      l_ilv1sql           VARCHAR2(32767);
      l_rel_prod1         NUMBER;
      l_rel_prod2         NUMBER;
      l_ilv2eq            VARCHAR2(32767);
      l_ilv2lk            VARCHAR2(32767);
      l_ilv2lkp           VARCHAR2(32767);
      l_ilv2btwn          VARCHAR2(32767);

   BEGIN

      IF  mod(p_relation_product,79) = 0 THEN
          l_rel_prod1 := 79;
      ELSIF  mod(p_relation_product,137) = 0 THEN
          l_rel_prod1 := 137;
      ELSIF  mod(p_relation_product,113) = 0 THEN
          l_rel_prod1 := 113;
      ELSIF  mod(p_relation_product,131) = 0 THEN
          l_rel_prod1 := 131;
      ELSIF  mod(p_relation_product,139) = 0 THEN
          l_rel_prod1 := 139;
      ELSIF  mod(p_relation_product,163) = 0 THEN
          l_rel_prod1 := 163;
      ELSIF  mod(p_relation_product,167) = 0 THEN
          l_rel_prod1 := 167;
      END IF;

    IF p_new_mode_fetch = 'Y'
    THEN
             Add_To_PackageTable (G_INDENT || 'SELECT /*+ NO_MERGE(ILV1) NO_MERGE(ILV2) ' );
             Add_To_PackageTable (G_INDENT || '                 USE_HASH(ILV1 ILV2) */' );
             Add_To_PackageTable (G_INDENT || '         ILV2.TRANS_OBJECT_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.TRANS_DETAIL_OBJECT_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.HEADER_ID1' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.HEADER_ID2' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_FC01' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_FC02' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_FC03' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_FC04' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_FC05' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC01' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC02' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC03' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC04' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC05' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC06' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC07' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC08' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC09' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC10' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR01' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR02' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR03' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR04' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR05' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR06' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR07' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR08' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR09' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR10' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR11' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR12' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR13' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR14' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR15' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR16' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR17' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR18' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR19' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR20' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR21' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR22' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR23' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR24' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR25' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR26' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR27' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR28' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR30' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR31' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR32' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR33' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR34' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR35' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR36' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR37' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR38' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR39' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR40' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR41' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR42' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR43' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR44' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR45' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR46' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR47' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR48' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR49' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR50' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR51' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR52' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR53' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR54' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR55' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR56' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR57' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR58' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR59' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR60' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM01' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM02' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM03' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM04' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM05' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM06' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM07' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM08' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM09' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM10' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM11' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM12' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM13' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM14' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM15' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM16' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM17' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM18' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM19' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM20' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM21' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM22' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM23' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM24' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM25' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM26' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM27' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM28' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM29' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM30' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM31' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM32' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM33' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM34' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM35' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM36' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM37' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM38' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM39' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM40' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM41' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM42' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM43' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM44' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM45' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM46' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM47' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM48' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM49' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM50' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM51' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM52' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM53' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM54' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM55' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM56' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM57' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM58' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM59' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM60' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.ASSIGNED_FLAG' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.PROCESSED_FLAG' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.ORG_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SECURITY_GROUP_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.OBJECT_VERSION_NUMBER' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.WORKER_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.TERR_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.ABSOLUTE_RANK' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.TOP_LEVEL_TERR_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.NUM_WINNERS' );
    ELSE
      Add_To_PackageTable (G_INDENT || '   SELECT /*+ NO_MERGE(ILV1) NO_MERGE(ILV2) ');
      Add_To_PackageTable (G_INDENT || '              USE_HASH(ILV1 ILV2) */');
      Add_To_PackageTable (G_INDENT || '          ILV2.trans_object_id');
      Add_To_PackageTable (G_INDENT || '        , ILV2.trans_detail_object_id');
      -- eihsu 06/19/2003 worker_id
      Add_To_PackageTable (G_INDENT || '        , ILV2.worker_id');
      Add_To_PackageTable (G_INDENT || '        , ILV2.header_id1');
      Add_To_PackageTable (G_INDENT || '        , ILV2.header_id2');
      Add_To_PackageTable (G_INDENT || '        , ILV2.terr_id');
      Add_To_PackageTable (G_INDENT || '        , ILV2.absolute_rank');
      Add_To_PackageTable (G_INDENT || '        , ILV2.top_level_terr_id ');
      Add_To_PackageTable (G_INDENT || '        , ILV2.num_winners');
      Add_To_PackageTable (G_INDENT || '        , ILV2.org_id');
    END IF;

      Add_To_PackageTable (G_INDENT || '   FROM');
      Add_To_PackageTable (G_INDENT || '       ( /* INLINE VIEW1 */');

      --get the content of ILV1
      -- dblee: 08/26/03 added p_new_mode_fetch flag argument
      build_ilv1(p_source_id, p_qual_type_id, p_relation_product, l_rel_prod1, p_new_mode_fetch, l_ilv1sql);
      write_buffer_content(l_ilv1sql);

      Add_To_PackageTable (G_INDENT || '      ) ILV1, ');
      Add_To_PackageTable (' ');
      Add_To_PackageTable (G_INDENT || '      ( /* INLINE VIEW2 */');

      --get the content of ILV2
      -- dblee/eihsu: 08/15/03 added p_new_mode_fetch flag argument
      Build_ilv2(p_source_id,p_qual_type_id,p_relation_product,l_rel_prod1,
            p_input_table_name,p_new_mode_fetch,p_sql,l_ilv2eq,l_ilv2lk,l_ilv2lkp,l_ilv2btwn);

      write_buffer_content(l_ilv2eq);

      Add_To_PackageTable (G_INDENT || '       ) ILV2 ');
      Add_To_PackageTable (G_INDENT || '       WHERE ILV1.terr_id = ILV2.terr_id ');

      IF l_rel_prod1 = 79 THEN
         /* bug 3835831 */
         Add_To_PackageTable(G_INDENT || '         AND ILV1.customer_id = ILV2.squal_num01');
         Add_To_PackageTable(G_INDENT || '         AND ( (ILV1.address_id IS NULL )');
         Add_To_PackageTable(G_INDENT || '               OR ');
         Add_To_PackageTable(G_INDENT || '               (ILV1.address_id= ILV2.squal_num02)');
         Add_To_PackageTable(G_INDENT || '             )');
/*
         Add_To_PackageTable(G_INDENT || '         AND ILV1.customer_id = ILV2.trans_object_id');
         Add_To_PackageTable(G_INDENT || '         AND ( (ILV1.address_id IS NULL AND ILV2.trans_detail_object_id IS NULL)');
         Add_To_PackageTable(G_INDENT || '               OR ');
         Add_To_PackageTable(G_INDENT || '               (ILV1.address_id= ILV2.trans_detail_object_id)');
         Add_To_PackageTable(G_INDENT || '             )');
*/
      ELSIF l_rel_prod1 = 137 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.sales_lead_id = ILV2.trans_object_id');
      ELSIF l_rel_prod1 = 113 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.sales_lead_id = ILV2.trans_object_id');
      ELSIF l_rel_prod1 = 131 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.sales_lead_id = ILV2.trans_object_id');
      ELSIF l_rel_prod1 = 139 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.lead_id = ILV2.trans_object_id');
      ELSIF l_rel_prod1 = 163 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.lead_id = ILV2.trans_object_id');
      ELSIF l_rel_prod1 = 167 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.lead_id = ILV2.trans_object_id');
      END IF;

      Add_To_PackageTable ('UNION ALL');
      Add_To_PackageTable (' ');

     IF p_new_mode_fetch = 'Y'
    THEN
             Add_To_PackageTable (G_INDENT || 'SELECT /*+ NO_MERGE(ILV1) NO_MERGE(ILV2) ' );
             Add_To_PackageTable (G_INDENT || '                 USE_HASH(ILV1 ILV2) */' );
             Add_To_PackageTable (G_INDENT || '         ILV2.TRANS_OBJECT_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.TRANS_DETAIL_OBJECT_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.HEADER_ID1' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.HEADER_ID2' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_FC01' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_FC02' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_FC03' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_FC04' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_FC05' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC01' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC02' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC03' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC04' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC05' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC06' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC07' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC08' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC09' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC10' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR01' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR02' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR03' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR04' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR05' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR06' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR07' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR08' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR09' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR10' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR11' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR12' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR13' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR14' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR15' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR16' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR17' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR18' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR19' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR20' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR21' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR22' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR23' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR24' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR25' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR26' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR27' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR28' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR30' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR31' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR32' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR33' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR34' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR35' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR36' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR37' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR38' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR39' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR40' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR41' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR42' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR43' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR44' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR45' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR46' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR47' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR48' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR49' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR50' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR51' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR52' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR53' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR54' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR55' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR56' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR57' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR58' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR59' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR60' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM01' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM02' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM03' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM04' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM05' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM06' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM07' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM08' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM09' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM10' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM11' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM12' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM13' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM14' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM15' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM16' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM17' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM18' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM19' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM20' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM21' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM22' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM23' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM24' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM25' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM26' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM27' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM28' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM29' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM30' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM31' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM32' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM33' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM34' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM35' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM36' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM37' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM38' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM39' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM40' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM41' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM42' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM43' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM44' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM45' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM46' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM47' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM48' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM49' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM50' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM51' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM52' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM53' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM54' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM55' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM56' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM57' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM58' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM59' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM60' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.ASSIGNED_FLAG' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.PROCESSED_FLAG' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.ORG_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SECURITY_GROUP_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.OBJECT_VERSION_NUMBER' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.WORKER_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.TERR_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.ABSOLUTE_RANK' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.TOP_LEVEL_TERR_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.NUM_WINNERS' );
    ELSE
      Add_To_PackageTable (G_INDENT || '   SELECT /*+ NO_MERGE(ILV1) NO_MERGE(ILV2) ');
      Add_To_PackageTable (G_INDENT || '              USE_HASH(ILV1 ILV2) */');
      Add_To_PackageTable (G_INDENT || '          ILV2.trans_object_id');
      Add_To_PackageTable (G_INDENT || '        , ILV2.trans_detail_object_id');
      -- eihsu 06/19/2003 worker_id
      Add_To_PackageTable (G_INDENT || '        , ILV2.worker_id');
      Add_To_PackageTable (G_INDENT || '        , ILV2.header_id1');
      Add_To_PackageTable (G_INDENT || '        , ILV2.header_id2');
      Add_To_PackageTable (G_INDENT || '        , ILV2.terr_id');
      Add_To_PackageTable (G_INDENT || '        , ILV2.absolute_rank');
      Add_To_PackageTable (G_INDENT || '        , ILV2.top_level_terr_id ');
      Add_To_PackageTable (G_INDENT || '        , ILV2.num_winners');
      Add_To_PackageTable (G_INDENT || '        , ILV2.org_id');
    END IF;

      Add_To_PackageTable (G_INDENT || '   FROM');
      Add_To_PackageTable (G_INDENT || '       ( /* INLINE VIEW1 */');

      --get the content of ILV1 for like
      write_buffer_content(l_ilv1sql);

      Add_To_PackageTable (G_INDENT || '      ) ILV1, ');
      Add_To_PackageTable (' ');
      Add_To_PackageTable (G_INDENT || '      ( /* INLINE VIEW2 */');

      --get the content of ILV2 for like
      write_buffer_content(l_ilv2lk);

      Add_To_PackageTable (G_INDENT || '       ) ILV2 ');
      Add_To_PackageTable (G_INDENT || '       WHERE ILV1.terr_id = ILV2.terr_id ');

      IF l_rel_prod1 = 79 THEN
         /* bug 3835831 */
         Add_To_PackageTable(G_INDENT || '         AND ILV1.customer_id = ILV2.squal_num01');
         Add_To_PackageTable(G_INDENT || '         AND ( (ILV1.address_id IS NULL )');
         Add_To_PackageTable(G_INDENT || '               OR ');
         Add_To_PackageTable(G_INDENT || '               (ILV1.address_id= ILV2.squal_num02)');
         Add_To_PackageTable(G_INDENT || '             )');
/*
         Add_To_PackageTable(G_INDENT || '         AND ILV1.customer_id = ILV2.trans_object_id');
         Add_To_PackageTable(G_INDENT || '         AND ( (ILV1.address_id IS NULL AND ILV2.trans_detail_object_id IS NULL)');
         Add_To_PackageTable(G_INDENT || '               OR ');
         Add_To_PackageTable(G_INDENT || '               (ILV1.address_id= ILV2.trans_detail_object_id)');
         Add_To_PackageTable(G_INDENT || '             )');
*/
      ELSIF l_rel_prod1 = 137 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.sales_lead_id = ILV2.trans_object_id');
      ELSIF l_rel_prod1 = 113 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.sales_lead_id = ILV2.trans_object_id');
      ELSIF l_rel_prod1 = 131 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.sales_lead_id = ILV2.trans_object_id');
      ELSIF l_rel_prod1 = 139 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.lead_id = ILV2.trans_object_id');
      ELSIF l_rel_prod1 = 163 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.lead_id = ILV2.trans_object_id');
      ELSIF l_rel_prod1 = 167 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.lead_id = ILV2.trans_object_id');
      END IF;

      Add_To_PackageTable ('UNION ALL');
      Add_To_PackageTable (' ');

       IF p_new_mode_fetch = 'Y'
    THEN
             Add_To_PackageTable (G_INDENT || 'SELECT /*+ NO_MERGE(ILV1) NO_MERGE(ILV2) ' );
             Add_To_PackageTable (G_INDENT || '                 USE_HASH(ILV1 ILV2) */' );
             Add_To_PackageTable (G_INDENT || '         ILV2.TRANS_OBJECT_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.TRANS_DETAIL_OBJECT_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.HEADER_ID1' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.HEADER_ID2' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_FC01' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_FC02' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_FC03' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_FC04' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_FC05' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC01' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC02' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC03' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC04' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC05' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC06' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC07' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC08' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC09' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC10' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR01' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR02' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR03' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR04' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR05' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR06' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR07' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR08' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR09' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR10' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR11' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR12' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR13' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR14' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR15' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR16' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR17' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR18' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR19' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR20' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR21' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR22' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR23' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR24' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR25' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR26' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR27' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR28' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR30' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR31' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR32' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR33' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR34' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR35' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR36' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR37' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR38' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR39' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR40' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR41' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR42' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR43' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR44' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR45' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR46' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR47' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR48' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR49' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR50' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR51' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR52' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR53' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR54' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR55' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR56' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR57' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR58' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR59' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR60' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM01' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM02' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM03' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM04' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM05' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM06' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM07' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM08' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM09' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM10' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM11' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM12' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM13' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM14' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM15' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM16' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM17' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM18' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM19' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM20' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM21' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM22' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM23' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM24' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM25' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM26' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM27' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM28' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM29' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM30' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM31' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM32' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM33' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM34' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM35' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM36' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM37' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM38' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM39' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM40' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM41' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM42' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM43' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM44' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM45' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM46' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM47' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM48' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM49' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM50' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM51' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM52' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM53' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM54' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM55' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM56' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM57' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM58' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM59' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM60' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.ASSIGNED_FLAG' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.PROCESSED_FLAG' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.ORG_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SECURITY_GROUP_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.OBJECT_VERSION_NUMBER' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.WORKER_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.TERR_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.ABSOLUTE_RANK' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.TOP_LEVEL_TERR_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.NUM_WINNERS' );
    ELSE
      Add_To_PackageTable (G_INDENT || '   SELECT /*+ NO_MERGE(ILV1) NO_MERGE(ILV2) ');
      Add_To_PackageTable (G_INDENT || '              USE_HASH(ILV1 ILV2) */');
      Add_To_PackageTable (G_INDENT || '          ILV2.trans_object_id');
      Add_To_PackageTable (G_INDENT || '        , ILV2.trans_detail_object_id');
      -- eihsu 06/19/2003 worker_id
      Add_To_PackageTable (G_INDENT || '        , ILV2.worker_id');
      Add_To_PackageTable (G_INDENT || '        , ILV2.header_id1');
      Add_To_PackageTable (G_INDENT || '        , ILV2.header_id2');
      Add_To_PackageTable (G_INDENT || '        , ILV2.terr_id');
      Add_To_PackageTable (G_INDENT || '        , ILV2.absolute_rank');
      Add_To_PackageTable (G_INDENT || '        , ILV2.top_level_terr_id ');
      Add_To_PackageTable (G_INDENT || '        , ILV2.num_winners');
      Add_To_PackageTable (G_INDENT || '        , ILV2.org_id');
    END IF;

      Add_To_PackageTable (G_INDENT || '   FROM');
      Add_To_PackageTable (G_INDENT || '       ( /* INLINE VIEW1 */');

      --get the content of ILV1 for like first char
      write_buffer_content(l_ilv1sql);

      Add_To_PackageTable (G_INDENT || '      ) ILV1, ');
      Add_To_PackageTable (' ');
      Add_To_PackageTable (G_INDENT || '      ( /* INLINE VIEW2 */');

      --get the content of ILV2 for like first char
      write_buffer_content(l_ilv2lkp);

      Add_To_PackageTable (G_INDENT || '       ) ILV2 ');
      Add_To_PackageTable (G_INDENT || '       WHERE ILV1.terr_id = ILV2.terr_id ');

      IF l_rel_prod1 = 79 THEN
         /* bug 3835831 */
         Add_To_PackageTable(G_INDENT || '         AND ILV1.customer_id = ILV2.squal_num01');
         Add_To_PackageTable(G_INDENT || '         AND ( (ILV1.address_id IS NULL )');
         Add_To_PackageTable(G_INDENT || '               OR ');
         Add_To_PackageTable(G_INDENT || '               (ILV1.address_id= ILV2.squal_num02)');
         Add_To_PackageTable(G_INDENT || '             )');
/*
         Add_To_PackageTable(G_INDENT || '         AND ILV1.customer_id = ILV2.trans_object_id');
         Add_To_PackageTable(G_INDENT || '         AND ( (ILV1.address_id IS NULL AND ILV2.trans_detail_object_id IS NULL)');
         Add_To_PackageTable(G_INDENT || '               OR ');
         Add_To_PackageTable(G_INDENT || '               (ILV1.address_id= ILV2.trans_detail_object_id)');
         Add_To_PackageTable(G_INDENT || '             )');
*/
      ELSIF l_rel_prod1 = 137 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.sales_lead_id = ILV2.trans_object_id');
      ELSIF l_rel_prod1 = 113 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.sales_lead_id = ILV2.trans_object_id');
      ELSIF l_rel_prod1 = 131 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.sales_lead_id = ILV2.trans_object_id');
      ELSIF l_rel_prod1 = 139 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.lead_id = ILV2.trans_object_id');
      ELSIF l_rel_prod1 = 163 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.lead_id = ILV2.trans_object_id');
      ELSIF l_rel_prod1 = 167 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.lead_id = ILV2.trans_object_id');
      END IF;

      Add_To_PackageTable ('UNION ALL');
      Add_To_PackageTable (' ');

    IF p_new_mode_fetch = 'Y'
    THEN
             Add_To_PackageTable (G_INDENT || 'SELECT /*+ NO_MERGE(ILV1) NO_MERGE(ILV2) ' );
             Add_To_PackageTable (G_INDENT || '                 USE_HASH(ILV1 ILV2) */' );
             Add_To_PackageTable (G_INDENT || '         ILV2.TRANS_OBJECT_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.TRANS_DETAIL_OBJECT_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.HEADER_ID1' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.HEADER_ID2' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_FC01' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_FC02' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_FC03' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_FC04' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_FC05' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC01' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC02' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC03' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC04' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC05' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC06' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC07' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC08' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC09' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CURC10' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR01' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR02' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR03' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR04' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR05' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR06' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR07' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR08' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR09' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR10' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR11' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR12' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR13' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR14' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR15' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR16' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR17' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR18' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR19' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR20' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR21' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR22' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR23' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR24' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR25' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR26' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR27' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR28' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR30' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR31' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR32' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR33' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR34' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR35' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR36' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR37' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR38' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR39' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR40' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR41' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR42' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR43' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR44' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR45' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR46' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR47' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR48' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR49' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR50' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR51' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR52' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR53' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR54' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR55' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR56' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR57' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR58' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR59' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_CHAR60' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM01' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM02' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM03' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM04' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM05' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM06' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM07' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM08' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM09' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM10' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM11' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM12' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM13' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM14' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM15' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM16' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM17' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM18' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM19' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM20' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM21' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM22' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM23' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM24' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM25' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM26' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM27' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM28' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM29' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM30' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM31' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM32' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM33' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM34' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM35' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM36' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM37' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM38' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM39' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM40' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM41' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM42' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM43' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM44' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM45' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM46' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM47' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM48' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM49' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM50' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM51' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM52' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM53' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM54' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM55' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM56' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM57' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM58' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM59' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SQUAL_NUM60' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.ASSIGNED_FLAG' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.PROCESSED_FLAG' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.ORG_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.SECURITY_GROUP_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.OBJECT_VERSION_NUMBER' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.WORKER_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.TERR_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.ABSOLUTE_RANK' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.TOP_LEVEL_TERR_ID' );
             Add_To_PackageTable (G_INDENT || '       , ILV2.NUM_WINNERS' );
    ELSE
      Add_To_PackageTable (G_INDENT || '   SELECT /*+ NO_MERGE(ILV1) NO_MERGE(ILV2) ');
      Add_To_PackageTable (G_INDENT || '              USE_HASH(ILV1 ILV2) */');
      Add_To_PackageTable (G_INDENT || '          ILV2.trans_object_id');
      Add_To_PackageTable (G_INDENT || '        , ILV2.trans_detail_object_id');
      -- eihsu 06/19/2003 worker_id
      Add_To_PackageTable (G_INDENT || '        , ILV2.worker_id');
      Add_To_PackageTable (G_INDENT || '        , ILV2.header_id1');
      Add_To_PackageTable (G_INDENT || '        , ILV2.header_id2');
      Add_To_PackageTable (G_INDENT || '        , ILV2.terr_id');
      Add_To_PackageTable (G_INDENT || '        , ILV2.absolute_rank');
      Add_To_PackageTable (G_INDENT || '        , ILV2.top_level_terr_id ');
      Add_To_PackageTable (G_INDENT || '        , ILV2.num_winners');
      Add_To_PackageTable (G_INDENT || '        , ILV2.org_id');
    END IF;

      Add_To_PackageTable (G_INDENT || '   FROM');
      Add_To_PackageTable (G_INDENT || '       ( /* INLINE VIEW1 */');

      --get the content of ILV1 for between
      write_buffer_content(l_ilv1sql);

      Add_To_PackageTable (G_INDENT || '      ) ILV1, ');
      Add_To_PackageTable (' ');
      Add_To_PackageTable (G_INDENT || '      ( /* INLINE VIEW2 */');

      --get the content of ILV2 for between
      write_buffer_content(l_ilv2btwn);

      Add_To_PackageTable (G_INDENT || '       ) ILV2 ');
      Add_To_PackageTable (G_INDENT || '       WHERE ILV1.terr_id = ILV2.terr_id ');

      IF l_rel_prod1 = 79 THEN
         /* bug 3835831 */
         Add_To_PackageTable(G_INDENT || '         AND ILV1.customer_id = ILV2.squal_num01');
         Add_To_PackageTable(G_INDENT || '         AND ( (ILV1.address_id IS NULL )');
         Add_To_PackageTable(G_INDENT || '               OR ');
         Add_To_PackageTable(G_INDENT || '               (ILV1.address_id= ILV2.squal_num02)');
         Add_To_PackageTable(G_INDENT || '             )');
/*
         Add_To_PackageTable(G_INDENT || '         AND ILV1.customer_id = ILV2.trans_object_id');
         Add_To_PackageTable(G_INDENT || '         AND ( (ILV1.address_id IS NULL AND ILV2.trans_detail_object_id IS NULL)');
         Add_To_PackageTable(G_INDENT || '               OR ');
         Add_To_PackageTable(G_INDENT || '               (ILV1.address_id= ILV2.trans_detail_object_id)');
         Add_To_PackageTable(G_INDENT || '             )');
*/
      ELSIF l_rel_prod1 = 137 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.sales_lead_id = ILV2.trans_object_id');
      ELSIF l_rel_prod1 = 113 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.sales_lead_id = ILV2.trans_object_id');
      ELSIF l_rel_prod1 = 131 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.sales_lead_id = ILV2.trans_object_id');
      ELSIF l_rel_prod1 = 139 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.lead_id = ILV2.trans_object_id');
      ELSIF l_rel_prod1 = 163 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.lead_id = ILV2.trans_object_id');
      ELSIF l_rel_prod1 = 167 THEN
         Add_To_PackageTable(G_INDENT || '         AND ILV1.lead_id = ILV2.trans_object_id');
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         g_ProgramStatus := 1;
         Add_To_PackageTable ('-- Program encountered invalid territory in rules2 ');

   END build_qualifier_rules2;


PROCEDURE gen_details_for_terr_change (
      p_source_id           IN       NUMBER,
      p_qual_type_id        IN       NUMBER,
      p_view_name           IN       VARCHAR2,
      p_sql                 OUT NOCOPY  terrsql_tbl_type
      )
   AS

      l_relation_product   NUMBER := 0;
      l_sql                VARCHAR2(32767):=NULL;
      i                    NUMBER := 0;
l_ilv2eq     VARCHAR2(32767);
l_ilv2lk     VARCHAR2(32767);
l_ilv2lkp     VARCHAR2(32767);
l_ilv2btwn     VARCHAR2(32767);
l_new_mode_fetch CHAR := 'N';

      /* ARPATEL: 01/06/2004 bug#3337382 */
      CURSOR c_terr_rel_prod is
            SELECT jtdr.terr_id, jtqu.qual_relation_product
              FROM jtf_terr_denorm_rules_all jtdr
	          ,jtf_terr_qtype_usgs_all jtqu
	          ,jtf_qual_type_usgs_all jqtu
                  ,jtf_changed_terr_all b
            WHERE jtdr.terr_id = jtdr.related_terr_id
              AND jtdr.terr_id= b.terr_id
              AND jqtu.source_id = jtdr.source_id
	      AND jqtu.qual_type_id = p_qual_type_id
	      AND jtdr.terr_id = jtqu.terr_id
              AND jtdr.source_id = p_source_id
	      AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id;

   BEGIN

      IF p_view_name IS NULL THEN

         RETURN;

      END IF;

      /* get all the territory,relation_product from jtf_changed_terr_all,jtf_terr_denorm_rules_all
         for the given qual_type_id */
      FOR JTF_csr in c_terr_rel_prod LOOP

           i := i + 1;

           IF l_relation_product <> JTF_csr.qual_relation_product THEN

              /* call the Build_Qualifier_Rules, passing p_print_flag='Y' to get the sql */
              /* p_view_name is the name of the view from which deatils to be selected  */
              Build_Qualifier_Rules(p_source_id,p_qual_type_id,JTF_csr.qual_relation_product,p_view_name,'N',l_new_mode_fetch, l_sql,l_ilv2eq,l_ilv2lk,l_ilv2lkp,l_ilv2btwn);
              l_relation_product := JTF_csr.qual_relation_product;

              /* build the final sql and pass to the caller */
              l_sql := replace(l_sql,'JTF_csr.terr_id',JTF_csr.terr_id);

           END IF;

           p_sql(i).terr_id := JTF_csr.terr_id;
           p_sql(i).terr_sql := l_sql;

      END LOOP;

   END gen_details_for_terr_change;


   PROCEDURE gen_terr_rules_recurse(
      p_terr_id             IN       NUMBER,
      p_source_id           IN       NUMBER,
      p_qualifier_type_id   IN       NUMBER,
      p_target_type         IN       VARCHAR2,
      p_input_table_name    IN       VARCHAR2,
      p_match_table_name    IN       VARCHAR2,
      p_search_name         IN       VARCHAR2 := 'SEARCH_TERR_RULES',
      -- dblee/eihsu: 08/15/03 added p_new_mode_fetch flag
	  p_new_mode_fetch      IN       CHAR := 'N')
   AS

      CURSOR c_rel_prod( lp_source_id      NUMBER
						 , lp_qual_type_id NUMBER)
      IS
         SELECT DISTINCT jtqp.relation_product
         FROM jtf_tae_qual_products jtqp
         WHERE jtqp.source_id = lp_source_id
            AND jtqp.trans_object_type_id= lp_qual_type_id
         ORDER BY jtqp.relation_product DESC;

      l_procedure_name       VARCHAR2(30);
      l_procedure_desc       VARCHAR2(255);
      l_parameter_list1      VARCHAR2(255);
      l_parameter_list2      VARCHAR2(360);
      l_qual_rules           VARCHAR2(32767);

      l_str_len        NUMBER;
      l_start          NUMBER;
      l_get_nchar      NUMBER;
      l_next_newline   NUMBER;
      l_rule_str       VARCHAR2(256);
      l_newline        VARCHAR2(2) := FND_GLOBAL.Local_Chr(10); /* newline character */
      l_indent         VARCHAR2(30);
      p_sql            VARCHAR2(32767) := NULL;
      --l_input_table_name VARCHAR2(30) := 'jtf_tae_trans_objs';
      l_ilv2eq     VARCHAR2(32767);
      l_ilv2lk     VARCHAR2(32767);
      l_ilv2lkp     VARCHAR2(32767);
      l_ilv2btwn     VARCHAR2(32767);
      l_sql            VARCHAR2(32767) := NULL;

   BEGIN
      --dbms_output.put_line('gen_terr_rules_recurse.p_search_name: ' || p_search_name);

      IF G_Debug THEN
         Write_Log(1, 'INSIDE PROCEDURE JTF_TAE_GEN_PVT.gen_terr_rules_recurse');
      END IF;

      --dbms_output.put_line('Value of p_qualifier_type_id='|| l_indent||TO_CHAR(p_qualifier_type_id));

      l_str_len := LENGTH(l_qual_rules);

      --dbms_output.put_line('After Build_Qualifier_Rules');

      l_procedure_name := p_search_name;
      l_procedure_desc := '/* Territory rules for Usage/Transaction: ' || TO_CHAR(p_source_id) || ' */';

      IF p_source_id = -1001 and p_search_name = 'SEARCH_TERR_RULES' THEN

              l_parameter_list1 :=
                      ' p_source_id          IN     NUMBER' || l_newline ||
                      ' , p_trans_object_type_id IN  NUMBER' || l_newline ||
                      ' , x_Return_Status        OUT VARCHAR2' || l_newline||
                      ' , x_Msg_Count            OUT NUMBER' ||  l_newline||
                      ' , x_Msg_Data             OUT VARCHAR2'|| l_newline||
                      ' , p_worker_id            IN NUMBER := 1'|| l_newline ;

      END IF;


      generate_object_definition( l_procedure_name, l_procedure_desc,
                                  l_parameter_list1, l_parameter_list2, 'P', 'BOOLEAN', 'PKB' );

      Add_To_PackageTable (' ');
      Add_To_PackageTable ('   L_REQUEST_ID                 NUMBER := FND_GLOBAL.CONC_REQUEST_ID();');
      Add_To_PackageTable ('   L_PROGRAM_APPL_ID            NUMBER := FND_GLOBAL.PROG_APPL_ID();');
      Add_To_PackageTable ('   L_PROGRAM_ID                 NUMBER := FND_GLOBAL.CONC_PROGRAM_ID();');
      Add_To_PackageTable ('   L_USER_ID                    NUMBER := FND_GLOBAL.USER_ID();');
      Add_To_PackageTable ('   l_sysdate                    DATE := SYSDATE;');
      Add_To_PackageTable (' ');
      Add_To_PackageTable ('   l_cursor                     NUMBER;');
      Add_To_PackageTable ('   l_dyn_str                    VARCHAR2(32767);');
      Add_To_PackageTable ('   l_num_rows                   NUMBER;');
      /* ARPATEL Bug#3489240 */
      Add_To_PackageTable ('   l_num_workers                   NUMBER;');

      Add_To_PackageTable ('   indx                         NUMBER := 1;');
      Add_To_PackageTable ('   lp_qual_combination_tbl      jtf_terr_number_list := jtf_terr_number_list();');
      Add_To_PackageTable (' ');
      Add_To_PackageTable ('   l_counter                    NUMBER; ');
      Add_To_PackageTable (' ');
      Add_To_PackageTable ('   j                            NUMBER:=0; ');
      Add_To_PackageTable ('   i                            NUMBER:=0; ');
      Add_To_PackageTable (' ');
      Add_To_PackageTable ('   CURSOR c_get_qualrel_prod IS ');
      Add_To_PackageTable ('      SELECT jtqp.relation_product ');
      Add_To_PackageTable ('      FROM jtf_tae_qual_products  jtqp ');
      Add_To_PackageTable ('      WHERE jtqp.source_id = p_source_id ');
      Add_To_PackageTable ('        AND jtqp.trans_object_type_id = p_trans_object_type_id');
      Add_To_PackageTable ('      ORDER BY jtqp.relation_product DESC ;');
      Add_To_PackageTable (' ');
      Add_To_PackageTable ('   CURSOR c_get_terr(l_qual_rel_prod number) IS');
      Add_To_PackageTable ('      SELECT distinct jtdr.terr_id ');
      Add_To_PackageTable ('           , jtdr.source_id ');
      Add_To_PackageTable ('           , jtdr.qual_type_id');
      Add_To_PackageTable ('           , jtdr.top_level_terr_id');
      Add_To_PackageTable ('           , jtdr.absolute_rank ');
      Add_To_PackageTable ('           , jtdr.num_winners ');
      Add_To_PackageTable ('           , jtdr.org_id ');
      Add_To_PackageTable ('      FROM jtf_terr_denorm_rules_all jtdr ');
      Add_To_PackageTable ('          ,jtf_terr_qtype_usgs_all jtqu ');
      Add_To_PackageTable ('          ,jtf_qual_type_usgs_all jqtu ');
      Add_To_PackageTable ('      WHERE jtdr.source_id = p_source_id ');
      Add_To_PackageTable ('        AND jtdr.resource_exists_flag= ''Y'' ');

      Add_To_PackageTable ('        AND jqtu.source_id = jtdr.source_id ');
      Add_To_PackageTable ('        AND jqtu.qual_type_id = p_trans_object_type_id ');
      Add_To_PackageTable ('        AND jtdr.terr_id = jtqu.terr_id ');
      Add_To_PackageTable ('        AND jtqu.qual_type_usg_id = jqtu.qual_type_usg_id ');

      Add_To_PackageTable ('        AND jtdr.terr_id = jtdr.related_terr_id ');
      Add_To_PackageTable ('        AND jtqu.qual_relation_product= l_qual_rel_prod;');
      Add_To_PackageTable (' ');
      Add_To_PackageTable ('BEGIN');
      Add_To_PackageTable (' ');
      Add_To_PackageTable ('   SAVEPOINT JTF_TAE_MATCHING_TRANSACTION; ');
      Add_To_PackageTable (' ');
      Add_To_PackageTable ('   FOR JTF_csr IN c_get_qualrel_prod LOOP ');
      Add_To_PackageTable ('     lp_qual_combination_tbl.EXTEND;');
      Add_To_PackageTable ('     j := j + 1;');
      Add_To_PackageTable ('     lp_qual_combination_tbl(j) := JTF_csr.relation_product;');
      Add_To_PackageTable ('   END LOOP;');
      Add_To_PackageTable (' ');
      --Add_To_PackageTable ('   lp_source_id     := ' || TO_CHAR(p_source_id) || ';');

      --IF ( l_str_len > 0 ) THEN
      Add_To_PackageTable ('   i := lp_qual_combination_tbl.FIRST;');

      --Add_To_PackageTable ('   FOR i IN lp_qual_combination_tbl.FIRST..lp_qual_combination_tbl.LAST LOOP ');
      Add_To_PackageTable ('   WHILE i <= lp_qual_combination_tbl.LAST LOOP ');

      FOR JTF_csr in c_rel_prod(p_source_id, p_qualifier_type_id) LOOP
         Add_To_PackageTable (' ');
         Add_To_PackageTable ('   BEGIN ');
         Add_To_PackageTable (' ');
         Add_To_PackageTable ('      IF lp_qual_combination_tbl(i) = ' || JTF_csr.relation_product || ' THEN');
         Add_To_PackageTable (' ');
         --Add_To_PackageTable ('  FOR JTF_csr in c_get_terr(lp_qual_combination_tbl(i)) LOOP ' );
         Add_To_PackageTable (' ');

         -- dblee: 08/15/03 added switch for new mode
         IF p_new_mode_fetch = 'Y' AND JTF_csr.relation_product <> 4841 THEN
            add_insert_nmtrans(p_match_table_name);
         ELSE
            /* ARPATEL BUG#3489240 03/10/2004 */
           IF JTF_csr.relation_product <> 4841
           THEN
            Add_To_PackageTable ('         INSERT INTO  '|| p_match_table_name || ' i');
            Add_To_PackageTable ('         (' );
            Add_To_PackageTable ('            trans_object_id');
            Add_To_PackageTable ('          , trans_detail_object_id');
                 -- eihsu worker_id 06/05/2003
            Add_To_PackageTable ('          , worker_id');
            Add_To_PackageTable ('          , header_id1');
            Add_To_PackageTable ('          , header_id2');
            Add_To_PackageTable ('          , source_id');
            Add_To_PackageTable ('          , trans_object_type_id');
            Add_To_PackageTable ('          , last_update_date');
            Add_To_PackageTable ('          , last_updated_by');
            Add_To_PackageTable ('          , creation_date');
            Add_To_PackageTable ('          , created_by');
            Add_To_PackageTable ('          , last_update_login');
            Add_To_PackageTable ('          , request_id');
            Add_To_PackageTable ('          , program_application_id');
            Add_To_PackageTable ('          , program_id');
            Add_To_PackageTable ('          , program_update_date');
            Add_To_PackageTable ('          , terr_id');
            Add_To_PackageTable ('          , absolute_rank');
            Add_To_PackageTable ('          , top_level_terr_id');
            Add_To_PackageTable ('          , num_winners');
            Add_To_PackageTable ('          , org_id');
            Add_To_PackageTable ('         )' );
           END IF;
         END IF; -- p_new_mode_fetch = 'Y'

         -- IF  mod(JTF_csr.relation_product,79) = 0 THEN
          /* for account classification */
         --  Add_To_PackageTable ('          SELECT ');
         --ELSIF mod(JTF_csr.relation_product,137) = 0 THEN
          /* for lead expected purchase */
         -- Add_To_PackageTable ('          SELECT ');
         --ELSIF mod(JTF_csr.relation_product,139) = 0 THEN
          /* for opportunity expected purchase */
         --  Add_To_PackageTable ('          SELECT ');
         --ELSE
         --  Add_To_PackageTable ('          SELECT ');
         --END IF;

         IF JTF_csr.relation_product= 4841 or JTF_csr.relation_product= 324347 or
            JTF_csr.relation_product= 45084233 or JTF_csr.relation_product= 44435539 or
            JTF_csr.relation_product= 62598971 or JTF_csr.relation_product= 61950277 or
            JTF_csr.relation_product= 924631 or JTF_csr.relation_product= 934313
	    or JTF_csr.relation_product = 663217 /* bug#3508485 */
	    or JTF_csr.relation_product = 353393
	    THEN

            JTF_TAE_SQL_LIB_PVT.get_qual_comb_sql (
               JTF_csr.relation_product,
               p_source_id,
               p_qualifier_type_id,
               p_input_table_name,
               /* ARPATEL 03/11/2004 BUG#3489240 */
               p_match_table_name,
               -- dblee: 08/26/03: added p_new_mode_fetch flag argument
               p_new_mode_fetch,
               l_sql);

            write_buffer_content(l_sql);

         ELSE -- JTF_csr.relation_product not in (4841, 324347, 353393, 663217, 45084233, 44435539, 62598971, 61950277, 924631, 934313)

            -- dblee: 08/15/03 added switch for new mode
            IF p_new_mode_fetch = 'Y' THEN
               add_select_nmtrans(p_match_table_name);
            ELSE

               IF (mod(JTF_csr.relation_product,79) = 0 and JTF_csr.relation_product/79 <> 1) or
                     (mod(JTF_csr.relation_product,137) = 0 and JTF_csr.relation_product/137 <> 1) or
                     (mod(JTF_csr.relation_product,113) = 0 and JTF_csr.relation_product/113 <> 1) or
                     (mod(JTF_csr.relation_product,131) = 0 and JTF_csr.relation_product/131 <> 1) or
                     (mod(JTF_csr.relation_product,163) = 0 and JTF_csr.relation_product/163 <> 1) or
                     (mod(JTF_csr.relation_product,167) = 0 and JTF_csr.relation_product/167 <> 1) or
                     (mod(JTF_csr.relation_product,139) = 0 and JTF_csr.relation_product/139 <> 1) THEN

                 /*  account classification,lead expected purchase,opportunity expected purchase */
                  Add_To_PackageTable ('         SELECT /*+ USE_CONCAT */ DISTINCT ');
                  Add_To_PackageTable ('                ILV2.trans_object_id');
                  Add_To_PackageTable ('              , ILV2.trans_detail_object_id');
                  -- eihsu worker_id 06/05/2003
                  Add_To_PackageTable ('              , ILV2.worker_id');
                  Add_To_PackageTable ('              , ILV2.header_id1');
                  Add_To_PackageTable ('              , ILV2.header_id2');
                  Add_To_PackageTable ('              , p_source_id');
                  Add_To_PackageTable ('              , p_trans_object_type_id');
                  Add_To_PackageTable ('              , l_sysdate');
                  Add_To_PackageTable ('              , L_USER_ID');
                  Add_To_PackageTable ('              , l_sysdate');
                  Add_To_PackageTable ('              , L_USER_ID');
                  Add_To_PackageTable ('              , L_USER_ID');
                  Add_To_PackageTable ('              , L_REQUEST_ID');
                  Add_To_PackageTable ('              , L_PROGRAM_APPL_ID');
                  Add_To_PackageTable ('              , L_PROGRAM_ID');
                  Add_To_PackageTable ('              , l_sysdate');
                  Add_To_PackageTable ('              , ILV2.terr_id');
                  Add_To_PackageTable ('              , ILV2.absolute_rank');
                  Add_To_PackageTable ('              , ILV2.top_level_terr_id');
                  Add_To_PackageTable ('              , ILV2.num_winners');
                  Add_To_PackageTable ('              , ILV2.org_id');
                  Add_To_PackageTable ('         FROM  ');
               ELSE
                  Add_To_PackageTable ('         SELECT /*+ USE_CONCAT */ DISTINCT ');
                  Add_To_PackageTable ('                trans_object_id');
                  Add_To_PackageTable ('              , trans_detail_object_id');
                  -- eihsu worker_id 06/05/2003
                  Add_To_PackageTable ('              , worker_id');
                  Add_To_PackageTable ('              , header_id1');
                  Add_To_PackageTable ('              , header_id2');
                  Add_To_PackageTable ('              , p_source_id');
                  Add_To_PackageTable ('              , p_trans_object_type_id');
                  Add_To_PackageTable ('              , l_sysdate');
                  Add_To_PackageTable ('              , L_USER_ID');
                  Add_To_PackageTable ('              , l_sysdate');
                  Add_To_PackageTable ('              , L_USER_ID');
                  Add_To_PackageTable ('              , L_USER_ID');
                  Add_To_PackageTable ('              , L_REQUEST_ID');
                  Add_To_PackageTable ('              , L_PROGRAM_APPL_ID');
                  Add_To_PackageTable ('              , L_PROGRAM_ID');
                  Add_To_PackageTable ('              , l_sysdate');
                  Add_To_PackageTable ('              , ILV.terr_id');
                  Add_To_PackageTable ('              , ILV.absolute_rank');
                  Add_To_PackageTable ('              , ILV.top_level_terr_id');
                  Add_To_PackageTable ('              , ILV.num_winners');
                  Add_To_PackageTable ('              , ILV.org_id');
                  Add_To_PackageTable ('          FROM  ');
               END IF;
	        END IF; -- p_new_mode_fetch = 'Y'

            l_newline := FND_GLOBAL.Local_Chr(10); /* newline character */
            l_indent  := '            ';
            l_start := 1;
            l_next_newline := 0;

            IF mod(JTF_csr.relation_product,67) = 0 or mod(JTF_csr.relation_product,73) = 0 THEN

               /* brackets are needed after FROM clause because of union generated for qual_usg_id=-1012 */
               IF mod(JTF_csr.relation_product,79) = 0 or
                     mod(JTF_csr.relation_product,137) = 0 or
                     mod(JTF_csr.relation_product,113) = 0 or
                     mod(JTF_csr.relation_product,131) = 0 or
                     mod(JTF_csr.relation_product,163) = 0 or
                     mod(JTF_csr.relation_product,167) = 0 or
                     mod(JTF_csr.relation_product,139) = 0 THEN
                  Add_To_PackageTable ('          ( ');
                  -- dblee: 08/26/03: added p_new_mode_fetch flag argument
                  Build_Qualifier_Rules2(p_source_id, p_qualifier_type_id, JTF_csr.relation_product,
                     p_input_table_name, 'N', p_new_mode_fetch, p_sql);

                  -- dblee: 08/23/03: accommodate the form of the new mode select list
                  IF p_new_mode_fetch = 'Y' THEN
                     Add_To_PackageTable ('          ) A ; ');
                  ELSE
                     Add_To_PackageTable ('          ) ILV2 ; ');
                  END IF;
               ELSE
                  Add_To_PackageTable ('          ( ');
                  Build_Qualifier_Rules(p_source_id,p_qualifier_type_id, JTF_csr.relation_product ,p_input_table_name,'N',p_new_mode_fetch,p_sql,l_ilv2eq,l_ilv2lk,l_ilv2lkp,l_ilv2btwn);

                  -- dblee: 08/23/03: accommodate the form of the new mode select list
                  IF p_new_mode_fetch = 'Y' THEN
                     Add_To_PackageTable ('          ) A ; ');
                  ELSE
                     Add_To_PackageTable ('          ) ILV ; ');
                  END IF;
               END IF;

            ELSE -- JTF_csr.relation_product not divisible by 67 or 73

               IF (mod(JTF_csr.relation_product,79) = 0 and JTF_csr.relation_product/79 <> 1) or
                     (mod(JTF_csr.relation_product,137) = 0 and JTF_csr.relation_product/137 <> 1) or
                     (mod(JTF_csr.relation_product,113) = 0 and JTF_csr.relation_product/113 <> 1) or
                     (mod(JTF_csr.relation_product,131) = 0 and JTF_csr.relation_product/131 <> 1) or
                     (mod(JTF_csr.relation_product,163) = 0 and JTF_csr.relation_product/163 <> 1) or
                     (mod(JTF_csr.relation_product,167) = 0 and JTF_csr.relation_product/167 <> 1) or
                     (mod(JTF_csr.relation_product,139) = 0 and JTF_csr.relation_product/139 <> 1) THEN

                 /* need bracket */
                  Add_To_PackageTable ('          ( ');
                  -- dblee: 08/26/03: added p_new_mode_fetch flag argument
                  Build_Qualifier_Rules1(p_source_id, p_qualifier_type_id, JTF_csr.relation_product,
                     p_input_table_name, 'N', p_new_mode_fetch, p_sql);

                  -- dblee: 08/23/03: accommodate the form of the new mode select list
                  IF p_new_mode_fetch = 'Y' THEN
                     Add_To_PackageTable ('          ) A ; ');
                  ELSE
                     Add_To_PackageTable ('          ) ILV2 ; ');
                  END IF;
               ELSE
                  /* brackets are not needed after FROM clause */
                  Build_Qualifier_Rules( p_source_id,p_qualifier_type_id,JTF_csr.relation_product,p_input_table_name,'N',p_new_mode_fetch, p_sql,l_ilv2eq,l_ilv2lk,l_ilv2lkp,l_ilv2btwn);
                 --gen_details_for_terr_change (-1001,-1002,'ABC',p_sql );
                  Add_To_PackageTable ('           ; ');
               END IF;

            END IF; -- JTF_csr.relation_product divisible by 67 or 73

         END IF; -- JTF_csr.relation_product in (4841, 324347, 663217, 353393, 45084233, 44435539, 62598971, 61950277, 924631, 934313)
         --Add_To_PackageTable ('END LOOP; ');


         Add_To_PackageTable ('    ');
         Add_To_PackageTable ('      x_Msg_Data  := ''' || G_DYN_PKG_NAME || '.SEARCH_TERR_RULES: ''');
         Add_To_PackageTable ('                     || ''Qualifier Combination = ''');
         Add_To_PackageTable ('                     || lp_qual_combination_tbl(i)');
         Add_To_PackageTable ('                     || '': # OF ROWS INSERTED = '' || SQL%ROWCOUNT;');
         Add_To_PackageTable ('   ');
         Add_To_PackageTable ('      JTF_TAE_CONTROL_PVT.WRITE_LOG(2, x_Msg_Data);');

         Add_To_PackageTable ('     END IF; ');
         Add_To_PackageTable ('    ');
         Add_To_PackageTable ('   EXCEPTION ');
         Add_To_PackageTable (G_INDENT1 || '   WHEN NO_DATA_FOUND THEN');
         Add_To_PackageTable ('   ');
         Add_To_PackageTable (G_INDENT1 || '      x_Msg_Data  := ''' || G_DYN_PKG_NAME || '.SEARCH_TERR_RULES: ''');
         Add_To_PackageTable (G_INDENT1 || '                     || ''Qualifier Combination = ''');
         Add_To_PackageTable (G_INDENT1 || '                     || lp_qual_combination_tbl(i)');
         Add_To_PackageTable (G_INDENT1 || '                     || ''NO_DATA_FOUND: NO ROWS INSERTED.'';');
         Add_To_PackageTable (G_INDENT1 || '      JTF_TAE_CONTROL_PVT.WRITE_LOG(2, x_Msg_Data);');
         Add_To_PackageTable ('    ');
         Add_To_PackageTable (G_INDENT1 || '   WHEN OTHERS THEN');
         Add_To_PackageTable ('   ');
         Add_To_PackageTable (G_INDENT1 || '      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;');
         Add_To_PackageTable (G_INDENT1 || '      x_Msg_Data  := ''' || G_DYN_PKG_NAME || '.SEARCH_TERR_RULES: ''');
         Add_To_PackageTable (G_INDENT1 || '                     || ''Qualifier Combination = ''');
         Add_To_PackageTable (G_INDENT1 || '                     || lp_qual_combination_tbl(i)');
         Add_To_PackageTable (G_INDENT1 || '                     || '' OTHERS: Program terminated with OTHERS exception: '' || SQLERRM;');
         Add_To_PackageTable (G_INDENT1 || '      JTF_TAE_CONTROL_PVT.WRITE_LOG(2, x_Msg_Data);');
         Add_To_PackageTable ('   ');
         Add_To_PackageTable (G_INDENT1 || '      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
         Add_To_PackageTable ('    ');
         Add_To_PackageTable ('   END; ');

      END LOOP;

      Add_To_PackageTable ('   COMMIT; ');
      Add_To_PackageTable ('   i := i + 1; ');
      Add_To_PackageTable ('');
      Add_To_PackageTable ('   END LOOP; ');

      /* generate END of PROCEDURE */
      generate_end_of_procedure(l_procedure_name, p_source_id, p_target_type);

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         g_ProgramStatus := 1;

         Add_To_PackageTable ('--TERR_RULE_GEN: Unhandled exception NO_DATA_FOUND');
         RETURN;

   END gen_terr_rules_recurse;


   /* ----------------------------------------------------------------
         This procedure will generate the Package
         called by The Get_WinningTerrMembers API
   -----------------------------------------------------------------*/
   PROCEDURE generate_nm_api(
      errbuf                 OUT NOCOPY     VARCHAR2,
      retcode                OUT NOCOPY     VARCHAR2,
      p_source_id            IN             NUMBER,
      p_trans_object_type_id IN             NUMBER,
      p_debug_flag           IN             VARCHAR2,
      p_sql_trace            IN             VARCHAR2)
   AS
      num_of_combination            NUMBER(15);
      package_name                  VARCHAR2(30);
      package_desc                  VARCHAR2(100);

      l_terr_id                     NUMBER;

      l_abs_source_id               NUMBER;


      l_package_name                VARCHAR2(30);

      l_Retcode                     VARCHAR2(10);
      l_message                     VARCHAR2(2000);

      lp_sysdate                    DATE := SYSDATE;

      query_str                     VARCHAR2(255);
      l_object_name                 VARCHAR2(128);
      l_object_type                 VARCHAR2(18);
      l_created                     DATE;
      l_last_ddl_time               DATE;
      l_timestamp                   VARCHAR2(19);
      l_status                      VARCHAR2(7);

      l_denorm_count                NUMBER;
      l_mv1_count                   NUMBER;
      l_mv2_count                   NUMBER;
      l_mv3_count                   NUMBER;
      l_mv4_count                   NUMBER;
      l_mv5_count                   NUMBER;
      l_mv6_count                   NUMBER;
      l_target_type                 VARCHAR2(30);
      l_input_table_name            VARCHAR2(30);
      l_match_table_name            VARCHAR2(30);
      l_Return_Status               VARCHAR2(1);
      l_Msg_Count                   NUMBER;
      l_Msg_Data                    VARCHAR2(2000);

   BEGIN

      --dbms_output.put_line('JTF_TAE_GEN_PVT.generate_ap: BEGIN');
      -- Initialize Global variables

      G_Debug    := FALSE;

      -- dblee: 09/02/03 set select clause global for new mode TAP
      g_select_list_1 := k_select_list_fm;

      l_abs_source_id := ABS(p_source_id);
      IF p_source_id = -1001 THEN
         IF p_trans_object_type_id = -1002 THEN
            l_target_type := 'ACCOUNT';
            l_input_table_name := 'JTF_TAE_1001_ACCOUNT_NM_TRANS';
            l_match_table_name := 'JTF_TAE_1001_ACCOUNT_MATCHES';

         ELSIF p_trans_object_type_id = -1003 THEN
            l_target_type := 'LEAD';
            l_input_table_name := 'JTF_TAE_1001_LEAD_NM_TRANS';
            l_match_table_name :=  'JTF_TAE_1001_LEAD_MATCHES';

       	 ELSIF p_trans_object_type_id = -1004 THEN
            l_target_type := 'OPPOR';
            l_input_table_name := 'JTF_TAE_1001_OPPOR_NM_TRANS';
            l_match_table_name :=  'JTF_TAE_1001_OPPOR_MATCHES';
         END IF;
      END IF;

      /* If the SQL trace flag is turned on, then turn on the trace */
      /* ARPATEL: 12/15/2003: Bug#3305019 fix */
      --IF UPPER(p_SQL_Trace) = 'Y' THEN
      --   dbms_session.set_sql_trace(TRUE);
      --END IF;

      /* call procedure to populate prod_relation */
      /* ARPATEL: not needed for NM as it has been done for this aource_id/trans_id combo
      JTF_TAE_CONTROL_PVT.Decompose_Terr_Defns
         	(p_Api_Version_Number     => 1.0,
         	p_Init_Msg_List          => FND_API.G_FALSE,
         	p_Commit                 => FND_API.G_FALSE,
         	p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
         	x_Return_Status          => l_return_status,
         	x_Msg_Count              => l_Msg_Count,
         	x_Msg_Data               => l_Msg_Data,
         	p_run_mode               => 'FULL',
         	p_classify_terr_comb     => 'Y',
         	p_process_tx_oin_sel     => 'N',
         	p_generate_indexes       => 'N',
         	p_source_id              => p_source_id,
         	p_trans_id               => p_trans_object_type_id,
          errbuf                   => ERRBUF,
          retcode                  => RETCODE	);
      */

      /* If the debug flag is set, THEN turn on the debug message logging */
      IF UPPER( rtrim(p_Debug_Flag) ) = 'Y' THEN
         G_Debug := TRUE;
      END IF;

      /* Check for territories for this Usage/Transaction Type */
      BEGIN

          SELECT COUNT(*)
          INTO num_of_combination
          FROM jtf_tae_qual_products jtqp
          WHERE jtqp.source_id = p_source_id
            AND jtqp.trans_object_type_id = p_trans_object_type_id;

         --dbms_output.put_line('JTF_TAE_GEN_PVT:' || num_of_combination);

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            num_of_combination := 0;
      END;

      IF G_Debug THEN

         Write_Log(2, ' ');
         Write_Log(2, '/***************** BEGIN: BATCH TAE: TERRITORY STATUS *********************/');
         Write_Log(2, ' ');
         Write_Log(2, 'Inside Generate_API initialize');
         Write_Log(2, 'source_id         - ' || TO_CHAR(p_Source_Id) );
         Write_Log(2, 'Number of valid Qualifier Combinations: ' || num_of_combination );
         Write_Log(2, ' ');
         Write_Log(2, '/***************** END: BATCH TAE: TERRITORY STATUS *********************/');
         Write_Log(2, ' ');

      END IF;

      IF G_Debug THEN

         Write_Log(2, ' ');
         Write_Log(2, '/***************** BEGIN: BATCH TAE: PACKAGE STATUS *********************/');
         Write_Log(2, ' ');

      END IF;

      /* territories exist for this USAGE combination */
      IF (num_of_combination > 0) THEN

         /* Catch-All territory */
         l_terr_id := 1;

         /* Generate Package NAME */
         -- dblee: 09/02/03: new mode matching phase, not new mode fetch
         l_package_name := 'JTF_TAE_' || TO_CHAR (l_abs_source_id) ||'_' || l_target_type|| '_NM_DYN';
         G_DYN_PKG_NAME := l_package_name;

         /* Generate Package BODY */
         package_desc := '/* Auto Generated Package */';
         generate_package_header(l_package_name, package_desc, 'PKB');


         /* generate individual SQL statements  territories */
         gen_terr_rules_recurse (
               p_terr_id           => l_terr_id,
               p_source_id         => p_source_id,
               p_qualifier_type_id => p_trans_object_type_id,
               p_target_type       => l_target_type,
               p_input_table_name  => l_input_table_name,
               p_match_table_name  => l_match_table_name,
               p_search_name       => 'SEARCH_TERR_RULES',
			   -- dblee: 09/02/03: new mode matching phase, not new mode fetch
               p_new_mode_fetch    => 'N' );

         --dbms_output.put_line('NEW ENGINE: Value of l_package_name='||l_package_name);

        /* generate end of package BODY */

        generate_end_of_package(l_package_name, 'TRUE');

      ELSE

         IF (G_Debug) THEN
            Write_Log(2, 'PACKAGE ' || l_package_name  || ' NOT CREATED SUCCESSFULLY: no territories exist for this Usage/Transaction combination. ');
         END IF;

         g_ProgramStatus := 1;

      END IF; /* num_of_combination > 0 */

      /* check status of DYNAMICALLY CREATED PACKAGE */
      BEGIN

         query_str :=
            ' SELECT uo.object_name, uo.object_type, uo.created, uo.last_ddl_time, uo.timestamp, uo.status' ||
            ' FROM user_objects uo' ||
            ' WHERE uo.object_type = ''PACKAGE BODY'' AND uo.object_name = :b1 and rownum < 2';

         EXECUTE IMMEDIATE query_str
         INTO l_object_name
            , l_object_type
            , l_created
            , l_last_ddl_time
            , l_timestamp
            , l_status
         USING l_package_name ;

         IF l_status = 'INVALID' THEN

            /* ACHANDA 03/08/2004 : Bug 3380047 : if the package is created in invalid status the message is */
            /* written to the log file irrespective of wthether debug flag is set to true or false           */
            Write_Log(1, 'Status of the package ' || l_package_name  || ' IS INVALID. ');
            IF G_Debug THEN
               Write_Log(2, ' ');
               Write_Log(2, 'PACKAGE ' || l_package_name  || ' NOT CREATED SUCCESSFULLY: cannot be compiled. ');
               Write_Log(2, ' ');
            END IF;

            /* ACHANDA 03/08/2004 : Bug 3380047 : set the value to 2 to        */
            /* distinguish this exception from other exceptions in the program */
            g_ProgramStatus := 2;

         END IF;

      EXCEPTION
         WHEN others THEN
            NULL;
      END;

      IF G_Debug THEN

         Write_Log(2, ' ');
         Write_Log(2, l_object_type || ': ' || l_package_name);
         Write_Log(2, 'Created: ' || TO_CHAR(l_created) );
         Write_Log(2, 'Last DDL Time: ' || TO_CHAR(l_last_ddl_time) );
         Write_Log(2, 'Timestamp: ' || l_timestamp );
         Write_Log(2, 'Status: ' || l_status );
         Write_Log(2, ' ');
         Write_Log(2, '/***************** END: BATCH TAE: PACKAGE STATUS *********************/');
         Write_Log(2, ' ');

      END IF;


   EXCEPTION
      WHEN utl_file.invalid_path OR utl_file.invalid_mode  OR
           utl_file.invalid_filehandle OR utl_file.invalid_operation OR
           utl_file.write_error THEN
           ERRBUF := 'Program terminated with exception. Error writing to output file.';
           RETCODE := 2;

      WHEN OTHERS THEN
           IF G_Debug THEN
              Write_Log(1,'Program terminated with OTHERS exception. ' || SQLERRM);
           END IF;
           ERRBUF  := 'Program terminated with OTHERS exception. ' || SQLERRM;
           RETCODE := 2;
   END generate_nm_api;


   /* ----------------------------------------------------------------
         This procedure will generate the Package
         called by [step 5 in the NM TAP process - populate NM_TRANS]
		 dblee: 08/15/03
   -----------------------------------------------------------------*/
   PROCEDURE generate_nm0_api (
      errbuf                 OUT NOCOPY    VARCHAR2,
      retcode                OUT NOCOPY    VARCHAR2,
      p_source_id            IN            NUMBER,
      p_trans_object_type_id IN            NUMBER,
      p_debug_flag           IN            VARCHAR2,
      p_sql_trace            IN            VARCHAR2
   )
   AS
      num_of_combination            NUMBER(15);
      package_name                  VARCHAR2(30);
      package_desc                  VARCHAR2(100);

      l_terr_id                     NUMBER;

      l_abs_source_id               NUMBER;


      l_package_name                VARCHAR2(30);

      l_Retcode                     VARCHAR2(10);
      l_message                     VARCHAR2(2000);

      lp_sysdate                    DATE := SYSDATE;

      query_str                     VARCHAR2(255);
      l_object_name                 VARCHAR2(128);
      l_object_type                 VARCHAR2(18);
      l_created                     DATE;
      l_last_ddl_time               DATE;
      l_timestamp                   VARCHAR2(19);
      l_status                      VARCHAR2(7);

      l_denorm_count                NUMBER;
      l_mv1_count                   NUMBER;
      l_mv2_count                   NUMBER;
      l_mv3_count                   NUMBER;
      l_mv4_count                   NUMBER;
      l_mv5_count                   NUMBER;
      l_mv6_count                   NUMBER;
      l_target_type                 VARCHAR2(30);
      l_input_table_name            VARCHAR2(30);
      l_match_table_name            VARCHAR2(30);
      l_Return_Status               VARCHAR2(1);
      l_Msg_Count                   NUMBER;
      l_Msg_Data                    VARCHAR2(2000);

   BEGIN
      -- dbms_output.put_line('JTF_TAE_GEN_PVT.generate_ap: BEGIN');

      -- Initialize Global variables
      G_Debug := FALSE;

      -- dblee: 08/22/03 set select clause global for new mode TAP
      g_select_list_1 := k_select_list_nm;

      l_abs_source_id := ABS(p_source_id);
      IF p_source_id = -1001 THEN
         IF p_trans_object_type_id = -1002 THEN
            l_target_type := 'ACCOUNT';
            l_input_table_name := 'JTF_TAE_1001_ACCOUNT_TRANS';
            l_match_table_name :=  'JTF_TAE_1001_ACCOUNT_NM_TRANS';

         ELSIF p_trans_object_type_id = -1003 THEN
            l_target_type := 'LEAD';
            l_input_table_name := 'JTF_TAE_1001_LEAD_TRANS';
            l_match_table_name :=  'JTF_TAE_1001_LEAD_NM_TRANS';

         ELSIF p_trans_object_type_id = -1004 THEN
            l_target_type := 'OPPOR';
            l_input_table_name := 'JTF_TAE_1001_OPPOR_TRANS';
            l_match_table_name :=  'JTF_TAE_1001_OPPOR_NM_TRANS';
         END IF;
      END IF;

      /* If the SQL trace flag is turned on, then turn on the trace */
      /* ARPATEL: 12/15/2003: Bug#3305019 fix */
      --IF UPPER(p_SQL_Trace) = 'Y' THEN
      --   dbms_session.set_sql_trace(TRUE);
      --END IF;

      /* call procedure to populate prod_relation */
      /* ARPATEL: this is not needed for NM as it has already been executed for this source_id/trans_id
      JTF_TAE_CONTROL_PVT.Decompose_Terr_Defns(
            p_Api_Version_Number     => 1.0,
         	p_Init_Msg_List          => FND_API.G_FALSE,
         	p_Commit                 => FND_API.G_FALSE,
         	p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
         	x_Return_Status          => l_return_status,
         	x_Msg_Count              => l_Msg_Count,
         	x_Msg_Data               => l_Msg_Data,
         	p_run_mode               => 'FULL',
         	p_classify_terr_comb     => 'Y',
         	p_process_tx_oin_sel     => 'N',
         	p_generate_indexes       => 'N',
         	p_source_id              => p_source_id,
         	p_trans_id               => p_trans_object_type_id,
            errbuf                   => ERRBUF,
            retcode                  => RETCODE	);
      */

      /* If the debug flag is set, Then turn on the debug message logging */
      IF UPPER(RTRIM(p_Debug_Flag)) = 'Y' THEN
         G_Debug := TRUE;
      END IF;

      /* Check for territories for this Usage/Transaction Type */
      BEGIN

         SELECT COUNT(*)
         INTO num_of_combination
         FROM jtf_tae_qual_products jtqp
         WHERE jtqp.source_id = p_source_id
            AND jtqp.trans_object_type_id = p_trans_object_type_id;

         --dbms_output.put_line('JTF_TAE_GEN_PVT:' || num_of_combination);

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            num_of_combination := 0;
      END;

      IF G_Debug THEN
         Write_Log(2, ' ');
         Write_Log(2, '/***************** BEGIN: BATCH TAE: TERRITORY STATUS *********************/');
         Write_Log(2, ' ');
         Write_Log(2, 'Inside Generate_API initialize');
         Write_Log(2, 'source_id         - ' || TO_CHAR(p_Source_Id) );
         Write_Log(2, 'Number of valid Qualifier Combinations: ' || num_of_combination );
         Write_Log(2, ' ');
         Write_Log(2, '/***************** END: BATCH TAE: TERRITORY STATUS *********************/');
         Write_Log(2, ' ');
      END IF;

      IF G_Debug THEN
         Write_Log(2, ' ');
         Write_Log(2, '/***************** BEGIN: BATCH TAE: PACKAGE STATUS *********************/');
         Write_Log(2, ' ');
      END IF;

      /* territories exist for this USAGE combination */
      IF num_of_combination > 0 THEN
         /* Catch-All territory */
         l_terr_id := 1;

         /* Generate Package NAME */
         -- dblee: 09/02/03: new mode matching phase, not new mode fetch
         l_package_name := 'JTF_TAE_' || TO_CHAR(l_abs_source_id) || '_' || l_target_type || '_NMC_DYN';
         G_DYN_PKG_NAME := l_package_name;

         /* Generate Package BODY */
         package_desc := '/* Auto Generated Package */';
         generate_package_header(l_package_name, package_desc, 'PKB');

         /* generate individual SQL statements  territories */
         gen_terr_rules_recurse(
               p_terr_id           => l_terr_id,
               p_source_id         => p_source_id,
               p_qualifier_type_id => p_trans_object_type_id,
               p_target_type       => l_target_type,
               p_input_table_name  => l_input_table_name,
               p_match_table_name  => l_match_table_name,
               p_search_name       => 'SEARCH_TERR_RULES',
			   p_new_mode_fetch    => 'Y' );

         --dbms_output.put_line('NEW ENGINE: Value of l_package_name='||l_package_name);

         /* generate end of package BODY */
         generate_end_of_package(l_package_name, 'TRUE');

      ELSE -- num_of_combination = 0

         IF G_Debug THEN
            Write_Log(2, 'PACKAGE ' || l_package_name
            || ' NOT CREATED SUCCESSFULLY: no territories exist for this Usage/Transaction combination. ');
         END IF;

         g_ProgramStatus := 1;
      END IF; /* num_of_combination > 0 */

      /* check status of DYNAMICALLY CREATED PACKAGE */
      BEGIN

         query_str :=
            ' SELECT uo.object_name, uo.object_type, uo.created, uo.last_ddl_time, uo.timestamp, uo.status' ||
            ' FROM user_objects uo' ||
            ' WHERE uo.object_type = ''PACKAGE BODY'' AND uo.object_name = :b1 and rownum < 2';

         EXECUTE IMMEDIATE query_str
         INTO l_object_name
            , l_object_type
            , l_created
            , l_last_ddl_time
            , l_timestamp
            , l_status
         USING l_package_name ;

         IF l_status = 'INVALID' THEN
            /* ACHANDA 03/08/2004 : Bug 3380047 : if the package is created in invalid status the message is */
            /* written to the log file irrespective of wthether debug flag is set to true or false           */
            Write_Log(1, 'Status of the package ' || l_package_name  || ' IS INVALID. ');
            IF G_Debug THEN
               Write_Log(2, ' ');
               Write_Log(2, 'PACKAGE ' || l_package_name  || ' NOT CREATED SUCCESSFULLY: cannot be compiled. ');
               Write_Log(2, ' ');
            END IF;

            /* ACHANDA 03/08/2004 : Bug 3380047 : set the value to 2 to        */
            /* distinguish this exception from other exceptions in the program */
            g_ProgramStatus := 2;
         END IF;

      EXCEPTION
         WHEN others THEN
            NULL;
      END;

      IF G_Debug THEN
         Write_Log(2, ' ');
         Write_Log(2, l_object_type || ': ' || l_package_name);
         Write_Log(2, 'Created: ' || TO_CHAR(l_created) );
         Write_Log(2, 'Last DDL Time: ' || TO_CHAR(l_last_ddl_time) );
         Write_Log(2, 'Timestamp: ' || l_timestamp );
         Write_Log(2, 'Status: ' || l_status );
         Write_Log(2, ' ');
         Write_Log(2, '/***************** END: BATCH TAE: PACKAGE STATUS *********************/');
         Write_Log(2, ' ');
      END IF;

   EXCEPTION
      WHEN utl_file.invalid_path OR utl_file.invalid_mode  OR
           utl_file.invalid_filehandle OR utl_file.invalid_operation OR
           utl_file.write_error THEN
           ERRBUF := 'Program terminated with exception. Error writing to output file.';
           RETCODE := 2;

      WHEN OTHERS THEN
         IF G_Debug THEN
              Write_Log(1,'Program terminated with OTHERS exception. ' || SQLERRM);
         END IF;
         ERRBUF  := 'Program terminated with OTHERS exception. ' || SQLERRM;
         RETCODE := 2;
   END generate_nm0_api;

   --Sales Credit
   PROCEDURE generate_sc_api (
      errbuf                 OUT NOCOPY     VARCHAR2,
      retcode                OUT NOCOPY     VARCHAR2,
      p_source_id            IN             NUMBER,
      p_trans_object_type_id IN             NUMBER,
      p_debug_flag           IN             VARCHAR2,
      p_sql_trace            IN             VARCHAR2
   )
   AS


      num_of_combination            NUMBER(15);
      package_name                  VARCHAR2(30);
      package_desc                  VARCHAR2(100);

      --l_index                       NUMBER;
      l_terr_id                     NUMBER;

      l_abs_source_id               NUMBER;


      l_package_name                VARCHAR2(30);

      l_Retcode                     VARCHAR2(10);
      l_message                     VARCHAR2(2000);

      lp_sysdate                    DATE := SYSDATE;

      query_str                     VARCHAR2(255);
      l_object_name                 VARCHAR2(128);
      l_object_type                 VARCHAR2(18);
      l_created                     DATE;
      l_last_ddl_time               DATE;
      l_timestamp                   VARCHAR2(19);
      l_status                      VARCHAR2(7);

      l_denorm_count                NUMBER;
      l_mv1_count                   NUMBER;
      l_mv2_count                   NUMBER;
      l_mv3_count                   NUMBER;
      l_mv4_count                   NUMBER;
      l_mv5_count                   NUMBER;
      l_mv6_count                   NUMBER;
      l_target_type                 VARCHAR2(30);
      l_input_table_name            VARCHAR2(30);
      l_match_table_name            VARCHAR2(30);
      l_Return_Status               VARCHAR2(1);
      l_Msg_Count                   NUMBER;
      l_Msg_Data                    VARCHAR2(2000);

   BEGIN

      --dbms_output.put_line('JTF_TAE_GEN_PVT.generate_ap: BEGIN');
      -- Initialize Global variables

      G_Debug    := FALSE;

      -- dblee: 09/02/03 set select clause global for full mode TAP
      g_select_list_1 := k_select_list_fm;

      l_abs_source_id := ABS(p_source_id);

            l_target_type := 'SCREDIT';
            l_input_table_name := 'JTF_TAE_1001_SC_TRANS';
            l_match_table_name :=  'JTF_TAE_1001_SC_MATCHES';

      /* If the SQL trace flag is turned on, then turn on the trace */
      /* ARPATEL: 12/15/2003: Bug#3305019 fix */
      --IF UPPER(p_SQL_Trace) = 'Y' THEN
      --   dbms_session.set_sql_trace(TRUE);
      --END IF;

      /* call procedure to populate prod_relation */
      /* ARPATEL: this is not needed as SC is based on ACCOUNT
      JTF_TAE_CONTROL_PVT.Decompose_Terr_Defns
         	(p_Api_Version_Number     => 1.0,
         	p_Init_Msg_List          => FND_API.G_FALSE,
         	p_Commit                 => FND_API.G_FALSE,
         	p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
         	x_Return_Status          => l_return_status,
         	x_Msg_Count              => l_Msg_Count,
         	x_Msg_Data               => l_Msg_Data,
         	p_run_mode               => 'FULL',
         	p_classify_terr_comb     => 'Y',
         	p_process_tx_oin_sel     => 'N',
         	p_generate_indexes       => 'N',
         	p_source_id              => p_source_id,
         	p_trans_id               => p_trans_object_type_id,
          errbuf                   => ERRBUF,
          retcode                  => RETCODE	);
      */

      /* If the debug flag is set, THEN turn on the debug message logging */
      IF UPPER( rtrim(p_Debug_Flag) ) = 'Y' THEN
         G_Debug := TRUE;
      END IF;

      /* Check for territories for this Usage/Transaction Type */
      BEGIN

          SELECT COUNT(*)
          INTO num_of_combination
          FROM jtf_tae_qual_products jtqp
          WHERE jtqp.source_id = p_source_id
            AND jtqp.trans_object_type_id = p_trans_object_type_id;

         --dbms_output.put_line('JTF_TAE_GEN_PVT:' || num_of_combination);

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            num_of_combination := 0;
      END;

      IF G_Debug THEN

         Write_Log(2, ' ');
         Write_Log(2, '/***************** BEGIN: BATCH TAE: TERRITORY STATUS *********************/');
         Write_Log(2, ' ');
         Write_Log(2, 'Inside Generate_API initialize');
         Write_Log(2, 'source_id         - ' || TO_CHAR(p_Source_Id) );
         Write_Log(2, 'Number of valid Qualifier Combinations: ' || num_of_combination );
         Write_Log(2, ' ');
         Write_Log(2, '/***************** END: BATCH TAE: TERRITORY STATUS *********************/');
         Write_Log(2, ' ');

      END IF;

      IF G_Debug THEN

         Write_Log(2, ' ');
         Write_Log(2, '/***************** BEGIN: BATCH TAE: PACKAGE STATUS *********************/');
         Write_Log(2, ' ');

      END IF;

      /* territories exist for this USAGE combination */
      IF (num_of_combination > 0) THEN

         /* Catch-All territory */
         l_terr_id := 1;

         /* Generate Package NAME */
         l_package_name := 'JTF_TAE_' || TO_CHAR (l_abs_source_id) ||'_' || l_target_type|| '_DYN';
         G_DYN_PKG_NAME := l_package_name;

         /* Generate Package BODY */
         package_desc := '/* Auto Generated Package */';
         generate_package_header(l_package_name, package_desc, 'PKB');

         /* generate individual SQL statements  territories */
         gen_terr_rules_recurse (
               p_terr_id           => l_terr_id,
               p_source_id         => p_source_id,
               p_qualifier_type_id => p_trans_object_type_id,
               p_target_type        => l_target_type,
               p_input_table_name  => l_input_table_name,
               p_match_table_name  => l_match_table_name,
               p_search_name       => 'SEARCH_TERR_RULES' );

         --dbms_output.put_line('NEW ENGINE: Value of l_package_name='||l_package_name);

        /* generate end of package BODY */
        generate_end_of_package(l_package_name, 'TRUE');

      ELSE

         IF (G_Debug) THEN
            Write_Log(2, 'PACKAGE ' || l_package_name  || ' NOT CREATED SUCCESSFULLY: no territories exist for this Usage/Transaction combination. ');
         END IF;

         g_ProgramStatus := 1;

      END IF; /* num_of_combination > 0 */

      /* check status of DYNAMICALLY CREATED PACKAGE */
      BEGIN

         query_str :=
            ' SELECT uo.object_name, uo.object_type, uo.created, uo.last_ddl_time, uo.timestamp, uo.status' ||
            ' FROM user_objects uo' ||
            ' WHERE uo.object_type = ''PACKAGE BODY'' AND uo.object_name = :b1 and rownum < 2';

         EXECUTE IMMEDIATE query_str
         INTO l_object_name
            , l_object_type
            , l_created
            , l_last_ddl_time
            , l_timestamp
            , l_status
         USING l_package_name ;

         IF l_status = 'INVALID' THEN

            /* ACHANDA 03/08/2004 : Bug 3380047 : if the package is created in invalid status the message is */
            /* written to the log file irrespective of wthether debug flag is set to true or false           */
            Write_Log(1, 'Status of the package ' || l_package_name  || ' IS INVALID. ');
            IF G_Debug THEN
               Write_Log(2, ' ');
               Write_Log(2, 'PACKAGE ' || l_package_name  || ' NOT CREATED SUCCESSFULLY: cannot be compiled. ');
               Write_Log(2, ' ');
            END IF;

            /* ACHANDA 03/08/2004 : Bug 3380047 : set the value to 2 to        */
            /* distinguish this exception from other exceptions in the program */
            g_ProgramStatus := 2;

         END IF;

      EXCEPTION
         WHEN others THEN
            NULL;
      END;

            IF G_Debug THEN

         Write_Log(2, ' ');
         Write_Log(2, l_object_type || ': ' || l_package_name);
         Write_Log(2, 'Created: ' || TO_CHAR(l_created) );
         Write_Log(2, 'Last DDL Time: ' || TO_CHAR(l_last_ddl_time) );
         Write_Log(2, 'Timestamp: ' || l_timestamp );
         Write_Log(2, 'Status: ' || l_status );
         Write_Log(2, ' ');
         Write_Log(2, '/***************** END: BATCH TAE: PACKAGE STATUS *********************/');
         Write_Log(2, ' ');

      END IF;


   EXCEPTION
      WHEN utl_file.invalid_path OR utl_file.invalid_mode  OR
           utl_file.invalid_filehandle OR utl_file.invalid_operation OR
           utl_file.write_error THEN
           ERRBUF := 'Program terminated with exception. Error writing to output file.';
           RETCODE := 2;

      WHEN OTHERS THEN
           IF G_Debug THEN
              Write_Log(1,'Program terminated with OTHERS exception. ' || SQLERRM);
           END IF;
           ERRBUF  := 'Program terminated with OTHERS exception. ' || SQLERRM;
           RETCODE := 2;
   END generate_sc_api;


      /* ----------------------------------------------------------------
         This procedure will generate the Package
         called by The Get_WinningTerrMembers API
   -----------------------------------------------------------------*/
   PROCEDURE generate_api (
      errbuf                 OUT NOCOPY     VARCHAR2,
      retcode                OUT NOCOPY     VARCHAR2,
      p_source_id            IN             NUMBER,
      p_trans_object_type_id IN             NUMBER,
      p_target_type          IN             VARCHAR2,
      p_debug_flag           IN             VARCHAR2,
      p_sql_trace            IN             VARCHAR2
   )
   AS


      num_of_combination            NUMBER(15);
      package_name                  VARCHAR2(30);
      package_desc                  VARCHAR2(100);

      --l_index                       NUMBER;
      l_terr_id                     NUMBER;

      l_abs_source_id               NUMBER;


      l_package_name                VARCHAR2(30);

      l_Retcode                     VARCHAR2(10);
      l_message                     VARCHAR2(2000);

      lp_sysdate                    DATE := SYSDATE;

      query_str                     VARCHAR2(255);
      l_object_name                 VARCHAR2(128);
      l_object_type                 VARCHAR2(18);
      l_created                     DATE;
      l_last_ddl_time               DATE;
      l_timestamp                   VARCHAR2(19);
      l_status                      VARCHAR2(7);

      l_denorm_count                NUMBER;
      l_mv1_count                   NUMBER;
      l_mv2_count                   NUMBER;
      l_mv3_count                   NUMBER;
      l_mv4_count                   NUMBER;
      l_mv5_count                   NUMBER;
      l_mv6_count                   NUMBER;
      l_target_type                 VARCHAR2(30);
      l_input_table_name            VARCHAR2(30);
      l_match_table_name            VARCHAR2(30);
      l_Return_Status               VARCHAR2(1);
      l_Msg_Count                   NUMBER;
      l_Msg_Data                    VARCHAR2(2000);

      --arpatel 09/03/2003
      l_nm0_message VARCHAR2(2000);
      l_nm0_Retcode VARCHAR2(10);
      l_nm_message VARCHAR2(2000);
      l_nm_Retcode VARCHAR2(10);
      l_sc_message VARCHAR2(2000);
      l_sc_Retcode VARCHAR2(10);

   BEGIN

      --dbms_output.put_line('JTF_TAE_GEN_PVT.generate_ap: BEGIN');
      -- Initialize Global variables

      G_Debug    := FALSE;

      /* ACHANDA 03/08/2004 : Bug 3380047 : some of the dynamic packages are  */
      /* created in "INVALID" status as g_pointer is not properly initialized */
      g_pointer := 0;

      -- dblee: 09/02/03 set select clause global for full mode TAP
      g_select_list_1 := k_select_list_fm;

      l_abs_source_id := ABS(p_source_id);
      IF p_source_id = -1001 THEN

         IF p_target_type = 'RPT' THEN
            l_target_type := p_target_type;
            l_input_table_name := 'JTF_TAE_1001_RPT_TRANS';
            l_match_table_name :=  'JTF_TAE_1001_RPT_MATCHES';

         ELSE
            IF p_trans_object_type_id = -1002 THEN
               l_target_type := 'ACCOUNT';
               l_input_table_name := 'JTF_TAE_1001_ACCOUNT_TRANS';
               l_match_table_name := 'JTF_TAE_1001_ACCOUNT_MATCHES';

            ELSIF p_trans_object_type_id = -1003 THEN
               l_target_type := 'LEAD';
               l_input_table_name := 'JTF_TAE_1001_LEAD_TRANS';
               l_match_table_name :=  'JTF_TAE_1001_LEAD_MATCHES';

          	ELSIF p_trans_object_type_id = -1004 THEN
               l_target_type := 'OPPOR';
               l_input_table_name := 'JTF_TAE_1001_OPPOR_TRANS';
               l_match_table_name :=  'JTF_TAE_1001_OPPOR_MATCHES';

            END IF;
         END IF;
      END IF;

      /* If the SQL trace flag is turned on, then turn on the trace */
      /* ARPATEL: 12/15/2003: Bug#3305019 fix */
      --IF UPPER(p_SQL_Trace) = 'Y' THEN
      --   dbms_session.set_sql_trace(TRUE);
      --END IF;

      /* call procedure to populate prod_relation */
      JTF_TAE_CONTROL_PVT.Decompose_Terr_Defns
         	(p_Api_Version_Number     => 1.0,
         	p_Init_Msg_List          => FND_API.G_FALSE,
         	p_Commit                 => FND_API.G_FALSE,
         	p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
         	x_Return_Status          => l_return_status,
         	x_Msg_Count              => l_Msg_Count,
         	x_Msg_Data               => l_Msg_Data,
         	p_run_mode               => 'FULL',
         	p_classify_terr_comb     => 'Y',
         	p_process_tx_oin_sel     => 'N',
         	p_generate_indexes       => 'N',
         	p_source_id              => p_source_id,
         	p_trans_id               => p_trans_object_type_id,
          errbuf                   => ERRBUF,
          retcode                  => RETCODE	);

      /* If the debug flag is set, THEN turn on the debug message logging */
      IF UPPER( rtrim(p_Debug_Flag) ) = 'Y' THEN
         G_Debug := TRUE;
      END IF;

      if p_source_id = -1001 and p_trans_object_type_id = -1002
      then
      --ARPATEL 09/04/2003
            --create sales credit dyn package
            generate_sc_api (
                              errbuf                 => l_sc_message ,
                              retcode                => l_sc_Retcode ,
                              p_source_id            => p_source_id,
                              p_trans_object_type_id => p_trans_object_type_id,
                              p_debug_flag           => p_debug_flag,
                              p_sql_trace            => p_sql_trace
                             );
       end if;

      /* Check for territories for this Usage/Transaction Type */
      BEGIN

          SELECT COUNT(*)
          INTO num_of_combination
          FROM jtf_tae_qual_products jtqp
          WHERE jtqp.source_id = p_source_id
            AND jtqp.trans_object_type_id = p_trans_object_type_id;

         --dbms_output.put_line('JTF_TAE_GEN_PVT:' || num_of_combination);

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            num_of_combination := 0;
      END;

      IF G_Debug THEN

         Write_Log(2, ' ');
         Write_Log(2, '/***************** BEGIN: BATCH TAE: TERRITORY STATUS *********************/');
         Write_Log(2, ' ');
         Write_Log(2, 'Inside Generate_API initialize');
         Write_Log(2, 'source_id         - ' || TO_CHAR(p_Source_Id) );
         Write_Log(2, 'Number of valid Qualifier Combinations: ' || num_of_combination );
         Write_Log(2, ' ');
         Write_Log(2, '/***************** END: BATCH TAE: TERRITORY STATUS *********************/');
         Write_Log(2, ' ');

      END IF;

      IF G_Debug THEN

         Write_Log(2, ' ');
         Write_Log(2, '/***************** BEGIN: BATCH TAE: PACKAGE STATUS *********************/');
         Write_Log(2, ' ');

      END IF;

      /* territories exist for this USAGE combination */
      IF (num_of_combination > 0) THEN

         /* Catch-All territory */
         l_terr_id := 1;

         /* Generate Package NAME */
         l_package_name := 'JTF_TAE_' || TO_CHAR (l_abs_source_id) ||'_' || l_target_type|| '_DYN';
         G_DYN_PKG_NAME := l_package_name;

         /* Generate Package BODY */
         package_desc := '/* Auto Generated Package */';
         generate_package_header(l_package_name, package_desc, 'PKB');

         /* generate individual SQL statements  territories */
         gen_terr_rules_recurse (
               p_terr_id           => l_terr_id,
               p_source_id         => p_source_id,
               p_qualifier_type_id => p_trans_object_type_id,
               p_target_type        => l_target_type,
               p_input_table_name  => l_input_table_name,
               p_match_table_name  => l_match_table_name,
               p_search_name       => 'SEARCH_TERR_RULES' );

         --dbms_output.put_line('NEW ENGINE: Value of l_package_name='||l_package_name);

        /* generate end of package BODY */
        generate_end_of_package(l_package_name, 'TRUE');

      ELSE

         IF (G_Debug) THEN
            Write_Log(2, 'PACKAGE ' || l_package_name  || ' NOT CREATED SUCCESSFULLY: no territories exist for this Usage/Transaction combination. ');
         END IF;

         g_ProgramStatus := 1;

      END IF; /* num_of_combination > 0 */

      /* check status of DYNAMICALLY CREATED PACKAGE */
      BEGIN

         query_str :=
            ' SELECT uo.object_name, uo.object_type, uo.created, uo.last_ddl_time, uo.timestamp, uo.status' ||
            ' FROM user_objects uo' ||
            ' WHERE uo.object_type = ''PACKAGE BODY'' AND uo.object_name = :b1 and rownum < 2';

         EXECUTE IMMEDIATE query_str
         INTO l_object_name
            , l_object_type
            , l_created
            , l_last_ddl_time
            , l_timestamp
            , l_status
         USING l_package_name ;

         IF l_status = 'INVALID' THEN

            /* ACHANDA 03/08/2004 : Bug 3380047 : if the package is created in invalid status the message is */
            /* written to the log file irrespective of wthether debug flag is set to true or false           */
            Write_Log(1, 'Status of the package ' || l_package_name  || ' IS INVALID. ');
            IF G_Debug THEN
               Write_Log(2, ' ');
               Write_Log(2, 'PACKAGE ' || l_package_name  || ' NOT CREATED SUCCESSFULLY: cannot be compiled. ');
               Write_Log(2, ' ');
            END IF;

            /* ACHANDA 03/08/2004 : Bug 3380047 : set the value to 2 to        */
            /* distinguish this exception from other exceptions in the program */
            g_ProgramStatus := 2;

         END IF;

      EXCEPTION
         WHEN others THEN
            NULL;
      END;

      --ARPATEL 09/03/2003 - Add calls create new mode init (fetch) dyn package and new mode dyn assignment package

      BEGIN

      /* ACHANDA 03/08/2004 : bug 3380047 : initialize g_pointer to 0 */
      g_pointer := 0;

      generate_nm0_api (
      errbuf                 => l_nm0_message ,
      retcode                => l_nm0_Retcode ,
      p_source_id            => p_source_id,
      p_trans_object_type_id => p_trans_object_type_id,
      p_debug_flag           => p_debug_flag,
      p_sql_trace            => p_sql_trace
      );

      /* ACHANDA 03/08/2004 : bug 3380047 : initialize g_pointer to 0 */
      g_pointer := 0;

      generate_nm_api (
      errbuf                 => l_nm_message ,
      retcode                => l_nm_Retcode ,
      p_source_id            => p_source_id,
      p_trans_object_type_id => p_trans_object_type_id,
      p_debug_flag           => p_debug_flag,
      p_sql_trace            => p_sql_trace
      );

      END;


      IF G_Debug THEN

         Write_Log(2, ' ');
         Write_Log(2, l_object_type || ': ' || l_package_name);
         Write_Log(2, 'Created: ' || TO_CHAR(l_created) );
         Write_Log(2, 'Last DDL Time: ' || TO_CHAR(l_last_ddl_time) );
         Write_Log(2, 'Timestamp: ' || l_timestamp );
         Write_Log(2, 'Status: ' || l_status );
         Write_Log(2, ' ');
         Write_Log(2, '/***************** END: BATCH TAE: PACKAGE STATUS *********************/');
         Write_Log(2, ' ');

      END IF;

      IF  g_ProgramStatus = 1 Then
          ERRBUF := 'Program Completed WITH EXCEPTIONS';
          RetCODE := 1;
      ElsIf g_ProgramStatus = 0 Then
          ERRBUF := 'Program completed SUCCESSFULLY.';
          RetCode := 0;
      /* ACHANDA : 03/08/2004 : Added to handle the case of the package getting created in invalid status */
      ElsIf g_ProgramStatus = 2 Then
          ERRBUF := 'Package is created in invalid status.';
          RetCode := 2;
      End If;


   EXCEPTION
      WHEN utl_file.invalid_path OR utl_file.invalid_mode  OR
           utl_file.invalid_filehandle OR utl_file.invalid_operation OR
           utl_file.write_error THEN
           ERRBUF := 'Program terminated with exception. Error writing to output file.';
           RETCODE := 2;

      WHEN OTHERS THEN
           IF G_Debug THEN
              Write_Log(1,'Program terminated with OTHERS exception. ' || SQLERRM);
           END IF;
           ERRBUF  := 'Program terminated with OTHERS exception. ' || SQLERRM;
           RETCODE := 2;
   END generate_api;

END JTF_TAE_GEN_PVT;

/
