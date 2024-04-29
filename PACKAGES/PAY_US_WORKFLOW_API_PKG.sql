--------------------------------------------------------
--  DDL for Package PAY_US_WORKFLOW_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_WORKFLOW_API_PKG" AUTHID CURRENT_USER AS
/* $Header: payuswfapipkg.pkh 120.0.12010000.1 2008/07/27 21:57:19 appldev ship $ */
--
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
   *                   Chertsey, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

    Package Name : PAY_US_WORKFLOW_API_PKG
    Package File Name : payuswfapipkg.pkh
    Description       : This package is used by Payroll Process Workflow


   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   08-JUN-2003  jgoswami    115.0            Created.
   19-JUN-2003  jgoswami    115.1  3006871   Added procedure ExecuteConcProgram,
                                             CheckProcessInputs
   12-APR-2004  JGoswami    115.3  3316422   Added procedure IsResponseRequired


*/
--

   TYPE attribute_data_rec IS RECORD (
      wf_item_type  wf_items.item_type%TYPE,
      wf_item_key  wf_items.item_key%TYPE,
      attr_name  VARCHAR2(30),
      attr_value varchar2(30)
      );

   TYPE cp_rqid_data_rec IS RECORD (
      wf_item_type  wf_items.item_type%TYPE,
      wf_item_key  wf_items.item_key%TYPE,
      cp_short_name  VARCHAR2(30),
      request_id varchar2(30)
      );

  TYPE attribute_data_tab IS TABLE OF attribute_data_rec
  INDEX BY BINARY_INTEGER;

  TYPE cp_rqid_data_tab IS TABLE OF cp_rqid_data_rec
  INDEX BY BINARY_INTEGER;

   attribute_data_val       attribute_data_tab;

   cp_rqid_data_val       cp_rqid_data_tab;

 TYPE pay_info_rec IS RECORD
    ( pay_request_id          Varchar2(30) := ' '
     ,pay_business_group_id varchar2(30) := ' '
     ,pay_payroll_id varchar2(30) := ' '
     ,pay_payroll_date_paid varchar2(30) := ' '
    );

  TYPE pay_info_tab IS TABLE OF pay_info_rec
  INDEX BY BINARY_INTEGER;


   pay_info_val       pay_info_tab;

procedure Get_Assignment_Info(document_id IN Varchar2,
                            display_type IN Varchar2,
                            document IN OUT nocopy Varchar2,
                            document_type IN OUT nocopy Varchar2);

procedure Get_message_details(document_id IN Varchar2,
                            display_type IN Varchar2,
                            document IN OUT nocopy Varchar2,
                            document_type IN OUT nocopy Varchar2);
procedure GetRetroInformation(itemtype in varchar2,
                                  itemkey in varchar2,
                                  actid in number,
                                  funcmode in varchar2,
                                  resultout out nocopy varchar2);

procedure post_notification_set_attr(itemtype in varchar2,
                                  itemkey in varchar2,
                                  actid in number,
                                  funcmode in varchar2,
                                  resultout out nocopy varchar2);

/*
------------------------------ get_parameter -------------------------------
function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2;
procedure set_attr_value(itemtype in varchar2,
                         itemkey in varchar2,
                         actid in number,
                         funcmode in varchar2,
                         resultout out nocopy varchar2);
procedure get_attr_value(itemtype in varchar2,
                         itemkey in varchar2,
                         actid in number,
                         funcmode in varchar2,
                         resultout out nocopy varchar2);
*/

/*
--  Later Use
FUNCTION get_value(
                            wf_item_type in varchar2,
                            wf_item_key in  varchar2,
                            attr_name in  varchar2
                          ) RETURN VARCHAR2;

FUNCTION set_value(
                    wf_item_type in varchar2 default 'NO_WF_ITEM',
                    wf_item_key in  varchar2,
                    wf_actid     in number
                    ) RETURN VARCHAR2;
*/

/*
Function Get_Batch_Details( arg1 in Varchar2) return Varchar2;
*/

PROCEDURE ExecuteConcProgram
(   p_itemtype in  varchar2
,   p_itemkey  in  varchar2
,   p_actid    in  number
,   p_funcmode in  varchar2
,   p_result   in out nocopy varchar2
);

PROCEDURE CheckProcessInputs
(   p_itemtype in  varchar2
,   p_itemkey  in  varchar2
,   p_actid    in  number
,   p_funcmode in  varchar2
,   p_result   in out nocopy varchar2
);

PROCEDURE IsResponseRequired
(   p_itemtype in  varchar2
,   p_itemkey  in  varchar2
,   p_actid    in  number
,   p_funcmode in  varchar2
,   p_result   in out nocopy varchar2
);

end PAY_US_WORKFLOW_API_PKG;


/
