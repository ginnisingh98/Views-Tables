--------------------------------------------------------
--  DDL for Package OKE_K_SECURED_VIEWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_K_SECURED_VIEWS_PKG" AUTHID CURRENT_USER AS
/* $Header: OKEKSVS.pls 120.0.12000000.1 2007/01/17 06:50:26 appldev ship $ */

PROCEDURE Generate_Secured_Views
( ERRBUF                           OUT NOCOPY   VARCHAR2
, RETCODE                          OUT NOCOPY   NUMBER
);

END OKE_K_SECURED_VIEWS_PKG;

 

/
