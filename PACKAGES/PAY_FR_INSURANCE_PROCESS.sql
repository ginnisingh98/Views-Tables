--------------------------------------------------------
--  DDL for Package PAY_FR_INSURANCE_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_INSURANCE_PROCESS" AUTHID CURRENT_USER AS
  /* $Header: pyfrtpin.pkh 115.2 2002/11/25 13:20:46 vsjain noship $ */

  cs_FINAL      CONSTANT NUMBER := 100;   -- Final Run
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Custom data types
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --

  TYPE t_ins IS RECORD
  ( assignment_id		NUMBER
  , base_net			NUMBER
  , element_entry_id		NUMBER
  , date_earned		        DATE
  , insurance_subject		NUMBER
  , insurance_exempt		NUMBER
  , insurance_adjustment	NUMBER
  , insurance_reduction         NUMBER);

  --

 TYPE t_ctl IS RECORD
  (iter        NUMBER
  ,p_mode      NUMBER);

  --
 FUNCTION iterate
  (p_assignment_id       NUMBER
  ,p_element_entry_id    NUMBER
  ,p_date_earned         DATE
  ,p_net_pay             NUMBER
  ,p_subject_insurance   NUMBER
  ,p_exempt_insurance	 NUMBER
  ,p_recipient           VARCHAR2
  ,p_stop_processing OUT NOCOPY VARCHAR2) RETURN NUMBER;

FUNCTION indirects
  (p_ins_subject        OUT NOCOPY NUMBER
  ,p_ins_exempt         OUT NOCOPY NUMBER
  ,p_ins_adjustment     OUT NOCOPY NUMBER
  ,p_ins_reduction      OUT NOCOPY NUMBER ) RETURN NUMBER ;

END pay_fr_insurance_process;

 

/
