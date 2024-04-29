--------------------------------------------------------
--  DDL for Package PSA_GVTMB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_GVTMB" AUTHID CURRENT_USER AS
/* $Header: psagvtms.pls 120.0.12010000.2 2009/05/14 16:20:46 cjain noship $ */
  PROCEDURE main
  (
    p_errbuf  OUT NOCOPY VARCHAR2,
    p_retcode OUT NOCOPY NUMBER
  );
END psa_gvtmb;

/
