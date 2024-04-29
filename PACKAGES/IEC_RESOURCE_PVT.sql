--------------------------------------------------------
--  DDL for Package IEC_RESOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_RESOURCE_PVT" AUTHID CURRENT_USER AS
/* $Header: IECVRESS.pls 115.6 2003/08/22 20:42:48 hhuang noship $ */

PROCEDURE CREATE_RESOURCE
   (X_RESOURCE_ID            OUT  NOCOPY JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE
   );
PROCEDURE GET_PRED_RES_ID
   (X_RESOURCE_ID            OUT  NOCOPY JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE
   );

END IEC_RESOURCE_PVT;


 

/
