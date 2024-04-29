--------------------------------------------------------
--  DDL for Package GHR_EXTRA_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_EXTRA_INFO" AUTHID CURRENT_USER AS
/* $Header: ghexinfo.pkh 120.0.12010000.3 2009/05/26 11:56:41 utokachi noship $ */
   g_records_fetched   NUMBER;
   g_current_record    NUMBER;


   TYPE r_extra_info_type IS RECORD (
        extra_info_id           per_position_extra_info.position_extra_info_id%type
       ,id                      per_position_extra_info.position_id%type
       ,information_type        per_position_extra_info.information_type%type
       ,request_id              per_position_extra_info.request_id%type
       ,program_application_id  per_position_extra_info.program_application_id%type
       ,program_id              per_position_extra_info.program_id%type
       ,program_update_date     per_position_extra_info.program_update_date%type
       ,attribute_category      per_position_extra_info.poei_attribute_category%type
       ,attribute1              per_position_extra_info.poei_attribute1%type
       ,attribute2              per_position_extra_info.poei_attribute2%type
       ,attribute3              per_position_extra_info.poei_attribute3%type
       ,attribute4              per_position_extra_info.poei_attribute4%type
       ,attribute5              per_position_extra_info.poei_attribute5%type
       ,attribute6              per_position_extra_info.poei_attribute6%type
       ,attribute7              per_position_extra_info.poei_attribute7%type
       ,attribute8              per_position_extra_info.poei_attribute8%type
       ,attribute9              per_position_extra_info.poei_attribute9%type
       ,attribute10             per_position_extra_info.poei_attribute10%type
       ,attribute11             per_position_extra_info.poei_attribute11%type
       ,attribute12             per_position_extra_info.poei_attribute12%type
       ,attribute13             per_position_extra_info.poei_attribute13%type
       ,attribute14             per_position_extra_info.poei_attribute14%type
       ,attribute15             per_position_extra_info.poei_attribute15%type
       ,attribute16             per_position_extra_info.poei_attribute16%type
       ,attribute17             per_position_extra_info.poei_attribute17%type
       ,attribute18             per_position_extra_info.poei_attribute18%type
       ,attribute19             per_position_extra_info.poei_attribute19%type
       ,attribute20             per_position_extra_info.poei_attribute20%type
       ,information_category    per_position_extra_info.poei_information_category%type
       ,information1            per_position_extra_info.poei_information1%type
       ,information2            per_position_extra_info.poei_information2%type
       ,information3            per_position_extra_info.poei_information3%type
       ,information4            per_position_extra_info.poei_information4%type
       ,information5            per_position_extra_info.poei_information5%type
       ,information6            per_position_extra_info.poei_information6%type
       ,information7            per_position_extra_info.poei_information7%type
       ,information8            per_position_extra_info.poei_information8%type
       ,information9            per_position_extra_info.poei_information9%type
       ,information10           per_position_extra_info.poei_information10%type
       ,information11           per_position_extra_info.poei_information11%type
       ,information12           per_position_extra_info.poei_information12%type
       ,information13           per_position_extra_info.poei_information13%type
       ,information14           per_position_extra_info.poei_information14%type
       ,information15           per_position_extra_info.poei_information15%type
       ,information16           per_position_extra_info.poei_information16%type
       ,information17           per_position_extra_info.poei_information17%type
       ,information18           per_position_extra_info.poei_information18%type
       ,information19           per_position_extra_info.poei_information19%type
       ,information20           per_position_extra_info.poei_information20%type
       ,information21           per_position_extra_info.poei_information21%type
       ,information22           per_position_extra_info.poei_information22%type
       ,information23           per_position_extra_info.poei_information23%type
       ,information24           per_position_extra_info.poei_information24%type
       ,information25           per_position_extra_info.poei_information25%type
       ,information26           per_position_extra_info.poei_information26%type
       ,information27           per_position_extra_info.poei_information27%type
       ,information28           per_position_extra_info.poei_information28%type
       ,information29           per_position_extra_info.poei_information29%type
       ,information30           per_position_extra_info.poei_information30%type
       ,object_version_number   per_position_extra_info.object_version_number%type
       ,last_update_date        per_position_extra_info.last_update_date%type
       ,last_updated_by         per_position_extra_info.last_updated_by%type
       ,last_update_login       per_position_extra_info.last_update_login%type
       ,created_by              per_position_extra_info.created_by%type
       ,creation_date           per_position_extra_info.creation_date%type
   );
   TYPE r_short_extra_info_type IS RECORD (
        extra_info_id           per_position_extra_info.position_extra_info_id%type
       ,id                      per_position_extra_info.position_id%type
       ,information_type        per_position_extra_info.information_type%type
       ,object_version_number   per_position_extra_info.object_version_number%type
       ,last_update_date        per_position_extra_info.last_update_date%type
       ,last_updated_by         per_position_extra_info.last_updated_by%type
       ,last_update_login       per_position_extra_info.last_update_login%type
       ,created_by              per_position_extra_info.created_by%type
       ,creation_date           per_position_extra_info.creation_date%type
   );

   TYPE c_extra_info_type IS REF CURSOR RETURN r_short_extra_info_type;

   TYPE r_extra_info_tab_type IS TABLE OF r_extra_info_type
          INDEX BY BINARY_INTEGER;
   r_extra_info_tab  r_extra_info_tab_type;

-- -----------------------
  FUNCTION OPEN_FETCH_CURSOR (
-- -----------------------
    p_form_name            in         varchar2
   ,p_date_effective       in out NOCOPY date
   ,p_id                   in out NOCOPY number
   ,p_information_type     in out NOCOPY varchar2
   )
   RETURN NUMBER;

-- -----------------------
   FUNCTION FETCH_CURSOR(
-- -----------------------
    p_extra_info_id           out NOCOPY number
   ,p_id                      out NOCOPY number
   ,p_information_type        out NOCOPY varchar2
   ,p_request_id              out NOCOPY number
   ,p_program_application_id  out NOCOPY number
   ,p_program_id              out NOCOPY number
   ,p_program_update_date     out NOCOPY date
   ,p_attribute_category      out NOCOPY varchar2
   ,p_attribute1              out NOCOPY varchar2
   ,p_attribute2              out NOCOPY varchar2
   ,p_attribute3              out NOCOPY varchar2
   ,p_attribute4              out NOCOPY varchar2
   ,p_attribute5              out NOCOPY varchar2
   ,p_attribute6              out NOCOPY varchar2
   ,p_attribute7              out NOCOPY varchar2
   ,p_attribute8              out NOCOPY varchar2
   ,p_attribute9              out NOCOPY varchar2
   ,p_attribute10             out NOCOPY varchar2
   ,p_attribute11             out NOCOPY varchar2
   ,p_attribute12             out NOCOPY varchar2
   ,p_attribute13             out NOCOPY varchar2
   ,p_attribute14             out NOCOPY varchar2
   ,p_attribute15             out NOCOPY varchar2
   ,p_attribute16             out NOCOPY varchar2
   ,p_attribute17             out NOCOPY varchar2
   ,p_attribute18             out NOCOPY varchar2
   ,p_attribute19             out NOCOPY varchar2
   ,p_attribute20             out NOCOPY varchar2
   ,p_information_category    out NOCOPY varchar2
   ,p_information1            out NOCOPY varchar2
   ,p_information2            out NOCOPY varchar2
   ,p_information3            out NOCOPY varchar2
   ,p_information4            out NOCOPY varchar2
   ,p_information5            out NOCOPY varchar2
   ,p_information6            out NOCOPY varchar2
   ,p_information7            out NOCOPY varchar2
   ,p_information8            out NOCOPY varchar2
   ,p_information9            out NOCOPY varchar2
   ,p_information10           out NOCOPY varchar2
   ,p_information11           out NOCOPY varchar2
   ,p_information12           out NOCOPY varchar2
   ,p_information13           out NOCOPY varchar2
   ,p_information14           out NOCOPY varchar2
   ,p_information15           out NOCOPY varchar2
   ,p_information16           out NOCOPY varchar2
   ,p_information17           out NOCOPY varchar2
   ,p_information18           out NOCOPY varchar2
   ,p_information19           out NOCOPY varchar2
   ,p_information20           out NOCOPY varchar2
   ,p_information21           out NOCOPY varchar2
   ,p_information22           out NOCOPY varchar2
   ,p_information23           out NOCOPY varchar2
   ,p_information24           out NOCOPY varchar2
   ,p_information25           out NOCOPY varchar2
   ,p_information26           out NOCOPY varchar2
   ,p_information27           out NOCOPY varchar2
   ,p_information28           out NOCOPY varchar2
   ,p_information29           out NOCOPY varchar2
   ,p_information30           out NOCOPY varchar2
   ,p_object_version_number   out NOCOPY number
   ,p_last_update_date        out NOCOPY date
   ,p_last_updated_by         out NOCOPY number
   ,p_last_update_login       out NOCOPY number
   ,p_created_by              out NOCOPY number
   ,p_creation_date           out NOCOPY date
   )
   RETURN VARCHAR2;
-- -----------------------
  PROCEDURE CLOSE_CURSOR(
-- -----------------------
   c_extra_info IN OUT NOCOPY c_extra_info_type
   );
END;

/
