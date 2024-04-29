--------------------------------------------------------
--  DDL for Package FND_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CONC" AUTHID CURRENT_USER as
/* $Header: AFCPDIGS.pls 120.2 2005/08/19 21:41:29 rckalyan ship $ */

   -- Request phase codes
   PHASE_PENDING   constant varchar2(1) := 'P';
   PHASE_INACTIVE  constant varchar2(1) := 'I';
   PHASE_RUNNING   constant varchar2(1) := 'R';
   PHASE_COMPLETED constant varchar2(1) := 'C';

   -- Request status codes
   STATUS_WAITING           constant varchar2(1) := 'A';
   STATUS_RESUMING          constant varchar2(1) := 'B';
   STATUS_COMPLETED_NORMAL  constant varchar2(1) := 'C';
   STATUS_CANCELLED         constant varchar2(1) := 'D';
   STATUS_ERROR             constant varchar2(1) := 'E';
   STATUS_WARNING           constant varchar2(1) := 'G';
   STATUS_HOLD              constant varchar2(1) := 'H';
   STATUS_NORMAL            constant varchar2(1) := 'I';
   STATUS_NO_MANAGER        constant varchar2(1) := 'M';
   STATUS_SCHEDULED         constant varchar2(1) := 'P';
   STATUS_STANDBY           constant varchar2(1) := 'Q';
   STATUS_RUNNING_NORMAL    constant varchar2(1) := 'R';
   STATUS_SUSPENDED         constant varchar2(1) := 'S';
   STATUS_TERMINATING       constant varchar2(1) := 'T';
   STATUS_DISABLED          constant varchar2(1) := 'U';
   STATUS_PAUSED            constant varchar2(1) := 'W';
   STATUS_TERMINATED        constant varchar2(1) := 'X';




-- ================================================
-- PUBLIC FUNCTIONS/PROCEDURES
-- ================================================


--
-- PROCEDURE
--   diagnose
-- Purpose
--   Perform diagnostics on a given request.
-- Arguments
--   request_id
--   phase       -- returns text string describing the phase
--   status      -- returns text string describing the status
--   help_text   -- returns translated diagnostic text
--
PROCEDURE diagnose ( request_id  IN     number,
		             phase       OUT NOCOPY    varchar2,
		             status      OUT NOCOPY    varchar2,
		             help_text   IN OUT NOCOPY varchar2
				   );

--
-- Function
--   process_alive
-- Purpose
--   Return TRUE if the process is alive,
--   FALSE otherwise.
-- Arguments
--   pid - concurrent process ID
-- Notes
--   Return FALSE on error.
--
function process_alive(pid number) return boolean;


--
-- Function
--   icm_alive
-- Purpose
--   If the ICM is dead, put the appropriate
--   message on the stack and return FALSE.
--   If the ICM is alive, TRUE is returned
-- Arguments
--   print   -- if FALSE, no message is put on the stack
--
function icm_alive(print boolean) return boolean;


--
-- Function
--   service_alive
-- Purpose
--   Checks to see if any one of a service's processes are alive.
--   Returns TRUE if one or more is alive, if none are alive returns FALSE.
-- Arguments
--   queue_id     -- concurrent queue id of the service
--   app_id       -- application id of the service
-- Notes
--   Calls process_alive for each process id.
--
function service_alive(queue_id in number,
                       app_id   in number) return boolean;



--
-- PROCEDURE
--   manager_check
-- Purpose
--   Checks status of managers that can run a request.
--
-- Arguments
--   IN:
--    req_id        -- request ID
--    cd_id         -- Conflict Domain ID
--   OUT:
--    mgr_defined   -- Is there a manager defined that will run
--                     the request?
--    mgr_active    -- Is there an active manager to run it?
--    mgr_workshift -- Will the request run in a current workshift?
--    mgr_running   -- Is there a manager running that can
--                     process the request?
--    run_alone     -- Is request waiting for run alone request?
--                     to complete.
--
PROCEDURE manager_check  (req_id        in  number,
                          cd_id         in  number,
                          mgr_defined   out nocopy boolean,
                          mgr_active    out nocopy boolean,
                          mgr_workshift out nocopy boolean,
                          mgr_running   out nocopy boolean,
                          run_alone     out nocopy boolean);


--
-- FUNCTION
--   get_phase
-- Purpose
--   Lookup meaning of a request phase_code.
--
function get_phase(pcode in varchar2) return varchar2;



--
-- FUNCTION
--   get_status
-- Purpose
--    Lookup meaning of a request status_code.
--
function get_status(scode in varchar2) return varchar2;




end FND_CONC;

 

/
