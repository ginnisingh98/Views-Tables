--------------------------------------------------------
--  DDL for Package AME_UPDATE_USERNAME_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_UPDATE_USERNAME_PKG" AUTHID CURRENT_USER as
/* $Header: ameupdun.pkh 120.0 2005/07/26 06:07 mbocutt noship $ */
  procedure update_username
    (itemtype    in            varchar2
    ,itemkey     in            varchar2
    ,actid       in            number
    ,funcmode    in            varchar2
    ,resultout   in out nocopy varchar2
    );

end ame_update_username_pkg;

 

/
