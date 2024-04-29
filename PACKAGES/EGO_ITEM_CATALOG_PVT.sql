--------------------------------------------------------
--  DDL for Package EGO_ITEM_CATALOG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ITEM_CATALOG_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOVCAGS.pls 120.1 2005/06/29 00:25:58 lkapoor noship $ */

/* Private API for processing catalog groups
** Applications should not call this catalog group api directly.
** return_status: this is returned by the api to indicate the success/failure of the call
** msg_count: this is returned by the api to indicate the number of message logged for this
** call.
**
*/

Procedure Process_Catalog_Groups
(  x_return_status           OUT NOCOPY VARCHAR2
 , x_msg_count               OUT NOCOPY NUMBER
 );

END EGO_ITEM_CATALOG_PVT;

 

/
