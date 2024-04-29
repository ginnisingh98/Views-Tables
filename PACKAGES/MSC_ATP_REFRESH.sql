--------------------------------------------------------
--  DDL for Package MSC_ATP_REFRESH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ATP_REFRESH" AUTHID CURRENT_USER AS
/* $Header: MSCATPRS.pls 120.1.12010000.1 2010/03/17 20:54:14 hulu noship $ */





--================ Refresh ATP Snapshot ==================

procedure RefreshATPSnapshot (	userId IN NUMBER,
                     		respId IN NUMBER,
                     		appId IN NUMBER);

END  MSC_ATP_REFRESH;

/
