--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_026
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_026" AUTHID CURRENT_USER AS
/* $Header: IGSPE13S.pls 120.0 2005/06/01 22:35:36 appldev noship $ */

/*
 ||  Created By : gmuralid
 ||  Date       : 2-DEC-2002
 ||  Build      : SEVIS
 ||  Bug No     : 2599109

 ||  Change History :
 ||  Who             When            What
 ||  ssaleem         8-OCT-2003      Included the procedure prc_pe_addr
 ||  ssaleem         25 Aug 2004     Moving the validate_record function in visa, passport and visit histry outside to the package level
 ||                                  Added new procedures validate_visa_pub,validate_passport_pub and visit histry pub that will be called by the Visa, Passport and Visit Histry Public APIs.
 ||                                  Changes as part of Bug # 3847525
*/

PROCEDURE prc_pe_visa(
   p_source_type_id  IN NUMBER,
   p_batch_id        IN NUMBER );

PROCEDURE prc_pe_passport(
          p_source_type_id  IN NUMBER,
          p_batch_id        IN NUMBER );

 PROCEDURE prc_pe_visit_histry(
               p_source_type_id  IN NUMBER,
               p_batch_id        IN NUMBER );

PROCEDURE prc_pe_eit(
          p_source_type_id  IN NUMBER,
          p_batch_id        IN NUMBER );

PROCEDURE prc_pe_addr(
          p_source_type_id IN NUMBER,
          p_batch_id IN  NUMBER );

FUNCTION validate_visa_pub(api_visa_rec IGS_PE_VISAPASS_PUB.visa_rec_type,
                           p_err_code OUT NOCOPY igs_pe_visa_int.error_code%TYPE) RETURN BOOLEAN;

FUNCTION validate_visit_histry_pub(api_visit_rec IGS_PE_VISAPASS_PUB.visit_hstry_rec_type,
                                   p_err_code OUT NOCOPY igs_pe_visa_int.error_code%TYPE) RETURN BOOLEAN;

FUNCTION validate_passport_pub(api_pass_rec IGS_PE_VISAPASS_PUB.passport_rec_type,
                                   p_err_code OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

END igs_ad_imp_026;

 

/
