--------------------------------------------------------
--  DDL for Package RCV_DEFAULT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_DEFAULT_PKG" AUTHID CURRENT_USER AS
/* $Header: RCVDFLTS.pls 120.1.12010000.1 2008/07/24 14:35:16 appldev ship $*/
   PROCEDURE default_header(
      rhi IN OUT NOCOPY rcv_headers_interface%ROWTYPE
   );

   PROCEDURE default_transaction(
      rti IN OUT NOCOPY rcv_transactions_interface%ROWTYPE
   );

   PROCEDURE default_from_parent(
      rti IN OUT NOCOPY rcv_transactions_interface%ROWTYPE
   );
END rcv_default_pkg;

/
