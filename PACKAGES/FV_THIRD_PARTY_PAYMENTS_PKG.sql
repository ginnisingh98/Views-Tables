--------------------------------------------------------
--  DDL for Package FV_THIRD_PARTY_PAYMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_THIRD_PARTY_PAYMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: FVTPPPRS.pls 120.0 2003/09/15 21:37:30 snama noship $ */

PROCEDURE MAIN (x_errbuf        OUT NOCOPY VARCHAR2,
	        x_retcode       OUT NOCOPY NUMBER,
	        p_checkrun_name            VARCHAR2);

END FV_THIRD_PARTY_PAYMENTS_PKG;

 

/
