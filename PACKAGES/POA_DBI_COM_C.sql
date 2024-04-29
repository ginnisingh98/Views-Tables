--------------------------------------------------------
--  DDL for Package POA_DBI_COM_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_COM_C" AUTHID CURRENT_USER AS
/* $Header: poadbicomcrs.pls 120.2 2008/02/25 10:09:09 nchava noship $ */

/* ***************************************************************************
* Procedure Name  : proc_commodity_check                                    *
* Description     : Procedure to determine whether the commodity exists     *
*                   or not                                                  *
* File Name       : poadbicomcrs.pls                                        *
* Visibility      : Public                                                  *
* Parameters/Mode : None                                                    *
* History         : 15-Nov-2006 Ankit Goyal Initial Creation                *
*                                                                           *
*************************************************************************** */

PROCEDURE proc_commodity_check (errbuf          OUT NOCOPY VARCHAR2,
			retcode         OUT NOCOPY NUMBER);


/****************************************************************************
* Procedure Name  : proc_category_commodity_update                          *
* Description     : Procedureto to update the categories                    *
* File Name       : poadbicomcrs.pls                                        *
* Visibility      : Public                                                  *
* Parameters/Mode : None                                                    *
* History         : 14-Nov-2006 Ankit Goyal Initial Creation                *
*                                                                           *
****************************************************************************/

PROCEDURE proc_category_commodity_update(errbuf          OUT NOCOPY VARCHAR2,
			retcode         OUT NOCOPY NUMBER);

END POA_DBI_COM_C ;

/
