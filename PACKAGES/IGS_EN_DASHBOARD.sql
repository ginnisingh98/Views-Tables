--------------------------------------------------------
--  DDL for Package IGS_EN_DASHBOARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_DASHBOARD" AUTHID CURRENT_USER AS
/* $Header: IGSENB2S.pls 120.1 2005/11/18 04:20:57 appldev noship $ */

  /*---------------------------------------------------------------------------------------
   Created by  : Somasekar.N , Oracle Student Systems Oracle IDC

  --Change History:
  --Who         When            What
  --jnalam      18-Nov-2--5     Added new function Schedule_Units_Exists Bug# 4742735
  ----------------------------------------------------------------------------------------*/

  TYPE LINK_TEXT_TYPE IS TABLE OF VARCHAR2(200) INDEX BY BINARY_INTEGER;
  TYPE CAL_TYPE IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
  TYPE SEQ_NUM_TYPE IS TABLE OF NUMBER(6) INDEX BY BINARY_INTEGER;
  TYPE PRG_CAR_TYPE IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
  TYPE PLAN_SCHED_TYPE IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

  PROCEDURE student_api (  p_n_person_id IN NUMBER,
                            p_c_person_type IN VARCHAR2,
                            p_text_tbl    OUT NOCOPY LINK_TEXT_TYPE,
                            p_cal_tbl     OUT NOCOPY CAL_TYPE,
                            p_seq_tbl     OUT NOCOPY SEQ_NUM_TYPE,
                            p_car_tbl     OUT NOCOPY PRG_CAR_TYPE,
                            p_typ_tbl     OUT NOCOPY PLAN_SCHED_TYPE,
                            p_sch_allow   OUT NOCOPY VARCHAR2);

   FUNCTION Schedule_Units_Exists ( cp_n_person_id IN NUMBER,
                                   cp_c_program_cd IN VARCHAR2,
                                   cp_c_cal_type IN VARCHAR2,
                                   cp_n_seq_num IN NUMBER ) RETURN BOOLEAN;

END IGS_EN_DASHBOARD;

 

/
