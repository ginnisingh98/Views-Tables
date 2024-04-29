--------------------------------------------------------
--  DDL for Package OZF_REFRESH_VIEW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_REFRESH_VIEW_PVT" AUTHID CURRENT_USER AS
/*$Header: ozfvrfes.pls 115.1 2004/01/19 01:13:32 jxwu noship $*/

G_PKG_NAME CONSTANT VARCHAR2(30) := 'ozf_refresh_view_pvt';

PROCEDURE load( ERRBUF                  OUT NOCOPY VARCHAR2,
                RETCODE                 OUT NOCOPY NUMBER,
		p_view_name             IN VARCHAR2);

END ozf_refresh_view_pvt;

 

/
