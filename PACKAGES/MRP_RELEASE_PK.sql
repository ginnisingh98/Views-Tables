--------------------------------------------------------
--  DDL for Package MRP_RELEASE_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_RELEASE_PK" AUTHID CURRENT_USER AS
/* $Header: MRPARELS.pls 115.3 2002/11/29 11:55:19 rashteka ship $ */

PROCEDURE mrp_auto_release
                (errbuf			OUT NOCOPY VARCHAR2,  --2663505
		 retcode		OUT NOCOPY NUMBER,    --2663505
		 arg_org_id             IN  NUMBER,
                 arg_plan_name          IN  VARCHAR2,
		 arg_use_start_date     IN  VARCHAR2);

END mrp_release_pk;

 

/
