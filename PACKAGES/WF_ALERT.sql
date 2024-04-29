--------------------------------------------------------
--  DDL for Package WF_ALERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_ALERT" AUTHID CURRENT_USER as
/* $Header: wfalerts.sql 115.1 99/07/16 23:50:23 porting s $ */

procedure CheckAlert(itemtype   in varchar2,
               itemkey    in varchar2,
               actid      in number,
               funcmode   in varchar2,
               resultout  in out varchar2);

procedure ErrorReport ( document_id   in varchar2,
                    display_type  in varchar2,
                    document      in out varchar2,
                    document_type in out varchar2);
end WF_ALERT;

 

/
