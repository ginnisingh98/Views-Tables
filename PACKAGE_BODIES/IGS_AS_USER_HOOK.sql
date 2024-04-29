--------------------------------------------------------
--  DDL for Package Body IGS_AS_USER_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_USER_HOOK" AS
/* $Header: IGSAS51B.pls 115.0 2002/11/07 14:27:05 kdande noship $ */
  --
  FUNCTION notify_bulk_doc_production (
    p_order_number                  IN   NUMBER,
    p_item_number                   IN   NUMBER,
    p_person_id                     IN   NUMBER
  ) RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END notify_bulk_doc_production;
  --
END igs_as_user_hook;

/
