--------------------------------------------------------
--  DDL for Package Body IEC_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_RULES_PVT" AS
/* $Header: IECVRULB.pls 115.5 2003/08/22 20:42:54 hhuang ship $ */

 procedure getWhereClause( ownerId IN number, ownerType IN varchar2, whereClause out NOCOPY varchar2 )
 as language java
 name 'oracle.apps.iec.storedproc.algorithms.AlgWrapSPUJ.getRule(long, java.lang.String, java.lang.String[])';

 procedure getAMSView( listHeaderId IN number, viewName out NOCOPY varchar2 )
 as language java
 name 'oracle.apps.iec.storedproc.algorithms.AlgWrapSPUJ.getView(long, java.lang.String[])';
END IEC_RULES_PVT;


/
