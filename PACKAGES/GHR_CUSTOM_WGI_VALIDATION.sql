--------------------------------------------------------
--  DDL for Package GHR_CUSTOM_WGI_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CUSTOM_WGI_VALIDATION" AUTHID CURRENT_USER as
/* $Header: ghcuswgi.pkh 120.0.12010000.3 2009/05/26 11:51:47 utokachi noship $ */
--
-- -----------------------------------------------------------------------------
-- |-------------------------------< custom_wgi_criteria >--------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
--  Description:
--    This procedure is provided for the customer to allow them to
--    add there own routines to do additional validation for a Automatic Within Grade
--    Increase. It is called from the main auto wgi procedure (GHR_WGI_PKG.GHR_WGI_EMP)
--
--
--  In Arguments of the record structure:
--    person_id (Person ID of the person selected for Auto WGI ).
--    assignment_id (Assignment ID of the person selected for Auto WGI ).
--    position_id (From Position of the Person selected for AUTO WGI)
--    p_effective_date (Effective date for Auto WGI calculated based on WGI Pay date element).
--
--  OUT Arguments of the record structure:
--    process_person BOOLEAN set to TRUE if Auto WGI is to be given otherwise FALSE
--
--
--
--
--  Developer Implementation Notes:
--    Customer defined.
--
--  {End of Comments}
-- -----------------------------------------------------------------------------
procedure custom_wgi_criteria
   ( p_wgi_in_data_rec              IN     GHR_WGI_PKG.wgi_in_rec_type
    ,p_wgi_out_data_rec             IN OUT NOCOPY GHR_WGI_PKG.wgi_out_rec_type
   );
--
end ghr_custom_wgi_validation;

/
