--------------------------------------------------------
--  DDL for Package PAY_KR_BEE_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_BEE_UPLOAD" 
/* $Header: pykrbee.pkh 115.3 2003/05/30 07:03:11 nnaresh noship $ */
AUTHID CURRENT_USER AS

-- This constant is defined in the spec as the defaults needs
-- to be the same in the header and the body.

   c_default_action_if_exists   CONSTANT VARCHAR2 (1)  := 'I';

   TYPE g_batch_line IS RECORD (
      session_date                  DATE,
      batch_id                      pay_batch_lines.batch_id%TYPE,
      assignment_id                 pay_batch_lines.assignment_id%TYPE,
      assignment_number             pay_batch_lines.assignment_number%TYPE,
      attribute_category            pay_batch_lines.attribute_category%TYPE,
      attribute1                    pay_batch_lines.attribute1%TYPE,
      attribute2                    pay_batch_lines.attribute2%TYPE,
      attribute3                    pay_batch_lines.attribute3%TYPE,
      attribute4                    pay_batch_lines.attribute4%TYPE,
      attribute5                    pay_batch_lines.attribute5%TYPE,
      attribute6                    pay_batch_lines.attribute6%TYPE,
      attribute7                    pay_batch_lines.attribute7%TYPE,
      attribute8                    pay_batch_lines.attribute8%TYPE,
      attribute9                    pay_batch_lines.attribute9%TYPE,
      attribute10                   pay_batch_lines.attribute10%TYPE,
      attribute11                   pay_batch_lines.attribute11%TYPE,
      attribute12                   pay_batch_lines.attribute12%TYPE,
      attribute13                   pay_batch_lines.attribute13%TYPE,
      attribute14                   pay_batch_lines.attribute14%TYPE,
      attribute15                   pay_batch_lines.attribute15%TYPE,
      attribute16                   pay_batch_lines.attribute16%TYPE,
      attribute17                   pay_batch_lines.attribute17%TYPE,
      attribute18                   pay_batch_lines.attribute18%TYPE,
      attribute19                   pay_batch_lines.attribute19%TYPE,
      attribute20                   pay_batch_lines.attribute20%TYPE,
      batch_sequence                pay_batch_lines.batch_sequence%TYPE,
      concatenated_segments         pay_batch_lines.concatenated_segments%TYPE,
      cost_allocation_keyflex_id    pay_batch_lines.cost_allocation_keyflex_id%TYPE,
      effective_date                pay_batch_lines.effective_date%TYPE,
      effective_start_date          pay_batch_lines.effective_start_date%TYPE,
      effective_end_date            pay_batch_lines.effective_end_date%TYPE,
      element_name                  pay_batch_lines.element_name%TYPE,
      element_type_id               pay_batch_lines.element_type_id%TYPE,
      reason                        pay_batch_lines.reason%TYPE,
      segment1                      pay_batch_lines.segment1%TYPE,
      segment2                      pay_batch_lines.segment2%TYPE,
      segment3                      pay_batch_lines.segment3%TYPE,
      segment4                      pay_batch_lines.segment4%TYPE,
      segment5                      pay_batch_lines.segment5%TYPE,
      segment6                      pay_batch_lines.segment6%TYPE,
      segment7                      pay_batch_lines.segment7%TYPE,
      segment8                      pay_batch_lines.segment8%TYPE,
      segment9                      pay_batch_lines.segment9%TYPE,
      segment10                     pay_batch_lines.segment10%TYPE,
      segment11                     pay_batch_lines.segment11%TYPE,
      segment12                     pay_batch_lines.segment12%TYPE,
      segment13                     pay_batch_lines.segment13%TYPE,
      segment14                     pay_batch_lines.segment14%TYPE,
      segment15                     pay_batch_lines.segment15%TYPE,
      segment16                     pay_batch_lines.segment16%TYPE,
      segment17                     pay_batch_lines.segment17%TYPE,
      segment18                     pay_batch_lines.segment18%TYPE,
      segment19                     pay_batch_lines.segment19%TYPE,
      segment20                     pay_batch_lines.segment20%TYPE,
      segment21                     pay_batch_lines.segment21%TYPE,
      segment22                     pay_batch_lines.segment22%TYPE,
      segment23                     pay_batch_lines.segment23%TYPE,
      segment24                     pay_batch_lines.segment24%TYPE,
      segment25                     pay_batch_lines.segment25%TYPE,
      segment26                     pay_batch_lines.segment26%TYPE,
      segment27                     pay_batch_lines.segment27%TYPE,
      segment28                     pay_batch_lines.segment28%TYPE,
      segment29                     pay_batch_lines.segment29%TYPE,
      segment30                     pay_batch_lines.segment30%TYPE,
      value_1                       pay_batch_lines.value_1%TYPE,
      value_2                       pay_batch_lines.value_2%TYPE,
      value_3                       pay_batch_lines.value_3%TYPE,
      value_4                       pay_batch_lines.value_4%TYPE,
      value_5                       pay_batch_lines.value_5%TYPE,
      value_6                       pay_batch_lines.value_6%TYPE,
      value_7                       pay_batch_lines.value_7%TYPE,
      value_8                       pay_batch_lines.value_8%TYPE,
      value_9                       pay_batch_lines.value_9%TYPE,
      value_10                      pay_batch_lines.value_10%TYPE,
      value_11                      pay_batch_lines.value_11%TYPE,
      value_12                      pay_batch_lines.value_12%TYPE,
      value_13                      pay_batch_lines.value_13%TYPE,
      value_14                      pay_batch_lines.value_14%TYPE,
      value_15                      pay_batch_lines.value_15%TYPE,
      entry_information_category    pay_batch_lines.entry_information_category%TYPE,
      entry_information1  pay_batch_lines.entry_information1%TYPE,
      entry_information2  pay_batch_lines.entry_information1%TYPE,
      entry_information3  pay_batch_lines.entry_information1%TYPE,
      entry_information4  pay_batch_lines.entry_information1%TYPE,
      entry_information5  pay_batch_lines.entry_information1%TYPE,
      entry_information6  pay_batch_lines.entry_information1%TYPE,
      entry_information7  pay_batch_lines.entry_information1%TYPE,
      entry_information8  pay_batch_lines.entry_information1%TYPE,
      entry_information9  pay_batch_lines.entry_information1%TYPE,
      entry_information10  pay_batch_lines.entry_information1%TYPE,
      entry_information11  pay_batch_lines.entry_information1%TYPE,
      entry_information12  pay_batch_lines.entry_information1%TYPE,
      entry_information13  pay_batch_lines.entry_information1%TYPE,
      entry_information14  pay_batch_lines.entry_information1%TYPE,
      entry_information15  pay_batch_lines.entry_information1%TYPE,
      entry_information16  pay_batch_lines.entry_information1%TYPE,
      entry_information17  pay_batch_lines.entry_information1%TYPE,
      entry_information18  pay_batch_lines.entry_information1%TYPE,
      entry_information19  pay_batch_lines.entry_information1%TYPE,
      entry_information20  pay_batch_lines.entry_information1%TYPE,
      entry_information21  pay_batch_lines.entry_information1%TYPE,
      entry_information22  pay_batch_lines.entry_information1%TYPE,
      entry_information23  pay_batch_lines.entry_information1%TYPE,
      entry_information24  pay_batch_lines.entry_information1%TYPE,
      entry_information25  pay_batch_lines.entry_information1%TYPE,
      entry_information26  pay_batch_lines.entry_information1%TYPE,
      entry_information27  pay_batch_lines.entry_information1%TYPE,
      entry_information28  pay_batch_lines.entry_information1%TYPE,
      entry_information29  pay_batch_lines.entry_information1%TYPE,
      entry_information30  pay_batch_lines.entry_information1%TYPE
                                                                 );

   -- OVERLOADING PROCEDURE
   PROCEDURE create_batch_line (
      p_batch_line   IN       g_batch_line,
      p_bline_id     OUT NOCOPY     NUMBER,
      p_obj_vn       OUT NOCOPY     NUMBER
   );

   PROCEDURE upload (
      errbuf                     OUT NOCOPY      VARCHAR2,
      retcode                    OUT NOCOPY      NUMBER,
      p_file_name                IN       VARCHAR2,
      p_effective_date           IN       VARCHAR2,
      p_business_group_id        IN       per_business_groups.business_group_id%TYPE,
      p_delimiter                IN       VARCHAR2,
      p_action_if_exists         IN       VARCHAR2 DEFAULT NULL,
      p_date_effective_changes   IN       VARCHAR2 DEFAULT NULL,
      p_batch_name               IN       VARCHAR2 DEFAULT NULL
   );

   PROCEDURE break_up_line (
      p_line           IN       VARCHAR2,
      p_session_date   IN       DATE,
      p_batch_id       IN       pay_batch_lines.batch_id%TYPE,
      p_batch_seq      IN       pay_batch_lines.batch_sequence%TYPE,
      p_delimiter      IN       VARCHAR2,
      p_bg_id          IN       per_business_groups.business_group_id%TYPE,
      p_leg_cd         IN       per_business_groups.legislation_code%TYPE,
      p_batch_line     OUT NOCOPY  g_batch_line
   );

   PROCEDURE create_batch_header (
      p_effective_date           IN       DATE,
      p_name                     IN       VARCHAR2,
      p_bg_id                    IN       NUMBER,
      p_action_if_exists         IN       VARCHAR2 DEFAULT c_default_action_if_exists ,
      p_date_effective_changes   IN       VARCHAR2 DEFAULT NULL,
      p_batch_id                 OUT NOCOPY    NUMBER,
      p_ovn                      OUT NOCOPY    NUMBER
   );

   PROCEDURE create_batch_line (
      p_session_date                 IN       DATE,
      p_batch_id                     IN       NUMBER,
      p_assignment_id                IN       NUMBER DEFAULT NULL,
      p_assignment_number            IN       VARCHAR2 DEFAULT NULL,
      p_attribute_category           IN       VARCHAR2 DEFAULT NULL,
      p_attribute1                   IN       VARCHAR2 DEFAULT NULL,
      p_attribute2                   IN       VARCHAR2 DEFAULT NULL,
      p_attribute3                   IN       VARCHAR2 DEFAULT NULL,
      p_attribute4                   IN       VARCHAR2 DEFAULT NULL,
      p_attribute5                   IN       VARCHAR2 DEFAULT NULL,
      p_attribute6                   IN       VARCHAR2 DEFAULT NULL,
      p_attribute7                   IN       VARCHAR2 DEFAULT NULL,
      p_attribute8                   IN       VARCHAR2 DEFAULT NULL,
      p_attribute9                   IN       VARCHAR2 DEFAULT NULL,
      p_attribute10                  IN       VARCHAR2 DEFAULT NULL,
      p_attribute11                  IN       VARCHAR2 DEFAULT NULL,
      p_attribute12                  IN       VARCHAR2 DEFAULT NULL,
      p_attribute13                  IN       VARCHAR2 DEFAULT NULL,
      p_attribute14                  IN       VARCHAR2 DEFAULT NULL,
      p_attribute15                  IN       VARCHAR2 DEFAULT NULL,
      p_attribute16                  IN       VARCHAR2 DEFAULT NULL,
      p_attribute17                  IN       VARCHAR2 DEFAULT NULL,
      p_attribute18                  IN       VARCHAR2 DEFAULT NULL,
      p_attribute19                  IN       VARCHAR2 DEFAULT NULL,
      p_attribute20                  IN       VARCHAR2 DEFAULT NULL,
      p_batch_sequence               IN       NUMBER DEFAULT NULL,
      p_concatenated_segments        IN       VARCHAR2 DEFAULT NULL,
      p_cost_allocation_keyflex_id   IN       NUMBER DEFAULT NULL,
      p_effective_date               IN       DATE,
      p_effective_start_date         IN       DATE DEFAULT NULL,
      p_effective_end_date           IN       DATE DEFAULT NULL,
      p_element_name                 IN       VARCHAR2 DEFAULT NULL,
      p_element_type_id              IN       NUMBER DEFAULT NULL,
      p_reason                       IN       VARCHAR2 DEFAULT NULL,
      p_segment1                     IN       VARCHAR2 DEFAULT NULL,
      p_segment2                     IN       VARCHAR2 DEFAULT NULL,
      p_segment3                     IN       VARCHAR2 DEFAULT NULL,
      p_segment4                     IN       VARCHAR2 DEFAULT NULL,
      p_segment5                     IN       VARCHAR2 DEFAULT NULL,
      p_segment6                     IN       VARCHAR2 DEFAULT NULL,
      p_segment7                     IN       VARCHAR2 DEFAULT NULL,
      p_segment8                     IN       VARCHAR2 DEFAULT NULL,
      p_segment9                     IN       VARCHAR2 DEFAULT NULL,
      p_segment10                    IN       VARCHAR2 DEFAULT NULL,
      p_segment11                    IN       VARCHAR2 DEFAULT NULL,
      p_segment12                    IN       VARCHAR2 DEFAULT NULL,
      p_segment13                    IN       VARCHAR2 DEFAULT NULL,
      p_segment14                    IN       VARCHAR2 DEFAULT NULL,
      p_segment15                    IN       VARCHAR2 DEFAULT NULL,
      p_segment16                    IN       VARCHAR2 DEFAULT NULL,
      p_segment17                    IN       VARCHAR2 DEFAULT NULL,
      p_segment18                    IN       VARCHAR2 DEFAULT NULL,
      p_segment19                    IN       VARCHAR2 DEFAULT NULL,
      p_segment20                    IN       VARCHAR2 DEFAULT NULL,
      p_segment21                    IN       VARCHAR2 DEFAULT NULL,
      p_segment22                    IN       VARCHAR2 DEFAULT NULL,
      p_segment23                    IN       VARCHAR2 DEFAULT NULL,
      p_segment24                    IN       VARCHAR2 DEFAULT NULL,
      p_segment25                    IN       VARCHAR2 DEFAULT NULL,
      p_segment26                    IN       VARCHAR2 DEFAULT NULL,
      p_segment27                    IN       VARCHAR2 DEFAULT NULL,
      p_segment28                    IN       VARCHAR2 DEFAULT NULL,
      p_segment29                    IN       VARCHAR2 DEFAULT NULL,
      p_segment30                    IN       VARCHAR2 DEFAULT NULL,
      p_value_1                      IN       VARCHAR2 DEFAULT NULL,
      p_value_2                      IN       VARCHAR2 DEFAULT NULL,
      p_value_3                      IN       VARCHAR2 DEFAULT NULL,
      p_value_4                      IN       VARCHAR2 DEFAULT NULL,
      p_value_5                      IN       VARCHAR2 DEFAULT NULL,
      p_value_6                      IN       VARCHAR2 DEFAULT NULL,
      p_value_7                      IN       VARCHAR2 DEFAULT NULL,
      p_value_8                      IN       VARCHAR2 DEFAULT NULL,
      p_value_9                      IN       VARCHAR2 DEFAULT NULL,
      p_value_10                     IN       VARCHAR2 DEFAULT NULL,
      p_value_11                     IN       VARCHAR2 DEFAULT NULL,
      p_value_12                     IN       VARCHAR2 DEFAULT NULL,
      p_value_13                     IN       VARCHAR2 DEFAULT NULL,
      p_value_14                     IN       VARCHAR2 DEFAULT NULL,
      p_value_15                     IN       VARCHAR2 DEFAULT NULL,
      p_entry_information_category   IN       VARCHAR2 DEFAULT NULL,
      p_entry_information1           IN       VARCHAR2 DEFAULT NULL,
      p_entry_information2           IN       VARCHAR2 DEFAULT NULL,
      p_entry_information3           IN       VARCHAR2 DEFAULT NULL,
      p_entry_information4           IN       VARCHAR2 DEFAULT NULL,
      p_entry_information5           IN       VARCHAR2 DEFAULT NULL,
      p_entry_information6           IN       VARCHAR2 DEFAULT NULL,
      p_entry_information7           IN       VARCHAR2 DEFAULT NULL,
      p_entry_information8           IN       VARCHAR2 DEFAULT NULL,
      p_entry_information9           IN       VARCHAR2 DEFAULT NULL,
      p_entry_information10          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information11          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information12          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information13          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information14          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information15          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information16          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information17          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information18          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information19          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information20          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information21          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information22          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information23          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information24          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information25          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information26          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information27          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information28          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information29          IN       VARCHAR2 DEFAULT NULL,
      p_entry_information30          IN       VARCHAR2 DEFAULT NULL,
      p_bl_id                        OUT NOCOPY   NUMBER,
      p_ovn                          OUT NOCOPY   NUMBER
   );


   PROCEDURE get_assignment_info (
      p_bus_group_id         IN       per_assignments_f.business_group_id%TYPE
            DEFAULT NULL,
      p_id_type              IN       VARCHAR2,
      p_id                   IN       VARCHAR2,
      p_effective_date       IN       DATE,
      p_assg_id              OUT NOCOPY  per_assignments_f.assignment_id%TYPE,
      p_assg_nr              OUT NOCOPY  per_assignments_f.assignment_number%TYPE,
      p_start_date           OUT NOCOPY  per_periods_of_service.date_start%TYPE,
      p_final_process_date   OUT NOCOPY  per_periods_of_service.final_process_date%TYPE
   );

   PROCEDURE get_element_info (
      p_leg_cd            IN       VARCHAR2,
      p_element_name      IN OUT NOCOPY VARCHAR2,
      p_element_type_id   IN OUT NOCOPY NUMBER
   );

   FUNCTION get_field (
      p_line        IN OUT NOCOPY   VARCHAR2,
      p_delimiter   IN       VARCHAR2,
      p_start_pos   IN       NUMBER DEFAULT 1,
      p_occurance   IN       NUMBER DEFAULT 1
   )
      RETURN VARCHAR2;

   FUNCTION correct_type_id (p_id_type VARCHAR2)
      RETURN BOOLEAN;

   /*This is called from the concurrent program PYKRUPHI */

  PROCEDURE upload_hia (
      errbuf                     OUT NOCOPY  VARCHAR2,
      retcode                    OUT NOCOPY  NUMBER,
      p_file_name                IN       VARCHAR2,
      p_effective_date           IN       VARCHAR2,
      p_business_group_id        IN       per_business_groups.business_group_id%TYPE,
      p_delimiter                IN       VARCHAR2,
      p_action_if_exists         IN       VARCHAR2 DEFAULT NULL,
      p_date_effective_changes   IN       VARCHAR2 DEFAULT NULL,
      p_batch_name               IN       VARCHAR2 DEFAULT NULL
   );


   /*This is called from the concurrent program PYKRUPNP */

  PROCEDURE upload_npa (
      errbuf                     OUT NOCOPY  VARCHAR2,
      retcode                    OUT NOCOPY  NUMBER,
      p_file_name                IN       VARCHAR2,
      p_effective_date           IN       VARCHAR2,
      p_business_group_id        IN       per_business_groups.business_group_id%TYPE,
      p_delimiter                IN       VARCHAR2,
      p_action_if_exists         IN       VARCHAR2 DEFAULT NULL,
      p_date_effective_changes   IN       VARCHAR2 DEFAULT NULL,
      p_batch_name               IN       VARCHAR2 DEFAULT NULL
   );

function get_row_value   (p_bus_group_id      in number,
                          p_table_name        in varchar2,
                          p_col_name          in varchar2,
                          p_table_value       in varchar2,
                          p_low_high_range    in varchar2,
                          p_effective_date    in date  default null)
         return varchar2;

END pay_kr_bee_upload;

 

/
