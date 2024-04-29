--------------------------------------------------------
--  DDL for Package WMA_RSC_CHRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMA_RSC_CHRG" AUTHID CURRENT_USER AS
/* $Header: wmafcus.pls 115.2 2002/12/13 07:52:57 rmahidha noship $ */

  function Charge_Resource_Overhead (p_header_id IN NUMBER) return boolean;
end wma_rsc_chrg;

 

/
