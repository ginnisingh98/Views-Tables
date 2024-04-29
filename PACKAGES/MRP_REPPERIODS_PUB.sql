--------------------------------------------------------
--  DDL for Package MRP_REPPERIODS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_REPPERIODS_PUB" AUTHID CURRENT_USER AS
/* $Header: MRPPRPDS.pls 115.0 99/07/16 12:34:29 porting ship $ */


PROCEDURE Maintain_Rep_Periods(
				arg_org_id      IN NUMBER,
				arg_user_id     IN NUMBER);

END MRP_RepPeriods_PUB;

 

/
