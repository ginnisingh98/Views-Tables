--------------------------------------------------------
--  DDL for Package GMS_ENC_COPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_ENC_COPY" AUTHID CURRENT_USER AS
/* $Header: GMSTEXCS.pls 120.1 2005/07/26 14:38:33 appldev ship $ */

  PROCEDURE  DUMMY ; -- Dummy procedure to validate package.
/*
  This package is not used...


  PROCEDURE  ValidateEmp ( X_person_id  IN NUMBER
                         , X_date       IN DATE
                         , X_status     OUT NOCOPY VARCHAR2 );

  PROCEDURE  CopyItems ( X_orig_enc_id     IN NUMBER
                       , X_new_enc_id      IN NUMBER
                       , X_date            IN DATE
                       , X_person_id       IN NUMBER );

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

  PROCEDURE online ( orig_enc_id            IN NUMBER
                   , new_enc_id             IN NUMBER
                   , enc_ending_date        IN DATE
                   , X_inc_by_person        IN NUMBER
                   , userid                 IN NUMBER
                   , procedure_return_code  IN OUT NOCOPY VARCHAR2 );

  PROCEDURE ReverseExpGroup ( X_orig_enc_group       IN VARCHAR2
                        ,  X_new_enc_group           IN VARCHAR2
                        ,  X_user_id                 IN NUMBER
                        ,  X_module                  IN VARCHAR2
                        ,  X_num_reversed            IN OUT NOCOPY NUMBER
                        ,  X_num_rejected            IN OUT NOCOPY NUMBER
                        ,  X_return_code             IN OUT NOCOPY VARCHAR2
                        ,  X_encgrp_status           IN VARCHAR2 DEFAULT 'WORKING' );
*/

END  GMS_ENC_COPY;

 

/
