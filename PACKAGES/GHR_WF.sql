--------------------------------------------------------
--  DDL for Package GHR_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_WF" AUTHID CURRENT_USER As
/* $Header: ghrwfnot.pkh 120.0 2005/06/24 07:30 appldev noship $ */
-- ----------------------------------------------------------------------------

PROCEDURE initiate_notification (p_request_id IN NUMBER
                                ,p_result_id  IN NUMBER
                                ,p_role       IN VARCHAR2
                                );


PROCEDURE CHECK_USER_EXIST
  (itemtype                       in varchar2
    , itemkey                        in varchar2
    , actid                          in number
    , funcmode                       in varchar2
    , result                     out nocopy    varchar2
  );
 end GHR_WF;

 

/
