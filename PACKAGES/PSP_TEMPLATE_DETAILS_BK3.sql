--------------------------------------------------------
--  DDL for Package PSP_TEMPLATE_DETAILS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_TEMPLATE_DETAILS_BK3" AUTHID CURRENT_USER as
/* $Header: PSPRDAIS.pls 120.0 2005/06/02 15:56:46 appldev noship $ */

--
-- ----------------------------------------------------------------------------
-- |------------------------- DELETE_TEMPLATE_DETAILS_b -------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_TEMPLATE_DETAILS_B
  (P_TEMPLATE_DETAIL_ID             in        NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------- DELETE_TEMPLATE_DETAILS_a -------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_TEMPLATE_DETAILS_A
  (P_TEMPLATE_DETAIL_ID             in        NUMBER
  ,P_OBJECT_VERSION_NUMBER            in   number
  ,P_WARNING                          in  varchar2
  );
end PSP_TEMPLATE_DETAILS_BK3;

 

/
