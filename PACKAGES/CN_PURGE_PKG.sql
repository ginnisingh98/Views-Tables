--------------------------------------------------------
--  DDL for Package CN_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PURGE_PKG" AUTHID CURRENT_USER AS
-- $Header: cnpurges.pls 115.4 2002/11/21 21:06:52 hlchen ship $

--
-- Package Body Name
--   cn_purge_pkg
-- Purpose
--
-- History
--
--  04/16/97  Xinyang Fan  Created

  --+
  -- Name
  --   purge
  -- Purpose
  --   +
  --
  -- History
  --+
  --   04/16/97 	Xinyang Fan		Created
  --   04/26/00     Vijay Pendyala      Modified
  --                                    As the parameter doesnot match with the
  --                                    concurrent request parameter list.


    PROCEDURE purge(errbuf OUT NOCOPY VARCHAR2,
		    retcode  OUT NOCOPY NUMBER,
		    x_start_period  IN varchar2,
		    x_end_period    IN varchar2,
		    x_salesrep_id IN number);

END cn_purge_pkg;

 

/
