--------------------------------------------------------
--  DDL for Package BEN_POPULATE_RBV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_POPULATE_RBV" AUTHID CURRENT_USER AS
/* $Header: benrbvpo.pkh 115.1 2003/04/09 00:30:35 mhoyes noship $ */
--
PROCEDURE populate_benmngle_rbvs
  (p_benefit_action_id in     number
  ,p_person_action_id  in     number
  ,p_validate_flag     in     varchar2
  );
--
function validate_mode
  (p_validate in varchar2
  ) return boolean;
--
END ben_populate_rbv;

 

/
