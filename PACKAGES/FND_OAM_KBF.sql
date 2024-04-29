--------------------------------------------------------
--  DDL for Package FND_OAM_KBF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_KBF" AUTHID CURRENT_USER AS
/* $Header: AFOAMBFS.pls 120.3 2005/11/16 21:45:52 ppradhan noship $ */
-------------------------------------------------------------------------------
-- Common constants
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- Exceptions Related
-------------------------------------------------------------------------------

  --
  -- Name
  --   get_sysal_cnt
  --
  -- Purpose
  --   Returns the count of System Alerts across various severities and
  --   acknowledged states by querying the fnd_log_unique_exceptions table.
  --
  -- Input Arguments
  --   p_category - category for which to return the counts. Null by
  --                by default.
  -- Output Arguments
  --   critical_n - count of new alerts which are of CRITICAL severity
  --   error_n    - count of new alerts which are of ERROR severity
  --   warning_n  - count of new alerts which are of WARNING severity
  --   critical_o - count of open alerts which are of CRITICAL severity
  --   error_o    - count of open alerts which are of ERROR severity
  --   warning_o  - count of open alerts which are of WARNING severity
  --
  -- Notes:
  --
  --
  PROCEDURE get_sysal_cnt
    (critical_n OUT NOCOPY number,
     error_n OUT NOCOPY number,
     warning_n OUT NOCOPY number,
     critical_o OUT NOCOPY number,
     error_o OUT NOCOPY number,
     warning_o OUT NOCOPY number,
     p_category in varchar2 default null);

  --
  -- Name
  --   get_occ_cnt
  --
  -- Purpose
  --   Returns the count of Occurrances of alerts across various severities
  --   and acknowledged states by querying
  --   the fnd_log_exceptions table.
  --
  -- Input Arguments
  --   p_category - category for which to return the counts. Null by
  --                by default.
  -- Output Arguments
  --   critical_n - count of new occurrances which are of CRITICAL severity
  --   error_n    - count of new occurrances which are of ERROR severity
  --   warning_n  - count of new occurrances which are of WARNING severity
  --   critical_o - count of open occurrances which are of CRITICAL severity
  --   error_o    - count of open occurrances which are of ERROR severity
  --   warning_o  - count of open occurrances which are of WARNING severity
  --
  -- Notes:
  --
  --
  PROCEDURE get_occ_cnt
    (critical_n OUT NOCOPY number,
     error_n OUT NOCOPY number,
     warning_n OUT NOCOPY number,
     critical_o OUT NOCOPY number,
     error_o OUT NOCOPY number,
     warning_o OUT NOCOPY number,
     p_category in varchar2 default null);


  --
  -- Name
  --   change_state
  --
  -- Purpose
  --   To change the state of a set of system alerts to 'O' - Open or 'C'
  --   to close the alert. Newly generated alerts have the state 'N'. This
  --   procedure will also insert a row into fnd_exception_notes to indicate
  --   that the alert's state has been changed by the given user.
  --
  -- Input Arguments
  --   p_logidset - a single logid or a set of ',' delimited log ids. e.g.
  --             '1234' or '1234,1235,1236'
  --   p_newstate - 'O' for Open or 'C' for Closed.
  --   p_username - user name of the apps user who is changing the state.
  --
  -- Notes:
  --   The purpose for this procedure is so that users can move the state
  --   of system alerts from the OAM UI.
  --
  PROCEDURE change_state
    (p_logidset IN varchar2,
     p_newstate IN varchar2,
     p_username IN varchar2);


-------------------------------------------------------------------------------
-- Metrics Related
-------------------------------------------------------------------------------


END fnd_oam_kbf;

 

/
