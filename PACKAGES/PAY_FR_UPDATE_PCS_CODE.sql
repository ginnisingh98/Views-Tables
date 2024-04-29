--------------------------------------------------------
--  DDL for Package PAY_FR_UPDATE_PCS_CODE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_UPDATE_PCS_CODE" AUTHID CURRENT_USER as
/* $Header: pyfrupcs.pkh 115.1 2003/12/23 10:40:41 ayegappa noship $ */

procedure update_old_pcs_codes (errbuf                 OUT NOCOPY VARCHAR2,
                                 retcode               OUT NOCOPY NUMBER,
		                 p_business_group_id   in         number);

end pay_fr_update_pcs_code;

 

/
