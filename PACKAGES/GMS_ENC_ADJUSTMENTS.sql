--------------------------------------------------------
--  DDL for Package GMS_ENC_ADJUSTMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_ENC_ADJUSTMENTS" AUTHID CURRENT_USER AS
/* $Header: gmsencas.pls 120.1 2006/02/07 02:52:57 cmishra noship $ */

--  INVALID_ITEM      EXCEPTION;
--  SUBROUTINE_ERROR  EXCEPTION;

  ExpItemsIdTab     pa_utils.IdTabTyp ;

  -- Added the following table to keep track of all the EI's that are
  -- being adjusted by Txn Import program.

  ExpAdjItemTab     pa_utils.IdTabTyp;
  BackOutId         NUMBER;
  x_dummy           VARCHAR2(250);
  -- The following variable will decide if MRC data needs to be updated.
  -- This flag is useful in cases where the MRC triggres are disabled(
  -- For example during install/upgrade)
  -- pa41fixs.sql uses this flag to upgrade MRC data.

  G_update_mrc_data Varchar2(1) := 'N';
/*
  PROCEDURE  CopyItems ( X_orig_enc_id     IN NUMBER
                       , X_new_enc_id      IN NUMBER
                       , X_date            IN DATE
                       , X_person_id       IN NUMBER );
*/

  PROCEDURE  preapproved ( copy_option             IN VARCHAR2
                         , copy_items              IN VARCHAR2
                         , orig_enc_group          IN VARCHAR2
                         , new_enc_group           IN VARCHAR2
                         , orig_enc_id             IN NUMBER
                         , enc_ending_date         IN DATE
                         , new_inc_by_person       IN NUMBER
                         , userid                  IN NUMBER
                         , procedure_num_copied    IN OUT NOCOPY NUMBER
                         , procedure_num_rejected  IN OUT NOCOPY NUMBER
                         , procedure_return_code   IN OUT NOCOPY VARCHAR2 );


  PROCEDURE ReverseEncGroup ( X_orig_enc_group       IN VARCHAR2
                        ,  X_new_enc_group           IN VARCHAR2
                        ,  X_user_id                 IN NUMBER
                        ,  X_module                  IN VARCHAR2
                        ,  X_num_reversed            IN OUT NOCOPY NUMBER
                        ,  X_num_rejected            IN OUT NOCOPY NUMBER
                        ,  X_return_code             IN OUT NOCOPY VARCHAR2
                        ,  X_encgrp_status           IN VARCHAR2 DEFAULT 'WORKING' );
/*

  PROCEDURE  BackoutItem( X_enc_item_id      IN NUMBER
                        , X_encumbrance_id   IN NUMBER
                        , X_adj_activity     IN VARCHAR2
                        , X_module           IN VARCHAR2
                        , X_user             IN NUMBER
                        , X_login            IN NUMBER
                        , X_status           OUT NOCOPY NUMBER );

*/

  PROCEDURE revalidate_employee (  p_incurred_by_person_id IN NUMBER,
                                   p_week_end_date         IN DATE,
				   x_count                 OUT NOCOPY NUMBER,
				   x_org_id                OUT NOCOPY NUMBER,
				   x_org_name              OUT NOCOPY VARCHAR2 );

END  GMS_ENC_ADJUSTMENTS;

 

/
