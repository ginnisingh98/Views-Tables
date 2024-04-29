--------------------------------------------------------
--  DDL for Package PAY_KR_ENTRIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_ENTRIES_PKG" AUTHID CURRENT_USER as
/* $Header: pykretr.pkh 120.7.12010000.2 2008/11/26 16:23:44 vaisriva ship $ */
-- size limit of input value in one element = 15
g_iv_max constant integer := 15;

type ev_rec is record
(
  input_value_id pay_input_values_f.input_value_id%TYPE,
  entry_value    pay_element_entry_values_f.screen_entry_value%TYPE,
  d_entry_value  hr_lookups.meaning%TYPE
);

type ev_rec_tbl is table of ev_rec index by binary_integer;

--
-- For Forms cache.
-- <How to use>
-- elm_tbl(element_type_id).element_code
-- iv_tbl(input_value_id).display_sequence
--
type elm_code_tbl is table of pay_element_types_f.element_name%TYPE index by binary_integer;
type elm_rec is record
(
  element_code        pay_element_types_f.element_name%TYPE,
  input_currency_code pay_element_types_f.input_currency_code%TYPE,
  multiple_entries_allowed_flag  pay_element_types_f.multiple_entries_allowed_flag%TYPE
);
type elm_rec_tbl is table of elm_rec index by binary_integer;

type iv_rec is record
(
  element_type_id  pay_input_values_f.element_type_id%TYPE,
  display_sequence pay_input_values_f.display_sequence%TYPE,
  uom              pay_input_values_f.uom%TYPE,
  mandatory_flag   pay_input_values_f.mandatory_flag%TYPE,
  max_length       number,
  format_mask      varchar2(80)
);

type iv_rec_tbl is table of iv_rec index by binary_integer;

-- ---------------------------------------------------------------------
-- |------------------------< calc_age >-------------------------------|
-- ---------------------------------------------------------------------
-- Calculation age of person from registration number
function calc_age
(
  p_national_identifier in varchar2,
  p_date_of_birth       in date,
  p_effective_date      in date
) return number;

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
-- |------------------------< derive_attributes >----------------------|
-- ---------------------------------------------------------------------
-- Call this procedure in the following triggers.
--   1) PRE-FORM
--   2) INIT_DATE_DEPENDENT
-- On Forms, set properties using output variables.
Procedure derive_attributes
(
  p_elm_code_tbl      in  elm_code_tbl,
  p_effective_date    in  date,
  p_business_group_id in  number,
  p_elm_rec_tbl       out NOCOPY elm_rec_tbl,
  p_iv_rec_tbl        out NOCOPY iv_rec_tbl
);

-- ---------------------------------------------------------------------
-- |------------------------< derive_format_mask >---------------------|
-- ---------------------------------------------------------------------
-- Call this procedure in the following triggers.
--   1) PRE-FORM
-- On Forms, set properties using output variables.
Procedure derive_format_mask
(
  p_elm_rec_tbl in     elm_rec_tbl,
  p_iv_rec_tbl  in out NOCOPY iv_rec_tbl
);

-- ---------------------------------------------------------------------
-- |-----------------------------< chk_entry >-------------------------|
-- ---------------------------------------------------------------------
-- This procedure must be called "once" on the following Forms trigger.
--   1) WHEN-DATABASE-RECORD(when INSERTING)
-- Not necessary to call this procedure on WHEN-VALIDATE-ITEM trigger
-- when updating.
-- When deleting, this procedure is called in part of API.
-- Call derive_default_values procedure instead of this procedure chk_entry.
Procedure chk_entry
(
  p_element_entry_id      in     number,
  p_assignment_id         in     number,
  p_element_link_id       in     number,
  p_entry_type            in     varchar2,
  p_original_entry_id     in     number   default null,
  p_target_entry_id       in     number   default null,
  p_effective_date        in     date,
  p_validation_start_date in     date,
  p_validation_end_date   in     date,
  p_effective_start_date  in out NOCOPY date,
  p_effective_end_date    in out NOCOPY date,
  p_usage                 in     varchar2,
  p_dt_update_mode        in     varchar2,
  p_dt_delete_mode        in     varchar2
);

-- ---------------------------------------------------------------------
-- |---------------------< derive_default_values >---------------------|
-- ---------------------------------------------------------------------
-- This procedure must be called in the following trigger.
--   1) WHEN-DATABASE-RECORD(when INSERTING)
-- This procedure includes chk_entry procedure.
Procedure derive_default_values
(
  p_assignment_id        in            number,
  p_element_code         in            varchar2,
  p_business_group_id    in            varchar2,
  p_entry_type           in            varchar2,
  p_element_link_id      out NOCOPY    number,
  p_ev_rec_tbl           out NOCOPY    ev_rec_tbl,
  p_effective_date       in            date,
  p_effective_start_date in out NOCOPY date,
  p_effective_end_date   in out NOCOPY date
);

-- ---------------------------------------------------------------------
-- |---------------------------< chk_entry_value >---------------------|
-- ---------------------------------------------------------------------
-- This procedure must be called every time before dtcsapi call.
Procedure chk_entry_value
(
  p_element_link_id   in     number,
  p_input_value_id    in     number,
  p_effective_date    in     date,
  p_business_group_id in     number,
  p_assignment_id     in     number,
  p_user_value        in out NOCOPY varchar2,
  p_canonical_value   out    NOCOPY varchar2,
  p_hot_defaulted     out    NOCOPY boolean,
  p_min_max_warning   out    NOCOPY boolean,
  p_user_min_value    out    NOCOPY varchar2,
  p_user_max_value    out    NOCOPY varchar2,
  p_formula_warning   out    NOCOPY boolean,
  p_formula_message   out    NOCOPY varchar2
);

-- ---------------------------------------------------------------------
-- |--------------------------< find_dt_upd_modes >--------------------|
-- ---------------------------------------------------------------------
Procedure find_dt_upd_modes
(
  p_effective_date       in  date,
  p_base_key_value       in  number,
  p_correction           out NOCOPY boolean,
  p_update               out NOCOPY boolean,
  p_update_override      out NOCOPY boolean,
  p_update_change_insert out NOCOPY boolean
);

-- ---------------------------------------------------------------------
-- |--------------------------< find_dt_del_modes >--------------------|
-- ---------------------------------------------------------------------
Procedure find_dt_del_modes
(
  p_effective_date     in  date,
  p_base_key_value     in  number,
  p_zap                out NOCOPY boolean,
  p_delete             out NOCOPY boolean,
  p_future_change      out NOCOPY boolean,
  p_delete_next_change out NOCOPY boolean
);

-- ---------------------------------------------------------------------
-- |-------------------------------< ins_lck >-------------------------|
-- ---------------------------------------------------------------------
Procedure ins_lck
(
  p_effective_date        in  date,
  p_datetrack_mode        in  varchar2,
  p_rec                   in  pay_element_entries_f%ROWTYPE,
  p_validation_start_date out NOCOPY date,
  p_validation_end_date   out NOCOPY date
);

-- ---------------------------------------------------------------------
-- |---------------------------------< lck >---------------------------|
-- ---------------------------------------------------------------------
Procedure lck
(
  p_effective_date        in  date,
  p_datetrack_mode        in  varchar2,
  p_element_entry_id      in  number,
  p_object_version_number in  number,
  p_validation_start_date out NOCOPY date,
  p_validation_end_date   out NOCOPY date
);

-- ---------------------------------------------------------------------
-- |-------------------------------< ins >-----------------------------|
-- ---------------------------------------------------------------------
Procedure ins
(
  p_validate              in         boolean,
  p_effective_date        in         date,
  p_assignment_id         in         number,
  p_element_link_id       in         number,
  p_ev_rec_tbl            in         ev_rec_tbl,
  p_business_group_id     in         number,
  p_element_entry_id      out NOCOPY number,
  p_effective_start_date  out NOCOPY date,
  p_effective_end_date    out NOCOPY date,
  p_object_version_number out NOCOPY number
);

-- ---------------------------------------------------------------------
-- |-------------------------------< upd >-----------------------------|
-- ---------------------------------------------------------------------
Procedure upd
(
  p_validate              in            boolean,
  p_effective_date        in            date,
  p_datetrack_update_mode in            varchar2,
  p_element_entry_id      in            number,
  p_object_version_number in out NOCOPY number,
  p_ev_rec_tbl            in            ev_rec_tbl,
  p_business_group_id     in            number,
  p_effective_start_date  out NOCOPY    date,
  p_effective_end_date    out NOCOPY    date
);

-- ---------------------------------------------------------------------
-- |-------------------------------< del >-----------------------------|
-- ---------------------------------------------------------------------
Procedure del
(
  p_validate              in            boolean,
  p_effective_date        in            date,
  p_datetrack_delete_mode in            varchar2,
  p_element_entry_id      in            number,
  p_object_version_number in out NOCOPY number,
  p_effective_start_date  out    NOCOPY date,
  p_effective_end_date    out    NOCOPY date
);

-- ---------------------------------------------------------------------
-- Function to handle contact relationship data
-- ---------------------------------------------------------------------
-- upd_contact_info
-- ---------------------------------------------------------------------
procedure upd_contact_info
( p_validate                 in     boolean  default null
 ,p_effective_date           in     date
 ,p_contact_relationship_id  in     number
 ,p_object_version_number    in out NOCOPY number
 ,p_cont_information2        in     varchar2 default null
 ,p_cont_information3        in     varchar2 default null
 ,p_cont_information4        in     varchar2 default null
 ,p_cont_information5        in     varchar2 default null
 ,p_cont_information7        in     varchar2 default null
 ,p_cont_information8        in     varchar2 default null
 ,p_cont_information10	     in     varchar2 default null
 ,p_cont_information12	     in     varchar2 default null
 ,p_cont_information13	     in     varchar2 default null
 ,p_cont_information14	     in     varchar2 default null
);

-- ---------------------------------------------------------------------
-- Procedure to handle contact Extra Information Data
-- ---------------------------------------------------------------------
-- upd_contact_info
-- ---------------------------------------------------------------------
procedure upd_contact_extra_info
( p_effective_date		IN		DATE,
  p_contact_extra_info_id	IN		NUMBER,
  p_contact_relationship_id	IN		NUMBER,
  p_contact_ovn			IN OUT NOCOPY	NUMBER,
  p_cei_information1            IN		VARCHAR2,
  p_cei_information2            IN		VARCHAR2,
  p_cei_information3            IN		VARCHAR2,
  p_cei_information4            IN		VARCHAR2,
  p_cei_information5            IN		VARCHAR2,
  p_cei_information6            IN		VARCHAR2,
  p_cei_information7            IN		VARCHAR2,
  p_cei_information8            IN		VARCHAR2,
  p_cei_information9            IN		VARCHAR2,
  p_cei_information10           IN		VARCHAR2, -- Bug 5667762
  p_cei_information11           IN		VARCHAR2,
  p_cei_information12           IN		VARCHAR2, -- Bug 6630135
  p_cei_information13           IN		VARCHAR2, -- Bug 6705170
  p_cei_information14           IN		VARCHAR2, -- Bug 7142612
  p_cei_information15           IN		VARCHAR2, -- Bug 7142612
  p_cei_effective_start_date    OUT NOCOPY	DATE,
  p_cei_effective_end_date      OUT NOCOPY	DATE
);

-- ---------------------------------------------------------------------
-- Procedure to handle contact Extra Information Data
-- ---------------------------------------------------------------------
-- create_contact_extra_info
-- ---------------------------------------------------------------------

procedure create_contact_extra_info
( p_effective_date            IN		DATE,
  p_contact_extra_info_id     OUT NOCOPY	NUMBER,
  p_contact_relationship_id   IN		NUMBER,
  p_contact_ovn               OUT NOCOPY	NUMBER,
  p_cei_information1          IN		VARCHAR2,
  p_cei_information2          IN		VARCHAR2,
  p_cei_information3          IN		VARCHAR2,
  p_cei_information4          IN		VARCHAR2,
  p_cei_information5          IN		VARCHAR2,
  p_cei_information6          IN		VARCHAR2,
  p_cei_information7          IN		VARCHAR2,
  p_cei_information8          IN		VARCHAR2,
  p_cei_information9          IN		VARCHAR2,
  p_cei_information10         IN		VARCHAR2, -- Bug 5667762
  p_cei_information11         IN		VARCHAR2,
  p_cei_information12         IN		VARCHAR2, -- Bug 6630135
  p_cei_information13         IN		VARCHAR2, -- Bug 6705170
  p_cei_information14         IN		VARCHAR2, -- Bug 7142612
  p_cei_information15         IN		VARCHAR2, -- Bug 7142612
  p_cei_effective_start_date  OUT NOCOPY	DATE,
  p_cei_effective_end_date    OUT NOCOPY	DATE
);

end pay_kr_entries_pkg;

/
