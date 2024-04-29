--------------------------------------------------------
--  DDL for Package PO_WFDS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_WFDS_PUB" AUTHID CURRENT_USER AS
/* $Header: POXPWFDS.pls 120.0.12010000.1 2011/09/09 09:30:18 kcthirum noship $ */

 /*=======================================================================+
 | FILENAME
 |   POXPWFDS.pls
 |
 | DESCRIPTION
 |   PL/SQL spec for package: PO_WFDS_PUB
 |
 *=====================================================================*/

-- Start of comments
-- API name     : synch_supp_wth_wf_dir_srvcs
-- Type         : public
-- Pre-reqs     : none
-- Function     : synchronize the supplier with workflow directory services
-- Parameters   :
-- IN           :       itemtype	in varchar2	required
--                      itemkey		in varchar2	required
--                      actid		in number	required
--                      funcmode	in varchar2	required
-- OUT          :       resultout	out	varchar2
-- Version      : initial version
-- End of comments
procedure synch_supp_wth_wf_dir_srvcs (  itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       out nocopy varchar2);

end PO_WFDS_PUB;

/
