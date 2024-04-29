--------------------------------------------------------
--  DDL for Package XTR_USER_ACCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_USER_ACCESS" AUTHID CURRENT_USER AS
/* $Header: xtruaccs.pls 120.1 2005/09/28 11:51:47 eaggarwa noship $ */

g_dealer_code xtr_dealer_codes.dealer_code%TYPE := null;

FUNCTION dealer_code RETURN xtr_dealer_codes.dealer_code%TYPE;

END XTR_USER_ACCESS;

 

/
