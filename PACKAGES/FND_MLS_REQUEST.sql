--------------------------------------------------------
--  DDL for Package FND_MLS_REQUEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_MLS_REQUEST" AUTHID CURRENT_USER as
/* $Header: AFMLSUBS.pls 120.2.12010000.2 2014/06/30 19:25:54 ckclark ship $ */



 -- Name
 --  FNDMLSUB
 -- Purpose
 --  MLS master program. Submits all language requests.
  --
  -- Arguments
  --   errbuff  - Completion message.
  --   retcode  - 0 = Success, 1 = Waring, 2 = Failure
  --   appl_id  - Set Application ID
  --   prog_id  - Program ID
  --   use_func - Whether to use language function or not. ( 'Y'/'N' )


procedure FNDMLSUB  (errbuf            out nocopy varchar2,
                     retcode           out nocopy number,
                     appl_id           in number,
                     prog_id           in number,
		     use_func          in varchar2 default 'N');


 -- Name
 --  standard_languages
 -- Purpose
 --  It returns all the installed languages.
 --

function standard_languages return varchar2;

end FND_MLS_REQUEST;

/
