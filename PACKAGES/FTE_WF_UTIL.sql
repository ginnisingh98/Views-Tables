--------------------------------------------------------
--  DDL for Package FTE_WF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_WF_UTIL" AUTHID CURRENT_USER AS
/* $Header: FTEWFUTS.pls 115.2 2002/12/03 21:51:13 hbhagava noship $ */

--*******************************************************

PROCEDURE GET_BLOCK_STATUS(itemtype  		in  	VARCHAR2,
                       itemkey   		in  	VARCHAR2,
                       p_workflow_process	in	VARCHAR2,
                       p_block_label		in	VARCHAR2,
                       x_return_status 		out NOCOPY	VARCHAR2);


FUNCTION GET_ATTRIBUTE_NUMBER(p_item_type IN VARCHAR2,
                              p_item_key  IN VARCHAR2,
                              p_aname     IN VARCHAR2) RETURN NUMBER;

END FTE_WF_UTIL;

 

/
