--------------------------------------------------------
--  DDL for Package CSTPACOV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPACOV" AUTHID CURRENT_USER AS
/* $Header: CSTACOVS.pls 115.4 2002/11/08 01:09:19 awwang ship $ */

PROCEDURE ins_overhead(
   I_INVENTORY_ITEM_ID    IN  NUMBER,
   I_ORGANIZATION_ID      IN  NUMBER,
   I_LAST_UPDATED_BY      IN  NUMBER,
   I_COST_TYPE_ID         IN  NUMBER,
   I_ITEM_TYPE            IN  NUMBER,
   I_LOT_SIZE             IN  NUMBER,
   I_SHRINKAGE_RATE       IN  NUMBER,

   O_RETURN_CODE          OUT NOCOPY NUMBER,
   O_RETURN_ERR           OUT NOCOPY VARCHAR2);

END CSTPACOV;


 

/
