--------------------------------------------------------
--  DDL for Package PMI_LOT_GENEALOGY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PMI_LOT_GENEALOGY_PKG" AUTHID CURRENT_USER AS
/* $Header: PMILTGES.pls 115.6 2002/12/05 17:01:23 skarimis ship $ */

PROCEDURE refresh_lot_genealogy(errbuf OUT NOCOPY varchar2,retcode OUT NOCOPY VARCHAR2);

END;

 

/
