--------------------------------------------------------
--  DDL for Package IGS_FI_PRC_IMPCLC_ANC_CHGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_PRC_IMPCLC_ANC_CHGS" AUTHID CURRENT_USER AS
/* $Header: IGSFI52S.pls 115.5 2002/11/29 00:24:54 nsidana ship $ */

  FUNCTION finp_get_anc_rate(p_fee_cal_type            IN IGS_FI_ANC_RATES.Fee_Cal_Type%TYPE,
                             p_fee_ci_sequence_number  IN IGS_FI_ANC_RATES.Fee_Ci_Sequence_Number%TYPE,
                             p_fee_type                IN IGS_FI_ANC_RATES.Fee_Type%TYPE,
                             p_ancillary_attribute1    IN IGS_FI_ANC_RATES.Ancillary_Attribute1%TYPE DEFAULT NULL,
                             p_ancillary_attribute2    IN IGS_FI_ANC_RATES.Ancillary_Attribute2%TYPE DEFAULT NULL,
                             p_ancillary_attribute3    IN IGS_FI_ANC_RATES.Ancillary_Attribute3%TYPE DEFAULT NULL,
                             p_ancillary_attribute4    IN IGS_FI_ANC_RATES.Ancillary_Attribute4%TYPE DEFAULT NULL,
                             p_ancillary_attribute5    IN IGS_FI_ANC_RATES.Ancillary_Attribute5%TYPE DEFAULT NULL,
                             p_ancillary_attribute6    IN IGS_FI_ANC_RATES.Ancillary_Attribute6%TYPE DEFAULT NULL,
                             p_ancillary_attribute7    IN IGS_FI_ANC_RATES.Ancillary_Attribute7%TYPE DEFAULT NULL,
                             p_ancillary_attribute8    IN IGS_FI_ANC_RATES.Ancillary_Attribute8%TYPE DEFAULT NULL,
                             p_ancillary_attribute9    IN IGS_FI_ANC_RATES.Ancillary_Attribute9%TYPE DEFAULT NULL,
                             p_ancillary_attribute10   IN IGS_FI_ANC_RATES.Ancillary_Attribute10%TYPE DEFAULT NULL,
                             p_ancillary_attribute11   IN IGS_FI_ANC_RATES.Ancillary_Attribute11%TYPE DEFAULT NULL,
                             p_ancillary_attribute12   IN IGS_FI_ANC_RATES.Ancillary_Attribute12%TYPE DEFAULT NULL,
                             p_ancillary_attribute13   IN IGS_FI_ANC_RATES.Ancillary_Attribute13%TYPE DEFAULT NULL,
                             p_ancillary_attribute14   IN IGS_FI_ANC_RATES.Ancillary_Attribute14%TYPE DEFAULT NULL,
                             p_ancillary_attribute15   IN IGS_FI_ANC_RATES.Ancillary_Attribute15%TYPE DEFAULT NULL,
                             p_ancillary_chg_rate     OUT NOCOPY IGS_FI_ANC_RATES.Ancillary_Chg_Rate%TYPE) RETURN BOOLEAN;

  PRAGMA RESTRICT_REFERENCES(finp_get_anc_rate, WNDS);

  FUNCTION finp_validate_input_data(p_fee_cal_type            IN IGS_FI_ANC_RATES.Fee_Cal_Type%TYPE,
                                    p_fee_ci_sequence_number  IN IGS_FI_ANC_RATES.Fee_Ci_Sequence_Number%TYPE,
                                    p_fee_type                IN IGS_FI_ANC_RATES.Fee_Type%TYPE,
                                    p_person_id               IN IGS_PE_PERSON.Person_Id%TYPE      DEFAULT NULL,
                                    p_person_id_type          IN IGS_PE_PERSON.Person_Id_Type%TYPE DEFAULT NULL,
                                    p_api_person_id           IN IGS_PE_PERSON.Api_Person_Id%TYPE  DEFAULT NULL,
                                    p_err_msg_name           OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

  PRAGMA RESTRICT_REFERENCES(finp_validate_input_data, WNDS);

  PROCEDURE finp_imp_calc_anc_charges(errbuf                   OUT NOCOPY VARCHAR2,
                                      retcode                  OUT NOCOPY NUMBER,
                                      p_person_id               IN IGS_PE_PERSON.Person_Id%TYPE DEFAULT NULL,
                                      p_person_id_type          IN IGS_PE_PERSON.Person_Id_Type%TYPE DEFAULT NULL,
                                      p_api_person_id           IN IGS_PE_PERSON.Api_Person_Id%TYPE DEFAULT NULL,
                                      p_fee_cal_type            IN IGS_FI_ANC_RATES.Fee_Cal_Type%TYPE,
                                      p_fee_ci_sequence_number  IN IGS_FI_ANC_RATES.Fee_Ci_Sequence_Number%TYPE,
                                      p_fee_type                IN IGS_FI_ANC_RATES.Fee_Type%TYPE DEFAULT NULL,
                                      p_org_id                  IN NUMBER);
END IGS_FI_PRC_IMPCLC_ANC_CHGS;

 

/
