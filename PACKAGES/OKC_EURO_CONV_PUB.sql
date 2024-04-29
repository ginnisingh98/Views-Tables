--------------------------------------------------------
--  DDL for Package OKC_EURO_CONV_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_EURO_CONV_PUB" AUTHID CURRENT_USER as
/* $Header: OKCPEURS.pls 120.1.12010000.2 2008/11/12 15:41:35 vgujarat ship $ */

PROCEDURE CONVERT_CONTRACTS (
 errbuf     OUT NOCOPY VARCHAR2,
 retcode    OUT NOCOPY VARCHAR2,
 p_org_id      NUMBER,
 p_conversion_type   VARCHAR2,
 p_conversion_date  VARCHAR2,
 p_update_yn VARCHAR2 );

end OKC_EURO_CONV_PUB;

/
