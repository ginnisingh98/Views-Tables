--------------------------------------------------------
--  DDL for Package FLM_KANBAN_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FLM_KANBAN_PURGE" AUTHID CURRENT_USER AS
/* $Header: FLMCPPKS.pls 115.4 2002/11/27 10:59:10 nrajpal noship $ */

SYS_YES                  CONSTANT NUMBER := 1;
SYS_NO                   CONSTANT NUMBER := 2;

G_ZERO                   CONSTANT NUMBER := 0;

G_SUCCESS                CONSTANT NUMBER := 0;
G_WARNING                CONSTANT NUMBER := 1;
G_ERROR                  CONSTANT NUMBER := 2;


G_KANBAN_CARD            CONSTANT NUMBER := 1;
G_PULL_SEQUENCE          CONSTANT NUMBER := 2;
G_EXCEPTION              CONSTANT NUMBER := 3;

G_BATCH                  CONSTANT NUMBER := 500;

G_CANCELLED_CARDS_ONLY   CONSTANT NUMBER := 1;
G_CANCELLED_AND_NEW      CONSTANT NUMBER := 2;

PROCEDURE PURGE_KANBAN_CARDS (
                    arg_pull_seq_id       in     number,
                    arg_org_id            in     number,
                    arg_item_id           in     number,
                    arg_subinv            in     varchar2,
                    arg_loc_id            in     number,
                    arg_delete_card       in     number,
                    arg_group_id          in     number,
                    retcode              out     NOCOPY	number,
                    errbuf               out     NOCOPY	varchar2
);

PROCEDURE CHECK_RESTRICTIONS (
                    arg_pull_seq_id       in     number,
                    arg_org_id            in     number,
                    arg_item_id           in     number,
                    arg_subinv            in     varchar2,
                    arg_loc_id            in     number,
                    arg_group_id          in     number,
                    retcode              out     NOCOPY	number,
                    errbuf               out     NOCOPY	varchar2
);

PROCEDURE PURGE_KANBAN (
                    errbuf               out     NOCOPY	varchar2,
                    retcode              out     NOCOPY	number,
                    arg_group_id          in     number,
                    arg_org_id            in     number,
                    arg_item_from         in     varchar2,
                    arg_item_to           in     varchar2,
                    arg_subinv_from       in     varchar2,
                    arg_subinv_to         in     varchar2,
                    arg_source_type       in     number,
                    arg_line_id           in     number,
                    arg_supplier_id       in     number,
                    arg_source_org_id     in     number,
                    arg_source_subinv     in     varchar2,
                    arg_delete_card       in     number
);

END FLM_KANBAN_PURGE;

 

/
