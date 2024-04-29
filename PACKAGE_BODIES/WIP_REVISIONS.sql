--------------------------------------------------------
--  DDL for Package Body WIP_REVISIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_REVISIONS" AS
/* $Header: wiprvdfb.pls 115.7 2003/10/01 00:30:31 rseela ship $ */

PROCEDURE Bom_Revision(P_Organization_Id IN NUMBER,
		     P_Item_Id IN NUMBER,
		     P_Revision IN OUT NOCOPY VARCHAR2,
		     P_Revision_Date IN OUT NOCOPY DATE,
		     P_Start_Date IN DATE) IS

x_released_revs_type	NUMBER;
x_released_revs_meaning	Varchar2(30);

BEGIN

	If P_Item_Id IS NULL THEN
		P_Revision_Date := '';
		P_Revision := '';
		return;
	END IF;

	IF P_Revision_Date IS NULL AND P_Revision IS NULL THEN
		P_Revision_Date := P_Start_Date;
	END IF;

	wip_common.Get_Released_Revs_Type_Meaning (x_released_revs_type,
                                                   x_released_revs_meaning
                                                  );

	IF P_Revision_Date IS NOT NULL THEN
               BOM_REVISIONS.Get_Revision
                (type => 'PART',
                 eco_status => x_released_revs_meaning,
                 examine_type => 'ALL',
                 org_id => P_Organization_Id,
                 item_id => P_item_id,
                 rev_date => P_Revision_Date,
                 itm_rev => P_Revision);
	ELSE
               BOM_REVISIONS.Get_High_Date
                (type => 'PART',
                 eco_status => x_released_revs_meaning,
                 org_id => P_Organization_Id,
                 item_id => P_item_id,
		 itm_rev =>P_Revision,
                 rev_date => P_Revision_Date);
	END IF;

END Bom_Revision;

PROCEDURE Routing_Revision(P_Organization_Id IN NUMBER,
		     P_Item_Id IN NUMBER,
		     P_Revision IN OUT NOCOPY VARCHAR2,
		     P_Revision_Date IN OUT NOCOPY DATE,
		     P_Start_Date IN DATE) IS

x_released_revs_type	NUMBER;
x_released_revs_meaning	Varchar(30);

BEGIN

	If P_Item_Id IS NULL THEN
		P_Revision_Date := '';
		P_Revision := '';
		return;
	END IF;

	IF P_Revision_Date IS NULL AND P_Revision IS NULL THEN
		P_Revision_Date := P_Start_Date;
	END IF;
        wip_common.Get_Released_Revs_Type_Meaning (x_released_revs_type,
                                                   x_released_revs_meaning
                                                  );

	IF P_Revision_Date IS NOT NULL THEN
               BOM_REVISIONS.Get_Revision
                (type => 'PROCESS',
                 eco_status => x_released_revs_meaning,
                 examine_type => 'ALL',
                 org_id => P_Organization_Id,
                 item_id => P_item_id,
                 rev_date => P_Revision_Date,
                 itm_rev => P_Revision);
	ELSE
               BOM_REVISIONS.Get_High_Date
                (type => 'PROCESS',
                 eco_status => x_released_revs_meaning,
                 org_id => P_Organization_Id,
                 item_id => P_item_id,
		 itm_rev =>P_Revision,
                 rev_date => P_Revision_Date);
	END IF;

END Routing_Revision;

END WIP_REVISIONS;

/
