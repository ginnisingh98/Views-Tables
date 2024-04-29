--------------------------------------------------------
--  DDL for Package PAY_ZA_BANK_DDF_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ZA_BANK_DDF_UPD" AUTHID CURRENT_USER AS
/* $Header: pyzabnku.pkh 120.0.12010000.1 2010/03/24 08:31:47 rbabla noship $ */

PROCEDURE qualify_bnk_update(
            p_assignment_id number
          , p_qualifier	out nocopy varchar2);

PROCEDURE update_bnk(p_assignment_id number);

end PAY_ZA_BANK_DDF_UPD;

/
