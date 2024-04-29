--------------------------------------------------------
--  DDL for Package Body GL_AUTO_ALLOC_WF_CUST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_AUTO_ALLOC_WF_CUST_PKG" AS
/*  $Header: glcwfalb.pls 120.3 2002/11/15 01:28:52 khchang ship $  */

Procedure dummy1(p_item_type      IN VARCHAR2,
                p_item_key       IN VARCHAR2,
                p_actid          IN NUMBER,
                p_funcmode        IN VARCHAR2,
                p_result         OUT NOCOPY VARCHAR2)
Is
Begin
 IF p_funcmode = 'RUN' THEN
    p_result := 'COMPLETE:PASS';
 ELSIF ( p_funcmode = 'CANCEL' ) THEN
    NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'dummy', p_item_type, p_item_key);
    raise;
End dummy1;

Procedure dummy2(p_item_type      IN VARCHAR2,
                p_item_key       IN VARCHAR2,
                p_actid          IN NUMBER,
                p_funcmode        IN VARCHAR2,
                p_result         OUT NOCOPY VARCHAR2)
Is
Begin
 IF p_funcmode = 'RUN' THEN
   p_result := 'COMPLETE:PASS';
 ELSIF ( p_funcmode = 'CANCEL' ) THEN
    NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'dummy1', p_item_type, p_item_key);
    raise;
End dummy2;

 End GL_AUTO_ALLOC_WF_CUST_PKG;

/
