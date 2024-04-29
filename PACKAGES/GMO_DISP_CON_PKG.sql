--------------------------------------------------------
--  DDL for Package GMO_DISP_CON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_DISP_CON_PKG" AUTHID CURRENT_USER  AS
/*$Header: GMOVDCPS.pls 120.1 2006/02/16 13:23 srpuri noship $*/

--This PL/SQL procedure is called through a concurrent program to generate the Dispense History XML.
PROCEDURE GENERATE_DISPHIST_XML(ERRBUF       OUT NOCOPY VARCHAR2,
                                RETCODE      OUT NOCOPY VARCHAR2,
                                Plant        IN         NUMBER,
                                SubInventory IN         VARCHAR2,
                                Batch        IN         NUMBER,
                                FromDate     IN         VARCHAR2,
                                ToDate       IN         VARCHAR2,
                                OperatorID   IN         VARCHAR2);


--This PL/SQL procedure is called through a concurrent program to generate the Dispense Dispatch XML.
PROCEDURE GENERATE_DISPDPCH_XML(ERRBUF       OUT NOCOPY VARCHAR2,
                                RETCODE      OUT NOCOPY VARCHAR2,
                                Plant        IN         NUMBER,
                                SubInventory IN         VARCHAR2,
                                Batch        IN         NUMBER,
                                FromDate     IN         VARCHAR2,
                                ToDate       IN         VARCHAR2);
FUNCTION GET_HAZARD_CLASS_NAME(P_INVENTORY_ITEM_ID NUMBER,
                          P_ORGANIZATION_ID NUMBER)
RETURN VARCHAR2;

      END GMO_DISP_CON_PKG;

 

/
