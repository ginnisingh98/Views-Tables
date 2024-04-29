--------------------------------------------------------
--  DDL for Package MSC_REPPERIODS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_REPPERIODS_PUB" AUTHID CURRENT_USER AS
/* $Header: MSCPRPDS.pls 120.0 2005/05/25 20:05:16 appldev noship $ */


PROCEDURE Maintain_Rep_Periods(
				arg_org_id      IN NUMBER,
				arg_instance_id      IN NUMBER,
				arg_user_id     IN NUMBER);

END MSC_RepPeriods_PUB;

 

/
