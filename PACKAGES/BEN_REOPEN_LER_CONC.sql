--------------------------------------------------------
--  DDL for Package BEN_REOPEN_LER_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_REOPEN_LER_CONC" AUTHID CURRENT_USER AS
/* $Header: benrecon.pkh 120.0.12000000.1 2007/07/12 10:08:03 gsehgal noship $ */
--
/* ============================================================================
*    Name
*      Reopen Life Events Concurrent Manager Process
*
*    Purpose
*       This package simply houses the concurrent manager and multi-thread
*       processes for Reopen Life Events.
*
*    History
*      Date        Who        Version    What?
*      -------     ---------  -------    --------------------------------------
*      8/14/2006   gsehgal    115.0      Created
*
* -----------------------------------------------------------------------------
*/
--
-- Global type declaration
--
type g_cache_person_process_object is record
   	(person_id                ben_person_actions.person_id%type
   	,person_action_id         ben_person_actions.person_action_id%type
   	,object_version_number    ben_person_actions.object_version_number%type
   	,ler_id                   ben_person_actions.ler_id%type
    );
type g_cache_person_process_rec is table of g_cache_person_process_object
    index by binary_integer;
--
-- Global varaibles.
--


-- Global Procedures
   PROCEDURE process (
      errbuf                  OUT NOCOPY      VARCHAR2,
      retcode                 OUT NOCOPY      NUMBER,
      p_benefit_action_id     IN              NUMBER,
      p_effective_date        IN              VARCHAR2,
      p_validate              IN              VARCHAR2 DEFAULT 'N',
      p_business_group_id     IN              NUMBER,
      p_ler_id                IN              NUMBER DEFAULT NULL,
      p_from_ocrd_date        IN              VARCHAR2 DEFAULT NULL,
      p_organization_id       IN              NUMBER DEFAULT NULL,
      p_location_id           IN              NUMBER DEFAULT NULL,
      p_benfts_grp_id         IN              NUMBER DEFAULT NULL,
      p_legal_entity_id       IN              NUMBER DEFAULT NULL,
      p_person_selection_rl   IN              NUMBER DEFAULT NULL,
      p_debug_messages        IN              VARCHAR2 DEFAULT 'N'
   );

   PROCEDURE do_multithread (
      errbuf                OUT NOCOPY      VARCHAR2,
      retcode               OUT NOCOPY      NUMBER,
      p_validate            IN              VARCHAR2 DEFAULT 'N',
      p_benefit_action_id   IN              NUMBER,
      p_effective_date      IN              VARCHAR2,
      p_business_group_id   IN              NUMBER,
      p_ler_id              IN              NUMBER,
      p_thread_id           IN              NUMBER
   );
   PROCEDURE submit_all_reports (p_rpt_flag IN BOOLEAN DEFAULT FALSE);
END ben_reopen_ler_conc;



 

/
