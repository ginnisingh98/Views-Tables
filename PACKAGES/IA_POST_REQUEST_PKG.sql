--------------------------------------------------------
--  DDL for Package IA_POST_REQUEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IA_POST_REQUEST_PKG" AUTHID CURRENT_USER AS
/* $Header: IAPREQS.pls 120.0.12010000.1 2008/07/24 09:53:37 appldev ship $   */



PROCEDURE post_transfer (
     errbuf                  OUT NOCOPY     VARCHAR2,
     retcode                 OUT NOCOPY     NUMBER,
     p_book_type_code        IN      VARCHAR2
);

END IA_POST_REQUEST_PKG;

/
