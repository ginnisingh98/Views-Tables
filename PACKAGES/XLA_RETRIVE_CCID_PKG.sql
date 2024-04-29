--------------------------------------------------------
--  DDL for Package XLA_RETRIVE_CCID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_RETRIVE_CCID_PKG" AUTHID CURRENT_USER AS
/* $Header: xlarccid.pkh 120.1.12010000.2 2009/08/05 12:40:07 karamakr noship $
===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_retrive_ccid_pkg                                                   |
|                                                                            |
| DESCRIPTION                                                                |
|     Package specification for the Retrive CCID's Program.                  |
|                                                                            |
| HISTORY                                                                    |
|     04/08/2008    T.Venkata Vamsi Krishna    Created                             |
|                                                                            |
+===========================================================================*/
   TYPE t_array_number IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   TYPE t_array_ccid IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   PROCEDURE get_ccid_information (
      errbuf                OUT NOCOPY      VARCHAR2,
      retcode               OUT NOCOPY     VARCHAR2,
      p_application_id      IN       NUMBER,
      p_acc_batch_id        IN       NUMBER,
      p_ledger_id           IN       NUMBER,
      p_parent_request_id   IN       NUMBER
   );

   PROCEDURE get_thread_ccid_inf (
      p_min_num             IN       NUMBER,
      p_max_num             IN       NUMBER,
      p_out_ccid            OUT NOCOPY     t_xla_array_ccid_inf,
      p_application_id      IN       NUMBER,
      p_acc_batch_id        IN       NUMBER,
      p_ledger_id           IN       NUMBER,
      p_parent_request_id   IN       NUMBER
   );

   PROCEDURE get_ccid_seq (
      p_coa_num        IN       NUMBER,
      p_ccid_seq_out   OUT   NOCOPY    t_xla_array_ccid_seq_inf
   );

   PROCEDURE collect_ccid_inf (
      p_application_id       IN   NUMBER,
      p_acc_batch_id         IN   NUMBER,
      p_ledger_id            IN   NUMBER,
      p_parent_request_id    IN   NUMBER,
      p_parallel_processes   IN   NUMBER
   );

   PROCEDURE update_ccid_inf (
         p_parent_request_id   IN              NUMBER,
         p_from_ccid           OUT NOCOPY      NUMBER,
         p_to_ccid             OUT NOCOPY      NUMBER,
         p_ledger_id           OUT NOCOPY      NUMBER
   );
END xla_retrive_ccid_pkg;

/
