--------------------------------------------------------
--  DDL for Package IGS_UC_EXPORT_DECISION_REPLY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_EXPORT_DECISION_REPLY" AUTHID CURRENT_USER AS
/* $Header: IGSUC65S.pls 115.2 2003/07/30 13:35:23 pmarada noship $ */

  PROCEDURE export_decision( p_app_no        IGS_UC_APP_CHOICES.APP_NO%TYPE,
                             p_choice_number IGS_UC_APP_CHOICES.CHOICE_NO%TYPE ) ;

  PROCEDURE export_reply( p_app_no        IGS_UC_APP_CHOICES.APP_NO%TYPE,
                          p_choice_number IGS_UC_APP_CHOICES.CHOICE_NO%TYPE ) ;

END igs_uc_export_decision_reply ;

 

/
