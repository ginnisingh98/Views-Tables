--------------------------------------------------------
--  DDL for Package FND_CONC_PP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CONC_PP" AUTHID CURRENT_USER as
/* $Header: AFCPPPIS.pls 120.2 2005/08/22 06:53:57 aweisber ship $ */



-- Function
--   MESSAGE
--
-- Purpose
--   Return an error message.  Messages are set when
--   validation (program) errors occur.
--
FUNCTION message RETURN VARCHAR2;

--
-- Procedure
--   Assign
--
-- Purpose
--   Assign a stored procedure to a request.  Returns step number if successful,--   a negative number if not.
--
-- Arguments:
--   Application     - Application Short Name
--
--   Executable_Name	     - Executable Name
--
--   Req_ID	     - request ID
--
--   S_Flag	     - do we execute if request was successful? ['Y'/'N']
--
--   W_Flag	     - do we execute if request completed with status warning?
--			['Y'/'N']
--
--   F_Flag	     - do we execute if request failed? ['Y'/'N']
--
--   Arg1 ->  Arg10  - Arguments that may be retrieved during execution.
--
FUNCTION	Assign(	Application 	IN Varchar2,
			Executable_Name IN Varchar2,
			Req_ID		IN Number,
			S_Flag		IN Varchar2,
			W_Flag		IN Varchar2,
			F_Flag		IN Varchar2,
			Arg1		IN Varchar2,
			Arg2		IN Varchar2,
			Arg3		IN Varchar2,
			Arg4		IN Varchar2,
			Arg5		IN Varchar2,
			Arg6		IN Varchar2,
			Arg7		IN Varchar2,
			Arg8		IN Varchar2,
			Arg9		IN Varchar2,
			Arg10		IN Varchar2) return number;

--
-- Procedure
--  Retrieve
--
-- Purpose
--   Assign a stored procedure to a request.  Returns step number if successful,--   a negative number if not.
--
-- Arguments:
--   Req_ID	     - request ID
--
--   Step Number     - Step Number
--
--   Arg1 ->  Arg10  - Arguments that were set at assignment.
--
FUNCTION       Retrieve(Req_ID		IN Number,
			Step  		IN Number,
			App_short_name  OUT NOCOPY Varchar2,
			exec_name	OUT NOCOPY VARCHAR2,
			S_Flag          OUT NOCOPY Varchar2,
                        W_Flag          OUT NOCOPY Varchar2,
                        F_Flag          OUT NOCOPY Varchar2,
			Arg1		OUT NOCOPY Varchar2,
			Arg2		OUT NOCOPY Varchar2,
			Arg3		OUT NOCOPY Varchar2,
			Arg4		OUT NOCOPY Varchar2,
			Arg5		OUT NOCOPY Varchar2,
			Arg6		OUT NOCOPY Varchar2,
			Arg7		OUT NOCOPY Varchar2,
			Arg8		OUT NOCOPY Varchar2,
			Arg9		OUT NOCOPY Varchar2,
			Arg10		OUT NOCOPY Varchar2) return number;

end FND_CONC_PP;

 

/
