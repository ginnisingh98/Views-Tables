--------------------------------------------------------
--  DDL for Package Body ENG_SOURCING_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_SOURCING_CHECK" AS
/* $Header: ENGSRCKB.pls 115.1 2003/11/16 00:15:41 mxgovind noship $ */

 /* Return values description:
	1 -> item sourced
	2 -> item not sourced
	3 -> package not customized by user
  */

   FUNCTION IS_ITEM_SOURCED(
	p_revised_item		NUMBER,
	p_source_organization	NUMBER,
	p_dest_organization	NUMBER
    ) RETURN NUMBER
    IS
    BEGIN


	    return 3;
    END IS_ITEM_SOURCED ;

END ENG_SOURCING_CHECK;

/
