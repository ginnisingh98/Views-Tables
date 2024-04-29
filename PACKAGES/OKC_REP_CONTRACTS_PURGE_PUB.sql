--------------------------------------------------------
--  DDL for Package OKC_REP_CONTRACTS_PURGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_REP_CONTRACTS_PURGE_PUB" AUTHID CURRENT_USER AS
/*$Header: OKCREPPURGES.pls 120.0.12010000.1 2013/11/21 10:38:54 skavutha noship $*/

PROCEDURE purge_contracts(
  errbuf               OUT NOCOPY VARCHAR2,
  retcode              OUT NOCOPY VARCHAR2,
  p_org_id             IN NUMBER,
  p_start_date         IN VARCHAR2,
  p_end_date           IN VARCHAR2,
  p_terminated_yn      IN VARCHAR2,
  p_expired_yn         IN VARCHAR2,
  p_cancelled_yn       IN VARCHAR2,
  p_rejected_yn        IN VARCHAR2
  );

END okc_rep_contracts_purge_pub;

/
