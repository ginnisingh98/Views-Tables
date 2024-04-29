--------------------------------------------------------
--  DDL for Package CSTPPCAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPPCAT" AUTHID CURRENT_USER AS
/* $Header: CSTPPCAS.pls 115.3 2002/11/11 19:21:12 awwang ship $ */

PROCEDURE CSTPCCAT (
  I_INVENTORY_ITEM_ID    IN  NUMBER,
  I_ORGANIZATION_ID      IN  NUMBER,
  I_LAST_UPDATED_BY      IN  NUMBER,
  I_COST_TYPE_ID         IN  NUMBER,
  I_ITEM_TYPE            IN  NUMBER,
  I_LOT_SIZE             IN  NUMBER,
  I_SHRINKAGE_RATE       IN  NUMBER,

  O_RETURN_CODE          OUT NOCOPY NUMBER,
  O_RETURN_ERR           OUT NOCOPY VARCHAR2
);

End CSTPPCAT;

 

/
