--------------------------------------------------------
--  DDL for Package ISC_DBI_BOOK_SUM2_REF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_BOOK_SUM2_REF_PKG" AUTHID CURRENT_USER AS
/* $Header: ISCRF70S.pls 115.9 2003/11/25 22:19:46 mbourget ship $ */

PROCEDURE refresh_past_due(errbuf                  IN OUT NOCOPY  VARCHAR2,
                           retcode                 IN OUT NOCOPY  VARCHAR2);
PROCEDURE refresh_past_due2(errbuf                  IN OUT NOCOPY  VARCHAR2,
                           retcode                 IN OUT NOCOPY  VARCHAR2);
PROCEDURE refresh_backorder(errbuf                  IN OUT NOCOPY  VARCHAR2,
                           retcode                 IN OUT NOCOPY  VARCHAR2);

END isc_dbi_book_sum2_ref_pkg;

 

/
