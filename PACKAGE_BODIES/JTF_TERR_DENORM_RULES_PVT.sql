--------------------------------------------------------
--  DDL for Package Body JTF_TERR_DENORM_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_DENORM_RULES_PVT" AS
/* $Header: jtfvtdrb.pls 120.0 2005/06/02 18:22:42 appldev ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERR_DENORM_RULES_PVT
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager public api's.
--      This packe is used to denormalise the complete territory
--      rules based on tha data setup in the JTF territory tables
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      12/13/00    JDOCHERT         CREATED
--      04/05/01    JDOCHERT         Removed restriction that resource needs
--                                   to be attached to territory record before
--                                   it will be inserted in JTF_TERR_DENORM_RULES_ALL
--      03/04/02    JDOCHERT         bug#2250830

--
--    End of Comments
--
  -- Changes by Hari starts.
  FUNCTION get_level_from_root(p_terr_id IN number) RETURN NUMBER IS

    l_level   NUMBER := 0;
    l_terr_id NUMBER := p_terr_id;

    CURSOR c_parent_terr_id (p_terr_id IN NUMBER) IS
       SELECT j.parent_territory_id
       FROM jtf_terr_all j
       WHERE j.terr_id = p_terr_id;

  BEGIN

    IF (p_terr_id = 1) THEN
      RETURN 1;
    END IF;

    LOOP
      OPEN c_parent_terr_id(l_terr_id);
      FETCH c_parent_terr_id into l_terr_id;
      CLOSE c_parent_terr_id;

      l_level := l_level+1;

      EXIT WHEN l_terr_id = 1;
    END LOOP;

    RETURN (l_level+1);

  END get_level_from_root;
  -- Changes by Hari ends.


PROCEDURE Populate_API(
		  P_ERROR_CODE      OUT NOCOPY  NUMBER
		, P_ERROR_MSG       OUT NOCOPY  VARCHAR2
        , P_SOURCE_ID       IN   NUMBER
        , p_qual_type_id    IN   NUMBER   )  IS

  CURSOR csr_get_terr ( lp_source_id     NUMBER
                      , lp_qual_type_id  NUMBER
                      , lp_sysdate       DATE ) IS
    SELECT  jt1.terr_id
          , NVL(jt1.rank, 999999999)
          , jt1.num_winners
          , jt1.parent_territory_id
          , jt2.num_winners parent_num_winners
          , jt1.org_id
    FROM    jtf_terr_qtype_usgs_all jtqu
          , jtf_terr_usgs_all jtu
          , jtf_terr_all jt2
          , jtf_terr_all jt1
          , jtf_qual_type_usgs jqtu
    WHERE jtqu.terr_id = jt1.terr_id
      AND jqtu.qual_type_usg_id = jtqu.qual_type_usg_id
      AND jqtu.qual_type_id = lp_qual_type_id
      AND jtu.source_id = lp_source_id
      AND jtu.terr_id = jt1.terr_id
      AND jt2.terr_id = jt1.parent_territory_id

      /* ARPATEL: 10/01/03: bug#3171141 fix. */
       AND ( jt1.org_id = jt2.org_id OR
            (jt1.org_id IS NULL AND jt2.org_id IS NULL) )

      AND jt1.terr_id <> 1
      AND NVL(jt1.end_date_active, lp_sysdate + 1) > lp_sysdate
      AND NVL(jt1.start_date_active, lp_sysdate -1) < lp_sysdate
      AND jt1.parent_territory_id IS NOT NULL

      --
      -- Test data
      --AND jt1.terr_id = 19279
      --

      --
      -- JDOCHERT: 11/25/03: Not required as
      -- records are always deleted at the
      -- start of DENORM Process
      --
      -- AND NOT EXISTS(
      --              SELECT jtdr.terr_id
      --              FROM jtf_terr_denorm_rules_all jtdr
      --              WHERE jtdr.terr_id = jt1.terr_id
      --                AND jtdr.source_id = lp_source_id
      --                AND jtdr.qual_type_id = lp_qual_type_id )
      --

      --
      -- JDOCHERT: 10/25/03: only need records
      -- for territories with resources
      -- JDOCHERT: 11/05/03: removed as it breaks multiple
      -- level number of winners processing
      --AND EXISTS
      --   ( SELECT jtr.terr_id
      --     FROM jtf_terr_rsc_all jtr
      --     WHERE (jtr.end_date_active IS NULL OR jtr.end_date_active >= SYSDATE)
      --       AND (jtr.start_date_active IS NULL OR jtr.start_date_active <= SYSDATE)
      --       AND jtr.terr_id = jt1.terr_id )
      --

      AND NOT EXISTS (
                    SELECT jt.terr_id
                    FROM jtf_terr_all jt
                    WHERE ( (NVL(jt.end_date_active, lp_sysdate + 1) < lp_sysdate) OR
                            (NVL(jt.start_date_active, lp_sysdate - 1) > lp_sysdate) )
                    CONNECT BY PRIOR jt.parent_territory_id = jt.terr_id AND jt.terr_id <> 1
                    START WITH jt.terr_id = jt1.terr_id );

  CURSOR csr_get_SALES_terr ( lp_source_id     NUMBER
                            , lp_sysdate       DATE ) IS
    SELECT  jt1.terr_id
          , NVL(jt1.rank, 999999999)
          , jt1.num_winners
          , jt1.parent_territory_id
          , jt2.num_winners parent_num_winners
          , jt1.org_id
    FROM    jtf_terr_usgs_all jtu
          , jtf_terr_all jt2
          , jtf_terr_all jt1

    WHERE
          jtu.source_id = lp_source_id
      AND jtu.terr_id = jt1.terr_id
      AND jt2.terr_id = jt1.parent_territory_id

      /* ARPATEL: 10/01/03: bug#3171141 fix. */
       AND ( jt1.org_id = jt2.org_id OR
            (jt1.org_id IS NULL AND jt2.org_id IS NULL) )

      AND jt1.terr_id <> 1
      AND NVL(jt1.end_date_active, lp_sysdate + 1) > lp_sysdate
      AND NVL(jt1.start_date_active, lp_sysdate -1) < lp_sysdate
      AND jt1.parent_territory_id IS NOT NULL
      AND NOT EXISTS (
                    SELECT jt.terr_id
                    FROM jtf_terr_all jt
                    WHERE ( (NVL(jt.end_date_active, lp_sysdate + 1) < lp_sysdate) OR
                            (NVL(jt.start_date_active, lp_sysdate - 1) > lp_sysdate) )
                    CONNECT BY PRIOR jt.parent_territory_id = jt.terr_id AND jt.terr_id <> 1
                    START WITH jt.terr_id = jt1.terr_id );

  l_status varchar2(10);
  l_industry varchar2(10);
  l_applsys_schema varchar2(30);
  l_result boolean;

  L_REQUEST_ID               NUMBER := FND_GLOBAL.CONC_REQUEST_ID();
  L_PROGRAM_APPL_ID          NUMBER := FND_GLOBAL.PROG_APPL_ID();
  L_PROGRAM_ID               NUMBER := FND_GLOBAL.CONC_PROGRAM_ID();
  L_USER_ID                  NUMBER := FND_GLOBAL.USER_ID();

  l_sysdate                  DATE   := SYSDATE;
  l_root_terr_id             CONSTANT NUMBER    := 1;
  l_new_parent_territory_id  NUMBER;

  /* JDOCHERT: 06/30/03: bug#3020630 */
  l_new_parent_num_winners   NUMBER;

  l_leaf_flag                VARCHAR2(1);
  l_level_from_parent        NUMBER    := 0;
  l_num_rows_read            INTEGER   := 0;
  l_num_rows_inserted        INTEGER   := 0;

  l_terr_id                  NUMBER;
  l_parent_territory_id      NUMBER;
  l_terr_rank                NUMBER;
  l_org_id                   NUMBER;

  l_num_qual           NUMBER;
  l_level_from_root    NUMBER;
  l_top_level_terr_id  NUMBER;
  l_num_winners        NUMBER;
  l_relative_rank      NUMBER;
  l_absolute_rank      NUMBER;
  l_max_rank           NUMBER;

  l_terr_id_tbl                  jtf_terr_number_list := jtf_terr_number_list(null);
  l_parent_territory_id_tbl      jtf_terr_number_list := jtf_terr_number_list(null);
  l_terr_rank_tbl                jtf_terr_number_list := jtf_terr_number_list(null);
  l_org_id_tbl                   jtf_terr_number_list := jtf_terr_number_list(null);
  l_num_winners_tbl              jtf_terr_number_list := jtf_terr_number_list(null);
  l_num_qual_tbl                 jtf_terr_number_list := jtf_terr_number_list(null);
  l_level_from_root_tbl          jtf_terr_number_list := jtf_terr_number_list(null);
  l_level_from_parent_tbl        jtf_terr_number_list := jtf_terr_number_list(null);
  l_top_level_terr_id_tbl        jtf_terr_number_list := jtf_terr_number_list(null);
  l_relative_rank_tbl            jtf_terr_number_list := jtf_terr_number_list(null);

  l_parent_num_winners_tbl       jtf_terr_number_list := jtf_terr_number_list(null);

BEGIN


  BEGIN

     /* delete old records */
     /* ARPATEL: 12/03: for ORacle Sales denorm records are no longer striped by TX type */
     if p_source_id = -1001
     then
     DELETE FROM jtf_terr_denorm_rules_all jtdr
     WHERE jtdr.source_id = p_source_id;
     else
     DELETE FROM jtf_terr_denorm_rules_all jtdr
     WHERE jtdr.source_id = p_source_id
       AND jtdr.qual_type_id = p_qual_type_id;
     end if;

       --AND ( jtdr.changed_parent_flag = 'Y' OR
       --      jtdr.changed_parent_flag  IS NULL );

     --dbms_output.put_line('Deleted ' || SQL%ROWCOUNT || ' rows from JTF_TERR_DENORM_RULES for ' ||
     --                     p_source_id || '/' || p_qual_type_id);

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
  END;

  BEGIN

       SELECT /*+ ORDERED */ MAX(j2.rank)
       INTO l_max_rank
       FROM jtf_qual_type_usgs j1
          , jtf_terr_all j2
          , jtf_terr_qtype_usgs_all j4
       WHERE ( j2.start_date_active <= l_sysdate AND
               NVL(j2.end_date_active, l_sysdate) >=  l_sysdate)
         AND j2.terr_id <> 1
				 -- EIHSU: 09/27/02: bug#2590004
         --AND j2.parent_territory_id = 1
         AND j4.terr_id = j2.terr_id
         AND j4.qual_type_usg_id = j1.qual_type_usg_id

         ---
         -- JDOCHERT: 03/03/02: bug#2250830
         --AND j1.qual_type_id = p_qual_type_id
         --

         AND j1.source_id = p_source_id;

       --dbms_output.put_line('Value of l_max_rank='||TO_CHAR(l_max_rank));

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_max_rank := 9999999999;
  END;


   /* Process each territory */
   --ARPATEL: 12/03/2003 for Oracle Sales only process 1 denorm record per territory
   if p_source_id = -1001
   then
   OPEN csr_get_SALES_terr(p_source_id,  SYSDATE);
   FETCH csr_get_SALES_terr BULK COLLECT INTO l_terr_id_tbl
                                      , l_terr_rank_tbl
                                      , l_num_winners_tbl /* JDOCHERT: 06/30/03: bug#3020630 */
                                      , l_parent_territory_id_tbl
                                      , l_parent_num_winners_tbl
                                      , l_org_id_tbl ;
   CLOSE csr_get_SALES_terr;
   else
   OPEN csr_get_terr(p_source_id, p_qual_type_id, SYSDATE);
   FETCH csr_get_terr BULK COLLECT INTO l_terr_id_tbl
                                      , l_terr_rank_tbl
                                      , l_num_winners_tbl /* JDOCHERT: 06/30/03: bug#3020630 */
                                      , l_parent_territory_id_tbl
                                      , l_parent_num_winners_tbl
                                      , l_org_id_tbl ;
   CLOSE csr_get_terr;
   end if;

   --dbms_output.put_line('Value of l_terr_id_tbl.LAST[1]='||TO_CHAR(l_terr_id_tbl.LAST));

   IF (l_terr_id_tbl.COUNT > 0) THEN
   FOR i IN l_terr_id_tbl.FIRST..l_terr_id_tbl.LAST
   LOOP

        l_num_rows_read     := l_num_rows_read  + 1 ;

        l_level_from_parent_tbl.EXTEND;
        l_level_from_parent_tbl(i) := 0;

        l_num_qual_tbl.EXTEND;

        /* TOTAL number of qualifiers */
	/* ARPATEL: 12/03/2003: For Oracle Sales num_qual is now stored in jtf_terr_qtype_usgs_all */
        if p_source_id = -1001
        then
          l_num_qual_tbl(i) := 0;
	else
        SELECT count(*)
        INTO l_num_qual_tbl(i)
        FROM jtf_terr_qual_all jtq
           , jtf_qual_usgs_all jqu
           , jtf_qual_type_usgs jqtu
           , jtf_qual_type_denorm_v v
        WHERE jtq.qual_usg_id = jqu.qual_usg_id
          AND ( (jtq.org_id = jqu.org_id) OR
                (jtq.org_id IS NULL AND jqu.org_ID IS NULL)
              )
          AND jqu.qual_type_usg_id = jqtu.qual_type_usg_id
          AND jqtu.qual_type_id <> -1001
          AND jqtu.source_id = p_source_id
          AND jqtu.qual_type_id = v.related_id
          AND v.qual_type_id = p_qual_type_id
          AND jtq.terr_id IN
        ( SELECT jt.terr_id
          FROM jtf_terr_all jt
          CONNECT BY PRIOR jt.parent_territory_id = jt.terr_id AND jt.terr_id <> 1
           START WITH jt.terr_id = l_terr_id_tbl(i) );

        end if; --p_source_id = -1001

        l_level_from_root_tbl.EXTEND;
    	-- Added By Hari Starts
    	l_level_from_root_tbl(i) := get_level_from_root(l_terr_id_tbl(i));
    	-- Added By Hari  Ends

        l_top_level_terr_id_tbl.EXTEND;

        --l_num_winners_tbl.EXTEND;

        /* top level terr_id + num_winners */
        /* JDOCHERT: 06/30/03: bug#3020630: */
        /* Sales territories now suppport Multiple Winners
        ** at Multiple Levels so do not default value from
        ** top-level territory
        **
        ** JDOCHERT: 07/07/03: bug#3088766
        ** If it is a top-level Sales territory and Number of
        ** Winners is not explicitly, then default value to 1.
        */
        IF (   p_source_id = -1001 AND
			            l_parent_territory_id_tbl(i) = 1 AND
			            l_num_winners_tbl(i) IS NULL ) THEN


           l_num_winners_tbl(i) := 1;

        END IF;


        IF ( p_source_id <> -1001 ) THEN

           SELECT jt.terr_id, NVL(jt.num_winners, 1)
           INTO l_top_level_terr_id_tbl(i), l_num_winners_tbl(i)
           FROM jtf_terr_all jt
           WHERE jt.parent_territory_id = 1
             AND (jt.org_id <> -3114 OR jt.org_id IS NULL)
           CONNECT BY PRIOR jt.parent_territory_id = jt.terr_id AND jt.terr_id <> 1
           START WITH jt.terr_id = l_terr_id_tbl(i);

        END IF;

        /* RELATIVE RANK */
        l_relative_rank_tbl.EXTEND;
        l_relative_rank_tbl(i) := 1/(l_terr_rank_tbl(i) * POWER(l_max_rank, l_level_from_root_tbl(i)));

        --dbms_output.put_line('l_terr_id = ' || TO_CHAR(l_terr_id_tbl(i)) ||
        --                     ' / l_relative_rank = ' || TO_CHAR(l_relative_rank_tbl(i)) );
        --dbms_output.put_line('Value of l_terr_rank='||TO_CHAR(l_terr_rank));
        --dbms_output.put_line('Value of l_level_from_root='||TO_CHAR(l_level_from_root));


      END LOOP; /*    FOR i IN l_terr_id_tbl.FIRST..l_terr_id_tbl.LAST  */
     END IF;

      FORALL i IN l_terr_id_tbl.FIRST..l_terr_id_tbl.LAST
        INSERT INTO jtf_terr_denorm_rules_all(
                       source_id
                     , qual_type_id
                     , terr_id
                     , absolute_rank
                     , relative_rank
                     , num_qual
                     , rank
                     , level_from_root
                     , level_from_parent
                     , related_terr_id
                     , top_level_terr_id
                     , num_winners
                     , immediate_parent_flag
                     , root_flag
                     , leaf_flag
                     , LAST_UPDATE_DATE
                     , LAST_UPDATED_BY
                     , CREATION_DATE
                     , CREATED_BY
                     , LAST_UPDATE_LOGIN
                     , REQUEST_ID
                     , PROGRAM_APPLICATION_ID
                     , PROGRAM_ID
                     , PROGRAM_UPDATE_DATE
                     --, CHANGED_PARENT_FLAG
                     , ORG_ID
                     , QUAL_RELATION_PRODUCT
                     , RESOURCE_EXISTS_FLAG
                   )
           VALUES  (
                       p_source_id
                     , NVL(p_qual_type_id, -1)
                     , l_terr_id_tbl(i)
                     , 9999 /* absolute rank */
                     , l_relative_rank_tbl(i)
                     , l_num_qual_tbl(i)
                     , l_terr_rank_tbl(i)
                     , l_level_from_root_tbl(i)
                     , l_level_from_parent_tbl(i)
                     , l_terr_id_tbl(i)            /* related_territory_id */
                     , l_top_level_terr_id_tbl(i)
                     , l_num_winners_tbl(i)
                     , 'N'                         /* immediate parent flag */
                     , NULL  --'N'                 /* root flag */
                     , NULL  /* leaf flag */
                     , L_SYSDATE
                     , L_USER_ID
                     , L_SYSDATE
                     , L_USER_ID
                     , L_USER_ID
                     , L_REQUEST_ID
                     , L_PROGRAM_APPL_ID
                     , L_PROGRAM_ID
                     , L_SYSDATE
                     --, 'N'
                     , l_org_id_tbl(i)
                     , 1
                     , 'N'
                   );

      L_NUM_ROWS_INSERTED := l_terr_id_tbl.LAST;

      --dbms_output.put_line('OTHERS Value of L_NUM_ROWS_INSERTED='||TO_CHAR(L_NUM_ROWS_INSERTED));
      --dbms_output.put_line('Value of P_ERROR_MSG='||sqlerrm);

       --dbms_output.put_line( ' l_terr_id = '||TO_CHAR(l_terr_id) ||
       --                      ' l_num_qual = ' || TO_CHAR(l_num_qual) ||
       --                          ' L_related_terr_id = ' || TO_CHAR(L_PARENT_TERRitory_ID) ||
       --                          ' l_top_level_terr_id = ' || TO_CHAR(l_top_level_terr_id) ||
       --                          ' l_num_winners = ' || TO_CHAR(l_num_winners) );

   IF (l_terr_id_tbl.COUNT > 0) THEN
   FOR i IN l_terr_id_tbl.FIRST..l_terr_id_tbl.LAST
   LOOP

       IF ( l_terr_id_tbl(i) <> l_root_terr_id AND
            l_parent_territory_id_tbl(i) <> 1 ) THEN

          /* Insert immediate parent details */
          BEGIN

              l_level_from_parent_tbl(i) := l_level_from_parent_tbl(i) + 1;
              l_level_from_root_tbl(i) := l_level_from_root_tbl(i) - 1;

              INSERT INTO jtf_terr_denorm_rules_all (
                         source_id
                       , qual_type_id
                       , terr_id
                       , absolute_rank
                       , relative_rank
                       , num_qual
                       , rank
                       , level_from_root
                       , level_from_parent
                       , related_terr_id
                       , top_level_terr_id
                       , num_winners
                       , immediate_parent_flag
                       , root_flag
                       , leaf_flag
                       , LAST_UPDATE_DATE
                       , LAST_UPDATED_BY
                       , CREATION_DATE
                       , CREATED_BY
                       , LAST_UPDATE_LOGIN
                       , REQUEST_ID
                       , PROGRAM_APPLICATION_ID
                       , PROGRAM_ID
                       , PROGRAM_UPDATE_DATE
                       --, CHANGED_PARENT_FLAG
                       , ORG_ID
                       , QUAL_RELATION_PRODUCT
                     )
             VALUES  (
                         p_source_id
                       , NVL(p_qual_type_id, -1)
                       , l_terr_id_tbl(i)
                       , 0  /* absolute_rank */
                       , 0  /* relative_rank */
                       , 0  /* num_qual */
                       , l_terr_rank_tbl(i)
                       , l_level_from_root_tbl(i)
                       , l_level_from_parent_tbl(i)
                       , l_parent_territory_id_tbl(i)  /* related_territory_id */
                       , l_top_level_terr_id_tbl(i)
                       , l_parent_num_winners_tbl(i)
                       , 'Y'   /* immediate parent flag */
                       , NULL  -- DECODE(l_parent_territory_id, l_root_terr_id, 'Y', 'N')  /* root flag */
                       , NULL   /* leaf flag */
                       , L_SYSDATE
                       , L_USER_ID
                       , L_SYSDATE
                       , L_USER_ID
                       , L_USER_ID
                       , L_REQUEST_ID
                       , L_PROGRAM_APPL_ID
                       , L_PROGRAM_ID
                       , L_SYSDATE
                       --, 'N'
                       , l_org_id_tbl(i)
                       , 1
                     );

                L_NUM_ROWS_INSERTED := L_NUM_ROWS_INSERTED + 1;

          END;  -- Immediate parent


          LOOP

              /* Check for the ancestors */
              /* JDOCHERT: 06/30/03: bug#3020630 */
              SELECT   DISTINCT TR1.PARENT_TERRITORY_ID, TR2.NUM_WINNERS
              INTO     l_new_parent_territory_id, l_new_parent_num_winners
              FROM     jtf_terr_all TR1, jtf_terr_all TR2
              WHERE TR2.terr_id = TR1.parent_territory_id
                AND TR1.TERR_ID <> 1
                AND TR1.TERR_ID = l_parent_territory_id_tbl(i);

              EXIT WHEN ( l_parent_territory_id_tbl(i) = l_root_terr_id OR
                          l_new_parent_territory_id  = 1 );

              /* Insert the ancestor details */
              l_level_from_parent_tbl(i) := l_level_from_parent_tbl(i) + 1;
              l_level_from_root_tbl(i) := l_level_from_root_tbl(i) - 1;


              --dbms_output.put_line('parent_terr_id='||
              --TO_CHAR(l_new_parent_territory_id));
              --dbms_output.put_line('parent_num_winners='||
              --TO_CHAR(l_new_parent_num_winners));

              INSERT INTO JTF_TERR_DENORM_RULES_ALL (
                       source_id
                     , qual_type_id
                     , terr_id
                     , absolute_rank
                     , relative_rank
                     , num_qual
                     , rank
                     , level_from_root
                     , level_from_parent
                     , related_terr_id
                     , top_level_terr_id
                     , num_winners
                     , immediate_parent_flag
                     , root_flag
                     , leaf_flag
                     , LAST_UPDATE_DATE
                     , LAST_UPDATED_BY
                     , CREATION_DATE
                     , CREATED_BY
                     , LAST_UPDATE_LOGIN
                     , REQUEST_ID
                     , PROGRAM_APPLICATION_ID
                     , PROGRAM_ID
                     , PROGRAM_UPDATE_DATE
                     --, CHANGED_PARENT_FLAG
                     , ORG_ID
                     , QUAL_RELATION_PRODUCT
                      )
              VALUES ( p_source_id
                     , NVL(p_qual_type_id, -1)
                     , l_terr_id_tbl(i)
                     , 0  /* absolute_rank */
                     , 0  /* relative_rank */
                     , 0  /* num_qual */
                     , l_terr_rank_tbl(i)
                     , l_level_from_root_tbl(i)
                     , l_level_from_parent_tbl(i)
                     , l_new_parent_territory_id  /* related_territory_id */
                     , l_top_level_terr_id_tbl(i)
                     , l_new_parent_num_winners /* JDOCHERT: 06/30/03: bug#3020630 */
                     , 'N'   /* immediate parent flag */
                     , NULL      -- DECODE(l_new_parent_territory_id, l_root_terr_id, 'Y', 'N')  /* root flag */
                     , NULL      -- 'N'   /* leaf flag */
                     , L_SYSDATE
                     , L_USER_ID
                     , L_SYSDATE
                     , L_USER_ID
                     , L_USER_ID
                     , L_REQUEST_ID
                     , L_PROGRAM_APPL_ID
                     , L_PROGRAM_ID
                     , L_SYSDATE
                     --, 'N'
                     , l_org_id_tbl(i)
                     , 1
                      );

                  L_NUM_ROWS_INSERTED := L_NUM_ROWS_INSERTED + 1;

                  l_parent_territory_id_tbl(i) := l_new_parent_territory_id;


          END LOOP; /* Ancestors */

       END IF; -- END OF IF L_related_terr_id IS NOT NULL

   END LOOP;

   END IF; -- end if l_terr_id_tbl.count > 0

   --
   -- START of code added for bug#2054644
   --
   BEGIN


      IF (p_source_id <> -1001) THEN

          UPDATE /*+ INDEX (o jtf_terr_values_n1) */
              jtf_terr_values_all o
          SET o.first_char = SUBSTR(o.low_value_char, 1, 1)
          WHERE o.terr_qual_id IN (
             SELECT /*+ INDEX (i2 jtf_qual_usgs_n1) */
                  i1.terr_qual_id
             FROM jtf_terr_qual_all i1, jtf_qual_usgs_all i2, jtf_qual_type_usgs_all i3
             WHERE i1.qual_usg_id = i2.qual_usg_id
               AND i2.display_type = 'CHAR'
               AND i2.lov_sql IS NULL
               AND i2.org_id = -3113
               AND i2.qual_type_usg_id = i3.qual_type_usg_id
               AND i3.source_id = p_source_id
               AND i3.qual_type_id in (SELECT related_id
                                       FROM jtf_qual_type_denorm_v
                                       WHERE qual_type_id = p_qual_type_id) );

      END IF;

   EXCEPTION
      WHEN OTHERS THEN
          NULL;
   END;
   --
   -- END of code added for bug#2054644
   --


  --DBMS_OUTPUT.PUT_LINE('ROWS READ    : ' || L_NUM_ROWS_READ);
  --DBMS_OUTPUT.PUT_LINE('ROWS INSERTED: ' || L_NUM_ROWS_INSERTED);

EXCEPTION

   WHEN OTHERS THEN

      P_ERROR_CODE := sqlcode;
      P_ERROR_MSG := sqlerrm;
      ROLLBACK;
      --dbms_output.put_line('Value of P_ERROR_MSG='||P_ERROR_MSG);

END Populate_API;

END JTF_TERR_DENORM_RULES_PVT;

/
