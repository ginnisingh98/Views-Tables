--------------------------------------------------------
--  DDL for Package CTO_ORDER_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_ORDER_PURGE" AUTHID CURRENT_USER as
/* $Header: CTOPURGS.pls 120.1 2005/06/06 10:07:54 appldev  $ */
/*
 *=========================================================================*
 |                                                                         |
 | Copyright (c) 2001, Oracle Corporation, Redwood Shores, California, USA |
 |                           All rights reserved.                          |
 |                                                                         |
 *=========================================================================*
 |                                                                         |
 | NAME                                                                    |
 |            CTO ORDER PURGE package spec                                 |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   PL/SQL package spec containing the spec deletion routine  for         |
 |   purging the data in CTO tables which were inserted during             |
 |   creation of orders                                                    |
 | ARGUMENTS                                                               |
 |   Input :  Please see the individual function or procedure.             |
 |                                                                         |
 | HISTORY                                                                 |
 |   Date      Author   Comments                                           |
 | --------- -------- ---------------------------------------------------- |
 |  05/09/2001  kkonada  intial creation of spec for cto table purge	   |
 |  06/01/2005  rekannan Added nocopy hint to out parameters
 *=========================================================================*/

PROCEDURE cto_purge_tables
          ( p_header_id       IN NUMBER,
            x_error_msg       OUT NOCOPY VARCHAR2,
            x_return_status   OUT NOCOPY VARCHAR2
           );

END CTO_ORDER_PURGE;

 

/
