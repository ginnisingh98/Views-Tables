--------------------------------------------------------
--  DDL for Package POA_EUL_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_EUL_UTILS" AUTHID CURRENT_USER AS
/* $Header: POAEULS.pls 120.0 2005/06/01 14:20:08 appldev noship $ */

 PROCEDURE EULMain (Errbuf         IN OUT NOCOPY VARCHAR2,
                    Retcode        IN OUT NOCOPY VARCHAR2,
                    pEulOwnerName  IN     VARCHAR2,
                    pBusAreaName   IN     VARCHAR2
                              DEFAULT 'Purchasing Intelligence Business Area',
                    pDiscoVersion  IN     VARCHAR2 DEFAULT 'DISCO4I');

END POA_EUL_UTILS;

 

/
