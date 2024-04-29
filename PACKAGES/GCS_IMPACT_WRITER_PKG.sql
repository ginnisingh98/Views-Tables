--------------------------------------------------------
--  DDL for Package GCS_IMPACT_WRITER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_IMPACT_WRITER_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsImpactWriters.pls 120.0 2006/04/24 05:54:07 gnayyar noship $ */

FUNCTION GDSD_UPDATE_IMPACT(p_subscription_guid   IN RAW,
                                               p_event IN OUT NOCOPY wf_event_t) return VARCHAR2;

END GCS_IMPACT_WRITER_PKG;

 

/
