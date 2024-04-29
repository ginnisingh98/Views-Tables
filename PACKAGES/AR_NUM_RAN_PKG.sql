--------------------------------------------------------
--  DDL for Package AR_NUM_RAN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_NUM_RAN_PKG" AUTHID CURRENT_USER AS
/* $Header: ARPEXTUS.pls 120.0 2005/03/15 00:44:18 hyu noship $ */
  g_num_max    NUMBER  := -1;
  FUNCTION     num_random RETURN NUMBER;
END;

 

/
