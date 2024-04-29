--------------------------------------------------------
--  DDL for Package JTF_NOTES_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_NOTES_EVENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfntbes.pls 115.1 2003/09/22 22:31:44 hbouten noship $ */


  PROCEDURE RaiseCreateNote
  ( p_NoteID            IN   NUMBER
  , p_SourceObjectCode  IN   VARCHAR2
  , p_SourceObjectID    IN   VARCHAR2
  );

  PROCEDURE RaiseUpdateNote
  ( p_NoteID            IN   NUMBER
  , p_SourceObjectCode  IN   VARCHAR2
  , p_SourceObjectID    IN   VARCHAR2
  );

  PROCEDURE RaiseDeleteNote
  ( p_NoteID            IN   NUMBER
  , p_SourceObjectCode  IN   VARCHAR2
  , p_SourceObjectID    IN   VARCHAR2
  );

END JTF_NOTES_EVENTS_PVT; -- end package JTF_NOTES_EVENTS_PVT

 

/
