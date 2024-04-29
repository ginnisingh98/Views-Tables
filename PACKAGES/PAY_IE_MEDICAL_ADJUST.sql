--------------------------------------------------------
--  DDL for Package PAY_IE_MEDICAL_ADJUST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_MEDICAL_ADJUST" AUTHID CURRENT_USER AS
/* $Header: pyiemadj.pkh 120.0 2007/11/06 09:03:32 rsahai noship $ */
PROCEDURE Medical_Validate_Commit(errbuf OUT NOCOPY VARCHAR2,
					retcode OUT NOCOPY VARCHAR2,
					p_bg_id IN NUMBER,
					p_eff_date IN VARCHAR2,
					p_asg_id IN VARCHAR2,
					p_benefit_type IN VARCHAR2,
					p_validate_commit IN VARCHAR2);

END pay_ie_medical_adjust;

/
