--------------------------------------------------------
--  DDL for Package QP_AGRUPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_AGRUPGRADE" AUTHID CURRENT_USER AS
/* $Header: QPXUPAGS.pls 120.0 2005/06/02 00:16:40 appldev noship $ */

   l_num NUMBER;
   G_LIST_TYPE_CODE                 CONSTANT VARCHAR2(3) := 'AGR';

  PROCEDURE Copy_Agreement(l_worker IN NUMBER := 1);
  PROCEDURE Create_Parallel_Slabs(l_workers IN NUMBER);

END QP_AgrUpgrade;


 

/
