--------------------------------------------------------
--  DDL for Package CSTPIDIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPIDIC" AUTHID CURRENT_USER AS
/* $Header: CSTIDIOS.pls 115.3 2002/11/08 21:01:05 awwang ship $ */
PROCEDURE CSTPIDIO (

   I_INVENTORY_ITEM_ID    IN  NUMBER,
   I_ORGANIZATION_ID      IN  NUMBER,
   I_LAST_UPDATED_BY      IN  NUMBER,
   I_COST_TYPE_ID         IN  NUMBER,
   I_ITEM_TYPE            IN  NUMBER,
   I_LOT_SIZE             IN  NUMBER,
   I_SHRINKAGE_RATE       IN  NUMBER,

   O_RETURN_CODE          OUT NOCOPY NUMBER,
   O_RETURN_ERR           OUT NOCOPY VARCHAR2) ;

END CSTPIDIC;

 

/
