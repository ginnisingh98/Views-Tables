--------------------------------------------------------
--  DDL for Package ARP_CMERGE_ARCUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CMERGE_ARCUS" AUTHID CURRENT_USER AS
/* $Header: ARHCMGNS.pls 115.3 2002/12/19 14:08:19 sponnamb noship $ */

  g_table_name               CONSTANT VARCHAR2(30) :=
                                   'HZ_CMERGE_TEMP';
  PROCEDURE merge (
         req_id                    NUMBER,
         set_num                   NUMBER,
         process_mode              VARCHAR2 );

  --create sites where 'create same site' option has been checked
  procedure create_same_sites (
            req_id                 NUMBER,
            set_num                NUMBER,
            status             OUT NOCOPY NUMBER );

  --create global temporary table.
  PROCEDURE create_temporary_table;

  --physically delete rows in customer tables after merging each set.
  PROCEDURE delete_rows (
         req_id                    NUMBER,
         set_num                   NUMBER );

   PROCEDURE merge_history(req_id  NUMBER,
                           set_num NUMBER,
                           status  OUT NOCOPY NUMBER);

END ARP_CMERGE_ARCUS;

 

/
