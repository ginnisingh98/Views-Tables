--------------------------------------------------------
--  DDL for Package GMD_ROUT_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_ROUT_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: GMDRTMGS.pls 115.4 2003/02/21 07:51:40 gmangari noship $  pxkumar */

  PROCEDURE INSERT_ROUT_STATUS;

  --BEGIN Bug#2200539 P.Raghu
  PROCEDURE INSERT_TRANSFER_PERCENT;
  --END Bug#2200539

end;

 

/
