--------------------------------------------------------
--  DDL for Package Body JTF_TERR_ENGINE_GEN2_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_ENGINE_GEN2_PVT" AS
/* $Header: jtfvtseb.pls 120.0 2005/06/02 18:23:03 appldev ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERR_ENGINE_GEN_PVT
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager public api's.
--      This package is used to generate the complete territory
--      Engine based on tha data setup in the JTF territory tables
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is available for private use only
--
--    HISTORY
--      03/11/00    JDOCHERT  Created
--      06/27/01    EIHSU     Added Trade Management logic
--      07/17/01    EIHSU     fixed bug 1887176
--      09/26/01    JDOCHERT  BUG#2008850
--      02/14/02    SP        Changed Paameter List for Contracts
--      10/11/2002  jradhakr  Changed the record declaration and access control for Collections
--                            bug 1677560
--      03/08/04    ACHANDA   Bug 3380047
--      03/09/04    ARPATEL   Bug 3470748
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
       If Which = 2 Then
          If G_Debug Then
             FND_FILE.put(1, mssg);
             FND_FILE.NEW_LINE(1, 1);
          End If;
       End IF;
   --
   END Write_Log;


  ----------------------------------------------------------------
  --         Store the Line for the package to a table
  ----------------------------------------------------------------
  PROCEDURE  Add_To_PackageTable(P_statement IN VARCHAR2)
  AS
  BEGIN
        --dbms_output.put_line( P_statement );

        ad_ddl.build_package(P_statement, g_pointer);

        --Increment the counters
        g_pointer := g_pointer + 1;
  Exception
        WHEN Others Then
             NULL;
  END Add_To_PackageTable;


  ----------------------------------------------------------------
  --             Create the package using AD_DDL command
  ----------------------------------------------------------------
   FUNCTION  Call_Create_Package(is_package_body VARCHAR2,
                                 package_name    VARCHAR2) RETURN BOOLEAN
   AS
      l_result         BOOLEAN;
      l_status varchar2(10);
      l_industry varchar2(10);

      l_applsys_schema VARCHAR2(30);

   BEGIN
      --dbms_output.put_line('Inside Call_Create_Package PACKAGE_NAME - ' || package_name || ' g_pointer - ' || to_char(g_pointer - 1) || is_package_body || is_package_body);
      If G_Debug Then
         Write_Log(1, 'INSIDE PROCEDURE JTF_TERR_ENGINE_GEN2_PVT.Call_Create_Package: PACKAGE_NAME = ' || package_name );
      End If;


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
       return TRUE;
   Exception
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
   End Call_Create_Package;





/*---------------------------------------------------------------
  This procedure will generate the PACKAGE
  SPEC or BODY controlled by a parameter

  eg: CREATE OR REPLACE PACKAGE      JTF_TERR_1001_LEAD_1_240 or
      CREATE OR REPLACE PACKAGE BODY JTF_TERR_1001_LEAD_1_240
 ---------------------------------------------------------------*/
   PROCEDURE generate_package_header (
      p_package_name   VARCHAR2,
      p_description    VARCHAR2,
      p_object_type    VARCHAR2
   )
   AS
      v_package_name                VARCHAR2(100);
   BEGIN

      v_package_name := LOWER (p_package_name);

      If G_Debug Then
         Write_Log(1, 'INSIDE PROCEDURE JTF_TERR_ENGINE_GEN2_PVT.generate_package_header: v_package_name = ' || v_package_name );
      End If;

      /* -- The description was commented out as part of AD_DDL error
         -- that caused others exception.
         -- ORA-20000: Unknown or unsupported object type in create_plsql_object()
         --
         -- Add_To_PackageTable (p_description);
      */

      IF (p_object_type = 'PKS')
      THEN

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
   PROCEDURE generate_end_of_package (p_package_name VARCHAR2, is_package_body VARCHAR2)
   AS
      v_package_name                VARCHAR2(100);
      l_Status                      BOOLEAN;
   BEGIN

      v_package_name := LOWER (p_package_name);

      If G_Debug Then
         Write_Log(1, 'INSIDE PROCEDURE JTF_TERR_ENGINE_GEN2_PVT.generate_end_of_package: v_package_name = ' || v_package_name );
      End If;

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
                                       , p_qual_type         VARCHAR2 )
   AS

      lp_pkg_name     VARCHAR2(30);

   BEGIN

      If G_Debug Then
         Write_Log(1, 'INSIDE PROCEDURE JTF_TERR_ENGINE_GEN2_PVT.generate_end_of_procedure: p_procedure_name = ' || p_procedure_name );
      End If;

      lp_pkg_name := 'JTF_TERR_' || TO_CHAR(ABS(p_source_id)) || '_' || p_qual_type || '_DYN';

      Add_To_PackageTable ('  ');
      Add_To_PackageTable ('   /*--------------------------------------');
      Add_To_PackageTable ('   ** When no territories, have NULL ');
      Add_To_PackageTable ('   ** so that package is not invalid' );
      Add_To_PackageTable ('   ** when it is created ');
      Add_To_PackageTable ('   **--------------------------------------*/ ');
      Add_To_PackageTable ('   NULL;');
      Add_To_PackageTable ('  ');
      Add_To_PackageTable ('EXCEPTION  ');
      Add_To_PackageTable ('  ');
      Add_To_PackageTable ('   WHEN COLLECTION_IS_NULL THEN  ');
      Add_To_PackageTable ('      FND_MSG_PUB.Add_Exc_Msg(''' || lp_pkg_name || ''', ''' || p_procedure_name || ''', ''EXCEPTION: COLLECTION_IS_NULL''); ');
      Add_To_PackageTable ('      FND_MSG_PUB.Add_Exc_Msg(''' || lp_pkg_name || ''', ''' || p_procedure_name || ''', SQLERRM); ');
      Add_To_PackageTable ('      ROLLBACK TO JTF_TERR_ASSIGN_TRANSACTION; ');
      Add_To_PackageTable ('      --dbms_output.put_line( ''SQLERRM: '' || SQLERRM );  ');
      Add_To_PackageTable ('      RAISE; ');
      Add_To_PackageTable ('  ');
      Add_To_PackageTable ('   WHEN SUBSCRIPT_BEYOND_COUNT THEN  ');
      Add_To_PackageTable ('      FND_MSG_PUB.Add_Exc_Msg(''' || lp_pkg_name || ''', ''' || p_procedure_name || ''', ''EXCEPTION: SUBSCRIPT_BEYOND_COUNT''); ');
      Add_To_PackageTable ('      FND_MSG_PUB.Add_Exc_Msg(''' || lp_pkg_name || ''', ''' || p_procedure_name || ''', SQLERRM); ');
      Add_To_PackageTable ('      ROLLBACK TO JTF_TERR_ASSIGN_TRANSACTION; ');
      Add_To_PackageTable ('      --dbms_output.put_line( ''SQLERRM: '' || SQLERRM );  ');
      Add_To_PackageTable ('      RAISE; ');
      Add_To_PackageTable ('  ');
      Add_To_PackageTable ('   WHEN SUBSCRIPT_OUTSIDE_LIMIT THEN  ');
      Add_To_PackageTable ('      FND_MSG_PUB.Add_Exc_Msg(''' || lp_pkg_name || ''', ''' || p_procedure_name || ''', ''EXCEPTION: SUBSCRIPT_OUTSIDE_LIMIT''); ');
      Add_To_PackageTable ('      FND_MSG_PUB.Add_Exc_Msg(''' || lp_pkg_name || ''', ''' || p_procedure_name || ''', SQLERRM); ');
      Add_To_PackageTable ('      ROLLBACK TO JTF_TERR_ASSIGN_TRANSACTION; ');
      Add_To_PackageTable ('      --dbms_output.put_line( ''SQLERRM: '' || SQLERRM );  ');
      Add_To_PackageTable ('      RAISE; ');
      Add_To_PackageTable ('  ');
      Add_To_PackageTable ('   WHEN VALUE_ERROR THEN  ');
      Add_To_PackageTable ('      FND_MSG_PUB.Add_Exc_Msg(''' || lp_pkg_name || ''', ''' || p_procedure_name || ''', ''EXCEPTION: VALUE_ERROR''); ');
      Add_To_PackageTable ('      FND_MSG_PUB.Add_Exc_Msg(''' || lp_pkg_name || ''', ''' || p_procedure_name || ''', SQLERRM); ');
      Add_To_PackageTable ('      ROLLBACK TO JTF_TERR_ASSIGN_TRANSACTION; ');
      Add_To_PackageTable ('      --dbms_output.put_line( ''SQLERRM: '' || SQLERRM );  ');
      Add_To_PackageTable ('      RAISE; ');
      Add_To_PackageTable ('  ');
      Add_To_PackageTable ('   WHEN NO_DATA_FOUND THEN  ');
      Add_To_PackageTable ('      FND_MSG_PUB.Add_Exc_Msg(''' || lp_pkg_name || ''', ''' || p_procedure_name || ''', ''EXCEPTION: NO_DATA_FOUND''); ');
      Add_To_PackageTable ('      FND_MSG_PUB.Add_Exc_Msg(''' || lp_pkg_name || ''', ''' || p_procedure_name || ''', SQLERRM); ');
      Add_To_PackageTable ('      ROLLBACK TO JTF_TERR_ASSIGN_TRANSACTION; ');
      Add_To_PackageTable ('      --dbms_output.put_line( ''SQLERRM: '' || SQLERRM );  ');
      Add_To_PackageTable ('      RAISE; ');
      Add_To_PackageTable ('  ');
      Add_To_PackageTable ('   WHEN OTHERS THEN  ');
      Add_To_PackageTable ('      FND_MSG_PUB.Add_Exc_Msg(''' || lp_pkg_name || ''', ''' || p_procedure_name || ''', ''EXCEPTION: OTHERS''); ');
      Add_To_PackageTable ('      FND_MSG_PUB.Add_Exc_Msg(''' || lp_pkg_name || ''', ''' || p_procedure_name || ''', SQLERRM); ');
      Add_To_PackageTable ('      ROLLBACK TO JTF_TERR_ASSIGN_TRANSACTION; ');
      Add_To_PackageTable ('      --dbms_output.put_line( ''SQLERRM: '' || SQLERRM );  ');
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

      If G_Debug Then
         Write_Log(1, 'INSIDE PROCEDURE JTF_TERR_ENGINE_GEN2_PVT.generate_object_definition: procedure_name = ' || procedure_name );
      End If;

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

/*************************************************
** Gets all the qualifiers that are used by this
** Usage/Transaction type combination
** and builds the SQL statement to check the
** qualifier rules
**************************************************/
   PROCEDURE build_qualifier_rules(
      p_source_id     IN   NUMBER,
      p_qual_type_id  IN   NUMBER,
      x_qual_rules    OUT NOCOPY  VARCHAR2 )
   AS

      CURSOR c_terr_qual( lp_source_id      NUMBER
                        , lp_qual_type_id   NUMBER
                        , lp_sysdate        DATE   ) IS

         SELECT jqu.qual_usg_id, jqu.rule1
           FROM jtf_qual_usgs_all jqu
              , jtf_qual_type_usgs jqtu
              , jtf_qual_type_denorm_v v
          WHERE --jqu.enabled_flag = 'Y'
                jqu.org_id = -3113
            AND jqu.qual_type_usg_id = jqtu.qual_type_usg_id
            AND jqtu.source_id = lp_source_id
            AND jqtu.qual_type_id = v.related_id
            AND jqu.rule1 IS NOT NULL
            AND v.qual_type_id = lp_qual_type_id
            AND EXISTS ( SELECT jtq.terr_id
                         FROM jtf_terr_qtype_usgs_all jtqu
                            , jtf_terr_all jt
                            , jtf_terr_qual_all jtq
                            , jtf_qual_type_usgs jqtu
                         WHERE NVL(jt.end_date_active, lp_sysdate + 1) > lp_sysdate
                           AND NVL(jt.start_date_active, lp_sysdate - 1) < lp_sysdate
                           AND jtqu.terr_id = jt.terr_id
                           AND jqtu.qual_type_usg_id = jtqu.qual_type_usg_id
                           AND jqtu.qual_type_id = lp_qual_type_id
                           AND jtqu.terr_id = jtq.terr_id
                           AND jtq.qual_usg_id = jqu.qual_usg_id )
         UNION

        SELECT jqu.qual_usg_id, jqu.rule2
           FROM jtf_qual_usgs_all jqu
              , jtf_qual_type_usgs_all jqtu
              , jtf_qual_type_denorm_v v
          WHERE --jqu.enabled_flag = 'Y'
                jqu.org_id = -3113
            AND jqu.qual_type_usg_id = jqtu.qual_type_usg_id
            AND jqtu.source_id = lp_source_id
            AND jqtu.qual_type_id = v.related_id
            AND jqu.rule2 IS NOT NULL
            AND v.qual_type_id = lp_qual_type_id
            AND EXISTS ( SELECT jtq.terr_id
                         FROM jtf_terr_values_all jtv
                            , jtf_terr_qtype_usgs_all jtqu
                            , jtf_terr_all jt
                            , jtf_terr_qual_all jtq
                            , jtf_qual_type_usgs jqtu
                         WHERE NVL(jt.end_date_active, lp_sysdate + 1) > lp_sysdate
                           AND NVL(jt.start_date_active, lp_sysdate - 1) < lp_sysdate
                           AND jtqu.terr_id = jt.terr_id
                           AND jtv.terr_qual_id = jtq.terr_qual_id
                           AND jtv.comparison_operator IN ('<>', 'NOT LIKE', 'NOT BETWEEN')
                           AND jqtu.qual_type_usg_id = jtqu.qual_type_usg_id
                           AND jqtu.qual_type_id = lp_qual_type_id
                           AND jtqu.terr_id = jtq.terr_id
                           AND jtq.qual_usg_id = jqu.qual_usg_id ) ;

      l_qual_usg_id        NUMBER;
      l_qual_rules         VARCHAR2(32767);
      l_rule               VARCHAR2(32767);
      l_counter            NUMBER := 1;
      l_newline            VARCHAR2(2);
      l_indent             VARCHAR2(30);
      l_sysdate            DATE;

   BEGIN

      --dbms_output.put_line('Inside build_rule_expression ');

      If G_Debug Then
         Write_Log(2, ' ');
         Write_Log(2, 'INSIDE PROCEDURE JTF_TERR_ENGINE_GEN2_PVT.build_qualifier_rules:');
         Write_Log(2, '   source_id         - ' || TO_CHAR(p_Source_Id) );
         Write_Log(2, '   qual_type_id      - ' || TO_CHAR(p_qual_type_id) );
         Write_Log(2, ' ');
      End If;

      l_newline := FND_GLOBAL.Local_Chr(10); /* newline character */
      l_sysdate := SYSDATE;

      OPEN c_terr_qual(p_source_id, p_qual_type_id, l_sysdate);

      LOOP

         FETCH c_terr_qual INTO l_qual_usg_id, l_rule;
         EXIT WHEN c_terr_qual%NOTFOUND;


          If G_Debug Then
             Write_Log(2, ' ');
             Write_Log(2, '/*----------------------------------------*/');
             Write_Log(2, 'PACKAGE RULE #' || l_counter );
             Write_Log(2, 'QUAL_USG_ID: ' || TO_CHAR(l_qual_usg_id) );
             Write_Log(2, ' ');
             Write_Log(2, 'RULE: ' ||l_rule );
             Write_Log(2, ' ');
             Write_Log(2, '/*----------------------------------------*/');
             Write_Log(2, ' ');
          End If;

         --IF (l_counter > 1) THEN
         --    l_qual_rules := l_newline || l_qual_rules || l_newline ||
         --                    ' UNION ALL ';
         --END IF;

         IF (l_counter = 1) THEN

           l_qual_rules :=  l_newline || l_rule ;

         ELSE

           l_qual_rules := l_qual_rules || l_newline || l_newline ||
                           'UNION ALL ' || l_newline || l_newline || l_rule;

         END IF;

         l_counter := l_counter + 1;
      END LOOP;

      CLOSE c_terr_qual;

      x_qual_rules := l_qual_rules;
      --dbms_output.put_line('Leaving build_rule_expression ');

   EXCEPTION
      WHEN OTHERS THEN
         g_ProgramStatus := 1;
         Add_To_PackageTable ('-- Program encountered invalid territory ');

   END build_qualifier_rules;



   PROCEDURE gen_terr_rules_recurse (
      p_terr_id             IN       NUMBER,
      p_source_id           IN       NUMBER,
      p_qualifier_type_id   IN       NUMBER,
      p_qualifier_type      IN       VARCHAR2,
      p_search_name         IN       VARCHAR2 := 'SEARCH_TERR_RULES'
   )
   AS
      l_procedure_name       VARCHAR2(30);
      l_procedure_desc       VARCHAR2(255);
      l_parameter_list1      VARCHAR2(360);
      l_parameter_list2      VARCHAR2(360);
      l_qual_rules           VARCHAR2(32767);

      l_str_len        NUMBER;
      l_start          NUMBER;
      l_get_nchar      NUMBER;
      l_next_newline   NUMBER;
      l_rule_str       VARCHAR2(256);
      l_newline        VARCHAR2(2) := FND_GLOBAL.Local_Chr(10); /* newline character */
      l_indent         VARCHAR2(30);


   BEGIN
--dbms_output.put_line('gen_terr_rules_recurse.p_search_name: ' || p_search_name);

      IF G_Debug THEN
         Write_Log(1, 'INSIDE PROCEDURE JTF_TERR_ENGINE_GEN2_PVT.gen_terr_rules_recurse');
      END IF;

      --dbms_output.put_line('Value of p_qualifier_type_id='|| l_indent||TO_CHAR(p_qualifier_type_id));

      Build_Qualifier_Rules(p_source_id, p_qualifier_type_id, l_qual_rules);

      l_str_len := LENGTH(l_qual_rules);

          --dbms_output.put_line('After Build_Qualifier_Rules');

          l_procedure_name := p_search_name;
          l_procedure_desc := '/* Territory rules for Usage/Transaction: ' ||
                              TO_CHAR(p_source_id) || ' / ' || p_qualifier_type || ' */';

          IF ( p_source_id = -1001 AND
               p_qualifier_type_id = -1002) THEN

             IF (p_search_name =  'SEARCH_TERR_RULES') THEN

                 l_parameter_list1 :=
                         '  p_rec                IN          JTF_TERRITORY_PUB.jtf_' || p_qualifier_type || '_bulk_rec_type ' || l_newline ||
                       '  , x_rec                OUT NOCOPY  JTF_TERRITORY_PUB.Winning_Bulk_Rec_Type ' || l_newline ||
                       '  , p_top_level_terr_id  IN          NUMBER := FND_API.G_MISS_NUM ';

				 l_parameter_list2 := '  , p_num_winners        IN          NUMBER := FND_API.G_MISS_NUM ';

             ELSIF (p_search_name =  'SEARCH_TERR_RULES_ALL') THEN

                 --
                 -- 03/27 JDOCHERT 11.5.4.0.2 code
                 -- x_rec is of different type that for SEARCH_TERR_RULES procedure above
                 --
                 l_parameter_list1 :=
                                '  p_rec    IN          JTF_TERRITORY_PUB.jtf_' || p_qualifier_type ||'_bulk_rec_type ' || l_newline ||
                              '  , x_rec    OUT NOCOPY  JTF_TERR_LOOKUP_PUB.win_rsc_tbl_type ' ;
             END IF;

          ELSIF ( p_source_id = -1001 AND
                  p_qualifier_type_id IN (-1003, -1004) ) THEN /* Opportunity + Lead */

              l_parameter_list1 :=
                                '  p_rec             IN          JTF_TERRITORY_PUB.jtf_' || p_qualifier_type ||'_bulk_rec_type ' || l_newline ||
                              '  , x_rec             OUT NOCOPY  JTF_TERRITORY_PUB.Winning_Bulk_Rec_Type ';

          ELSIF ( p_source_id = -1001 AND
                  p_qualifier_type_id IN (-1105) ) THEN /* Quote*/

              l_parameter_list1 :=
                                '  p_rec             IN          JTF_TERRITORY_PUB.jtf_ACCOUNT_bulk_rec_type ' || l_newline ||
                              '  , x_rec             OUT NOCOPY  JTF_TERRITORY_PUB.Winning_Bulk_Rec_Type ';

          ELSIF ( p_source_id IN (-1003, -1500, -1600, -1700) ) THEN

              l_parameter_list1 :=
                                '  p_rec             IN          JTF_TERR_ASSIGN_PUB.bulk_trans_rec_type ' || l_newline ||
                              '  , x_rec             OUT NOCOPY  JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type ';

          ELSE  /* Defects/Service */

              l_parameter_list1 :=
                                '  p_rec             IN          JTF_TERRITORY_PUB.jtf_bulk_trans_rec_type ' || l_newline ||
                              '  , x_rec             OUT NOCOPY  JTF_TERRITORY_PUB.Winning_Bulk_Rec_Type ';
          END IF;

          l_parameter_list2 := l_parameter_list2 || l_newline ||
                       '  , p_role               IN          VARCHAR2 := FND_API.G_MISS_CHAR ' || l_newline ||
                       '  , p_resource_type      IN          VARCHAR2 := FND_API.G_MISS_CHAR ';

		  IF (p_search_name =  'SEARCH_TERR_RULES_ALL') THEN
		     l_parameter_list2 := NULL;
		  END IF;

          generate_object_definition( l_procedure_name, l_procedure_desc,
                                      l_parameter_list1, l_parameter_list2, 'P', 'BOOLEAN', 'PKB' );

          Add_To_PackageTable (' ');
          Add_To_PackageTable (' l_return_status              VARCHAR2(10);');
          Add_To_PackageTable (' l_result_id                  NUMBER;');
          Add_To_PackageTable (' l_sysdate                    DATE;');
          --Add_To_PackageTable (' l_top_level_terr_id_lst      jtf_terr_number_list := jtf_terr_number_list();');
          --Add_To_PackageTable (' l_num_win_lst                jtf_terr_number_list := jtf_terr_number_list();');
          Add_To_PackageTable (' ');
          Add_To_PackageTable (' lp_top_level_terr_id         NUMBER;');
          Add_To_PackageTable (' lp_num_winners               NUMBER;');
          Add_To_PackageTable (' lp_role                      VARCHAR2(60);');
          Add_To_PackageTable (' lp_resource_type             VARCHAR2(60);');
          Add_To_PackageTable (' ');
          Add_To_PackageTable (' lp_qual_type_id               NUMBER;');
          Add_To_PackageTable (' lp_source_id                  NUMBER;');
          Add_To_PackageTable (' ');
          Add_To_PackageTable (' l_cursor                     NUMBER;');
          Add_To_PackageTable (' l_dyn_str                    VARCHAR2(32767);');
          Add_To_PackageTable (' l_num_rows                   NUMBER;');
          Add_To_PackageTable (' indx                         NUMBER := 1;');
          Add_To_PackageTable (' lp_trans_id_tbl              jtf_terr_number_list := jtf_terr_number_list();');
          Add_To_PackageTable (' ');
          Add_To_PackageTable (' l_result_id_arr                   DBMS_SQL.NUMBER_TABLE; ');
          Add_To_PackageTable (' l_trans_id_arr                    DBMS_SQL.NUMBER_TABLE; ');
          Add_To_PackageTable (' l_trans_object_id_arr             DBMS_SQL.NUMBER_TABLE; ');
          Add_To_PackageTable (' l_trans_object_detail_id_arr      DBMS_SQL.NUMBER_TABLE; ');
          Add_To_PackageTable (' l_absolute_rank_arr               DBMS_SQL.NUMBER_TABLE; ');
          Add_To_PackageTable (' l_terr_id_arr                     DBMS_SQL.NUMBER_TABLE; ');
          Add_To_PackageTable (' l_top_level_terr_id_arr           DBMS_SQL.NUMBER_TABLE; ');
          Add_To_PackageTable (' l_num_winners_arr                 DBMS_SQL.NUMBER_TABLE; ');
          Add_To_PackageTable (' l_terr_rsc_id_arr                 DBMS_SQL.NUMBER_TABLE; ');
          Add_To_PackageTable (' l_resource_id_arr                 DBMS_SQL.NUMBER_TABLE; ');
          Add_To_PackageTable (' l_resource_type_arr               DBMS_SQL.VARCHAR2_TABLE; ');
          Add_To_PackageTable (' l_group_id_arr                    DBMS_SQL.NUMBER_TABLE; ');
          Add_To_PackageTable (' l_role_arr                        DBMS_SQL.VARCHAR2_TABLE; ');
          Add_To_PackageTable (' l_full_access_flag_arr            DBMS_SQL.VARCHAR2_TABLE; ');
          Add_To_PackageTable (' l_primary_contact_flag_arr        DBMS_SQL.VARCHAR2_TABLE; ');
          Add_To_PackageTable (' ');
          Add_To_PackageTable (' l_counter                    NUMBER; ');
          Add_To_PackageTable (' ');

          IF (p_search_name =  'SEARCH_TERR_RULES_ALL') THEN

             Add_To_PackageTable ('  CURSOR csr_get_rsc ( lp_terr_id NUMBER  ');
             Add_To_PackageTable ('                     , lp_sysdate DATE) IS  ');
             Add_To_PackageTable ('        SELECT /*+ ORDERED ' );
             Add_To_PackageTable ('                   INDEX (jtr JTF_TERR_RSC_N3) */ ' );
             Add_To_PackageTable ('        DISTINCT ' );
             Add_To_PackageTable ('          rsc.resource_name     resource_name ' );
             Add_To_PackageTable ('        , rsc.source_job_title  resource_job_title ' );
             Add_To_PackageTable ('        , rsc.source_phone      resource_phone ' );
             Add_To_PackageTable ('        , rsc.source_email      resource_email ' );
             Add_To_PackageTable ('        , rsc.source_mgr_name   resource_mgr_name ' );
             Add_To_PackageTable ('        , mgr.source_phone      resource_mgr_phone ' );
             Add_To_PackageTable ('        , mgr.source_email      resource_mgr_email ' );
             Add_To_PackageTable ('        , lp_terr_id            terr_id ' );
             Add_To_PackageTable ('        FROM ' );
             Add_To_PackageTable ('          jtf_terr_rsc_all jtr ' );
             Add_To_PackageTable ('        , jtf_terr_rsc_access_all jtra ' );
             Add_To_PackageTable ('        , jtf_rs_resource_extns_vl rsc ' );
             Add_To_PackageTable ('        , jtf_rs_resource_extns_vl mgr ' );
             Add_To_PackageTable ('        WHERE mgr.source_id (+) = rsc.source_mgr_id ' );
             Add_To_PackageTable ('          AND rsc.resource_id = jtr.resource_id ' );
             Add_To_PackageTable ('          AND DECODE( rsc.category ' );
             Add_To_PackageTable ('                  , ''EMPLOYEE'', ''RS_EMPLOYEE'' ' );
             Add_To_PackageTable ('                  , ''PARTNER'', ''RS_PARTNER''  ' );
             Add_To_PackageTable ('                  , ''SUPPLIER_CONTACT'', ''RS_SUPPLIER''  ' );
             Add_To_PackageTable ('                  , ''PARTY'', ''RS_PARTY'' ' );
             Add_To_PackageTable ('                  , ''OTHER'', ''RS_OTHER'' ' );
             Add_To_PackageTable ('                  , ''TBH'', ''RS_TBH'') = jtr.resource_type ' );
             Add_To_PackageTable ('          AND( jtra.ACCESS_TYPE IN (''ACCOUNT'', ''OPPOR'', ''LEAD'') OR jtra.ACCESS_TYPE IS NULL ) ' );
             Add_To_PackageTable ('          AND jtr.terr_rsc_id = jtra.terr_rsc_id (+) ' );
             Add_To_PackageTable ('          AND NVL(jtr.end_date_active, lp_sysdate+1) > lp_sysdate ');
             Add_To_PackageTable ('          AND NVL(jtr.start_date_active, lp_sysdate-1) < lp_sysdate ');
             Add_To_PackageTable ('          AND jtr.terr_id = lp_terr_id ; ' );
             Add_To_PackageTable (' ');
             Add_To_PackageTable (' l_rsc_counter                NUMBER; ');

          END IF;


          Add_To_PackageTable ('BEGIN');
          Add_To_PackageTable (' ');
          Add_To_PackageTable ('   SAVEPOINT JTF_TERR_ASSIGN_TRANSACTION; ');
          Add_To_PackageTable (' ');


          /* JDOCHERT: 07/18/03: bug#3020630 */
          --
          -- now in jtftrmvc.sql
          --Add_To_PackageTable (' ');
          --Add_To_PackageTable ('   JTF_TERR_ASSIGN_PUB.create_matches_GT_tbls( ');
          --Add_To_PackageTable ('      p_source_id             => ' || TO_CHAR(p_source_id) );
          --Add_To_PackageTable ('    , p_trans_object_type_id  => ' || TO_CHAR(p_qualifier_type_id) );
          --Add_To_PackageTable ('    , x_return_status         => l_return_status ' );
          --Add_To_PackageTable ('   ); ');
          --Add_To_PackageTable (' ');
          --

          /* ARPATEL: 01/20/04: bug#3348954 */
          Add_To_PackageTable ('   DELETE FROM jtf_terr_results_GT_MT;  ');
          Add_To_PackageTable (' ');

          IF ( p_source_id = -1001 AND
               p_qualifier_type_id IN (-1002, -1003, -1004) ) THEN
             Add_To_PackageTable ('   FOR j IN p_rec.party_id.FIRST..p_rec.party_id.LAST LOOP ');
          ELSE
             Add_To_PackageTable ('   FOR j IN p_rec.trans_object_id.FIRST..p_rec.trans_object_id.LAST LOOP ');
          END IF;

          Add_To_PackageTable ('     lp_trans_id_tbl.EXTEND;');
          Add_To_PackageTable ('     lp_trans_id_tbl(j) := j;');
          Add_To_PackageTable ('   END LOOP;');
          Add_To_PackageTable (' ');


          --
          --Add_To_PackageTable ('   SELECT JTF_TERR_RESULTS_S.NEXTVAL ');
          --Add_To_PackageTable ('   INTO l_result_id ');
          --Add_To_PackageTable ('   FROM dual;');
          --Add_To_PackageTable (' ');
          --Add_To_PackageTable ('   --dbms_output.put_line(''Value of l_result_id=''||TO_CHAR(l_result_id)); ');
          --

          Add_To_PackageTable (' ');
          Add_To_PackageTable ('   l_sysdate        := SYSDATE;');
          Add_To_PackageTable ('   lp_qual_type_id  := ' || TO_CHAR(p_qualifier_type_id) || ';');
          Add_To_PackageTable ('   lp_source_id     := ' || TO_CHAR(p_source_id) || ';');
          Add_To_PackageTable (' ');

       IF ( l_str_len > 0 ) THEN

          IF ( p_search_name =  'SEARCH_TERR_RULES' ) THEN


             IF (p_source_id = -1001 AND p_qualifier_type_id = -1002) THEN

                Add_To_PackageTable ('   lp_top_level_terr_id := p_top_level_terr_id; ');
                Add_To_PackageTable ('   lp_num_winners := p_num_winners; ');
                Add_To_PackageTable (' ');
                Add_To_PackageTable ('   IF ( lp_top_level_terr_id = FND_API.G_MISS_NUM ) THEN ');
                Add_To_PackageTable ('      lp_top_level_terr_id  := NULL; ');
                Add_To_PackageTable ('      lp_num_winners  := NULL; ');
                Add_To_PackageTable ('   END IF; ');
                Add_To_PackageTable (' ');

             END IF;

             Add_To_PackageTable ('   lp_role := p_role; ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('   IF ( lp_role = FND_API.G_MISS_CHAR ) THEN ');
             Add_To_PackageTable ('      lp_role := NULL; ');
             Add_To_PackageTable ('   END IF; ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('   lp_resource_type := p_resource_type; ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('   IF ( lp_resource_type = FND_API.G_MISS_CHAR ) THEN ');
             Add_To_PackageTable ('      lp_resource_type := NULL; ');
             Add_To_PackageTable ('   END IF; ');
             Add_To_PackageTable (' ');


          END IF; /* ( p_search_name =  'SEARCH_TERR_RULES' ) */

          Add_To_PackageTable (' ');


          -- JDOCHERT - 05/03/01
          IF ( p_source_id = -1001 AND
               p_qualifier_type_id IN (-1002, -1003, -1004) ) THEN
             -- JDOCHERT - 06/05/01
             Add_To_PackageTable ('   FORALL i IN lp_trans_id_tbl.FIRST..lp_trans_id_tbl.LAST ');
          ELSE
             Add_To_PackageTable ('   FORALL i IN p_rec.trans_object_id.FIRST..p_rec.trans_object_id.LAST ');
          END IF;

          Add_To_PackageTable (' ');
          Add_To_PackageTable ('      INSERT INTO jtf_terr_results_GT_MT jtr ');
          Add_To_PackageTable ('      ( ');
          Add_To_PackageTable ('         result_id');
          Add_To_PackageTable ('       , trans_id');
          Add_To_PackageTable ('       , trans_object_id');
          Add_To_PackageTable ('       , trans_detail_object_id');
          Add_To_PackageTable ('       , terr_id');
          Add_To_PackageTable ('       , absolute_rank');
          Add_To_PackageTable ('       , top_level_terr_id');
          Add_To_PackageTable ('       , worker_id');

		  --
		  -- JDOCHERT: 08/03/03: NUM WINNERS NOT NEEDED
		  -- BUG#3020630
		  --Add_To_PackageTable ('       , num_winners');
		  --

          Add_To_PackageTable ('      ) ');
          Add_To_PackageTable ('      SELECT /*+ ORDERED */');
          Add_To_PackageTable ('             l_result_id');
          Add_To_PackageTable ('           , lp_trans_id_tbl(i)');

          IF ( p_source_id = -1001 ) THEN

             IF (p_qualifier_type_id = -1002) THEN

                Add_To_PackageTable ('           , p_rec.party_id(i) ');
                Add_To_PackageTable ('           , p_rec.party_site_id(i) ');

             ELSIF (p_qualifier_type_id = -1003) THEN

                Add_To_PackageTable ('           , p_rec.sales_lead_id(i) ');
                Add_To_PackageTable ('           , p_rec.sales_lead_line_id(i) ');

             ELSIF (p_qualifier_type_id = -1004) THEN

                Add_To_PackageTable ('           , p_rec.lead_id(i) ');
                Add_To_PackageTable ('           , p_rec.lead_line_id(i) ');

             ELSIF (p_qualifier_type_id = -1105) THEN
                Add_To_PackageTable ('           , p_rec.trans_object_id(i) ');
                Add_To_PackageTable ('           , 1 TRANS_DETAIL_OBJECT_ID ');
             END IF;

          ELSE
             Add_To_PackageTable ('           , p_rec.trans_object_id(i) ');
             Add_To_PackageTable ('           , p_rec.trans_detail_object_id(i) ');
          END IF;

          Add_To_PackageTable ('           , terr_id ');
          Add_To_PackageTable ('           , absolute_rank ');
          Add_To_PackageTable ('           , top_level_terr_id');
          Add_To_PackageTable ('           , 1 WORKER_ID');

		  --
		  -- JDOCHERT: 08/03/03: NUM WINNERS NOT NEEDED
		  -- BUG#3020630
          --Add_To_PackageTable ('           , num_winners');
		  --

          Add_To_PackageTable ('      FROM  ');
          Add_To_PackageTable ('          (  /* START OF DYNAMIC PART */ ');


          --
          --IF ( p_search_name =  'SEARCH_TERR_RULES' ) THEN
          --
          --   Add_To_PackageTable ('             /* START OF INLINE VIEW# OUTER */ ');
          --   Add_To_PackageTable ('             ( SELECT ILV.terr_id terr_id, ILV.absolute_rank absolute_rank, ILV.top_level_terr_id ');
          --   Add_To_PackageTable ('               FROM (  /* START OF DYNAMIC PART */ ');
          --
          --ELSIF ( p_search_name =  'SEARCH_TERR_RULES_ALL' ) THEN
          --
          --   Add_To_PackageTable ('                    (  /* START OF DYNAMIC PART */ ');
          --
          --END IF;
          --

          l_newline := FND_GLOBAL.Local_Chr(10); /* newline character */
          l_indent  := '            ';
          l_start := 1;
          l_next_newline := 0;


          --dbms_output.put_line('BEFORE LOOP: Value of l_next_newline='||TO_CHAR(l_next_newline));
          --dbms_output.put_line('Value of LENGTH(l_qual_rules)= ' || TO_CHAR(l_str_len) );

          WHILE (TRUE) LOOP

            l_next_newline := INSTR(l_qual_rules, l_newline, l_start, 1);

            IF (l_next_newline = 0) THEN
               /* no new line characters => end of string */
               l_get_nchar := l_str_len;
            ELSE
               /* set of characters up to next newline */
               l_get_nchar := l_next_newline - l_start;
            END IF;


            --dbms_output.put_line('Value of lstart='|| TO_CHAR(l_start) || ' l_next_newline='||TO_CHAR(l_next_newline) || ' l_get_nchar='||TO_CHAR(l_get_nchar));

            l_rule_str := substr(l_qual_rules, l_start, l_get_nchar);

            --dbms_output.put_line(l_rule_str);
            Add_To_PackageTable(l_indent || l_rule_str);

            EXIT WHEN l_next_newline = 0;

            l_rule_str := NULL;
            l_start := l_next_newline + 1;

          END LOOP;


          Add_To_PackageTable (' ');
          Add_To_PackageTable ('                    /* END OF DYNAMIC PART */ ) ILV ');

		  --
		  -- JDOCHERT: 08/03/03: NUM WINNERS NOT NEEDED
		  -- BUG#3020630
          --Add_To_PackageTable ('      GROUP BY ILV.terr_id, ilv.absolute_rank, ilv.top_level_terr_id, ilv.num_winners ');
		  --
          Add_To_PackageTable ('      GROUP BY ILV.terr_id, ilv.absolute_rank, ilv.top_level_terr_id ');
		  --

          /* ARPATEL: 12/03/2003 for Oracle Sales we now use num_qual in jtf_terr_qtype_usgs_all */
          IF p_source_id = -1001
          THEN
            Add_To_PackageTable ('      HAVING (ILV.terr_id, COUNT(*)) IN ( ');
            Add_To_PackageTable ('           SELECT ');
            Add_To_PackageTable ('                 jtw.terr_id ');
            Add_To_PackageTable ('               , jua.num_qual ' );
            Add_To_PackageTable ('           FROM jtf_terr_denorm_rules_all jtw ');
            Add_To_PackageTable ('               ,jtf_terr_qtype_usgs_all jua ');
            Add_To_PackageTable ('               ,jtf_qual_type_usgs_all jqa ');
            Add_To_PackageTable ('           WHERE jtw.source_id = lp_source_id');
            Add_To_PackageTable ('             AND jqa.source_id = jtw.source_id ');
            Add_To_PackageTable ('             AND jqa.qual_type_id = lp_qual_type_id ');
            Add_To_PackageTable ('             AND jtw.resource_exists_flag = ''Y'' ');
            Add_To_PackageTable ('             AND jtw.terr_id = jua.terr_id ');
            Add_To_PackageTable ('             AND jua.qual_type_usg_id = jqa.qual_type_usg_id ');
            Add_To_PackageTable ('             AND jtw.related_terr_id = ilv.terr_id ');
            Add_To_PackageTable ('             AND jtw.terr_id = ilv.terr_id ); ');
            Add_To_PackageTable (' ');
            Add_To_PackageTable (' ');
          ELSE
            Add_To_PackageTable ('      HAVING (ILV.terr_id, COUNT(*)) IN ( ');
            Add_To_PackageTable ('           SELECT ');
            Add_To_PackageTable ('                 jtw.terr_id ');
            Add_To_PackageTable ('               , jtw.num_qual ' );
            Add_To_PackageTable ('           FROM jtf_terr_denorm_rules_all jtw ');
            Add_To_PackageTable ('           WHERE jtw.source_id = lp_source_id');
            Add_To_PackageTable ('             AND jtw.qual_type_id = lp_qual_type_id ');
            Add_To_PackageTable ('             AND jtw.resource_exists_flag = ''Y'' ');
            Add_To_PackageTable ('             AND jtw.related_terr_id = ilv.terr_id ');
            Add_To_PackageTable ('             AND jtw.terr_id = ilv.terr_id ); ');
            Add_To_PackageTable (' ');
            Add_To_PackageTable (' ');
          END IF;


          IF ( p_search_name =  'SEARCH_TERR_RULES' AND
               p_source_id = -1001 ) THEN


             Add_To_PackageTable (' ');
             Add_To_PackageTable ('      JTF_TERR_ASSIGN_PUB.get_winning_resources (            ');
             Add_To_PackageTable ('              p_source_id                => lp_source_id,    ');
             Add_To_PackageTable ('              p_trans_object_type_id     => lp_qual_type_id, ');
             Add_To_PackageTable ('              x_return_status            => l_Return_Status, ');
             Add_To_PackageTable ('              x_winners_rec              => x_rec );         ');
             Add_To_PackageTable (' ');

          ELSIF ( p_source_id <> -1001 AND
                  p_search_name =  'SEARCH_TERR_RULES' ) THEN


             Add_To_PackageTable ('   l_cursor := DBMS_SQL.OPEN_CURSOR; ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('   l_dyn_str :=');
             Add_To_PackageTable ('       '' SELECT /*+ ORDERED INDEX (jtra JTF_TERR_RSC_N1) '' || ' );
             Add_To_PackageTable ('       ''                    INDEX (jtraa JTF_TERR_RSC_ACCESS_N1)*/ '' || ' );
             Add_To_PackageTable ('       ''       DISTINCT '' || ' );
             Add_To_PackageTable ('       ''       WT.result_id '' || ' );
             Add_To_PackageTable ('       ''     , WT.trans_id '' || ' );
             Add_To_PackageTable ('       ''     , WT.trans_object_id '' || ' );
             Add_To_PackageTable ('       ''     , WT.trans_detail_object_id '' || ' );
             Add_To_PackageTable ('       ''     , WT.terr_id '' || ' );
             Add_To_PackageTable ('       ''     , WT.absolute_rank '' || ' );
             Add_To_PackageTable ('       ''     , jtra.terr_rsc_id '' || ' );
             Add_To_PackageTable ('       ''     , jtra.resource_id '' || ' );
             Add_To_PackageTable ('       ''     , jtra.resource_type '' || ' );
             Add_To_PackageTable ('       ''     , jtra.group_id'' || ' );
             Add_To_PackageTable ('       ''     , jtra.role '' || ' );
             Add_To_PackageTable ('       ''     , jtra.full_access_flag '' || ' );
             Add_To_PackageTable ('       ''     , jtra.primary_contact_flag '' || ' );
             Add_To_PackageTable ('       '' FROM '' || ' );

             Add_To_PackageTable ('       ''    ( SELECT                      '' || ' );
             Add_To_PackageTable ('       ''         o.result_id              '' || ' );
             Add_To_PackageTable ('       ''       , o.trans_id               '' || ' );
             Add_To_PackageTable ('       ''       , o.trans_object_id        '' || ' );
             Add_To_PackageTable ('       ''       , o.trans_detail_object_id '' || ' );
             Add_To_PackageTable ('       ''       , o.terr_id                '' || ' );
             Add_To_PackageTable ('       ''       , o.absolute_rank          '' || ' );
             Add_To_PackageTable ('       ''      FROM                        '' || ' );
             Add_To_PackageTable ('       ''       ( SELECT                    '' || ' );
             Add_To_PackageTable ('       ''          i.result_id              '' || ' );
             Add_To_PackageTable ('       ''        , i.trans_id               '' || ' );
             Add_To_PackageTable ('       ''        , i.trans_object_id        '' || ' );
             Add_To_PackageTable ('       ''        , i.trans_detail_object_id '' || ' );
             Add_To_PackageTable ('       ''        , i.terr_id                '' || ' );
             Add_To_PackageTable ('       ''        , i.absolute_rank          '' || ' );
             Add_To_PackageTable ('       ''        , i.top_level_terr_id      '' || ' );

		     --
	    	 -- JDOCHERT: 08/03/03: NUM WINNERS NOT NEEDED
    		 -- BUG#3020630
			 --Add_To_PackageTable ('       ''        , NVL(i.num_winners, 1) num_winners            '' || ' );
			 --

             Add_To_PackageTable ('       ''        , RANK() OVER ( PARTITION BY                   '' || ' );
             Add_To_PackageTable ('       ''                            i.trans_id                 '' || ' );
             Add_To_PackageTable ('       ''                          , i.trans_object_id          '' || ' );
             Add_To_PackageTable ('       ''                          , i.trans_detail_object_id   '' || ' );
             Add_To_PackageTable ('       ''                          , i.top_level_terr_id        '' || ' );
             Add_To_PackageTable ('       ''                        ORDER BY i.absolute_rank DESC, i.terr_id) AS TERR_RANK '' || ' );
             Add_To_PackageTable ('       ''        FROM jtf_terr_results_GT_MT i '' || ' );

             --
             -- Not required now that Global Temporary Table is being used
             --Add_To_PackageTable ('       ''        WHERE i.result_id = :b1.result_id '' || ' );
             --
             --

             Add_To_PackageTable ('       ''       ) o                                    '' || ' );
             Add_To_PackageTable ('       ''       WHERE o.TERR_RANK <= (SELECT NVL(t.num_winners, 1) FROM jtf_terr_all t WHERE t.terr_id = o.top_level_terr_id) '' || ' );
             Add_To_PackageTable ('       ''    ) WT '' || ' );
             Add_To_PackageTable ('       ''    , jtf_terr_rsc_all jtra '' || ' );
             Add_To_PackageTable ('       ''    , jtf_terr_rsc_access_all jtraa '' || ' );
             Add_To_PackageTable ('       '' WHERE '' || ' );

             IF (p_qualifier_type_id = -1002) THEN

                Add_To_PackageTable ('       ''       ( jtraa.ACCESS_TYPE = ''''ACCOUNT'''' )'' || ' );

             ELSIF (p_qualifier_type_id = -1003) THEN

                Add_To_PackageTable ('       ''       ( jtraa.ACCESS_TYPE = ''''LEAD'''' )'' || ' );

             ELSIF (p_qualifier_type_id = -1004) THEN

                Add_To_PackageTable ('       ''       ( jtraa.ACCESS_TYPE = ''''OPPOR'''' )'' || ' );

             ELSIF (p_qualifier_type_id = -1105) THEN

                Add_To_PackageTable ('       ''       ( jtraa.ACCESS_TYPE = ''''QUOTE'''' )'' || ' );

             ELSIF (p_qualifier_type_id = -1005) THEN

                /* Service: Service Request */
                Add_To_PackageTable ('       ''       ( jtraa.ACCESS_TYPE IN (''''SERV_REQ'''', ''''ACCOUNT'''')  OR jtraa.ACCESS_TYPE IS NULL  )'' || ' );

             ELSIF (p_qualifier_type_id = -1006) THEN

                /* Service: Task */
                Add_To_PackageTable ('       ''       ( jtraa.ACCESS_TYPE = ''''TASK''''  OR jtraa.ACCESS_TYPE IS NULL )'' || ' );

             ELSIF (p_qualifier_type_id = -1009) THEN

                /* Service: Service Request and Task */
                Add_To_PackageTable ('       ''       ( jtraa.ACCESS_TYPE = ''''SRV_TASK''''  OR jtraa.ACCESS_TYPE IS NULL )'' || ' );

             ELSIF (p_qualifier_type_id = -1010) THEN

                /* Defect Management: Defect or Enhancement */
                Add_To_PackageTable ('       ''       ( jtraa.ACCESS_TYPE = ''''DEF_MGMT''''  OR jtraa.ACCESS_TYPE IS NULL )'' || ' );

             ELSIF (p_qualifier_type_id = -1501) THEN

                /* Service: Contract Renewal */
                Add_To_PackageTable ('       ''       ( jtraa.ACCESS_TYPE = ''''KREN''''  OR jtraa.ACCESS_TYPE IS NULL )'' || ' );

             ELSIF (p_qualifier_type_id = -1601) THEN

                /* Collections: Delinquency */
                Add_To_PackageTable ('       ''       ( jtraa.ACCESS_TYPE = ''''DELQCY''''  OR jtraa.ACCESS_TYPE IS NULL )'' || ' );

             ELSIF (p_qualifier_type_id = -1007) THEN

                /* Trade Management: Offer */
                Add_To_PackageTable ('       ''       ( jtraa.ACCESS_TYPE = ''''OFFER''''  OR jtraa.ACCESS_TYPE IS NULL )'' || ' );

             ELSIF (p_qualifier_type_id = -1302) THEN

                /* Trade Management: Claim */
                Add_To_PackageTable ('       ''       ( jtraa.ACCESS_TYPE = ''''CLAIM''''  OR jtraa.ACCESS_TYPE IS NULL )'' || ' );

		-- ARPATEL bug#3146288 change -1700 to -1701
             ELSIF (p_qualifier_type_id = -1701) THEN

                /* Partner Management: Partner */
                Add_To_PackageTable ('       ''       ( jtraa.ACCESS_TYPE = ''''PARTNER''''  OR jtraa.ACCESS_TYPE IS NULL )'' || ' );

             END IF;

             Add_To_PackageTable ('       ''   AND jtra.terr_rsc_id = jtraa.terr_rsc_id (+) '' || ' );
             Add_To_PackageTable ('       ''   AND  ( ( jtra.end_date_active IS NULL OR jtra.end_date_active >= :b1_sysdate ) AND '' || ' );
             Add_To_PackageTable ('       ''         ( jtra.start_date_active IS NULL OR jtra.start_date_active <= :b2_sysdate ) '' || ' );
             Add_To_PackageTable ('       ''        ) '' || ' );
             Add_To_PackageTable ('       ''   AND  ( ( :b1_role IS NULL ) OR ( jtra.role = :b2_role ) )'' || ' );
             Add_To_PackageTable ('       ''   AND  ( ( :b1_resource_type IS NULL) OR ( jtra.resource_type = :b2_resource_type ) )'' || ' );
             Add_To_PackageTable ('       ''   AND jtra.terr_id = WT.TERR_ID ''; ' );
             Add_To_PackageTable (' ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('   DBMS_SQL.PARSE ( l_Cursor, l_dyn_str, DBMS_SQL.NATIVE ); ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('   /* bind all input variables */ ');

             --
             -- Not required now that Global Temporary Table is being used
             --Add_To_PackageTable ('   DBMS_SQL.BIND_VARIABLE (l_cursor, '':b1_result_id'', l_result_id); ');
             --

             Add_To_PackageTable ('   DBMS_SQL.BIND_VARIABLE (l_cursor, '':b1_sysdate'', l_sysdate, 32767); ');
             Add_To_PackageTable ('   DBMS_SQL.BIND_VARIABLE (l_cursor, '':b2_sysdate'', l_sysdate, 32767); ');
             Add_To_PackageTable ('   DBMS_SQL.BIND_VARIABLE (l_cursor, '':b1_role'', lp_role, 32767 ); ');
             Add_To_PackageTable ('   DBMS_SQL.BIND_VARIABLE (l_cursor, '':b2_role'', lp_role, 32767 ); ');
             Add_To_PackageTable ('   DBMS_SQL.BIND_VARIABLE (l_cursor, '':b1_resource_type'', lp_resource_type, 32767 ); ');
             Add_To_PackageTable ('   DBMS_SQL.BIND_VARIABLE (l_cursor, '':b2_resource_type'', lp_resource_type, 32767 ); ');

             -- 07/17/03 JDOCHERT: FOLLOWING IS NOW OBSOLETE
             -- DUES TO MULTI-LEVEL WINNERS PROCESSING
             -- FOR ORACLE SALES BUG#3020630
             --
             --IF (p_source_id = -1001 AND p_qualifier_type_id = -1002) THEN
             --
             --   Add_To_PackageTable ('   DBMS_SQL.BIND_VARIABLE (l_cursor, '':b1_num_winners'', lp_num_winners ); ');
             --   Add_To_PackageTable ('   DBMS_SQL.BIND_VARIABLE (l_cursor, '':b2_num_winners'', lp_num_winners ); ');
             --   Add_To_PackageTable ('   DBMS_SQL.BIND_VARIABLE (l_cursor, '':b1_top_level_terr_id'', lp_top_level_terr_id ); ');
             --   Add_To_PackageTable ('   DBMS_SQL.BIND_VARIABLE (l_cursor, '':b2_top_level_terr_id'', lp_top_level_terr_id ); ');
             --
             --END IF;
             --

             Add_To_PackageTable (' ');
             Add_To_PackageTable ('   /* bind all output variables */ ');
             Add_To_PackageTable ('   DBMS_SQL.DEFINE_ARRAY(l_cursor, 1,  l_result_id_arr, 32767, indx ); ');
             Add_To_PackageTable ('   DBMS_SQL.DEFINE_ARRAY(l_cursor, 2,  l_trans_id_arr, 32767, indx ); ');
             Add_To_PackageTable ('   DBMS_SQL.DEFINE_ARRAY(l_cursor, 3,  l_trans_object_id_arr, 32767, indx ); ');
             Add_To_PackageTable ('   DBMS_SQL.DEFINE_ARRAY(l_cursor, 4,  l_trans_object_detail_id_arr, 32767, indx ); ');
             Add_To_PackageTable ('   DBMS_SQL.DEFINE_ARRAY(l_cursor, 5,  l_terr_id_arr, 32767, indx ); ');
             Add_To_PackageTable ('   DBMS_SQL.DEFINE_ARRAY(l_cursor, 6,  l_absolute_rank_arr, 32767, indx ); ');
             Add_To_PackageTable ('   DBMS_SQL.DEFINE_ARRAY(l_cursor, 7,  l_terr_rsc_id_arr, 32767, indx ); ');
             Add_To_PackageTable ('   DBMS_SQL.DEFINE_ARRAY(l_cursor, 8, l_resource_id_arr, 32767, indx ); ');
             Add_To_PackageTable ('   DBMS_SQL.DEFINE_ARRAY(l_cursor, 9, l_resource_type_arr, 32767, indx ); ');
             Add_To_PackageTable ('   DBMS_SQL.DEFINE_ARRAY(l_cursor, 10, l_group_id_arr, 32767, indx ); ');
             Add_To_PackageTable ('   DBMS_SQL.DEFINE_ARRAY(l_cursor, 11, l_role_arr, 32767, indx ); ');
             Add_To_PackageTable ('   DBMS_SQL.DEFINE_ARRAY(l_cursor, 12, l_full_access_flag_arr, 32767, indx ); ');
             Add_To_PackageTable ('   DBMS_SQL.DEFINE_ARRAY(l_cursor, 13, l_primary_contact_flag_arr, 32767, indx ); ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('   /* Execute the procedure call */ ');
             Add_To_PackageTable ('   l_num_rows := DBMS_SQL.EXECUTE_AND_FETCH( l_cursor ); ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('   DBMS_SQL.COLUMN_VALUE (l_cursor, 1, l_result_id_arr); ');
             Add_To_PackageTable ('   DBMS_SQL.COLUMN_VALUE (l_cursor, 2, l_trans_id_arr); ');
             Add_To_PackageTable ('   DBMS_SQL.COLUMN_VALUE (l_cursor, 3, l_trans_object_id_arr); ');
             Add_To_PackageTable ('   DBMS_SQL.COLUMN_VALUE (l_cursor, 4, l_trans_object_detail_id_arr); ');
             Add_To_PackageTable ('   DBMS_SQL.COLUMN_VALUE (l_cursor, 5, l_terr_id_arr); ');
             Add_To_PackageTable ('   DBMS_SQL.COLUMN_VALUE (l_cursor, 6, l_absolute_rank_arr); ');
             Add_To_PackageTable ('   DBMS_SQL.COLUMN_VALUE (l_cursor, 7, l_terr_rsc_id_arr); ');
             Add_To_PackageTable ('   DBMS_SQL.COLUMN_VALUE (l_cursor, 8, l_resource_id_arr); ');
             Add_To_PackageTable ('   DBMS_SQL.COLUMN_VALUE (l_cursor, 9, l_resource_type_arr); ');
             Add_To_PackageTable ('   DBMS_SQL.COLUMN_VALUE (l_cursor, 10, l_group_id_arr); ');
             Add_To_PackageTable ('   DBMS_SQL.COLUMN_VALUE (l_cursor, 11, l_role_arr); ');
             Add_To_PackageTable ('   DBMS_SQL.COLUMN_VALUE (l_cursor, 12, l_full_access_flag_arr); ');
             Add_To_PackageTable ('   DBMS_SQL.COLUMN_VALUE (l_cursor, 13, l_primary_contact_flag_arr); ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('   DBMS_SQL.CLOSE_CURSOR(l_cursor); ');
             Add_To_PackageTable ('  ');
             Add_To_PackageTable ('   l_counter := l_terr_id_arr.FIRST; ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('   WHILE (l_counter <= l_terr_id_arr.last) LOOP ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('      --dbms_output.put_line( ''Winning Terr: '' || l_terr_id_arr(l_counter) );  ');
             Add_To_PackageTable (' ');

             IF (p_source_id = -1001) THEN

                Add_To_PackageTable ('      x_rec.PARTY_ID.EXTEND; ');
                Add_To_PackageTable ('      x_rec.PARTY_SITE_ID.EXTEND; ');

             END IF;

             Add_To_PackageTable ('      x_rec.TRANS_OBJECT_ID.EXTEND; ');
             Add_To_PackageTable ('      x_rec.TRANS_DETAIL_OBJECT_ID.EXTEND; ');
             Add_To_PackageTable ('      x_rec.ABSOLUTE_RANK.EXTEND; ');
             Add_To_PackageTable ('      x_rec.terr_id.EXTEND; ');
             Add_To_PackageTable ('      x_rec.terr_rsc_id.EXTEND; ');
             Add_To_PackageTable ('      x_rec.resource_id.EXTEND; ');
             Add_To_PackageTable ('      x_rec.resource_type.EXTEND; ');
             Add_To_PackageTable ('      x_rec.group_id.EXTEND; ');
             Add_To_PackageTable ('      x_rec.role.EXTEND; ');
             Add_To_PackageTable ('      x_rec.full_access_flag.EXTEND; ');
             Add_To_PackageTable ('      x_rec.primary_contact_flag.EXTEND; ');
             Add_To_PackageTable (' ');

             IF (p_source_id = -1001) THEN

                /* For Oracle Sales/Accounts */
                Add_To_PackageTable ('      x_rec.PARTY_ID(l_counter)               := l_trans_object_id_arr(l_counter); ');
                Add_To_PackageTable ('      x_rec.PARTY_SITE_ID(l_counter)          := l_trans_object_detail_id_arr(l_counter); ');

             END IF;

             /* All other transactions */
             Add_To_PackageTable ('      x_rec.TRANS_OBJECT_ID(l_counter)        := l_trans_object_id_arr(l_counter); ');
             Add_To_PackageTable ('      x_rec.TRANS_DETAIL_OBJECT_ID(l_counter) := l_trans_object_detail_id_arr(l_counter); ');
             Add_To_PackageTable ('      x_rec.ABSOLUTE_RANK(l_counter)          := l_absolute_rank_arr(l_counter); ');
             Add_To_PackageTable ('      x_rec.terr_id(l_counter)                := l_terr_id_arr(l_counter); ');
             Add_To_PackageTable ('      x_rec.terr_rsc_id(l_counter)            := l_terr_rsc_id_arr(l_counter); ');
             Add_To_PackageTable ('      x_rec.resource_id(l_counter)            := l_resource_id_arr(l_counter); ');
             Add_To_PackageTable ('      x_rec.resource_type(l_counter)          := l_resource_type_arr(l_counter); ');
             Add_To_PackageTable ('      x_rec.group_id(l_counter)               := l_group_id_arr(l_counter); ');
             Add_To_PackageTable ('      x_rec.role(l_counter)                   := l_role_arr(l_counter); ');
             Add_To_PackageTable ('      x_rec.full_access_flag(l_counter)       := l_full_access_flag_arr(l_counter); ');
             Add_To_PackageTable ('      x_rec.primary_contact_flag(l_counter)   := l_primary_contact_flag_arr(l_counter); ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('      l_counter := l_counter + 1; ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('   END LOOP; ');


          ELSIF ( p_search_name =  'SEARCH_TERR_RULES_ALL' ) THEN

             --
             --Add_To_PackageTable ('                      AND jtw.related_terr_id = ilv.terr_id ');
             --Add_To_PackageTable ('                      AND jtw.terr_id = ilv.terr_id    ) ; ');
             --
             Add_To_PackageTable ('   l_cursor := DBMS_SQL.OPEN_CURSOR; ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('   l_dyn_str :=');
             Add_To_PackageTable ('       '' SELECT column_value terr_id '' || ' );
             Add_To_PackageTable ('       '' FROM '' || ' );
             Add_To_PackageTable ('       ''       jtf_terr_results jtr '' || ' );
             Add_To_PackageTable ('       ''     , TABLE ( CAST ( MULTISET ( SELECT ilv1.terr_id '' || ' );
             Add_To_PackageTable ('       ''                                 FROM ( SELECT  /*+ INDEX (j JTF_TERR_RESULTS_U1) */ '' || ' );
             Add_To_PackageTable ('       ''                                                j.terr_id '' || ' );
             Add_To_PackageTable ('       ''                                              , j.top_level_terr_id '' || ' );
             Add_To_PackageTable ('       ''                                              , j.absolute_rank '' || ' );
             Add_To_PackageTable ('       ''                                              , j.trans_id '' || ' );
             Add_To_PackageTable ('       ''                                        FROM jtf_terr_results j '' || ' );
             Add_To_PackageTable ('       ''                                        WHERE j.result_id = :b1_result_id '' || ' );
             Add_To_PackageTable ('       ''                                        ORDER BY j.trans_id, j.top_level_terr_id, j.absolute_rank DESC '' || ' );
             Add_To_PackageTable ('       ''                                      ) ilv1 '' || ' );
             Add_To_PackageTable ('       ''                                 WHERE ilv1.top_level_terr_id = jtr.top_level_terr_id '' || ' );
             Add_To_PackageTable ('       ''                                   AND ilv1.trans_id = jtr.trans_id '' || ' );
             Add_To_PackageTable ('       ''                                   AND (  '' || ' );
             Add_To_PackageTable ('       ''                                         (ROWNUM <= (SELECT NVL(t.num_winners, 1) FROM jtf_terr_all t WHERE t.terr_id = ilv1.top_level_terr_id) ) '' || ' );
             Add_To_PackageTable ('       ''                                        ) '' || ' );
             Add_To_PackageTable ('       ''                               ) AS JTF_TERR_NUMBER_LIST      )     ) '' || ' );
             Add_To_PackageTable ('       '' WHERE 1 = 1 '' || ' );
             Add_To_PackageTable ('       ''   AND jtr.terr_id = COLUMN_VALUE '' || ' );
             Add_To_PackageTable ('       ''   AND jtr.result_id = :b2_result_id ''; ' );
             Add_To_PackageTable (' ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('   DBMS_SQL.PARSE ( l_Cursor, l_dyn_str, DBMS_SQL.NATIVE ); ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('   /* bind all input variables */ ');
             Add_To_PackageTable ('   DBMS_SQL.BIND_VARIABLE (l_cursor, '':b1_result_id'', l_result_id ); ');
             Add_To_PackageTable ('   DBMS_SQL.BIND_VARIABLE (l_cursor, '':b2_result_id'', l_result_id ); ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('   /* bind all output variables */ ');
             Add_To_PackageTable ('   DBMS_SQL.DEFINE_ARRAY(l_cursor, 1, l_terr_id_arr, 32767, indx ); ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('   /* Execute the procedure call */ ');
             Add_To_PackageTable ('   l_num_rows := DBMS_SQL.EXECUTE_AND_FETCH( l_cursor ); ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('   DBMS_SQL.COLUMN_VALUE (l_cursor, 1, l_terr_id_arr); ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('   DBMS_SQL.CLOSE_CURSOR(l_cursor); ');
             Add_To_PackageTable ('  ');
             Add_To_PackageTable ('   l_counter := l_terr_id_arr.FIRST; ');
             Add_To_PackageTable ('   l_rsc_counter := 1; ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('      WHILE (l_counter <= l_terr_id_arr.last) LOOP ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('         --dbms_output.put_line( ''Winning Terr: '' || l_terr_id_arr(l_counter) );  ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('         FOR cgr IN  csr_get_rsc( l_terr_id_arr(l_counter), l_sysdate ) LOOP ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('             x_rec(l_rsc_counter).resource_name      := cgr.resource_name; ');
             Add_To_PackageTable ('             x_rec(l_rsc_counter).resource_job_title := cgr.resource_job_title; ');
             Add_To_PackageTable ('             x_rec(l_rsc_counter).resource_phone     := cgr.resource_phone; ');
             Add_To_PackageTable ('             x_rec(l_rsc_counter).resource_email     := cgr.resource_email; ');
             Add_To_PackageTable ('             x_rec(l_rsc_counter).resource_mgr_name  := cgr.resource_mgr_name; ');
             Add_To_PackageTable ('             x_rec(l_rsc_counter).resource_mgr_phone := cgr.resource_mgr_phone; ');
             Add_To_PackageTable ('             x_rec(l_rsc_counter).resource_mgr_email := cgr.resource_mgr_email; ');
             Add_To_PackageTable ('             x_rec(l_rsc_counter).terr_id            := cgr.terr_id; ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('             --dbms_output.put_line(''Value of x_rec(l_rsc_counter).resource_name = '' || x_rec(l_rsc_counter).resource_name); ');
             Add_To_PackageTable ('             --dbms_output.put_line(''Value of l_rsc_counter = '' ||TO_CHAR(l_rsc_counter)); ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('             l_rsc_counter := l_rsc_counter + 1; ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('         END LOOP; ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('         l_counter := l_counter + 1; ');
             Add_To_PackageTable (' ');
             Add_To_PackageTable ('      END LOOP; ');
             Add_To_PackageTable (' ');

          END IF; /* p_search_name =  'SEARCH_TERR_RULES' */


          --
          -- JDOCHERT: 07/23/03: bug#3020630
          --Add_To_PackageTable (' ');
          --Add_To_PackageTable ('   DELETE FROM jtf_terr_results jtrs');
          --Add_To_PackageTable ('   WHERE jtrs.result_id = l_result_id; ');
          --Add_To_PackageTable (' ');
          --


      END IF; /* ( l_str_len > 0 ) */

      /* generate END of PROCEDURE */
      generate_end_of_procedure(l_procedure_name, p_source_id, p_qualifier_type);

   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         g_ProgramStatus := 1;
         Add_To_PackageTable (
            '--TERR_RULE_GEN: Unhandled exception NO_DATA_FOUND'
         );
         RETURN;
   END gen_terr_rules_recurse;


   /* ----------------------------------------------------------------
         This procedure will generate the Package
         called by The Get_WinningTerrMembers API
   -----------------------------------------------------------------*/
   PROCEDURE generate_api (
      errbuf                OUT NOCOPY      VARCHAR2,
      retcode               OUT NOCOPY      VARCHAR2,
      p_source_id           IN       NUMBER,
      p_qualifier_type_id   IN       NUMBER,
      p_debug_flag          IN       VARCHAR2,
      p_sql_trace           IN       VARCHAR2
   )
   AS

      num_of_terr                   NUMBER(15);
      package_name                  VARCHAR2(30);
      package_desc                  VARCHAR2(100);

      --l_index                       NUMBER;
      l_terr_id                     NUMBER;

      l_abs_source_id               NUMBER;

      l_qualifier_type              VARCHAR2(30);
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

   BEGIN
--dbms_output.put_line('JTF_TERR_ENGINE_GEN2_PVT.generate_api ');
      -- Initialize Global variables
      G_Debug    := FALSE;

      /* ACHANDA 03/08/2004 : Bug 3380047 : some of the dynamic packages are  */
      /* created in "INVALID" status as g_pointer is not properly initialized */
      g_pointer := 0;

      l_abs_source_id := ABS(p_source_id);

      /* Initialize */
      SELECT j.name
        INTO l_qualifier_type
        FROM jtf_qual_types j
       WHERE j.qual_type_id = p_qualifier_type_id;

       /* ARPATEL: 12/15/2003: Bug#3305019 */
      /* If the SQL trace flag is turned on, then turn on the trace */
      --If UPPER(p_SQL_Trace) = 'Y' Then
      --   dbms_session.set_sql_trace(TRUE);
      --End If;

      /* If the debug flag is set, Then turn on the debug message logging */
      If UPPER( rtrim(p_Debug_Flag) ) = 'Y' Then
         G_Debug := TRUE;
      End If;

      /* Check for territories for this Usage/Transaction Type */
      BEGIN

          SELECT COUNT(*)
          INTO num_of_terr
          FROM    jtf_terr_qtype_usgs_all jtqu
                , jtf_terr_usgs_all jtu
                , jtf_terr_all jt1
                , jtf_qual_type_usgs jqtu
          WHERE jtqu.terr_id = jt1.terr_id
            AND jqtu.qual_type_usg_id = jtqu.qual_type_usg_id
            AND jqtu.qual_type_id = p_qualifier_type_id
            AND jtu.source_id = p_source_id
            AND jtu.terr_id = jt1.terr_id
            AND NVL(jt1.end_date_active, lp_sysdate) >= lp_sysdate
            AND jt1.start_date_active <= lp_sysdate
            AND EXISTS (
                SELECT jtrs.terr_rsc_id
                FROM jtf_terr_rsc_all jtrs
                WHERE NVL(jtrs.end_date_active, lp_sysdate) >= lp_sysdate
                  AND NVL(jtrs.start_date_active, lp_sysdate) <= lp_sysdate
                  AND jtrs.terr_id = jt1.terr_id )
            AND NOT EXISTS (
              SELECT jt.terr_id
              FROM jtf_terr_all jt
              WHERE  NVL(jt.end_date_active, lp_sysdate + 1) < lp_sysdate
              CONNECT BY PRIOR jt.parent_territory_id = jt.terr_id AND jt.terr_id <> 1
              START WITH jt.terr_id = jt1.terr_id)
            AND jqtu.qual_type_id <> -1001
            AND rownum < 2;

     --dbms_output.put_line('JTF_TERR_ENGINE_GEN2_PVT:' || num_of_terr);
      EXCEPTION
         WHEN NO_DATA_FOUND Then
         num_of_terr := 0;
      END;

      IF G_Debug THEN

            /* Check for territories for this Usage/Transaction Type */
            BEGIN

                SELECT COUNT(*)
                INTO num_of_terr
                FROM    jtf_terr_qtype_usgs_all jtqu
                      , jtf_terr_usgs_all jtu
                      , jtf_terr_all jt1
                      , jtf_qual_type_usgs jqtu
                WHERE jtqu.terr_id = jt1.terr_id
                  AND jqtu.qual_type_usg_id = jtqu.qual_type_usg_id
                  AND jqtu.qual_type_id = p_qualifier_type_id
                  AND jtu.source_id = p_source_id
                  AND jtu.terr_id = jt1.terr_id
                  AND NVL(jt1.end_date_active, lp_sysdate) >= lp_sysdate
                  AND jt1.start_date_active <= lp_sysdate
                  AND EXISTS (
                      SELECT jtrs.terr_rsc_id
                      FROM jtf_terr_rsc_all jtrs
                      WHERE NVL(jtrs.end_date_active, lp_sysdate) >= lp_sysdate
                        AND NVL(jtrs.start_date_active, lp_sysdate) <= lp_sysdate
                        AND jtrs.terr_id = jt1.terr_id )
                  AND NOT EXISTS (
                    SELECT jt.terr_id
                    FROM jtf_terr_all jt
                    WHERE  NVL(jt.end_date_active, lp_sysdate + 1) < lp_sysdate
                    CONNECT BY PRIOR jt.parent_territory_id = jt.terr_id AND jt.terr_id <> 1
                    START WITH jt.terr_id = jt1.terr_id)
                  AND jqtu.qual_type_id <> -1001;

            --dbms_output.put_line('JTF_TERR_ENGINE_GEN2_PVT:' || num_of_terr);
            EXCEPTION
               WHEN NO_DATA_FOUND Then
               num_of_terr := 0;
            END;

         Write_Log(2, ' ');
         Write_Log(2, '/***************** BEGIN: TERRITORY STATUS *********************/');
         Write_Log(2, ' ');
         Write_Log(2, 'Inside Generate_API initialize');
         Write_Log(2, 'source_id         - ' || TO_CHAR(p_Source_Id) );
         Write_Log(2, 'qualifier_type_id - ' || TO_CHAR(p_qualifier_type_id) );
         Write_Log(2, 'Number of valid territories with resources for this Transaction: ' || num_of_terr );
         Write_Log(2, ' ');
         Write_Log(2, '/***************** END: TERRITORY STATUS *********************/');
         Write_Log(2, ' ');

      END IF;


      IF G_Debug THEN

         Write_Log(2, ' ');
         Write_Log(2, '/***************** BEGIN: PACKAGE STATUS *********************/');
         Write_Log(2, ' ');

      END IF;

      /* territories exist for this USAGE/TRANSACTION TYPE combination */
      IF (num_of_terr > 0) THEN

         /* Catch-All territory */
         l_terr_id := 1;

         /* Generate Package NAME */
         l_package_name := 'JTF_TERR_' || TO_CHAR (l_abs_source_id) || '_' ||
                         l_qualifier_type || '_DYN';

         /* Generate Package BODY */
         package_desc := '/* Auto Generated Package */';
         generate_package_header(l_package_name, package_desc, 'PKB');

         /* generate individual SQL statements  territories */
         gen_terr_rules_recurse (
               p_terr_id           => l_terr_id,
               p_source_id         => p_source_id,
               p_qualifier_type_id => p_qualifier_type_id,
               p_qualifier_type    => l_qualifier_type,
               p_search_name       => 'SEARCH_TERR_RULES' );

         --dbms_output.put_line('NEW ENGINE: Value of l_package_name='||l_package_name);

         /* Also generate Search across all orgs for Oracle Sales/Accounts*/
         IF ( p_source_id = -1001 AND
              p_qualifier_type_id = -1002 ) THEN

            /* generate individual SQL statements  territories */
            gen_terr_rules_recurse (
               p_terr_id           => l_terr_id,
               p_source_id         => p_source_id,
               p_qualifier_type_id => p_qualifier_type_id,
               p_qualifier_type    => l_qualifier_type,
               p_search_name       => 'SEARCH_TERR_RULES_ALL' );

         END IF;

        --dbms_output.put_line('[1]Value of p_qualifier_type_id = '||l_package_name);

        /* generate end of package BODY */
        generate_end_of_package(l_package_name, 'TRUE');

        --dbms_output.put_line('[2]Value of p_qualifier_type_id='||TO_CHAR(p_qualifier_type_id));

      ELSE

          IF (G_Debug) THEN
             Write_Log(2, 'PACKAGE ' || l_package_name  || ' NOT CREATED SUCCESSFULLY: no territories with resources exist for this Usage/Transaction combination. ');
          END IF;

          g_ProgramStatus := 1;

      END IF; /* num_of_terr > 0 */


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

         IF (l_status = 'INVALID') THEN

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
         Write_Log(2, '/***************** END: PACKAGE STATUS *********************/');
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

      Write_Log(2,ERRBUF);


   EXCEPTION
      WHEN utl_file.invalid_path OR utl_file.invalid_mode  OR
           utl_file.invalid_filehandle OR utl_file.invalid_operation OR
           utl_file.write_error Then
           ERRBUF := 'Program terminated with exception. Error writing to output file.';
           RETCODE := 2;

      WHEN OTHERS THEN
           If G_Debug Then
              Write_Log(1,'Program terminated with OTHERS exception. ' || SQLERRM);
           End If;
           ERRBUF  := 'Program terminated with OTHERS exception. ' || SQLERRM;
           RETCODE := 2;
   END generate_api;

END JTF_TERR_ENGINE_GEN2_PVT;

/
