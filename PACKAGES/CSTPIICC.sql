--------------------------------------------------------
--  DDL for Package CSTPIICC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPIICC" AUTHID CURRENT_USER AS
/* $Header: CSTIICIS.pls 115.3 2002/11/08 22:41:44 awwang ship $ */
PROCEDURE CSTPIICI (

   i_item_id			IN  NUMBER,
   i_org_id			IN  NUMBER,
   i_user_id			IN  NUMBER,

   o_return_code		OUT NOCOPY NUMBER,
   o_return_err			OUT NOCOPY VARCHAR2);

END CSTPIICC;

 

/
