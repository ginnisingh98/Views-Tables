--------------------------------------------------------
--  DDL for Package FND_WF_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_WF_STANDARD" AUTHID CURRENT_USER as
/* $Header: AFWFSTDS.pls 115.6 2003/01/30 03:23:47 rosthoma ship $ */


Procedure SubmitConcProgram(itemtype  in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  funcmode  in varchar2,
                  resultout in out nocopy varchar2);

Procedure ExecuteConcProgram(itemtype  in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  funcmode  in varchar2,
                  resultout in out nocopy varchar2);

Procedure WaitForConcProgram(itemtype  in varchar2,
                    itemkey   in varchar2,
                    actid     in number,
                    funcmode  in varchar2,
                    resultout in out nocopy varchar2);

Procedure Submit_CP(itemtype in varchar2,
                    itemkey  in varchar2,
                    actid    in number,
                    req_id   in out nocopy number);

Function  Seed_CB(itemtype  in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  req_id    in number) RETURN number;


Procedure CALLBACK (errbuff out nocopy varchar2,
                       retcode out nocopy varchar2,
                       step in number  );


END FND_WF_STANDARD;

 

/
