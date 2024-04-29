--------------------------------------------------------
--  DDL for Package ZX_TRN_VALIDATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TRN_VALIDATION_PKG" AUTHID CURRENT_USER AS
/* $Header: zxctaxregns.pls 120.13 2005/08/02 13:37:59 amohiudd ship $  */

FUNCTION common_check_numeric (p_check_value IN VARCHAR2,
                               p_from        IN NUMBER,
                               p_for         IN NUMBER)   RETURN VARCHAR2;

FUNCTION common_check_length (p_country_code  IN VARCHAR2,
                              p_num_digits    IN NUMBER,
                              p_trn           IN VARCHAR2) RETURN VARCHAR2;


PROCEDURE validate_trn (p_country_code           IN  VARCHAR2,
                        p_tax_reg_num            IN  VARCHAR2,
                        p_tax_regime_code        IN  VARCHAR2,
                        p_tax                    IN  VARCHAR2,
                        p_tax_jurisdiction_code  IN  VARCHAR2,
                        p_ptp_id                 IN  NUMBER,
                        p_party_type_code        IN  VARCHAR2,
                        p_trn_type               IN  VARCHAR2,
                        p_error_buffer           OUT NOCOPY VARCHAR2,
                        p_return_status          OUT NOCOPY VARCHAR2,
                        x_party_type_token       OUT NOCOPY VARCHAR2,
                        x_party_name_token       OUT NOCOPY VARCHAR2,
                        x_party_site_name_token  OUT NOCOPY VARCHAR2  );

procedure VALIDATE_TRN_AT (p_trn               IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2);

procedure VALIDATE_TRN_BE (p_trn               IN VARCHAR2,
                              p_trn_type          IN VARCHAR2,
                              p_check_unique_flag IN VARCHAR2,
                              p_return_status     OUT NOCOPY VARCHAR2,
                              p_error_buffer      OUT NOCOPY VARCHAR2);

procedure VALIDATE_TRN_DK (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2);

procedure VALIDATE_TRN_EE (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2);

procedure VALIDATE_TRN_FI (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2);

procedure VALIDATE_TRN_FR (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2);

procedure VALIDATE_TRN_DE (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2);

procedure VALIDATE_TRN_GR (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2);


procedure VALIDATE_TRN_IE (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2);

procedure VALIDATE_TRN_IT (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2);

procedure VALIDATE_TRN_LU (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2);

procedure VALIDATE_TRN_SK (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2);

procedure VALIDATE_TRN_NL(p_trn               IN VARCHAR2,
                          p_trn_type          IN VARCHAR2,
                          p_check_unique_flag IN VARCHAR2,
                          p_return_status     OUT NOCOPY VARCHAR2,
                          p_error_buffer      OUT NOCOPY VARCHAR2);

procedure VALIDATE_TRN_PL (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2);

procedure VALIDATE_TRN_PT (p_trn_value         IN  VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN  VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2);

procedure VALIDATE_TRN_ES(p_trn                IN VARCHAR2,
                          p_trn_type           IN VARCHAR2,
                          p_check_unique_flag  IN VARCHAR2,
                          p_return_status      OUT NOCOPY VARCHAR2,
                          p_error_buffer       OUT NOCOPY VARCHAR2);

procedure VALIDATE_TRN_SE (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2);

procedure VALIDATE_TRN_GB (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2);

procedure VALIDATE_TRN_CH (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2);

procedure VALIDATE_TRN_RU (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2);

procedure VALIDATE_TRN_HU (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2);

PROCEDURE VALIDATE_TRN_BR (p_trn              IN VARCHAR2,
                           p_trn_type         IN VARCHAR2,
                           p_return_status    OUT NOCOPY VARCHAR2,
                           p_error_buffer     OUT NOCOPY VARCHAR2);

PROCEDURE VALIDATE_TRN_AR ( p_trn               IN VARCHAR2,
                            p_trn_type          IN VARCHAR2,
                            p_return_status     OUT NOCOPY VARCHAR2,
                            p_error_buffer      OUT NOCOPY VARCHAR2);

PROCEDURE VALIDATE_TRN_CL ( p_trn               IN VARCHAR2,
                            p_return_status     OUT NOCOPY VARCHAR2,
                            p_error_buffer      OUT NOCOPY VARCHAR2);

PROCEDURE VALIDATE_TRN_CO ( p_trn               IN VARCHAR2,
                            p_return_status     OUT NOCOPY VARCHAR2,
                            p_error_buffer      OUT NOCOPY VARCHAR2);

PROCEDURE VALIDATE_TRN_TW ( p_trn               IN VARCHAR2,
                            p_return_status     OUT NOCOPY VARCHAR2,
                            p_error_buffer      OUT NOCOPY VARCHAR2);

procedure VALIDATE_TRN_MT (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2);

procedure VALIDATE_TRN_CY (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2);

procedure VALIDATE_TRN_LV (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2);

procedure VALIDATE_TRN_LT (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2);

procedure VALIDATE_TRN_SI (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2);

END ZX_TRN_VALIDATION_PKG;

 

/
