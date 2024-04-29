--------------------------------------------------------
--  DDL for Package FND_CONC_SSWA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CONC_SSWA" AUTHID CURRENT_USER as
/* $Header: AFCPSSUS.pls 120.1.12010000.2 2009/05/13 16:52:07 tkamiya ship $ */

--
-- Package
--   FND_CONC_SSWA
-- Purpose
--   Utilities for the Concurrent Self Service Web Applications
-- History
  --
  -- PUBLIC VARIABLES
  --

  -- Exceptions

  -- Exception Pragmas

  --
  -- PUBLIC FUNCTIONS
  --

  --
  -- Name
  --   get_phase
  -- Purpose
  --   Returns a translated phase description.
  --
  function get_phase (pcode  in char,
	              scode  in char,
		      hold   in char,
	              enbld  in char,
	              stdate in date,
		      rid    in number) return varchar2;

  pragma restrict_references (get_phase, WNDS);

  --
  -- Name
  --   get_sswa_status
  -- Purpose
  --   Returns a  status code for sswa.
  --
  function get_sswa_status (pcode  in char,
	               scode  in char,
		       hold   in char,
	               enbld  in char,
	               stdate in date,
		       rid    in number) return varchar2;

  pragma restrict_references (get_sswa_status, WNDS);

  --
  -- Name
  --   get_status
  -- Purpose
  --   Returns a translated status description for sswa.
  --
  function get_status (pcode  in char,
                       scode  in char,
                       hold   in char,
                       enbld  in char,
                       stdate in date,
                       rid    in number) return varchar2;

  pragma restrict_references (get_status, WNDS);

 --
  -- Name
  --   map_attr_to_arg
  -- Purpose
  --   Maps the application column name - attribute - in fnd_concurrent requests
  --   to the enabled arguments of the program's desc flexfield
  function map_attr_to_arg(attrno in number,
                           reqid in number) return varchar2;

  -- FUnction will return schedule description based on the schedule type
  -- This function is copied from FNDRSRUN form

  function get_sch_desc( request_id IN number) return varchar2;

  pragma restrict_references(get_sch_desc, WNDS);


  -- Function will return 'Y'/'N' value based on program has arguments defined
  -- or not.
  function program_has_args( program_name IN varchar2,
                             program_appl_id IN number) return varchar2;
  pragma restrict_references(program_has_args, WNDS);

  -- function will return elapsed time between two times in 'HH24:MI:SS' format
  -- First argument should be later time
  -- It returns varchar2
  function elapsed_time (end_time in date,
                         begin_time in date) return varchar2;
  pragma restrict_references(elapsed_time, WNDS);

  -- function will return notification list as concatinated string
  -- It returns varchar2(2000)
  function get_notifications(request_id in number) return varchar2;
  pragma restrict_references(get_notifications, WNDS);

  -- This function will return request diagnostics for a given request_id.
  -- This is a wrapper on top of fnd_conc.diagnose procedure.
  function diagnostics( request_id IN number ) return varchar2;
  --  pragma restrict_references(diagnostics, WNDS);

  -- This function will return Y/N based on the request outfile information
  -- and request status.

     function get_ofile_status(req_id  IN number) return varchar2;
     pragma restrict_references(get_ofile_status, WNDS);

  --
  -- Name
  --   layout_enabled
  -- Purpose
  --   Returns true if program contains any data definition in xml publisher
  --   schema.
  -- Arguments
  --   ProgramApplName - Concurrent Program Application Short Name
  --   ProgramShortName - Concurrent Program Short Name
  --
  function layout_enabled ( ProgramApplName  varchar2,
                            ProgramShortName varchar2) return boolean;

  --
  -- Name
  --   layout_enabled_YN
  -- Purpose
  --   calls layout_enabled but returns Y or N instead of boolean
  --   used for calling from C code
  --
 function layout_enabled_YN ( ProgramApplName varchar2,
                              ProgramShortName varchar2) return varchar2;

  --
  -- Name
  --   publisher_installed
  -- Purpose
  --   Returns true if xml publisher installed otherwise false
  -- Arguments
  --
  function publisher_installed  return boolean;
 end FND_CONC_SSWA;

/
