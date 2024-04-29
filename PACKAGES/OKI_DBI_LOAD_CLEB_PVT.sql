--------------------------------------------------------
--  DDL for Package OKI_DBI_LOAD_CLEB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_DBI_LOAD_CLEB_PVT" AUTHID CURRENT_USER AS
/* $Header: OKIRILES.pls 120.1 2006/03/28 23:35:16 asparama noship $ */

  g_start_date     DATE;
  g_end_date       DATE;
  g_run_date       DATE;
  g_load_type      VARCHAR2(100);


  PROCEDURE Rlog (  p_string IN VARCHAR2,  p_indent IN NUMBER );
  PROCEDURE Rout (  p_string IN VARCHAR2,  p_indent IN NUMBER );


  PROCEDURE Reset_Base_Tables  ( errbuf   OUT NOCOPY VARCHAR2,  retcode  OUT NOCOPY VARCHAR2 );
  PROCEDURE Direct_Load ( p_recs_processed OUT NOCOPY NUMBER );
  PROCEDURE incr_Load   ( p_recs_processed OUT NOCOPY NUMBER );

  PROCEDURE Populate_Inc_Table_Init;
  PROCEDURE Populate_Inc_Table_Inc;
  PROCEDURE Report_Missing_Currencies;
  PROCEDURE Process_Deletes;
  PROCEDURE Load_Currencies;
  PROCEDURE Populate_Ren_Rel(p_no_of_Workers IN NUMBER);


  PROCEDURE Load_staging(
                           p_worker   IN NUMBER
                        ,  p_recs_processed OUT NOCOPY NUMBER
                        );
  PROCEDURE Update_LHS  (
                           p_worker   IN NUMBER
                        ,  p_no_of_workers IN NUMBER
                        ,  p_recs_processed OUT NOCOPY NUMBER
                        );
  PROCEDURE populate_prev_inc  (
                           p_worker   IN NUMBER
                        ,  p_no_of_workers IN NUMBER
                        ,  p_stage IN NUMBER
                        ,  p_recs_processed OUT NOCOPY NUMBER
                        );
  PROCEDURE delta_changes( p_worker IN NUMBER
                       , p_no_of_workers IN NUMBER
                       , p_recs_processed OUT NOCOPY NUMBER
                       );
  PROCEDURE Update_RHS  (
                           p_worker   IN NUMBER
                        ,  p_no_of_workers IN NUMBER
                        ,  p_recs_processed OUT NOCOPY NUMBER
                        );

  PROCEDURE update_staging( p_worker IN NUMBER
                        , p_no_of_workers IN NUMBER
                        , p_recs_processed OUT NOCOPY NUMBER
                        );
  PROCEDURE worker       (
                         errbuf      OUT   NOCOPY VARCHAR2,
                         retcode     OUT   NOCOPY VARCHAR2,
                         p_worker_no  IN NUMBER,
                         p_phase      IN NUMBER,
                         p_no_of_workers IN NUMBER
                         );

  FUNCTION  launch_worker( p_worker_no  IN NUMBER ,
                           p_phase      IN NUMBER,
                           p_no_of_workers IN NUMBER) RETURN NUMBER;
  PROCEDURE Initial_Load (
                         errbuf  OUT NOCOPY VARCHAR2,
                         retcode OUT NOCOPY VARCHAR2,
                         p_start_date IN VARCHAR2,
                         p_end_date   IN VARCHAR2
                         );
  PROCEDURE Populate_Base_Tables
                         (
                         errbuf  OUT NOCOPY VARCHAR2,
                         retcode OUT NOCOPY VARCHAR2,
                         p_start_date IN VARCHAR2,
                         p_end_date   IN VARCHAR2,
                         p_no_of_workers IN NUMBER
                         );

END OKI_DBI_LOAD_CLEB_PVT;

 

/
