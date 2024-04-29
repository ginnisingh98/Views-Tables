--------------------------------------------------------
--  DDL for Package FLM_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FLM_PURGE" AUTHID CURRENT_USER AS
/* $Header: FLMCPPGS.pls 115.6 2003/08/13 06:48:58 nrajpal noship $ */

SYS_YES                  CONSTANT NUMBER := 1;
SYS_NO                   CONSTANT NUMBER := 2;

G_ZERO                   CONSTANT NUMBER := 0;
G_BATCH                  CONSTANT NUMBER := 500;
G_CLOSED_STATUS          CONSTANT NUMBER := 2;

G_DEBUG                          BOOLEAN := FALSE;
G_SUCCESS                CONSTANT NUMBER := 0;
G_WARNING                CONSTANT NUMBER := 1;
G_ERROR                  CONSTANT NUMBER := 2;


PROCEDURE VERIFY_FOREIGN_KEYS(
                    arg_wip_entity_id   in      NUMBER,
                    arg_org_id          in      NUMBER,
                    arg_item_id         in      NUMBER,
                    arg_table_name      out     NOCOPY  VARCHAR2,
                    arg_return_value    out     NOCOPY  NUMBER,
                    errbuf              out     NOCOPY  VARCHAR2
);

/* Added for Enhancement #2829204
   Added arg_auto_replenish parameter, to delink the Kanban Card Activity
   with the flow schedule, for flow schedules which has auto_replenish = 'Y' */
PROCEDURE DELETE_TABLES(
                    arg_wip_entity_id   in      NUMBER,
                    arg_org_id          in      NUMBER,
		    arg_auto_replenish  in      VARCHAR2,
                    arg_return_value    out     NOCOPY  NUMBER,
                    errbuf              out     NOCOPY  VARCHAR2
);

/* Added arg_purge_option argument for deleting from wip_transactions
and wip_transaction_accounts tables only */
PROCEDURE PURGE_SCHEDULES(
                    errbuf               out     NOCOPY varchar2,
                    retcode              out     NOCOPY number,
                    arg_org_id           in      number,
                    arg_cutoff_date      in      varchar2,
                    arg_line             in      VARCHAR2,
                    arg_assembly         in      VARCHAR2,
                    arg_purge_option     in      number
);
END FLM_PURGE;

 

/
