--------------------------------------------------------
--  DDL for Package CREATE_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CREATE_HISTORY" AUTHID CURRENT_USER as
/* $Header: GMPDPHSTS.pls 115.2 2003/01/30 17:28:27 rpatangy noship $ */

PROCEDURE shipment_history (
                        errbuf       OUT  NOCOPY VARCHAR2,
                        retcode      OUT  NOCOPY VARCHAR2,
                        p_sr_item_pk IN   VARCHAR2,
                        pfrom_date   IN   DATE,
                        pto_date     IN   DATE ,
                        pqty         IN   NUMBER ) ;


PROCEDURE booking_history (
                        errbuf       OUT  NOCOPY VARCHAR2,
                        retcode      OUT  NOCOPY VARCHAR2,
                        p_sr_item_pk IN   VARCHAR2,
                        pfrom_date   IN   DATE,
                        pto_date     IN   DATE ,
                        pqty         IN   NUMBER ) ;


END create_history ;

 

/
