--------------------------------------------------------
--  DDL for Package FND_FLEX_WORKFLOW_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_WORKFLOW_APIS" AUTHID CURRENT_USER AS
/* $Header: AFFFWKAS.pls 120.1.12010000.1 2008/07/25 14:15:01 appldev ship $ */


PROCEDURE start_generation(itemtype IN  VARCHAR2,
			   itemkey  IN  VARCHAR2,
			   actid    IN  NUMBER,
			   funcmode IN  VARCHAR2,
			   result   OUT nocopy VARCHAR2);

PROCEDURE assign_to_segment(itemtype IN  VARCHAR2,
			    itemkey  IN  VARCHAR2,
			    actid    IN  NUMBER,
			    funcmode IN  VARCHAR2,
			    result   OUT nocopy VARCHAR2);

PROCEDURE get_value_from_combination(itemtype IN  VARCHAR2,
				     itemkey  IN  VARCHAR2,
				     actid    IN  NUMBER,
				     funcmode IN  VARCHAR2,
				     result   OUT nocopy VARCHAR2);

PROCEDURE get_value_from_combination2(itemtype IN  VARCHAR2,
				      itemkey  IN  VARCHAR2,
				      actid    IN  NUMBER,
				      funcmode IN  VARCHAR2,
				      result   OUT nocopy VARCHAR2);

PROCEDURE copy_from_combination(itemtype IN  VARCHAR2,
				itemkey  IN  VARCHAR2,
				actid    IN  NUMBER,
				funcmode IN  VARCHAR2,
				result   OUT nocopy VARCHAR2);

PROCEDURE copy_segment_from_combination(itemtype IN  VARCHAR2,
					itemkey  IN  VARCHAR2,
					actid    IN  NUMBER,
					funcmode IN  VARCHAR2,
					result   OUT nocopy VARCHAR2);

PROCEDURE copy_segment_from_combination2(itemtype IN  VARCHAR2,
					 itemkey  IN  VARCHAR2,
					 actid    IN  NUMBER,
					 funcmode IN  VARCHAR2,
					 result   OUT nocopy VARCHAR2);

PROCEDURE is_combination_complete(itemtype IN  VARCHAR2,
				  itemkey  IN  VARCHAR2,
				  actid    IN  NUMBER,
				  funcmode IN  VARCHAR2,
				  result   OUT nocopy VARCHAR2);

PROCEDURE validate_combination(itemtype IN  VARCHAR2,
			       itemkey  IN  VARCHAR2,
			       actid    IN  NUMBER,
			       funcmode IN  VARCHAR2,
			       result   OUT nocopy VARCHAR2);

PROCEDURE abort_generation(itemtype IN  VARCHAR2,
			   itemkey  IN  VARCHAR2,
			   actid    IN  NUMBER,
			   funcmode IN  VARCHAR2,
			   result   OUT nocopy VARCHAR2);

PROCEDURE end_generation(itemtype IN  VARCHAR2,
			 itemkey  IN  VARCHAR2,
			 actid    IN  NUMBER,
			 funcmode IN  VARCHAR2,
			 result   OUT nocopy VARCHAR2);

PROCEDURE debug_on;

PROCEDURE debug_off;

END fnd_flex_workflow_apis;

/
