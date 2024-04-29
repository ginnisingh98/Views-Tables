--------------------------------------------------------
--  DDL for Package WIP_COMMON_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_COMMON_WF_PKG" AUTHID CURRENT_USER AS
/*$Header: wipwfcms.pls 115.9 2002/12/01 13:34:00 simishra ship $ */

FUNCTION OSPEnabled RETURN BOOLEAN;

PROCEDURE SelectBuyer( itemtype  in varchar2,
		       itemkey   in varchar2,
		       actid     in number,
		       funcmode  in varchar2,
		       resultout out NOCOPY varchar2);

PROCEDURE SelectSupplierCNT( itemtype  in varchar2,
		       itemkey   in varchar2,
		       actid     in number,
		       funcmode  in varchar2,
		       resultout out NOCOPY varchar2);

PROCEDURE SelectProdScheduler( itemtype  in varchar2,
		       itemkey   in varchar2,
		       actid     in number,
		       funcmode  in varchar2,
		       resultout out NOCOPY varchar2);

PROCEDURE SelectShippingManager( itemtype  in varchar2,
		       itemkey   in varchar2,
		       actid     in number,
		       funcmode  in varchar2,
		       resultout out NOCOPY varchar2);

PROCEDURE SelectDefaultBuyer( itemtype  in varchar2,
		       itemkey   in varchar2,
		       actid     in number,
		       funcmode  in varchar2,
		       resultout out NOCOPY varchar2);

PROCEDURE OpenPO(p1    varchar2 default null,
                 p2    varchar2 default null,
                 p3    varchar2 default null,
                 p4    varchar2 default null,
                 p5    varchar2 default null,
                 p11   varchar2 default null);

PROCEDURE GetPOURL(itemtype        in varchar2,
                   itemkey         in varchar2,
                   actid           in number,
                   funcmode        in varchar2,
                   resultout       out NOCOPY varchar2);

END wip_common_wf_pkg;

 

/
