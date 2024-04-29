--------------------------------------------------------
--  DDL for Package FV_GEN_ARTRX_REIMB_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_GEN_ARTRX_REIMB_PROC" AUTHID CURRENT_USER AS
-- $Header: FVGARTRS.pls 120.0.12010000.1 2009/06/17 17:23:59 bnarang noship $

PROCEDURE main
(p_errbuf    OUT NOCOPY VARCHAR2,
 p_retcode   OUT NOCOPY NUMBER,
 p_period_name IN VARCHAR2,
 p_invoice_date IN VARCHAR2);

END   FV_GEN_ARTRX_REIMB_PROC;

/
