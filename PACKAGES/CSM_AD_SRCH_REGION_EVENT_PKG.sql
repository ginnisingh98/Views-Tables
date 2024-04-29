--------------------------------------------------------
--  DDL for Package CSM_AD_SRCH_REGION_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_AD_SRCH_REGION_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmeasrs.pls 120.1 2008/01/16 11:52:07 mkosuri noship $ */
PROCEDURE REFRESH_ACC(p_status OUT NOCOPY VARCHAR2,p_message OUT NOCOPY VARCHAR2 );

END CSM_AD_SRCH_REGION_EVENT_PKG ;

/
