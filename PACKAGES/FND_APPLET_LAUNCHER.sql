--------------------------------------------------------
--  DDL for Package FND_APPLET_LAUNCHER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_APPLET_LAUNCHER" AUTHID CURRENT_USER as
/* $Header: AFAPPLTS.pls 115.6 2003/03/12 21:07:24 rtse ship $ */


procedure launch(
  applet_class       in varchar2,
  archive_list       in varchar2,
  user_args          in varchar2,
  title_msg          in varchar2  default null,
  title_app          in varchar2  default null,
  height             in number    default 300,
  width              in number    default 400,
  cache              in varchar2  default 'off',
  validate_session   in boolean   default TRUE);

procedure launch_application(
  application_name   in varchar2,
  title_msg          in varchar2  default null,
  title_app          in varchar2  default null);

end fnd_applet_launcher;

 

/
