--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_OPEN_ENRT_STAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_OPEN_ENRT_STAT" AS
/* $Header: hrirpoes.pkb 120.0 2005/09/21 01:28:52 anmajumd noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< SET_BIND_PARAMETERS >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure will populate X_CUSTOM_OUTPUT parameter with all the BIND
-- variables required for the execution of queries returned by GET_???_SQL
-- procedures.
--
procedure SET_BIND_PARAMETERS(
      p_page_parameter_tbl IN              bis_pmv_page_parameter_tbl,
      x_custom_output      IN  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL,
      p_selection          OUT NOCOPY NUMBER)
IS
  --
  l_custom_rec           BIS_QUERY_ATTRIBUTES;
  L_VALUE                varchar2(80);
  --
  l_pgm_rptgtyp_id       number;
  l_enrt_perd_found      boolean := false;
  l_effective_date       date;
  l_asnd_lf_evt_dt       date;
  --
  cursor c_pgm_enrt_perd ( cv_pgm_id         NUMBER,
                           cv_effective_date DATE )
  IS
     SELECT asnd_lf_evt_dt
       FROM (SELECT MAX (asnd_lf_evt_dt) asnd_lf_evt_dt
               FROM hri_cs_time_benrl_prd_ct enp
              WHERE pgm_id = cv_pgm_id
                AND enrt_strt_dt <= cv_effective_date
             );
   --
  cursor c_rptgrp_enrt_perd ( cv_rptgrp_id      NUMBER,
                              cv_effective_date DATE )
  IS
     SELECT asnd_lf_evt_dt
       FROM (SELECT MAX (asnd_lf_evt_dt) asnd_lf_evt_dt
               FROM hri_cs_time_benrl_prd_ct enp
              WHERE enrt_strt_dt <= cv_effective_date
                AND pgm_id IN (SELECT pgm_id
                                 FROM hri_cs_co_rpgh_pirg_ct
                                WHERE rptgtyp_id = cv_rptgrp_id
                               )
             );
  --
BEGIN
  --
  l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  --
  IF (p_page_parameter_tbl.COUNT > 0)
  THEN
     --
     FOR i IN p_page_parameter_tbl.FIRST .. p_page_parameter_tbl.LAST
     LOOP
       --
       p_selection := 1; /* Default the dimension selection to PROGRAM */
       --
       /*
       IF p_page_parameter_tbl (i).parameter_name = 'SELECT_A+SELECT_B'
       THEN
          --
          -- Dimension Selection
          -- 1 = Program
          -- 2 = Reporting Group
          --
          l_value := ( p_page_parameter_tbl (i).parameter_id );
          l_value := rtrim(ltrim(l_value, ''''), '''');
          --
          p_selection := l_value;
          --
       */
       IF p_page_parameter_tbl (i).parameter_name = 'PGM_A+PGM_B'
       THEN
          --
          l_value := ( p_page_parameter_tbl (i).parameter_id );
          l_value := rtrim(ltrim(l_value, ''''), '''');
          --
          -- For Dimension : Program =>  PGM_A+PGM_B = PGM_ID
          --
          --
          -- For Dimension : Reporting Group => PGM_A+PGM_B = RPTGTYP_ID
          --
          x_custom_output.EXTEND;
          x_custom_output(x_custom_output.LAST) := bis_query_attributes
                                                      (  ':PGM_RPTGTYP_ID'
                                                       , l_value
                                                       , bis_pmv_parameters_pub.bind_type
                                                       , bis_pmv_parameters_pub.numeric_bind);
          --
          l_pgm_rptgtyp_id := l_value;
          --
       ELSIF p_page_parameter_tbl (i).parameter_name = 'PL_TYP_A+PL_TYP_B'
       THEN
          --
          l_value := ( p_page_parameter_tbl (i).parameter_id );
          l_value := rtrim(ltrim(l_value, ''''), '''');
          --
          -- For Dimension : Reporting Group => PL_TYP_A+PL_TYP_B = PL_TYP_ID
          --
          --
          -- For Dimension : Program =>  PL_TYP_A+PL_TYP_B = PTIP_ID
          --
          x_custom_output.EXTEND;
          x_custom_output(x_custom_output.LAST) := bis_query_attributes
                                                      (  ':PTIP_PLTYP_ID'
                                                       , l_value
                                                       , bis_pmv_parameters_pub.bind_type
                                                       , bis_pmv_parameters_pub.numeric_bind);
          --
       ELSIF p_page_parameter_tbl (i).parameter_name = 'PLN_A+PLN_B'
       THEN
          --
          l_value := ( p_page_parameter_tbl (i).parameter_id );
          l_value := rtrim(ltrim(l_value, ''''), '''');
          --
          -- For Dimension : Reporting Group => PLN_A+PLN_B = PL_ID
          --
          --
          -- For Dimension : Program =>  PLN_A+PLN_B = PLIP_ID
          --
          x_custom_output.EXTEND;
          x_custom_output(x_custom_output.LAST) := bis_query_attributes
                                                      (  ':PLIP_PL_ID'
                                                       , l_value
                                                       , bis_pmv_parameters_pub.bind_type
                                                       , bis_pmv_parameters_pub.numeric_bind);
          --
       /*
       --
       -- Uncomment this code when Enrollment Period Dimension is Re-instated
       --
       ELSIF p_page_parameter_tbl (i).parameter_name = 'ENRT_PERD_A+ENRT_PERD_B'
       THEN
          --
          l_value := ( p_page_parameter_tbl (i).parameter_id );
          l_value := rtrim(ltrim(l_value, ''''), '''');
          --
          -- Assigned Life Event Date
          --
          x_custom_output.EXTEND;
          x_custom_output(x_custom_output.LAST) := bis_query_attributes
                                                      (  ':ASND_LF_EVT_DT'
                                                       , to_char(l_asnd_lf_evt_dt, 'DD/MM/YYYY')
                                                       , bis_pmv_parameters_pub.bind_type
                                                       , bis_pmv_parameters_pub.DATE_BIND);
          --
          if nvl(l_value, '') <> ''
          then
            --
            l_enrt_perd_found := TRUE;
            --
          end if;
          --
       */
       ELSIF p_page_parameter_tbl (i).parameter_name = 'AS_OF_DATE'
       THEN
          --
          l_value := ( p_page_parameter_tbl (i).parameter_id );
          l_value := rtrim(ltrim(l_value, ''''), '''');
          --
          -- Effective Date
          --
          x_custom_output.EXTEND;
          x_custom_output(x_custom_output.LAST) := bis_query_attributes
                                                      (  ':BEN_AS_OF_DATE'
                                                       , l_value
                                                       , bis_pmv_parameters_pub.bind_type
                                                       , bis_pmv_parameters_pub.DATE_BIND);
          --
          l_effective_date := to_date(l_value, 'DD/MM/YYYY');
          --
       ELSIF p_page_parameter_tbl (i).parameter_name = 'ACTN_TYP_A+ACTN_TYP_B'
       THEN
          --
          l_value := ( p_page_parameter_tbl (i).parameter_id );
          l_value := rtrim(ltrim(l_value, ''''), '''');
          --
          -- Action Type Code
          --
          x_custom_output.EXTEND;
          x_custom_output(x_custom_output.LAST) := bis_query_attributes
                                                      (  ':ACTN_TYP_CD'
                                                       , l_value
                                                       , bis_pmv_parameters_pub.bind_type
                                                       , bis_pmv_parameters_pub.VARCHAR2_BIND);
          --
       END IF;
       --
     END LOOP;
     --
     -- Display data for the latest enrollment period relative to the effective date
     -- In future when Enrollment Period dimension is re-instated, query data based on
     -- enrollment period selected
     --
     if l_effective_date is not null AND
        p_selection is not null
     then
       --
       if p_selection = 1
       then
         --
         -- Program
         --
         open c_pgm_enrt_perd ( cv_pgm_id         => l_pgm_rptgtyp_id ,
                                cv_effective_date => l_effective_date );
           --
           fetch c_pgm_enrt_perd into l_asnd_lf_evt_dt;
           --
         close c_pgm_enrt_perd ;
         --
       /*
       elsif p_selection = 2
       then
         --
         -- Reporting Group
         --
         open c_rptgrp_enrt_perd ( cv_rptgrp_id      => l_pgm_rptgtyp_id,
                                   cv_effective_date => l_effective_date );
         --
           fetch c_rptgrp_enrt_perd into l_asnd_lf_evt_dt;
           --
         close c_rptgrp_enrt_perd ;
         --
       */
       end if;
       --
     end if;
     --
     x_custom_output.EXTEND;
     x_custom_output(x_custom_output.LAST) := bis_query_attributes
                                                 (  ':ASND_LF_EVT_DT'
                                                  , to_char(l_asnd_lf_evt_dt, 'DD/MM/YYYY')
                                                  , bis_pmv_parameters_pub.bind_type
                                                  , bis_pmv_parameters_pub.DATE_BIND);
     --
  END IF;
  --
--
END SET_BIND_PARAMETERS;
--
-- ----------------------------------------------------------------------------
-- |-------------------< PRINT_TABLE_PARAMETERS >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- The procedure will print all parameters passed by P_PAGE_PARAMETER_TBL to user pipe DBI
-- This procedure is added for debugging purpose. Whenever it is required to check the
-- parameters passed by parameter portlet, call this procedure from CHECK_???_SQL procedures
-- Remember to uncomment call to this procedure, since it enables a trace
--
PROCEDURE PRINT_TABLE_PARAMETERS (
     p_page_parameter_tbl IN              bis_pmv_page_parameter_tbl )
IS
   --
   --
BEGIN
   --
   hr_utility.trace_on(null, 'DBIBEN');
   hr_utility.set_location('--------------------------------------', 9999);
   --
   IF (p_page_parameter_tbl.COUNT > 0)
   THEN
      --
      FOR i IN p_page_parameter_tbl.FIRST .. p_page_parameter_tbl.LAST
      LOOP
         --
         hr_utility.set_location('----', 9999);
         hr_utility.set_location('ACE parameter_name = ' || p_page_parameter_tbl (i).parameter_name, 9999);
         hr_utility.set_location('ACE parameter_value = ' || p_page_parameter_tbl (i).parameter_value, 9999);
         hr_utility.set_location('ACE parameter_id = ' || p_page_parameter_tbl (i).parameter_id, 9999);
         --
      END LOOP;
      --
   END IF;
   --
   hr_utility.trace_off;
   --
END PRINT_TABLE_PARAMETERS;
--
-- ----------------------------------------------------------------------------
-- |--------------------< GET_PARAMETER_VALUE >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- The function will return the paramter value for the passed parameter name
--
FUNCTION GET_PARAMETER_VALUE (
   p_page_parameter_tbl   IN   bis_pmv_page_parameter_tbl,
   p_parameter_name       IN   VARCHAR2
)
   RETURN VARCHAR2
IS
   --
   l_value   varchar2(3000);
   --
BEGIN
   --
   IF (p_page_parameter_tbl.COUNT > 0)
   THEN
      --
      FOR i IN p_page_parameter_tbl.FIRST .. p_page_parameter_tbl.LAST
      LOOP
         --
         IF p_page_parameter_tbl (i).parameter_name = p_parameter_name
         THEN
            --
            l_value := p_page_parameter_tbl (i).parameter_value;
            --
         END IF;
         --
      END LOOP;
      --
   END IF;
   --
   RETURN l_value;
   --
END GET_PARAMETER_VALUE;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< GET_PARAMETER_ID >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- The function will return the paramter ID for the passed parameter name
--
FUNCTION GET_PARAMETER_ID (
   p_page_parameter_tbl   IN   bis_pmv_page_parameter_tbl,
   p_parameter_name       IN   VARCHAR2
)
   RETURN varchar2
IS
   --
   l_id   varchar2(3000);
   --
BEGIN
   --
   IF (p_page_parameter_tbl.COUNT > 0)
   THEN
      --
      FOR i IN p_page_parameter_tbl.FIRST .. p_page_parameter_tbl.LAST
      LOOP
         --
         IF p_page_parameter_tbl (i).parameter_name = p_parameter_name
         THEN
            --
            l_id := p_page_parameter_tbl (i).parameter_id;
            l_id := rtrim(ltrim(l_id, ''''), '''');
            --
         END IF;
         --
      END LOOP;
      --
   END IF;
   --
   RETURN l_id;
   --
END GET_PARAMETER_ID;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< GET_ELIGENRL_PLIP_SQL >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Participation By Plan
-- AK_REGION = HRI_P_ELIGENRL_PRTT_PLIP
--
PROCEDURE GET_ELIGENRL_PLIP_SQL (
   p_page_parameter_tbl   IN              bis_pmv_page_parameter_tbl,
   x_custom_sql           OUT NOCOPY      VARCHAR2,
   x_custom_output        OUT NOCOPY      bis_query_attributes_tbl
)
IS
   --
   l_selection            number;
   l_custom_rec           BIS_QUERY_ATTRIBUTES;
   --
BEGIN
   --
   x_custom_sql := ' SELECT NULL     HRI_P_CHAR1_GA  /* Participation By Plan */,
                            NULL     HRI_P_MEASURE1,
                            NULL     HRI_P_MEASURE2,
                            NULL     HRI_P_MEASURE3_MP,
                            NULL     HRI_P_MEASURE4,
                            NULL     HRI_P_DRILL_URL1
                       FROM DUAL';
   --
   l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
   x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
   --
   set_bind_parameters( p_page_parameter_tbl => p_page_parameter_tbl,
                        x_custom_output      => x_custom_output,
                        p_selection          => l_selection) ;
   --
   IF l_selection = 1
   THEN
      --
      -- Use Views corresponding to Program Dimension
      --
      x_custom_sql :=
        ' SELECT cppv.value           HRI_P_CHAR1_GA  /* Participation By Plan (Program) */,
                 cppmv.elig_count     HRI_P_MEASURE1,
                 cppmv.enrt_count     HRI_P_MEASURE2,
                 cppmv.enrt_per       HRI_P_MEASURE3_MP,
                 cppmv.plip_id        HRI_P_MEASURE4,
                 (SELECT ''pFunctionName=HRI_P_ELIGENRL_PRTT_OIPL'' ||
                         ''&'' || ''PLN_A+PLN_B=HRI_P_MEASURE4'' ||
                         ''&'' || ''pParamIds=Y''
                    FROM dual
                   WHERE EXISTS
                            ( SELECT 1
                                FROM BEN_OIPL_F
                               WHERE pl_id = cppv.pl_id
                             )
                 )              HRI_P_DRILL_URL1
            FROM HRI_MDP_BEN_ELIGENRL_CPP_MV cppmv,
                 HRI_CL_CO_PGMH_PLIP_V cppv
           WHERE cppmv.asnd_lf_evt_dt = :ASND_LF_EVT_DT
             AND cppv.id = cppmv.plip_id
             AND cppmv.asnd_lf_evt_dt BETWEEN cppv.start_date AND cppv.end_date
             AND cppv.pgm_id = :PGM_RPTGTYP_ID
             AND cppv.ptip_id = :PTIP_PLTYP_ID
             AND :BEN_AS_OF_DATE BETWEEN cppmv.effective_start_Date
                                     AND cppmv.effective_end_Date
               &ORDER_BY_CLAUSE';
      --
    /*
    ELSIF l_selection = 2
    THEN
       --
       -- Use Views corresponding to Reporting Group Dimension
       --
       x_custom_sql :=
         ' SELECT rplnv.value         HRI_P_CHAR1_GA, --  Participation By Plan (Reporting Group)
                  cppmv.elig_count    HRI_P_MEASURE1,
                  cppmv.enrt_count    HRI_P_MEASURE2,
                  cppmv.enrt_per      HRI_P_MEASURE3_MP,
                  cppmv.pl_id         HRI_P_MEASURE4,
                  (SELECT ''pFunctionName=HRI_P_ELIGENRL_PRTT_OIPL'' ||
                          ''&'' || ''PLN_A+PLN_B=HRI_P_MEASURE4'' ||
                          ''&'' || ''pParamIds=Y''
                     FROM dual
                    WHERE EXISTS
                             ( SELECT 1
                                 FROM BEN_OIPL_F
                                WHERE pl_id = cppmv.pl_id
                             )
                  )             HRI_P_DRILL_URL1
             FROM HRI_MDP_BEN_ELIGENRL_RPLN_MV cppmv,
                  HRI_CL_CO_RPTG_PL_V rplnv
            WHERE cppmv.asnd_lf_evt_dt = :ASND_LF_EVT_DT
              AND rplnv.id = cppmv.pl_id
              AND rplnv.rptgtyp_id = cppmv.rptgtyp_id
              AND cppmv.asnd_lf_evt_dt BETWEEN rplnv.start_date AND rplnv.end_date
              AND cppmv.rptgtyp_id = :PGM_RPTGTYP_ID
              AND rplnv.pl_typ_id = :PTIP_PLTYP_ID
              AND :BEN_AS_OF_DATE BETWEEN cppmv.effective_start_Date
                                      AND cppmv.effective_end_Date
               &ORDER_BY_CLAUSE';
    */
        --
    END IF;
    --
END GET_ELIGENRL_PLIP_SQL;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< GET_ELIGENRL_OIPL_SQL >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Participation By Option In Plan
-- AK_REGION = HRI_P_ELIGENRL_PRTT_OIPL
--
PROCEDURE GET_ELIGENRL_OIPL_SQL (
   p_page_parameter_tbl   IN              bis_pmv_page_parameter_tbl,
   x_custom_sql           OUT NOCOPY      VARCHAR2,
   x_custom_output        OUT NOCOPY      bis_query_attributes_tbl
)
IS
   --
   l_selection            number;
   l_custom_rec           BIS_QUERY_ATTRIBUTES;
   --
BEGIN
   --
   x_custom_sql := ' SELECT NULL     HRI_P_CHAR1_GA  /* Participation By Option In Plan */,
                            NULL     HRI_P_MEASURE1,
                            NULL     HRI_P_MEASURE2,
                            NULL     HRI_P_MEASURE3_MP
                       FROM DUAL';
   --
   l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
   x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
   --
   set_bind_parameters( p_page_parameter_tbl => p_page_parameter_tbl,
                        x_custom_output      => x_custom_output,
                        p_selection          => l_selection) ;
   --
   IF l_selection = 1
   THEN
       --
       -- Use Views corresponding to Program Dimension
       --
       x_custom_sql :=
         '    SELECT copv.value        HRI_P_CHAR1_GA /* Participation By Option In Plan (Program) */,
                     copmv.elig_count HRI_P_MEASURE1,
                     copmv.enrt_count HRI_P_MEASURE2,
                     copmv.enrt_per   HRI_P_MEASURE3_MP
                FROM HRI_MDP_BEN_ELIGENRL_COP_MV copmv,
                     HRI_CL_CO_PGMH_OIPLIP_V copv
               WHERE copmv.asnd_lf_evt_dt = :ASND_LF_EVT_DT
                 AND copv.id = copmv.compobj_sk_pk
                 AND copmv.asnd_lf_evt_dt BETWEEN copv.start_date AND copv.end_date
                 AND copv.pgm_id = :PGM_RPTGTYP_ID
                 AND copv.ptip_id = :PTIP_PLTYP_ID
                 AND copv.plip_id = :PLIP_PL_ID
                 AND copv.oiplip_id <> -1 /* Bug 4543445 To remove records with - plan without options */
                 AND :BEN_AS_OF_DATE BETWEEN copmv.effective_start_Date
                                         AND copmv.effective_end_Date
               &ORDER_BY_CLAUSE';
       --
   /*
   ELSIF l_selection = 2
   THEN
      --
      -- Use Views corresponding to Reporting Group Dimension
      --
      x_custom_sql :=
        '    SELECT optv.name         HRI_P_CHAR1_GA, --  Participation By Option In Plan (Reporting Group)
                    roptmv.elig_count HRI_P_MEASURE1,
                    roptmv.enrt_count HRI_P_MEASURE2,
                    roptmv.enrt_per   HRI_P_MEASURE3_MP
               FROM HRI_MDP_BEN_ELIGENRL_ROPT_MV roptmv,
                    BEN_OIPL_F copv,
                    BEN_OPT_F optv
              WHERE roptmv.asnd_lf_evt_dt = :ASND_LF_EVT_DT
                AND copv.oipl_id = roptmv.oipl_id
                AND copv.opt_id = optv.opt_id
                AND roptmv.asnd_lf_evt_dt BETWEEN copv.effective_start_date AND copv.effective_end_date
                AND roptmv.asnd_lf_evt_dt BETWEEN optv.effective_start_date AND optv.effective_end_date
                AND roptmv.rptgtyp_id = :PGM_RPTGTYP_ID
                AND copv.pl_id = :PLIP_PL_ID
                AND :BEN_AS_OF_DATE BETWEEN roptmv.effective_start_Date
                                        AND roptmv.effective_end_Date
              &ORDER_BY_CLAUSE';
   */
       --
   END IF;
   --
END GET_ELIGENRL_OIPL_SQL;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< GET_ENRLACTN_SQL >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Open Action Items
-- AK_REGION : HRI_P_ENRLACTN_OPN_ITEMS
--
PROCEDURE GET_ENRLACTN_SQL (
     p_page_parameter_tbl   IN              bis_pmv_page_parameter_tbl,
     x_custom_sql           OUT NOCOPY      VARCHAR2,
     x_custom_output        OUT NOCOPY      bis_query_attributes_tbl
  )
IS
   --
   l_selection            number;
   l_custom_rec           BIS_QUERY_ATTRIBUTES;
   --
BEGIN
   --
   x_custom_sql := ' SELECT NULL     HRI_P_CHAR1_GA  /* Open Action Items */,
                            NULL     HRI_P_MEASURE1,
                            NULL     HRI_P_MEASURE2,
                            NULL     HRI_P_CHAR2_GA
                       FROM DUAL';
   --
   l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
   x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
   --
   set_bind_parameters( p_page_parameter_tbl => p_page_parameter_tbl,
                        x_custom_output      => x_custom_output,
                        p_selection          => l_selection) ;
   --
   IF l_selection = 1
   THEN
      --
      -- Use Views corresponding to Program Dimension
      --
      x_custom_sql :=
         '   SELECT  actd.value         HRI_P_CHAR1_GA /* Open Action Items (Program) */,
                     sspnd_count        HRI_P_MEASURE1,
                     actn_item_ind      HRI_P_MEASURE2,
                     actd.id            HRI_P_CHAR2_GA
                FROM HRI_MDP_BEN_ENRLACTN_PGM_MV peac,
                     HRI_CL_BACTN_TYP_V actd
               WHERE asnd_lf_evt_dt = :ASND_LF_EVT_DT
                 AND pgm_id = :PGM_RPTGTYP_ID
                 AND peac.actn_typ_cd = actd.ID
                 AND :BEN_AS_OF_DATE BETWEEN effective_start_Date
                                         AND effective_end_Date
                 AND actn_item_ind > 0
               &ORDER_BY_CLAUSE';
      --
   /*
   ELSIF l_selection = 2
   THEN
      --
      -- Use Views corresponding to Reporting Group Dimension
      --
      x_custom_sql :=
         '   SELECT  actd.value        HRI_P_CHAR1_GA, --   Open Action Items (Reporting Group)
                     sspnd_count       HRI_P_MEASURE1,
                     actn_item_ind     HRI_P_MEASURE2,
                     actd.id           HRI_P_CHAR2_GA
                FROM HRI_MDP_BEN_ENRLACTN_RPG_MV peac,
                     HRI_CL_BACTN_TYP_V actd
               WHERE asnd_lf_evt_dt = :ASND_LF_EVT_DT
                 AND rptgtyp_id = :PGM_RPTGTYP_ID
                 AND peac.actn_typ_cd = actd.ID
                 AND :BEN_AS_OF_DATE BETWEEN effective_start_Date
                                         AND effective_end_Date
              &ORDER_BY_CLAUSE';
     */
     --
   END IF;
   --
END GET_ENRLACTN_SQL;
--
-- ----------------------------------------------------------------------------
-- |------------------------< GET_ENRLACTN_DET_SQL >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Open Action Item Details
-- AK_REGION : HRI_P_ENRLACTN_OPN_ITEM_DTL
--
 PROCEDURE GET_ENRLACTN_DET_SQL (
   p_page_parameter_tbl   IN              bis_pmv_page_parameter_tbl,
   x_custom_sql           OUT NOCOPY      VARCHAR2,
   x_custom_output        OUT NOCOPY      bis_query_attributes_tbl
)
IS
   --
   l_selection            NUMBER;
   l_custom_rec           BIS_QUERY_ATTRIBUTES;
   l_lnk_profile_chk      NUMBER;
   --
   l_parameter_rec        hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
   l_bind_tab             hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;
   l_lnk_emp_name         VARCHAR2(255);
   --
BEGIN
   --
   x_custom_sql := ' SELECT NULL     HRI_P_CHAR1_GA  /* Open Action Item Details */,
                            NULL     HRI_P_CHAR2_GA,
                            NULL     HRI_P_CHAR3_GA,
                            NULL     HRI_P_CHAR4_GA,
                            NULL     HRI_P_CHAR5_GA,
                            NULL     HRI_P_CHAR6_GA,
                            NULL     HRI_P_CHAR7_GA,
                            NULL     HRI_P_CHAR8_GA,
                            NULL     HRI_P_DATE1_GA,
                            NULL     HRI_P_CHAR9_GA,
                            NULL     HRI_P_DRILL_URL1
                       FROM DUAL';
   --
   l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
   x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
   --
   set_bind_parameters( p_page_parameter_tbl => p_page_parameter_tbl,
                        x_custom_output      => x_custom_output,
                        p_selection          => l_selection) ;
   --
   -- Populate L_PARAMETER_REC and L_BIND_TAB for subsequent use in CHK_EMP_DIR_LNK
   --
   hri_oltp_pmv_util_param.get_parameters_from_table ( p_page_parameter_tbl  => p_page_parameter_tbl,
                                                       p_parameter_rec       => l_parameter_rec,
                                                       p_bind_tab            => l_bind_tab);
   --
   -- This function call checks Profile Option HRI:DBI Link To Transaction System
   -- Link to HR Employee Directory
   --
   l_lnk_profile_chk := hri_oltp_pmv_util_pkg.chk_emp_dir_lnk( p_parameter_rec  => l_parameter_rec,
                                                               p_bind_tab       => l_bind_tab);
   --
   IF (l_lnk_profile_chk = 1 AND l_parameter_rec.time_curr_end_date = TRUNC(SYSDATE) )
   THEN
     --
     l_lnk_emp_name := 'pFunctionName=HR_EMPDIR_EMPDTL_PROXY_SS&pId=HRI_P_CHAR9_GA&OAPB=FII_HR_BRAND_TEXT';
     --
   ELSE
     --
     l_lnk_emp_name := '';
     --
   END IF ;
   --
   IF l_selection = 1
   THEN
      --
      -- Use Views corresponding to Program Dimension
      --
      x_custom_sql :=
        '  SELECT  per.full_name                 HRI_P_CHAR1_GA  /* Open Action Item Details (Program) */,
                   per.employee_number           HRI_P_CHAR2_GA,
                   per.email_address             HRI_P_CHAR3_GA,
                   copv.pl_value                 HRI_P_CHAR4_GA,
                   copv.value                    HRI_P_CHAR5_GA,
                   HR_GENERAL.DECODE_LOOKUP (''YES_NO'',
                      DECODE (peac.sspnd_ind ,1,''Y'',''N'')) HRI_P_CHAR6_GA,
                   icopv.pl_value                HRI_P_CHAR7_GA,
                   icopv.value                   HRI_P_CHAR8_GA,
                   peac.due_dt                   HRI_P_DATE1_GA,
                   per.person_id                 HRI_P_CHAR9_GA,
                   ''' || l_lnk_emp_name || '''  HRI_P_DRILL_URL1
             FROM HRI_MB_BEN_ENRLACTN_CT peac,
                  HRI_CL_CO_PGMH_OIPLIP_V copv,
                  HRI_CL_CO_PGMH_OIPLIP_V icopv,
                  PER_ALL_PEOPLE_F per
            WHERE peac.asnd_lf_evt_dt = :ASND_LF_EVT_DT
              AND peac.actn_typ_cd = :ACTN_TYP_CD
              AND :BEN_AS_OF_DATE BETWEEN peac.effective_start_Date
                                      AND peac.effective_end_Date
              AND peac.compobj_sk_pk = copv.id
              AND NVL(peac.interim_compobj_sk_pk, -1) = icopv.id(+)
              AND per.person_id = peac.person_id
              AND NVL(TRUNC(SYSDATE),peac.asnd_lf_evt_dt) BETWEEN per.effective_start_date
                                                       AND per.effective_end_date
              AND copv.pgm_id = :PGM_RPTGTYP_ID
              AND peac.actn_item_ind > 0
               &ORDER_BY_CLAUSE';
      --
   /*
   ELSIF l_selection = 2
   THEN
      --
      -- Use Views corresponding to Reporting Group Dimension
      --
      x_custom_sql :=
        '    SELECT per.full_name       HRI_P_CHAR1_GA, --  Open Action Item Details (Reporting Group)
                    per.employee_number HRI_P_CHAR2_GA,
                    per.email_address   HRI_P_CHAR3_GA,
                    cppv.value          HRI_P_CHAR4_GA,
                    decode(copv.opt_id,
                            null, null,
                            copv.value) HRI_P_CHAR5_GA,
                    hl.meaning          HRI_P_CHAR6_GA,
                    icppv.value         HRI_P_CHAR7_GA,
                   decode(icopv.opt_id,
                          null, null,
                          icopv.value) HRI_P_CHAR8_GA,
                    peac.due_dt         HRI_P_DATE1_GA,
                   per.person_id       HRI_P_CHAR9_GA,
                   ''' || l_lnk_emp_name || '''  HRI_P_DRILL_URL1
               FROM HRI_MB_BEN_ENRLACTN_CT peac,
                    HRI_CL_CO_OIPLIP_V copv,
                    HRI_CL_CO_PLIP_V cppv,
                    HRI_CL_CO_OIPLIP_V icopv,
                    HRI_CL_CO_PLIP_V icppv,
                    PER_ALL_PEOPLE_F per,
                    HR_LOOKUPS hl
              WHERE peac.asnd_lf_evt_dt = :ASND_LF_EVT_DT
               AND peac.actn_typ_cd = :ACTN_TYP_CD
               AND :BEN_AS_OF_DATE BETWEEN peac.effective_start_Date
                                       AND peac.effective_end_Date
               AND copv.plip_id = cppv.id
               AND peac.interim_compobj_sk_pk = icopv.id(+)
               AND icopv.plip_id = icppv.id(+)
               AND per.person_id = peac.person_id
               AND peac.asnd_lf_evt_dt BETWEEN per.effective_start_date AND per.effective_end_date
               and peac.compobj_sk_pk = copv.id
               AND hl.lookup_type = ''YES_NO''
               AND DECODE(peac.sspnd_ind,1,''Y'',''N'') = hl.lookup_code
               AND copv.pgm_id IN
                       ( SELECT pgm_id
                           FROM hri_cl_co_rptgrp_v
                          WHERE ID = :PGM_RPTGTYP_ID )
              &ORDER_BY_CLAUSE';
      --
   */
   END IF;
   --
END GET_ENRLACTN_DET_SQL;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< GET_ELCTN_EVNT_SQL >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Event Status
-- AK_REGION : HRI_P_ELCTN_EVNT_STATUS
--
PROCEDURE GET_ELCTN_EVNT_SQL (
   p_page_parameter_tbl   IN              bis_pmv_page_parameter_tbl,
   x_custom_sql           OUT NOCOPY      VARCHAR2,
   x_custom_output        OUT NOCOPY      bis_query_attributes_tbl
)
IS
   --
   l_selection            number;
   l_custom_rec           BIS_QUERY_ATTRIBUTES;
   --
BEGIN
   --
   x_custom_sql := ' SELECT NULL     HRI_P_CHAR1_GA  /* Event Status */,
                            NULL     HRI_P_MEASURE1
                       FROM DUAL';
   --
   l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
   x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
   --
   set_bind_parameters( p_page_parameter_tbl => p_page_parameter_tbl,
                        x_custom_output      => x_custom_output,
                        p_selection          => l_selection) ;
   --
   IF l_selection = 1
   THEN
      --
      -- Use Views corresponding to Program Dimension
      --
      x_custom_sql :=
        '    SELECT /* Event Status (Program) */
                    HR_GENERAL.DECODE_LOOKUP (
	                      DECODE(pelc.ler_status_cd,
                                 ''MNL'',''BEN_PTNL_LER_FOR_PER_STAT''
                                      ,''BEN_PER_IN_LER_STAT'')
                       , pelc.ler_status_cd) HRI_P_CHAR1_GA,
                    per_count  HRI_P_MEASURE1
               FROM HRI_MDP_BEN_LESTAT_PGM_MV pelc
              WHERE asnd_lf_evt_dt = :ASND_LF_EVT_DT
                AND pgm_id = :PGM_RPTGTYP_ID
               &ORDER_BY_CLAUSE';
       --
   /*
    ELSIF l_selection = 2
    THEN
       --
       -- Use Views corresponding to Reporting Group Dimension
       --
       x_custom_sql :=
         '    SELECT hl.meaning HRI_P_CHAR1_GA, --  Event Status (Reporting Group)
                     per_count HRI_P_MEASURE1
                FROM HRI_MDP_BEN_LESTAT_RPTG_MV pelc,
                     HR_LOOKUPS hl
               WHERE asnd_lf_evt_dt = :ASND_LF_EVT_DT
                 AND rptgtyp_id = :PGM_RPTGTYP_ID
                 AND pelc.ler_status_cd = hl.lookup_code
                 AND hl.lookup_type = ''BEN_PER_IN_LER_STAT''
               &ORDER_BY_CLAUSE';
       --
    */
    END IF;
    --
END GET_ELCTN_EVNT_SQL;
--
-- ----------------------------------------------------------------------------
-- |------------------------< GET_ENRT_KPI_GRAPH_SQL >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Open Enrollment KPIs
-- AK_REGION : HRI_P_ELCTN_ENRT_GRAPH
--
PROCEDURE GET_ENRT_KPI_GRAPH_SQL (
   p_page_parameter_tbl   IN              bis_pmv_page_parameter_tbl,
   x_custom_sql           OUT NOCOPY      VARCHAR2,
   x_custom_output        OUT NOCOPY      bis_query_attributes_tbl
)
IS
   --
   l_selection            number;
   l_custom_rec           BIS_QUERY_ATTRIBUTES;
   --
BEGIN
   --
   x_custom_sql := ' SELECT NULL     HRI_P_CHAR1_GA  /* Open Enrollment KPIs */,
                            NULL     HRI_P_MEASURE1
                       FROM DUAL';
   --
   l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
   x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
   --
   set_bind_parameters( p_page_parameter_tbl => p_page_parameter_tbl,
                        x_custom_output      => x_custom_output,
                        p_selection          => l_selection) ;
   --
   IF l_selection = 1
   THEN
      --
      -- Use Views corresponding to Program Dimension
      --
      x_custom_sql :=
        '    SELECT hl.meaning          HRI_P_CHAR1_GA /* Open Enrollment KPIs (Program) */,
                    pelc.cnt_all        HRI_P_MEASURE1
               FROM HRI_MDP_BEN_ELCTN_PGMV_MV pelc,
                    HR_LOOKUPS hl
              WHERE asnd_lf_evt_dt = :ASND_LF_EVT_DT
                AND pgm_id = :PGM_RPTGTYP_ID
                AND hl.lookup_type = ''HRI_BEN_ENRT_STATUS''
                AND hl.lookup_code <> ''ELIG''
                AND hl.lookup_code = rec_type
               &ORDER_BY_CLAUSE';
       --
    /*
    ELSIF l_selection = 2
    THEN
       --
       -- Use Views corresponding to Reporting Group Dimension
       --
       x_custom_sql :=
         '    SELECT hl.meaning         HRI_P_CHAR1_GA, -- Open Enrollment KPIs (Reporting Group)
                     pelc.cnt_all       HRI_P_MEASURE1
                FROM HRI_MDP_BEN_ELCTN_RPTGV_MV pelc,
                     HR_LOOKUPS hl
               WHERE asnd_lf_evt_dt = :ASND_LF_EVT_DT
                 AND rptgtyp_id = :PGM_RPTGTYP_ID
                 AND hl.lookup_type = ''HRI_BEN_ENRT_STATUS''
                 AND hl.lookup_code <> ''ELIG''
                 AND hl.lookup_code = rec_type
               &ORDER_BY_CLAUSE';
       --
    */
    END IF;
    --
END GET_ENRT_KPI_GRAPH_SQL;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< GET_ENRT_KPI_SQL >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Open Enrollment Status
-- AK_REGION : HRI_K_ELCTN_ENRT
--
PROCEDURE GET_ENRT_KPI_SQL (
   p_page_parameter_tbl   IN              bis_pmv_page_parameter_tbl,
   x_custom_sql           OUT NOCOPY      VARCHAR2,
   x_custom_output        OUT NOCOPY      bis_query_attributes_tbl
)
IS
   --
   l_selection            number;
   l_custom_rec           BIS_QUERY_ATTRIBUTES;
   --
BEGIN
   --
   x_custom_sql := ' SELECT NULL     HRI_P_MEASURE1 /* Open Enrollment Status */,
                            NULL     HRI_P_MEASURE2,
                            NULL     HRI_P_MEASURE3,
                            NULL     HRI_P_MEASURE4
                       FROM DUAL';
   --
   l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
   x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
   --
   set_bind_parameters( p_page_parameter_tbl => p_page_parameter_tbl,
                        x_custom_output      => x_custom_output,
                        p_selection          => l_selection) ;
   --
   IF l_selection = 1
   THEN
      --
      -- Use Views corresponding to Program Dimension
      --
      x_custom_sql :=
        '    SELECT  elig_count         HRI_P_MEASURE1 /* Open Enrollment Status (Program) */,
                     enrt_count         HRI_P_MEASURE2,
                     not_enrt_count     HRI_P_MEASURE3,
                     dflt_count         HRI_P_MEASURE4
                FROM HRI_MDP_BEN_ELCTN_PGM_MV
               WHERE asnd_lf_evt_dt = :ASND_LF_EVT_DT
                 AND pgm_id = :PGM_RPTGTYP_ID ';
       --
    /*
    ELSIF l_selection = 2
    THEN
       --
       -- Use Views corresponding to Reporting Group Dimension
       --
       x_custom_sql :=
         '    SELECT  elig_count        HRI_P_MEASURE1, --  Open Enrollment Status (Reporting Group)
                      enrt_count        HRI_P_MEASURE2,
                      not_enrt_count    HRI_P_MEASURE3,
                      dflt_count        HRI_P_MEASURE4
                 FROM HRI_MDP_BEN_ELCTN_RPTG_MV
                WHERE asnd_lf_evt_dt = :ASND_LF_EVT_DT
                  AND rptgtyp_id = :PGM_RPTGTYP_ID ';
       --
    */
    END IF;
    --
END GET_ENRT_KPI_SQL;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< GET_ELIGENRL_PTIP_SQL >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Participation By Plan Type
-- AK_REGION : HRI_P_ELIGENRL_PRTT_PTIP
--
PROCEDURE GET_ELIGENRL_PTIP_SQL (
   p_page_parameter_tbl   IN              bis_pmv_page_parameter_tbl,
   x_custom_sql           OUT NOCOPY      VARCHAR2,
   x_custom_output        OUT NOCOPY      bis_query_attributes_tbl
)
IS
   --
   l_selection            number;
   l_custom_rec           BIS_QUERY_ATTRIBUTES;
   --
BEGIN
   --
   x_custom_sql := ' SELECT NULL     HRI_P_CHAR1_GA  /* Participation By Plan Type */,
                            NULL     HRI_P_MEASURE1,
                            NULL     HRI_P_MEASURE2,
                            NULL     HRI_P_MEASURE3_MP,
                            NULL     HRI_P_MEASURE4,
                            NULL     HRI_P_MEASURE5,
                            NULL     HRI_P_MEASURE6,
                            NULL     HRI_P_MEASURE7_MP,
                            NULL     HRI_P_MEASURE8_MP,
                            NULL     HRI_P_MEASURE9_MP,
                            NULL     HRI_P_MEASURE10
                       FROM DUAL';
   --
   l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
   x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
   --
   set_bind_parameters( p_page_parameter_tbl => p_page_parameter_tbl,
                        x_custom_output      => x_custom_output,
                        p_selection          => l_selection) ;
   --
   IF l_selection = 1
   THEN
      --
      -- Use Views corresponding to Program Dimension
      --
      x_custom_sql :=
        '   SELECT ctpv.value                 HRI_P_CHAR1_GA /* Participation By Plan Type (Program) */,
                   ctpmv.elig_count           HRI_P_MEASURE1,
                   ctpmv.enrt_count           HRI_P_MEASURE2,
                   ctpmv.enrt_per             HRI_P_MEASURE3_MP,
                   ctpmv.waive_expl_count     HRI_P_MEASURE4,
                   ctpmv.waive_dflt_count     HRI_P_MEASURE5,
                   ctpmv.waive_total_count    HRI_P_MEASURE6,
                   ctpmv.waive_expl_per       HRI_P_MEASURE7_MP,
                   ctpmv.waive_dflt_per       HRI_P_MEASURE8_MP,
                   ctpmv.waive_total_per      HRI_P_MEASURE9_MP,
                   ctpmv.ptip_id              HRI_P_MEASURE10
              FROM HRI_MDP_BEN_ELIGENRL_CTP_MV ctpmv,
                   HRI_CL_CO_PGMH_PTIP_V ctpv
             WHERE ctpmv.asnd_lf_evt_dt = :ASND_LF_EVT_DT
               AND ctpv.id = ctpmv.ptip_id
               AND ctpmv.asnd_lf_evt_dt BETWEEN ctpv.start_date AND ctpv.end_date
               AND ctpv.pgm_id = :PGM_RPTGTYP_ID
               AND :BEN_AS_OF_DATE BETWEEN ctpmv.effective_start_date
                                       AND ctpmv.effective_end_date
               &ORDER_BY_CLAUSE';
       --
    /*
    ELSIF l_selection = 2
    THEN
       --
       -- Use Views corresponding to Reporting Group Dimension
       --
       x_custom_sql :=
         '   SELECT ptpv.value                HRI_P_CHAR1_GA, --  Participation By Plan Type (Reporting Group)
                    ptpmv.elig_count          HRI_P_MEASURE1,
                    ptpmv.enrt_count          HRI_P_MEASURE2,
                    ptpmv.enrt_per            HRI_P_MEASURE3_MP,
                    ptpmv.waive_expl_count    HRI_P_MEASURE4,
                    ptpmv.waive_dflt_count    HRI_P_MEASURE5,
                    ptpmv.waive_total_count   HRI_P_MEASURE6,
                    ptpmv.waive_expl_per      HRI_P_MEASURE7_MP,
                    ptpmv.waive_dflt_per      HRI_P_MEASURE8_MP,
                    ptpmv.waive_total_per     HRI_P_MEASURE9_MP,
                    ptpmv.pl_typ_id           HRI_P_MEASURE10
               FROM HRI_MDP_BEN_ELIGENRL_RPTP_MV ptpmv,
                    HRI_CL_CO_RPTG_PLTYP_V ptpv
              WHERE ptpmv.asnd_lf_evt_dt = :ASND_LF_EVT_DT
                AND ptpv.id = ptpmv.pl_typ_id
                AND ptpv.rptgtyp_id = ptpmv.rptgtyp_id
                AND ptpmv.asnd_lf_evt_dt BETWEEN ptpv.start_date AND ptpv.end_date
                AND ptpmv.rptgtyp_id = :PGM_RPTGTYP_ID
                AND :BEN_AS_OF_DATE BETWEEN ptpmv.effective_start_Date
                                        AND ptpmv.effective_end_Date
               &ORDER_BY_CLAUSE';
    */
       --
    END IF;
    --
END GET_ELIGENRL_PTIP_SQL;
--
END HRI_OLTP_PMV_OPEN_ENRT_STAT;

/
