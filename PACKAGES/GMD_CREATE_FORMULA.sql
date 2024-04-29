--------------------------------------------------------
--  DDL for Package GMD_CREATE_FORMULA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_CREATE_FORMULA" AUTHID CURRENT_USER AS
/* $Header: GMDPCFMS.pls 120.1 2005/09/23 06:48:40 txdaniel noship $ */
	-- Has only one procedure which is a
	-- wrapper procedure that call the
	-- Formula API's to load formula

  PROCEDURE Create_Formula;

END GMD_CREATE_FORMULA;

 

/
