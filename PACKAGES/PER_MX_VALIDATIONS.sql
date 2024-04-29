--------------------------------------------------------
--  DDL for Package PER_MX_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_MX_VALIDATIONS" AUTHID CURRENT_USER as
/* $Header: permxval.pkh 120.0.12000000.1 2007/01/22 03:24:56 appldev noship $ */

    PROCEDURE check_SS( p_ss_id             IN VARCHAR2,
                        p_person_id         IN NUMBER,
                        p_business_group_id IN NUMBER,
                        p_warning          OUT NOCOPY VARCHAR2,
			p_valid_ss         OUT NOCOPY VARCHAR2);

    PROCEDURE check_RFC( p_rfc_id            IN VARCHAR2,
                         p_person_id         IN NUMBER,
                         p_business_group_id IN NUMBER,
                         p_warning          OUT NOCOPY VARCHAR2,
	 		 p_valid_rfc        OUT NOCOPY VARCHAR2);

    PROCEDURE check_MS( p_ms_id             IN VARCHAR2,
                        p_person_id         IN NUMBER,
                        p_business_group_id IN NUMBER,
                        p_warning          OUT NOCOPY VARCHAR2);

    PROCEDURE check_FGA( p_fga_id            IN VARCHAR2,
                         p_person_id         IN NUMBER,
                         p_business_group_id IN NUMBER,
                         p_warning          OUT NOCOPY VARCHAR2);

    PROCEDURE check_IMC( p_imc_id            IN VARCHAR2);

    PROCEDURE check_regstrn_id( p_regstrn_id        IN VARCHAR2,
                                p_disab_id          IN NUMBER);

    PROCEDURE check_SS_Leaving_Reason( p_ss_leaving_reason  IN VARCHAR2);

end per_mx_validations;

 

/
