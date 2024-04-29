--------------------------------------------------------
--  DDL for Package CSM_CUSTOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_CUSTOM_PKG" 
/* $Header: csmecuss.pls 120.1 2005/07/24 22:56:15 trajasek noship $*/
  AUTHID CURRENT_USER AS
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person       Date       Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

PROCEDURE counter_values_del(p_counter_value_id in number, x_return_status OUT NOCOPY varchar2);

END CSM_CUSTOM_PKG;

 

/
