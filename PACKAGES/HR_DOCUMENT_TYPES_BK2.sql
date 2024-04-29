--------------------------------------------------------
--  DDL for Package HR_DOCUMENT_TYPES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DOCUMENT_TYPES_BK2" AUTHID CURRENT_USER as
/* $Header: hrdtyapi.pkh 120.3.12010000.2 2008/08/06 08:36:12 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_document_type_b >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_document_type_b(
 p_document_type_id               in     number
,p_effective_date                 in     date
,p_document_type                  in     varchar2
,p_language_code                  in     varchar2
,p_description                     in varchar2
,p_category_code                  in     varchar2
,p_active_inactive_flag           in     varchar2
,p_multiple_occurences_flag       in     varchar2
,p_authorization_required         in     varchar2
,p_sub_category_code              in     varchar2
,p_legislation_code               in     varchar2
,p_warning_period                 in     number
,p_request_id                     in     number
,p_program_application_id         in     number
,p_program_id                     in     number
,p_program_update_date            in     date
,p_object_version_number         in     number
);

--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_document_type_a >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_document_type_a(
 p_document_type_id               in     number
,p_effective_date                 in     date
,p_document_type                  in     varchar2
,p_language_code                  in     varchar2
,p_description                     in varchar2
,p_category_code                  in     varchar2
,p_active_inactive_flag           in     varchar2
,p_multiple_occurences_flag       in     varchar2
,p_authorization_required         in     varchar2
,p_sub_category_code              in     varchar2
,p_legislation_code               in     varchar2
,p_warning_period                 in     number
,p_request_id                     in     number
,p_program_application_id         in     number
,p_program_id                     in     number
,p_program_update_date            in     date
,p_object_version_number          in     number
);
end hr_document_types_bk2;
--
--

/
