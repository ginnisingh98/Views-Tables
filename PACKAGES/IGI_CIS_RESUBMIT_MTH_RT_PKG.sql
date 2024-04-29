--------------------------------------------------------
--  DDL for Package IGI_CIS_RESUBMIT_MTH_RT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_CIS_RESUBMIT_MTH_RT_PKG" AUTHID CURRENT_USER AS
/*  $Header: igicisrsmrs.pls 120.0.12010000.2 2017/02/20 11:31:48 yanasing noship $ */
procedure main (
      errbuf OUT NOCOPY VARCHAR2,
      retcode OUT NOCOPY NUMBER,
      p_period_name IN varchar2,
      p_mode IN VARCHAR2 DEFAULT 'V');

END IGI_CIS_RESUBMIT_MTH_RT_PKG;

/
