--------------------------------------------------------
--  DDL for Package JTY_COLLECTION_MIGRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTY_COLLECTION_MIGRATION_PKG" AUTHID CURRENT_USER AS
/* $Header: jtfcolms.pls 120.1 2006/09/11 21:26:25 mhtran noship $ */

--    Start of Comments

--    ---------------------------------------------------

--    PACKAGE NAME:   JTY_COLLECTION_MIGRATION_PKG

--    ---------------------------------------------------



--  PURPOSE

--      to migrate specific hierarchy to collection usage

--

--

--  PROCEDURES:

--       (see below for specification)

--

--

--  HISTORY

--    08/25/2006  MHTRAN          Package Body Created

--    End of Comments

--

PROCEDURE UPDATE_TERR_RECORD (
    x_errbuf            	  OUT NOCOPY VARCHAR2,
    x_retcode           	  OUT NOCOPY VARCHAR2,
    p_terr_id			  	  IN  NUMBER
);

END JTY_COLLECTION_MIGRATION_PKG;

 

/
