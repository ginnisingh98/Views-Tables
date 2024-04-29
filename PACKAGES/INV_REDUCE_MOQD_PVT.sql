--------------------------------------------------------
--  DDL for Package INV_REDUCE_MOQD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_REDUCE_MOQD_PVT" AUTHID CURRENT_USER AS
/* $Header: INVRMOQS.pls 120.1 2006/04/20 05:06:58 salagars noship $ */
   -----------------------------------------------------------------------
   -- Name : consolidate_moqd
   -- Desc : Consolidate Onhand quantities for a particular Org
   --
   -- I/P params :
   --    P_ORG_ID          : Org Id
   -----------------------------------------------------------------------

    PROCEDURE consolidate_moqd(
        ERRBUF OUT NOCOPY VARCHAR2 ,
        RETCODE OUT NOCOPY NUMBER ,
        P_ORG_ID IN NUMBER )
 ;

 END INV_REDUCE_MOQD_PVT;

 

/
