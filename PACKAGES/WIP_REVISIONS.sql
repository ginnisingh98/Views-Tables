--------------------------------------------------------
--  DDL for Package WIP_REVISIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_REVISIONS" AUTHID CURRENT_USER AS
/* $Header: wiprvdfs.pls 115.6 2002/11/29 14:45:24 simishra ship $ */

PROCEDURE Bom_Revision(P_Organization_Id IN NUMBER,
		     P_Item_Id IN NUMBER,
		     P_Revision IN OUT NOCOPY VARCHAR2,
		     P_Revision_Date IN OUT NOCOPY DATE,
		     P_Start_Date IN DATE) ;

PROCEDURE Routing_Revision(P_Organization_Id IN NUMBER,
		     P_Item_Id IN NUMBER,
		     P_Revision IN OUT NOCOPY VARCHAR2,
		     P_Revision_Date IN OUT NOCOPY DATE,
		     P_Start_Date IN DATE) ;

END WIP_REVISIONS;

 

/
