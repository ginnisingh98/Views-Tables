--------------------------------------------------------
--  DDL for Package PAY_FR_CPAM_PREPROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_CPAM_PREPROCESSOR" AUTHID CURRENT_USER AS
/* $Header: pyfrcpam.pkh 120.0 2005/05/29 04:59:24 appldev noship $  */
--
PROCEDURE CPAM_INFO_CREATE(
         p_effective_start_date      IN DATE
        ,p_effective_end_date        IN DATE
        ,p_element_entry_id          IN NUMBER
        ,p_assignment_id             IN NUMBER
        ,p_element_link_id           IN NUMBER
        ,p_entry_type                IN VARCHAR2
        ,p_date_earned               IN DATE
        );

--

procedure CPAM_INFO_UPDATE(
         p_effective_start_date      IN DATE
        ,p_effective_end_date        IN DATE
        ,p_element_entry_id          IN NUMBER
        ,p_date_earned               IN DATE
        ,p_entry_type_o              IN VARCHAR2
        ,p_effective_start_date_o    IN DATE
        ,p_assignment_id_o           IN NUMBER
        ,p_element_link_id_o         IN NUMBER
        ,p_date_earned_o             IN DATE
        );
--
procedure CPAM_INFO_DELETE(
        p_element_entry_id           IN NUMBER
       ,p_element_link_id_o          IN NUMBER
       ,p_effective_start_date_o     IN DATE
       ,p_assignment_id_o            IN NUMBER
       ,p_datetrack_mode             IN VARCHAR2
        );
--


END PAY_FR_CPAM_PREPROCESSOR;

 

/
