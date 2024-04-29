--------------------------------------------------------
--  DDL for Package CSM_NOTES_TYPE_MAP_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_NOTES_TYPE_MAP_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmenmps.pls 120.0 2006/04/19 01:53 trajasek noship $ */

PROCEDURE REFRESH_ACC(p_status OUT NOCOPY VARCHAR2,
                                       p_message OUT NOCOPY VARCHAR2);

END CSM_NOTES_TYPE_MAP_EVENT_PKG;

 

/
