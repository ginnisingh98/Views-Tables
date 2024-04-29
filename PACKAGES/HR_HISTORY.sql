--------------------------------------------------------
--  DDL for Package HR_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_HISTORY" AUTHID CURRENT_USER as
/* $Header: dthistry.pkh 115.5 2002/12/05 15:08:07 apholt ship $ */
/*
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
/*
   NAME
     dthistry.pkh
--
   DESCRIPTION
     Package header for the DateTrack History PL/SQL procedures.
     This package is used by Forms 4 DateTrack History.
--
  MODIFIED (DD-MON-YYYY)
     P.K.Attwood  03-JUN-1994 - created.
     P.K.Attwood  23-JAN-1996 - Fix for wwbug 295511. Added extra parameter
                                p_view_owner to the get_view_and_prompts
                                procedure. It returns the name of the Oracle
                                account which actually owns the _D view or
                                _F table. This is required for extra secure
                                user logic.
     P.K.Attwood  08-MAY-1998 - 115.1 Changes for wwbug 658889.
                                New DateTrack History feature.
                                The Forms coder can optionally specify an
                                alternative DateTrack History view. If this
                                view name is not specified or cannot be
                                found in the database then the standard _D
                                view or _F table will be used as before.
     P.K.Attwood  16-MAR-1999 - 115.2 Changes made to provide MLS for
                                DateTrack History prompts. Altered the
                                p_language_code parameter from IN to OUT
                                on the get_view_and_prompts procedure.
     S.McMillan   09-APR-2001 - Added function fetch_dt_column_prompt.
     M.Enderby    28-NOV-2002 - GSCC changes (bug 2620598)
     A.Holt       05-Dec-2002 - NOCOPY Performance Changes for 11.5.9*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_view_and_prompts >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Workout which view or table the DateTrack History Form should
--   use to obtain data. Also returns some display prompts for the
--   session's current language.
--
-- Prerequisites:
--   This procedure should only be executed from the DateTrack History Form.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_table_name                   Yes  varchar2 Name of the DateTrack table.
--   p_alternative_history_view     Yes  varchar2 Name of an override
--                                                DateTrack History view.
--                                                This parameter can be set
--                                                to null.
--
-- Post Success:
--   If the alternative view, standard DateTrack History view or table
--   can be found in the database then the following OUT parameters will
--   be populated.
--
--   Name                           Type     Description
--   p_language_code                varchar2 Value from userenv('LANG').
--   p_view_name                    varchar2 Name of the view or table the
--                                           DateTrack History Form should use
--                                           to obtain the history of data
--                                           values.
--   p_view_owner                   varchar2 Name of the database account
--                                           which owns the p_view_name view
--                                           or table.
--   p_title_prompt                 varchar2 The entity name to include in
--                                           the window title prompt. Depends
--                                           on p_language_code.
--   p_effective_start_prompt       varchar2 The display column prompt for
--                                           effective_start_date. Depends on
--                                           p_language_code.
--   p_effective_end_prompt         varchar2 The display column prompt for
--                                           effective_end_date. Depends on
--                                           p_language_code.
--
-- Post Failure:
--   If neither the alternative view, standard DateTrack History view or
--   table can be found in the database then an error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure get_view_and_prompts
  (p_table_name                in     varchar2
  ,p_alternative_history_view  in     varchar2
  ,p_language_code                out nocopy varchar2
  ,p_view_name                    out nocopy varchar2
  ,p_view_owner                   out nocopy varchar2
  ,p_title_prompt                 out nocopy varchar2
  ,p_effective_start_prompt       out nocopy varchar2
  ,p_effective_end_prompt         out nocopy varchar2
  );
--
-- Old overload version.
--
-- Left an old overload version of the get_view_and_prompts
-- procedure, without the new p_alternative_history_view parameter
-- or the changed p_language_code parameter.
-- This old version can be removed after R11.5, as the DTXHISTY
-- Form will have been changed to always call the new version.
--
procedure get_view_and_prompts
( p_table_name             in  varchar2,
  p_language_code          in  varchar2,
  p_view_name              out nocopy varchar2,
  p_view_owner             out nocopy varchar2,
  p_title_prompt           out nocopy varchar2,
  p_effective_start_prompt out nocopy varchar2,
  p_effective_end_prompt   out nocopy varchar2
);
--
-- Function to return column prompt for a given table.
-- Fix for bug 1616627.
--
FUNCTION fetch_dt_column_prompt(p_table_name    IN VARCHAR2
                               ,p_column_name   IN VARCHAR2
                               ,p_language_code IN VARCHAR2) RETURN VARCHAR2;
--
end hr_history;

 

/
