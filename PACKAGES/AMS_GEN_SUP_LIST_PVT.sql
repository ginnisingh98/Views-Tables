--------------------------------------------------------
--  DDL for Package AMS_GEN_SUP_LIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_GEN_SUP_LIST_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvspls.pls 115.4 2002/11/22 08:56:21 jieli ship $ */

-----------------------------------------------------------
-- PACKAGE
--    AMS_Gen_Sup_List_PVT
--
-- PURPOSE
--    Private API for Oracle Marketing Party Sources.
--
-- PROCEDURES

--Schedule_Suppression_List

--------------------------------------------------------------------
-- PROCEDURE
--    Schedule_Suppression_List
-- PURPOSE
--    Used as a concurrent program to schedule generation of all
--    suppression lists in the system
--------------------------------------------------------------------
PROCEDURE Schedule_Suppression_List(
   errbuf                  OUT NOCOPY   VARCHAR2,
   retcode                 OUT NOCOPY   NUMBER
);


END AMS_Gen_Sup_List_PVT;

 

/
