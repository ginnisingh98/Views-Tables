--------------------------------------------------------
--  DDL for Package OKS_USAGE_SETTLE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_USAGE_SETTLE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPSTLS.pls 120.0 2005/05/25 18:13:58 appldev noship $ */

PROCEDURE Calculate_Settlement
 (
  ERRBUF               OUT      NOCOPY VARCHAR2,
  RETCODE              OUT      NOCOPY NUMBER,
  P_DNZ_CHR_ID          IN             NUMBER
 );


END;

 

/
