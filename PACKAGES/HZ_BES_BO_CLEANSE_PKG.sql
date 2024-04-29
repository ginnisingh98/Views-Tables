--------------------------------------------------------
--  DDL for Package HZ_BES_BO_CLEANSE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_BES_BO_CLEANSE_PKG" AUTHID CURRENT_USER AS
/* $Header: ARHBESCS.pls 120.2 2005/09/21 17:37:07 smattegu noship $ */

--------------------------------------
-- declaration of procedures and functions
--------------------------------------
/**
 * PROCEDURE cleanse_main
 *
 * DESCRIPTION
 *   Cleanse Infrastructure Program
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   OUT:
 *     Errbuf                   Error buffer
 *     Retcode                  Return code
 *
 * NOTES
 *
 */

PROCEDURE cleanse_main(
    Errbuf                      OUT NOCOPY     VARCHAR2,
    Retcode                     OUT NOCOPY     VARCHAR2
);

END HZ_BES_BO_CLEANSE_PKG;

 

/
