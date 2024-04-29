--------------------------------------------------------
--  DDL for Package PQH_FR_WF_NTF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_WF_NTF" AUTHID CURRENT_USER as
/* $Header: pqfrpswf.pkh 115.1 2002/11/27 23:43:32 rpasapul noship $ */

PROCEDURE psv_ntf_api(
        p_validation_id                  in number
      , p_person_id                      in number
      , p_role_name                      in varchar2 default null
      , p_role_id                        in number   default null
      , p_user_name                      in varchar2 default null
      , p_user_id                        in number   default null
      , p_comments                       in varchar2 default null
      , p_param1_name                    in varchar2 default null
      , p_param1_value                   in varchar2 default null
      , p_param2_name                    in varchar2 default null
      , p_param2_value                   in varchar2 default null
      , p_param3_name                    in varchar2 default null
      , p_param3_value                   in varchar2 default null
      , p_param4_name                    in varchar2 default null
      , p_param4_value                   in varchar2 default null
      , p_param5_name                    in varchar2 default null
      , p_param5_value                   in varchar2 default null
      , p_param6_name                    in varchar2 default null
      , p_param6_value                   in varchar2 default null
      , p_param7_name                    in varchar2 default null
      , p_param7_value                   in varchar2 default null
      , p_param8_name                    in varchar2 default null
      , p_param8_value                   in varchar2 default null
      , p_param9_name                    in varchar2 default null
      , p_param9_value                   in varchar2 default null
      , p_param10_name                   in varchar2 default null
      , p_param10_value                  in varchar2 default null
      );

PROCEDURE WHICH_MESSAGE (
        itemtype                         in varchar2
      , itemkey                          in varchar2
      , actid                            in number
      , funcmode                         in varchar2
      , result                       out nocopy    varchar2);

end PQH_FR_WF_NTF;

 

/
