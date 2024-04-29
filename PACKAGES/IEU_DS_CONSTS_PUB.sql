--------------------------------------------------------
--  DDL for Package IEU_DS_CONSTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_DS_CONSTS_PUB" AUTHID CURRENT_USER AS
/* $Header: IEUDSCTS.pls 120.0 2005/06/02 16:02:42 appldev noship $ */



  G_DS_NONE              NUMBER := 1;
  G_DS_OK                NUMBER := 2;
  G_DS_OK_CANCEL         NUMBER := 3;
  G_DS_IGNORE_CANCEL     NUMBER := 4;
  G_DS_CONTINUE_CANCEL   NUMBER := 5;
  G_DS_RETRY_CANCEL      NUMBER := 6;


END IEU_DS_CONSTS_PUB;
 

/
