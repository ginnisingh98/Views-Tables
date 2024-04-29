--------------------------------------------------------
--  DDL for Package CSM_PAGE_PERZ_DELTA_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_PAGE_PERZ_DELTA_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmeppds.pls 120.0.12010000.2 2008/10/22 11:03:10 trajasek ship $ */

PROCEDURE REFRESH_PAGE_PERZ_DELTA(p_status OUT NOCOPY VARCHAR2,
                                       p_message OUT NOCOPY VARCHAR2);
--Bug 7239431
PROCEDURE REFRESH_USER(p_user_id NUMBER);

END CSM_PAGE_PERZ_DELTA_EVENT_PKG;

/
