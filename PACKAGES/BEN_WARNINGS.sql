--------------------------------------------------------
--  DDL for Package BEN_WARNINGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_WARNINGS" AUTHID CURRENT_USER as
/* $Header: benwarng.pkh 120.1 2006/11/23 13:56:16 gsehgal noship $ */

  type g_oab_warnings_rec is record
    (message_name fnd_new_messages.message_name%type,
     application_short_name fnd_application.application_short_name%type,
     parm1 number,
     parm2 number,
     parma varchar2(600),/*bug 3127048  increased the length */
     parmb varchar2(600),/*bug 3127048  increased the length */
     parmc varchar2(600),--bug 4120426
     person_id number);

  type g_oab_warnings_table is table of g_oab_warnings_rec
    index by binary_integer;

  g_oab_warnings g_oab_warnings_table;

  g_oab_warnings_count number ;

  g_warning_rec         ben_type.g_report_rec ;
----------------------------------------------------------------------------
--  exist_warning -- bug 4120426
----------------------------------------------------------------------------
FUNCTION exist_warning
    (p_application_short_name  in varchar2,
     p_message_name            in varchar2,
     p_parm1     in number   default null,
     p_parm2     in number   default null,
     p_parma     in varchar2 default null,
     p_parmb     in varchar2 default null,
     p_parmc     in varchar2 default null,
     p_person_id in number   default null) return boolean;
----------------------------------------------------------------------------
--  load_warning
----------------------------------------------------------------------------
PROCEDURE load_warning
    (p_application_short_name  in varchar2,
     p_message_name            in varchar2,
     p_parm1     in number   default null,
     p_parm2     in number   default null,
     p_parma     in varchar2 default null,
     p_parmb     in varchar2 default null,
     p_parmc     in varchar2 default null,--bug 4120426
     p_person_id in number   default null);

----------------------------------------------------------------------------
--  trim_warnings
----------------------------------------------------------------------------
PROCEDURE trim_warnings(p_trim in number);

----------------------------------------------------------------------------
--  empty_warnings
----------------------------------------------------------------------------
PROCEDURE empty_warnings;

----------------------------------------------------------------------------
--  set_warning
----------------------------------------------------------------------------
PROCEDURE set_warning
    (p_index number);

----------------------------------------------------------------------------
--  write_warnings_batch
----------------------------------------------------------------------------
PROCEDURE write_warnings_batch;

----------------------------------------------------------------------------
--  write_warnings_online
----------------------------------------------------------------------------
PROCEDURE write_warnings_online (p_session_id in number) ;

----------------------------------------------------------------------------
--  delete_warnings
----------------------------------------------------------------------------
PROCEDURE delete_warnings (
   p_application_short_name   IN   VARCHAR2,
   p_message_name             IN   VARCHAR2,
   p_parm1                    IN   NUMBER DEFAULT NULL,
   p_parm2                    IN   NUMBER DEFAULT NULL,
   p_parma                    IN   VARCHAR2 DEFAULT NULL,
   p_parmb                    IN   VARCHAR2 DEFAULT NULL,
   p_parmc                    IN   VARCHAR2 DEFAULT NULL,
   p_person_id                IN   NUMBER DEFAULT NULL
);

end ben_warnings;

/
