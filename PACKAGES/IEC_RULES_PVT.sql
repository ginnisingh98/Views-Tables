--------------------------------------------------------
--  DDL for Package IEC_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_RULES_PVT" AUTHID CURRENT_USER AS
/* $Header: IECVRULS.pls 115.6 2003/08/22 20:42:55 hhuang ship $ */

 procedure  getWhereClause( ownerId IN number, ownerType IN varchar2, whereClause out NOCOPY varchar2);
 procedure  getAMSView( listHeaderId IN number, viewName out NOCOPY varchar2);
END IEC_RULES_PVT;


 

/
