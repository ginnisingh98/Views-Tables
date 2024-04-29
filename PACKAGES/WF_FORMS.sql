--------------------------------------------------------
--  DDL for Package WF_FORMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_FORMS" AUTHID CURRENT_USER as
/* $Header: wffrms.pls 120.3 2005/10/04 05:18:36 rtodi ship $ */

java_loc   VARCHAR2(80) := '/OA_JAVA/';

--
-- Applet
--   Generate the applet tag for WFForms
-- IN
--   port - port listened by the socket listener
--   name - name for the applet
--   codebase - where the java classes can be located
--   archive  - first looks for java classes at this archive
--
-- OUT
--   status - true if is permitted to launch, false otherwise
--
procedure Applet(fname    in  varchar2,
                 dispname in  varchar2 default null,
                 port     in  varchar2 default '0',
                 codebase in  varchar2 default Wf_Forms.java_loc,
                 code     in  varchar2 default
                               'oracle.apps.fnd.wf.WFFormsApplet',
                 archive  in  varchar2 default null,
                 status   out nocopy boolean);

--
-- AppletWindow
--   Generate the applet window to call up a form
-- IN
--   fname - form function with format 'func1:PARAM1="&ID" PARAM2="&NAME"'
--   port - port listened by the socket listener
--   codebase - where the java classes can be located
--   code - name for the class
--   archive  - first looks for java classes at this archive
--
procedure AppletWindow(fname    in  varchar2,
                       port     in  varchar2 default '0',
                       codebase in  varchar2 default Wf_Forms.java_loc,
                       code     in  varchar2 default
                                    'oracle.apps.fnd.wf.WFFormsApplet',
                       archive  in  varchar2 default null);

end WF_FORMS;

 

/
