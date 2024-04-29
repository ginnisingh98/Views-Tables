--------------------------------------------------------
--  DDL for Package PA_WORKFLOW_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_WORKFLOW_HISTORY" AUTHID CURRENT_USER as
/* $Header: PAWFHSUS.pls 120.1 2005/08/18 01:19:01 avaithia noship $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+

 FILE NAME   : PAWFHSUS.pls
 DESCRIPTION :



 HISTORY     : 08/22/02 SYAO Initial Creation
	       18-Aug-05 avaithia    Bug 4537865 : NOCOPY Mandate changes
=============================================================================*/


PROCEDURE save_comment_history(
			       itemtype                      IN      VARCHAR2
			       ,itemkey                       IN      VARCHAR2
			       ,funcmode                      IN      VARCHAR2
			       , user_name IN VARCHAR2
			       , comment IN varchar2);

PROCEDURE show_history
	  (document_id IN VARCHAR2,
	   display_type IN VARCHAR2,
	   document IN OUT NOCOPY VARCHAR2, -- 4537865
	   document_type IN OUT NOCOPY VARCHAR2);  -- 4537865



END pa_workflow_history;


 

/
