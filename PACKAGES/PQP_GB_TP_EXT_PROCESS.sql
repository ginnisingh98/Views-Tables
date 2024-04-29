--------------------------------------------------------
--  DDL for Package PQP_GB_TP_EXT_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_TP_EXT_PROCESS" AUTHID CURRENT_USER AS
--  /* $Header: pqpgbtpext.pkh 120.0 2005/05/29 02:20:59 appldev noship $ */
--
--

--
-- Type Definitions
--
TYPE t_request_ids_type IS TABLE OF fnd_concurrent_requests.request_id%TYPE
INDEX BY BINARY_INTEGER;

--
-- Globals
--
g_extract_type          fnd_lookups.lookup_code%type;
g_extract_udt_name      pay_user_tables.user_table_name%type;
g_report_type           VARCHAR2(10);
g_lea_business_groups   pqp_gb_t1_pension_extracts.t_all_bgs_type;
g_request_ids           t_request_ids_type;
g_execution_mode        VARCHAR2(10) := 'PARALLEL'; -- Or SERIAL
g_wait_interval         NUMBER := 60; -- seconds
g_max_wait              NUMBER := 0; -- Meaning no time out

g_proc_name          VARCHAR2(61)       := 'pqp_gb_tp_ext_process.';
g_debug              BOOLEAN            := hr_utility.debug_enabled;
g_master_request_id  fnd_concurrent_requests.request_id%TYPE;

-- Bugfix 3671727:ENH1: Added this new global
g_lea_number            VARCHAR2(3):=RPAD(' ',3,' ');

-- Debug
PROCEDURE DEBUG (
   p_trace_message    IN   VARCHAR2
  ,p_trace_location   IN   NUMBER DEFAULT NULL
);

-- Debug_Enter
PROCEDURE debug_enter (
   p_proc_name   IN   VARCHAR2
  ,p_trace_on    IN   VARCHAR2 DEFAULT NULL
);

-- Debug_Exit
PROCEDURE debug_exit (
   p_proc_name   IN   VARCHAR2
  ,p_trace_off   IN   VARCHAR2 DEFAULT NULL
);

-- Debug Others
PROCEDURE debug_others (
   p_proc_name   IN   VARCHAR2
  ,p_proc_step   IN   NUMBER DEFAULT NULL
);

--
-- get_ext_rslt_frm_req
--
FUNCTION get_ext_rslt_frm_req (p_request_id IN NUMBER
                              ,p_ext_dfn_id IN NUMBER
                              )
  RETURN NUMBER;

--
-- get_ext_rslt_count
--
PROCEDURE get_ext_rslt_count (p_ext_rslt_id  IN            NUMBER
                             ,p_ext_file_id  IN            NUMBER
                             ,p_hdr_count       OUT NOCOPY NUMBER
                             ,p_dtl_count       OUT NOCOPY NUMBER
                             ,p_trl_count       OUT NOCOPY NUMBER
                             ,p_per_count       OUT NOCOPY NUMBER
                             ,p_err_count       OUT NOCOPY NUMBER
                             ,p_tot_count       OUT NOCOPY NUMBER
                             );

--
-- create_extract_results
--
PROCEDURE create_extract_results (p_master_ext_rslt_id           IN NUMBER
                                 ,p_master_request_id            IN NUMBER
                                 ,p_ext_dfn_id                   IN NUMBER
                                 ,p_request_id                   IN NUMBER
                                 ,p_business_group_id            IN NUMBER
                                 ,p_program_application_id       IN NUMBER
                                 ,p_program_id                   IN NUMBER
                                 ,p_effective_date               IN DATE
                                 );

--
-- copy_extract_results
--
PROCEDURE copy_extract_results (p_tab_request_ids       IN pqp_gb_tp_ext_process.t_request_ids_type
                               ,p_ext_dfn_id            IN NUMBER
                               ,p_master_business_group IN NUMBER
                               );
--
-- copy_extract_process
--
PROCEDURE copy_extract_process (errbuf              OUT NOCOPY VARCHAR2
                               ,retcode             OUT NOCOPY NUMBER
                               ,p_ext_dfn_id        IN NUMBER
                               ,p_business_group_id IN NUMBER
                               ,p_request_id_1      IN NUMBER DEFAULT NULL
                               ,p_request_id_2      IN NUMBER DEFAULT NULL
                               ,p_request_id_3      IN NUMBER DEFAULT NULL
                               ,p_request_id_4      IN NUMBER DEFAULT NULL
                               ,p_request_id_5      IN NUMBER DEFAULT NULL
                               );

--
-- set_cross_person_records
--
PROCEDURE set_cross_person_records
  (p_business_group_id  IN NUMBER
  ,p_effective_date     IN DATE
  ,p_master_request_id  IN NUMBER DEFAULT NULL
  -- Bugfix 3671727:ENH2 :Added new param
  ,p_ext_dfn_id         IN VARCHAR2
  );

--
-- tpa_extract_process
--
PROCEDURE tpa_extract_process
  (errbuf               OUT NOCOPY      VARCHAR2
  ,retcode              OUT NOCOPY      NUMBER
  ,p_ext_dfn_id         IN              NUMBER
  ,p_effective_date     IN              VARCHAR2
  ,p_business_group_id  IN              NUMBER
  ,p_lea_yn             IN              VARCHAR2 DEFAULT NULL
  ,p_argument1          IN              VARCHAR2 DEFAULT NULL
  ,p_organization_id    IN              NUMBER
  -- Bugfix 3671727:ENH1 : Added new param
  ,p_argument2          IN              VARCHAR2
  ,p_lea_number         IN              VARCHAR2
  );

END pqp_gb_tp_ext_process;

 

/
