--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_AUTOALLOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_AUTOALLOC_PKG" AS
/*  $Header: PAPAALCB.pls 120.2 2005/08/19 16:18:51 ramurthy noship $  */

  --  	Called from most of the procedures/functions in this package

PROCEDURE DUMMY_ALLOCATION
			( p_item_type	IN 	VARCHAR2,
                         p_item_key	IN 	VARCHAR2,
                         p_actid	IN 	NUMBER,
                         p_funcmode	IN 	VARCHAR2,
                         p_result	OUT NOCOPY 	VARCHAR2)
IS
Begin

IF p_funcmode = 'RUN' THEN
   p_result := 'COMPLETE:PASS';
ELSIF ( p_funcmode = 'CANCEL' ) THEN
       NULL;
END IF;


EXCEPTION
  WHEN OTHERS THEN
      Wf_Core.Context('PA_CLIENT_EXTN_AUTOALLOC_PKG', 'Dummy_Allocation',
		       p_item_type, p_item_key);
	  raise;

End Dummy_Allocation;

--------------------------------------------------------------------------------

Procedure Dummy_Dist_Cost
			( p_item_type	IN 	VARCHAR2,
                         p_item_key	IN 	VARCHAR2,
                         p_actid	IN 	NUMBER,
                         p_funcmode	IN 	VARCHAR2,
                         p_result	OUT NOCOPY 	VARCHAR2)
IS
BEGIN

IF p_funcmode = 'RUN' THEN
   p_result := 'COMPLETE:PASS';
ELSIF ( p_funcmode = 'CANCEL' ) THEN
  NULL;
END IF;

EXCEPTION
 WHEN OTHERS THEN
  Wf_Core.Context('PA_CLIENT_EXTN_AUTOALLOC_PKG', 'Dummy_Dist_Cost',
                   p_item_type, p_item_key);
  raise;

END Dummy_Dist_Cost;

--------------------------------------------------------------------------------

Procedure Dummy_Summarization
			( p_item_type	IN 	VARCHAR2,
                         p_item_key	IN 	VARCHAR2,
                         p_actid	IN 	NUMBER,
                         p_funcmode	IN 	VARCHAR2,
                         p_result	OUT NOCOPY 	VARCHAR2)
IS
BEGIN
IF p_funcmode = 'RUN' THEN
   p_result := 'COMPLETE:PASS';
ELSIF ( p_funcmode = 'CANCEL' ) THEN
     NULL;
END IF;

EXCEPTION
   WHEN OTHERS THEN
        Wf_Core.Context('PA_CLIENT_EXTN_AUTOALLOC_PKG', 'Dummy_Summarization',
        p_item_type, p_item_key);
        raise;


END Dummy_Summarization;

--------------------------------------------------------------------------------

END PA_CLIENT_EXTN_AUTOALLOC_PKG;

/
