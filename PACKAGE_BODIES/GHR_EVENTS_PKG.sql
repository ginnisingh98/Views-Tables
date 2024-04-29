--------------------------------------------------------
--  DDL for Package Body GHR_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_EVENTS_PKG" as
/* $Header: ghrwseve.pkb 120.0.12010000.2 2009/05/26 10:52:27 vmididho noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := 'ghr_events_pkg.';  -- Global package name
--
--------------------------- <get_next_event_id> ------------------------------------
FUNCTION get_next_event_id
  RETURN NUMBER
IS
--
  l_proc       varchar2(72) := g_package||'get_next_event_id';

CURSOR get_id IS
  SELECT GHR_EVENTS_S.NEXTVAL event_id
  FROM DUAL;

--
BEGIN
  FOR get_id_rec IN get_id  LOOP
    RETURN(get_id_rec.event_id);
  END LOOP;
  --
  --
END get_next_event_id;
----------------------------------------------------------------------------------

--------------------------- <delete_ok> ------------------------------------
FUNCTION delete_ok
  (p_event_id   IN      ghr_events.event_id%type) RETURN BOOLEAN IS
--
-- Returning TRUE allows Delete to happen.
-- Returning FALSE will Stop Delete
--
  l_proc       varchar2(72) := g_package||'delete_ok';
  l_del_chk    BOOLEAN      := TRUE;

CURSOR del_chk IS
  SELECT EVH.event_id
  FROM GHR_EVENT_HISTORY EVH
  WHERE EVH.event_id = p_event_id;

--
BEGIN
  FOR del_chk_rec IN del_chk LOOP
    RETURN(FALSE);
  END LOOP;
  RETURN(TRUE);
--
END delete_ok;
----------------------------------------------------------------------------------

end ghr_events_pkg ;

/
