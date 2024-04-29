--------------------------------------------------------
--  DDL for Package IEM_RESOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_RESOURCE_PVT" AUTHID CURRENT_USER AS
/* $Header: iemvress.pls 115.1 2002/12/07 02:09:17 liangxia noship $ */

PROCEDURE CREATE_RESOURCE
   (X_RESOURCE_ID            OUT NOCOPY JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE
   );
PROCEDURE GET_PRED_RES_ID
   (X_RESOURCE_ID            OUT NOCOPY JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE
   );

END IEM_RESOURCE_PVT;


 

/
