--------------------------------------------------------
--  DDL for Package Body IBU_INIT_QUEUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBU_INIT_QUEUE" as
/* $Header: ibucpkgb.pls 115.3 2003/02/21 01:57:33 nazhou ship $ */

begin
	ibu_init_queue.queue_name := 'IBU.ibu_queue';
	ibu_init_queue.queue_table_name := 'IBU.ibu_subs_table';
end ibu_init_queue;

/
