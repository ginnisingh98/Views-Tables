--------------------------------------------------------
--  DDL for Package IGS_SV_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_SV_UTIL" AUTHID CURRENT_USER AS
/* $Header: IGSSV02S.pls 120.1 2006/04/27 22:19:21 prbhardw noship $ */

/******************************************************************

    Copyright (c) 2006 Oracle Corporation, Redwood Shores, CA, USA
                         All rights reserved.

 Created By         : SreeKrishna Vadde

 Date Created By    : Wednesday, January 04, 2006

 Purpose            : This  is a utility package for all sevis related operations


 remarks            : None

 Change History

Who                   When           What
-----------------------------------------------------------
******************************************************************/
   TYPE bath_crsr IS REF CURSOR;

   PROCEDURE get_prev_btch_dtls (
      p_key_code            IN       VARCHAR2,
      p_person_id           IN       NUMBER,
      p_cur_batch_id        IN       NUMBER,
      p_extra_param         IN       VARCHAR2,
      x_prev_batch_id       OUT  NOCOPY    NUMBER,
      x_prev_btch_prcs_dt   OUT  NOCOPY    DATE
   );

   PROCEDURE get_tbl_extra_params (
      p_key_code       IN       VARCHAR2,
      p_extra_param    IN       VARCHAR2,
      x_tbl_name       OUT   NOCOPY   VARCHAR2,
      x_extra_critra   OUT  NOCOPY    VARCHAR2
   );

   FUNCTION ismutuallyexclusive (
      p_person_id          NUMBER,
      p_batch_id           NUMBER,
      p_operation          VARCHAR2,
      p_information_type   VARCHAR2
   )
      RETURN BOOLEAN;

   PROCEDURE change_record_status (
      p_person_id     IN   NUMBER,
      p_batch_id      IN   NUMBER,
      p_info_key      IN   VARCHAR2,
      p_extra_param   IN   VARCHAR2,
      P_CHANGE_DATA   IN   VARCHAR2,
      p_summary_id    IN   NUMBER
   );
   FUNCTION GET_BTCH_PROCESS_DT(
      p_person_id igs_sv_prgms_info.person_id%TYPE,
      --p_auth_reason igs_sv_prgms_info.authorization_reason%TYPE
      p_sevis_auth_id igs_sv_prgms_info.sevis_auth_id%TYPE
 ) RETURN DATE;

 FUNCTION open_new_batch(p_person_id number, p_batch_id number, p_caller varchar2)
 return number ;

 PROCEDURE create_Person_Rec(
       p_person_id NUMBER,
       p_old_batch_id NUMBER,
       p_new_batch_id NUMBER);

PROCEDURE GET_PROGRAM_DATES (
      p_person_id IN igs_pe_nonimg_form.person_id%TYPE,
      p_prgm_end_date OUT NOCOPY   igs_pe_nonimg_form.prgm_end_date%TYPE,
      p_prgm_start_date OUT NOCOPY igs_pe_nonimg_form.prgm_start_date%TYPE
 );

END igs_sv_util;

 

/
