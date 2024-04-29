--------------------------------------------------------
--  DDL for Package IGS_AS_USER_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_USER_HOOK" AUTHID CURRENT_USER AS
/* $Header: IGSAS51S.pls 115.0 2002/11/07 14:27:48 kdande noship $ */
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 28-JAN-2002
  ||  Purpose : User Hook Package for Assessments.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  --
  FUNCTION notify_bulk_doc_production (
    p_order_number                  IN   NUMBER,
    p_item_number                   IN   NUMBER,
    p_person_id                     IN   NUMBER
  ) RETURN BOOLEAN;
  --
END igs_as_user_hook;

 

/
