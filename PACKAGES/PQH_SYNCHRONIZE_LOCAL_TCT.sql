--------------------------------------------------------
--  DDL for Package PQH_SYNCHRONIZE_LOCAL_TCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_SYNCHRONIZE_LOCAL_TCT" AUTHID CURRENT_USER as
/* $Header: pqtatlcp.pkh 115.0 2003/03/21 17:08:33 srajakum noship $ */
--
--
Procedure copy_global_attr_to_local(errbuf       out nocopy varchar2
                                  , retcode      out nocopy number
                                  , p_short_name in varchar2);
--
END;

 

/
