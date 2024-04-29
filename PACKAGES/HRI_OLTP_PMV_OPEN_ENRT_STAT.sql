--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_OPEN_ENRT_STAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_OPEN_ENRT_STAT" AUTHID CURRENT_USER AS
/* $Header: hrirpoes.pkh 120.0 2005/09/21 01:29:02 anmajumd noship $ */


  --procedure get_enrt_kpi_for_graph
  procedure GET_ENRT_KPI_GRAPH_SQL(p_page_parameter_tbl in bis_pmv_page_parameter_tbl
                       ,x_custom_sql out nocopy varchar2
                       ,x_custom_output out nocopy bis_query_attributes_tbl);

  --procedure GET_PTIP_PRTT
  procedure GET_ELIGENRL_PLIP_SQL(p_page_parameter_tbl in bis_pmv_page_parameter_tbl
                       ,x_custom_sql out nocopy varchar2
                       ,x_custom_output out nocopy bis_query_attributes_tbl);

  -- procedure GET_PER_ACTN
  procedure GET_ENRLACTN_DET_SQL(p_page_parameter_tbl in bis_pmv_page_parameter_tbl
                       ,x_custom_sql out nocopy varchar2
                       ,x_custom_output out nocopy bis_query_attributes_tbl);

  -- procedure GET_PLIP_PRTT
  procedure GET_ELIGENRL_OIPL_SQL(p_page_parameter_tbl in bis_pmv_page_parameter_tbl
                       ,x_custom_sql out nocopy varchar2
                       ,x_custom_output out nocopy bis_query_attributes_tbl);

  -- PROCEDURE get_main_prtt (
  PROCEDURE GET_ELIGENRL_PTIP_SQL (
      p_page_parameter_tbl   IN              bis_pmv_page_parameter_tbl,
      x_custom_sql           OUT NOCOPY      VARCHAR2,
      x_custom_output        OUT NOCOPY      bis_query_attributes_tbl
   );

  -- PROCEDURE get_enrt_kpi (
  PROCEDURE GET_ENRT_KPI_SQL (
      p_page_parameter_tbl   IN              bis_pmv_page_parameter_tbl,
      x_custom_sql           OUT NOCOPY      VARCHAR2,
      x_custom_output        OUT NOCOPY      bis_query_attributes_tbl
   );

  --PROCEDURE get_open_enrl_actn (
  PROCEDURE GET_ENRLACTN_SQL (
      p_page_parameter_tbl   IN              bis_pmv_page_parameter_tbl,
      x_custom_sql           OUT NOCOPY      VARCHAR2,
      x_custom_output        OUT NOCOPY      bis_query_attributes_tbl
   );
  -- PROCEDURE get_lf_evt_status (
  PROCEDURE GET_ELCTN_EVNT_SQL (
      p_page_parameter_tbl   IN              bis_pmv_page_parameter_tbl,
      x_custom_sql           OUT NOCOPY      VARCHAR2,
      x_custom_output        OUT NOCOPY      bis_query_attributes_tbl
   );
END HRI_OLTP_PMV_OPEN_ENRT_STAT;

 

/
