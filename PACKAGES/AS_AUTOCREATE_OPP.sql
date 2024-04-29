--------------------------------------------------------
--  DDL for Package AS_AUTOCREATE_OPP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_AUTOCREATE_OPP" AUTHID CURRENT_USER as
/* $Header: asxldops.pls 120.1 2005/06/05 22:52:14 appldev  $ */

-- Start of Comments
-- Package name     : AS_AUTOCREATE_OPP
-- Purpose          : Create opportunity records from sales lead tables
-- History          : 08/02/00 FFANG  Created.
-- NOTE             :
-- End of Comments
--

Procedure Create_Opp_from_Sales_lead(
		   ERRBUF OUT NOCOPY /* file.sql.39 change */ varchar2,
		   RETCODE OUT NOCOPY /* file.sql.39 change */ varchar2,
		   p_debug_mode IN  VARCHAR2,
		   p_trace_mode IN  VARCHAR2);


END AS_AUTOCREATE_OPP;

 

/
