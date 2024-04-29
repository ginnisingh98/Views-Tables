--------------------------------------------------------
--  DDL for Package ITG_WF_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ITG_WF_UTILS" AUTHID CURRENT_USER AS
/* ARCS: $Header: itgwfuts.pls 120.1 2005/10/06 02:12:36 bsaratna noship $
 * CVS:  itgwfuts.pls,v 1.9 2002/12/23 21:20:30 ecoe Exp
 */

  /* Outbound WF Action to set up the CLN collaboration. */
  PROCEDURE create_outbound_collaboration(
    itemtype  IN         VARCHAR2,
    itemkey   IN         VARCHAR2,
    actid     IN         NUMBER,
    funcmode  IN         VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
  );


  PROCEDURE update_outbound_collaboration(
    itemtype  IN         VARCHAR2,
    itemkey   IN         VARCHAR2,
    actid     IN         NUMBER,
    funcmode  IN         VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
  );

  PROCEDURE update_outbound_collab_cbod(
    itemtype  IN         VARCHAR2,
    itemkey   IN         VARCHAR2,
    actid     IN         NUMBER,
    funcmode  IN         VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
  );

	--4335714
	PROCEDURE set_cbod_description
	(
		itemtype                in varchar2,
		itemkey                 in varchar2,
		actid                   in number,
		funcmode                in varchar2,
		resultout               out nocopy varchar2);


END itg_wf_utils;

 

/
