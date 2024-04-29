--------------------------------------------------------
--  DDL for Package FND_OAM_DSCRAM_STATS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DSCRAM_STATS_PKG" AUTHID CURRENT_USER as
/* $Header: AFOAMDSSTATS.pls 120.1 2006/06/07 17:49:25 ilawler noship $ */

   ------------
   -- Constants
   ------------

   ---------------------------------
   -- Public Procedures/Functions --
   ---------------------------------

   -- API used by the Dscram java master controller to create a stats entry for each start/resume/restart
   -- operation.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_run_id          DSCRAM_RUNS.RUN_ID for which this stat is being created.
   --   p_start_time      Run's start time
   --   p_prestart_status Run's status prior to start, used to detect resumed runs
   --   p_start_message   Anything to put in the message field as notes for the start
   --   x_run_stat_id:    DSCRAM_STATS.STAT_ID of the stat row created
   --   x_return_status:  FND_API-compliant return status
   --   x_return_msg:     Message explaining non-success return statuses
   PROCEDURE CREATE_ENTRY_FOR_RUN(p_run_id              IN NUMBER,
                                  p_start_time          IN DATE,
                                  p_prestart_status     IN VARCHAR2 DEFAULT NULL,
                                  p_start_message       IN VARCHAR2 DEFAULT NULL,
                                  x_run_stat_id         OUT NOCOPY      NUMBER,
                                  x_return_status       OUT NOCOPY      VARCHAR2,
                                  x_return_msg          OUT NOCOPY      VARCHAR2);

   -- API used by any Dscram code to allocate a stats row for an entity in the context of the passed
   -- in p_run_stat_id.
   -- Invariants:
   --   A call to CREATE_ENTRY_FOR_RUN must have already occured to get a valid p_run_stat_id.
   -- Parameters:
   --   p_run_stat_id:        DSCRAM_STATS.STAT_ID for the run which the stat is to be associated with, must not be null
   --   x_source_object_type: String corresponding to one of the CONSTANTS_PKG.G_TYPE_* constants
   --   x_source_object_id:   Number corresponding to the unique ID of the object in its base table
   --   x_start_time:         Datetime when object was started
   --   x_prestart_status:    Status of the object prior to start
   --   x_stat_id:            DSCRAM_STATS.STAT_ID of stat row created
   --   x_return_status:      FND_API-compliant return status
   --   x_return_msg:         Message explaining non-success return statuses
   PROCEDURE CREATE_ENTRY(p_run_stat_id         IN NUMBER,
                          p_source_object_type  IN VARCHAR2,
                          p_source_object_id    IN NUMBER,
                          p_start_time          IN DATE,
                          p_prestart_status     IN VARCHAR2 DEFAULT NULL,
                          p_start_message       IN VARCHAR2 DEFAULT NULL,
                          x_stat_id             OUT NOCOPY      NUMBER);

   -- API used by PL/SQL Dscram code after an execute_bundle.  Figures out the run_stat_id from the bundle
   -- state.
   -- See: CREATE_ENTRY(p_run_stat_id...x_return_msg) above.
   PROCEDURE CREATE_ENTRY(p_source_object_type  IN VARCHAR2,
                          p_source_object_id    IN NUMBER,
                          p_start_time          IN DATE,
                          p_prestart_status     IN VARCHAR2 DEFAULT NULL,
                          p_start_message       IN VARCHAR2 DEFAULT NULL,
                          x_stat_id             OUT NOCOPY      NUMBER);

   -- Alternate API that wraps the create stats entry in an autonomous transaction and commits it.
   -- If p_dismiss_failure is FND_API.G_TRUE, failed entries aren't logged.
   -- See: CREATE_ENTRY(p_run_stat_id...x_return_msg) above.
   PROCEDURE CREATE_ENTRY_AUTONOMOUSLY(p_source_object_type     IN VARCHAR2,
                                       p_source_object_id       IN NUMBER,
                                       p_start_time             IN DATE,
                                       p_prestart_status        IN VARCHAR2 DEFAULT NULL,
                                       p_start_message          IN VARCHAR2 DEFAULT NULL,
                                       p_dismiss_failure        IN VARCHAR2 DEFAULT NULL,
                                       x_stat_id                OUT NOCOPY NUMBER);

   -- API used by the Dscram java master controller to create a stats entry for each start/resume/restart
   -- operation.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_run_id          DSCRAM_RUNS.RUN_ID for which this stat is being created.
   --   p_end_time        Time when entity completed
   --   p_postend_status  Status of object after completion
   --   p_end_message     Any message you want to attach as notes to completion, may be an error code
   --   x_run_stat_id:    DSCRAM_STATS.STAT_ID of the stat row created
   --   x_return_status:  FND_API-compliant return status
   --   x_return_msg:     Message explaining non-success return statuses
   PROCEDURE COMPLETE_ENTRY_FOR_RUN(p_run_id            IN NUMBER,
                                    p_end_time          IN DATE,
                                    p_postend_status    IN VARCHAR2 DEFAULT NULL,
                                    p_end_message       IN VARCHAR2 DEFAULT NULL,
                                    x_return_status     OUT NOCOPY      VARCHAR2,
                                    x_return_msg        OUT NOCOPY      VARCHAR2);

   -- API used by any Dscram code to finish off a stats row
   -- in p_run_stat_id.
   -- Invariants:
   --   A call to CREATE_ENTRY_FOR_RUN must have already occured to get a valid p_run_stat_id.
   -- Parameters:
   --   p_run_stat_id:        DSCRAM_STATS.STAT_ID for the run which the stat is to be associated with, must not be null
   --   x_source_object_type: String corresponding to one of the CONSTANTS_PKG.G_TYPE_* constants
   --   x_source_object_id:   Number corresponding to the unique ID of the object in its base table
   --   p_end_time        Time when entity completed
   --   p_postend_status  Status of object after completion
   --   p_end_message     Any message you want to attach as notes to completion, may be an error code
   --
   -- Doesn't include return statuses because a failed stats completion wouldn't fail the completed object.
   PROCEDURE COMPLETE_ENTRY(p_run_stat_id               IN NUMBER,
                            p_source_object_type        IN VARCHAR2,
                            p_source_object_id          IN NUMBER,
                            p_end_time                  IN DATE,
                            p_postend_status            IN VARCHAR2 DEFAULT NULL,
                            p_end_message               IN VARCHAR2 DEFAULT NULL);

   -- API used by PL/SQL Dscram code in the complete_<object> procedures.
   -- Figures out the run_stat_id from the bundle state.
   -- See: COMPLETE_ENTRY above.
   PROCEDURE COMPLETE_ENTRY(p_source_object_type        IN VARCHAR2,
                            p_source_object_id          IN NUMBER,
                            p_end_time                  IN DATE,
                            p_postend_status            IN VARCHAR2 DEFAULT NULL,
                            p_end_message               IN VARCHAR2 DEFAULT NULL);


   -- API used to test for the existence of a stats row.
   -- Invariants:
   --   None.
   -- Parameters:
   --   p_run_stat_id:        DSCRAM_STATS.STAT_ID for the run which the stat is to be associated with, must not be null
   --   x_source_object_type: String corresponding to one of the CONSTANTS_PKG.G_TYPE_* constants
   --   x_source_object_id:   Number corresponding to the unique ID of the object in its base table
   FUNCTION HAS_ENTRY(p_run_stat_id             IN NUMBER,
                      p_source_object_type      IN VARCHAR2,
                      p_source_object_id        IN NUMBER)
      RETURN BOOLEAN;

   -- API used to test for the existence of a stats row.
   -- Invariants:
   --   None.
   -- Parameters:
   --   x_source_object_type: String corresponding to one of the CONSTANTS_PKG.G_TYPE_* constants
   --   x_source_object_id:   Number corresponding to the unique ID of the object in its base table
   FUNCTION HAS_ENTRY(p_source_object_type      IN VARCHAR2,
                      p_source_object_id        IN NUMBER)
      RETURN BOOLEAN;

END FND_OAM_DSCRAM_STATS_PKG;

 

/
