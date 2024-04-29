--------------------------------------------------------
--  DDL for Package PJI_LAUNCH_UPP_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_LAUNCH_UPP_MAIN" AUTHID CURRENT_USER as
 /* $Header: PJILN01S.pls 120.0.12010000.3 2010/03/10 08:12:31 rkuttiya noship $ */

  g_full_disp_name      varchar2(30) := 'PJI_PJP_SUMMARIZE_FULL';
  g_incr_disp_name      varchar2(30) := 'PJI_PJP_SUMMARIZE_INCR';
  g_prtl_disp_name      varchar2(30) := 'PJI_PJP_SUMMARIZE_PRTL';
  g_rbs_disp_name       varchar2(30) := 'PJI_PJP_SUMMARIZE_RBS';
  g_retcode             varchar2(255);
  g_stat_count          number := 0;   /* Added for bug 8416116 */

  PROCEDURE LAUNCH_UPP_PROCESS
  (
    errbuf                    out  NOCOPY  varchar2,
    retcode                   out  NOCOPY  varchar2,
    p_num_of_projects            in     number ,
    p_temp_table_size           in     number ,
    p_num_parallel_runs         in     number ,
    p_num_of_batches            in     number ,
    p_wait_time_seconds         in     number ,
    p_regenerate_batches        in     varchar2 ,  -- Sridhar added this new parameter
    p_incremental_mode          in     varchar2,   -- Sridhar Carlson added this new parameter
    P_OPERATING_UNIT            in     number,
    p_project_status            in     varchar2 );--rkuttiya added new parameter for 12.1.3


  PROCEDURE CREATE_UPP_BATCHES
  (
    p_wbs_temp_table_size           in   number ,
    p_num_of_projects               in   number ,
    p_incremental_mode          in     varchar2,   -- Sridhar Carlson added this new parameter
    P_OPERATING_UNIT            in     number,
    p_project_status            in     varchar2 ) -- new parameter for 12.1.3
    ;

  PROCEDURE CREATE_INCR_PROJECT_LIST
  (
    p_operating_unit            in   number
  ) ;

  PROCEDURE UPDATE_BATCH_CONC_STATUS
  (
    p_first_time_flag   in  varchar2,
    x_count_batches     out NOCOPY  number,
    x_count_running     out  NOCOPY number,
    x_count_errored     out  NOCOPY number,
    x_count_completed   out  NOCOPY number,
    x_count_pending     out  NOCOPY number
  );

end PJI_LAUNCH_UPP_MAIN;

/
