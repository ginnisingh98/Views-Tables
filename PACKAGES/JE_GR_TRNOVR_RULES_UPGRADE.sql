--------------------------------------------------------
--  DDL for Package JE_GR_TRNOVR_RULES_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_GR_TRNOVR_RULES_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: jegrupgs.pls 120.1 2006/05/11 08:31:05 rjreddy noship $ */

PROCEDURE upgrade_main (errbuf OUT NOCOPY varchar2,
                        retcode OUT NOCOPY number);

END je_gr_trnovr_rules_upgrade;


 

/
