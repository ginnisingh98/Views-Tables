--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_AUTOALLOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_AUTOALLOC_PKG" AUTHID CURRENT_USER AS
/*  $Header: PAPAALCS.pls 120.1 2005/08/17 12:58:34 ramurthy noship $  */

  --  	Called from most of the procedures/functions in this package
  --  	Writes debug Msg to the log file if Debug Flag is on

Procedure Dummy_Allocation
			( p_item_type	IN 	VARCHAR2,
                         p_item_key	IN 	VARCHAR2,
                         p_actid	IN 	NUMBER,
                         p_funcmode	IN 	VARCHAR2,
                         p_result	OUT NOCOPY 	VARCHAR2);

--------------------------------------------------------------------------------

Procedure Dummy_Dist_Cost
			( p_item_type	IN 	VARCHAR2,
                         p_item_key	IN 	VARCHAR2,
                         p_actid	IN 	NUMBER,
                         p_funcmode	IN 	VARCHAR2,
                         p_result	OUT NOCOPY 	VARCHAR2);

--------------------------------------------------------------------------------

Procedure Dummy_Summarization
			( p_item_type	IN 	VARCHAR2,
                         p_item_key	IN 	VARCHAR2,
                         p_actid	IN 	NUMBER,
                         p_funcmode	IN 	VARCHAR2,
                         p_result	OUT NOCOPY 	VARCHAR2);

--------------------------------------------------------------------------------

END PA_CLIENT_EXTN_AUTOALLOC_PKG;

 

/
