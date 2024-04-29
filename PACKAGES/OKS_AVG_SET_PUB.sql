--------------------------------------------------------
--  DDL for Package OKS_AVG_SET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_AVG_SET_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPAVGS.pls 120.0 2005/05/25 17:42:18 appldev noship $ */

PROCEDURE	Average_Main
 (
  ERRBUF			OUT NOCOPY  VARCHAR2,
  RETCODE			OUT NOCOPY  NUMBER,
  P_CONTRACT_ID  	        IN          NUMBER
 );


END OKS_AVG_SET_PUB;

 

/
