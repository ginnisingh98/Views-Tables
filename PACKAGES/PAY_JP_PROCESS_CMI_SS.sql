--------------------------------------------------------
--  DDL for Package PAY_JP_PROCESS_CMI_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_PROCESS_CMI_SS" authid current_user as
/* $Header: pyjpcmis.pkh 120.1 2006/01/15 18:17 keyazawa noship $ */
--
  g_transaction_step_id number;
--
  type t_txn_value_rec is record(
    name hr_api_transaction_values.name%type,
    datatype hr_api_transaction_values.datatype%type,
    varchar2_value hr_api_transaction_values.varchar2_value%type,
    date_value hr_api_transaction_values.date_value%type,
    number_value hr_api_transaction_values.number_value%type);
--
  type t_txn_value_tbl is table of t_txn_value_rec index by binary_integer;
--
  g_txn_value_tbl t_txn_value_tbl;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< calc_car_amount >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure calculates the amount of commutation information for
--   traffic tool.
--
-- Pre-Requisities:
--   N/A
--
-- In Parameters:
--   p_business_group_id       number
--   p_assignment_id           number
--   p_effective_date          date
--   p_attribute_category      varchar2 default null
--   p_attribute1 - 20         varchar2 default null
--   p_means_code              varchar2 default null
--   p_vehicle_info_id         number   default null
--   p_period_code             varchar2 default null
--   p_distance                number   default null
--   p_fuel_cost_code          varchar2 default null
--   p_amount                  number   default null
--   p_parking_fees            number   default null
--   p_equivalent_cost         number   default null
--   p_pay_start_month         varchar2 default null
--   p_pay_end_month           varchar2 default null
--   p_si_start_month_code     varchar2 default null
--   p_update_date             date     default null
--   p_update_reason_code      varchar2 default null
--   p_comments                varchar2 default null
--
-- Out Parameters:
--   p_new_car_amount          nocopy number
--   p_val_returned            nocopy number
--   p_error_message           nocopy long
--
-- Post Success:
--   The amount will be calculated.
--
-- Post Failure:
--   The amount will not be calculated and an error will be raised.
--
-- Developer Implementation Notes:
--   N/A
--
-- Access Status:
--   Public
--
-- {End Of Comments}
-------------------------------------------------------------------------------
procedure calc_car_amount
(
	p_business_group_id   in         number,
	p_assignment_id       in         number,
	p_effective_date      in         date,
	--
	p_attribute_category  in         varchar2 default null,
	p_attribute1          in         varchar2 default null,
	p_attribute2          in         varchar2 default null,
	p_attribute3          in         varchar2 default null,
	p_attribute4          in         varchar2 default null,
	p_attribute5          in         varchar2 default null,
	p_attribute6          in         varchar2 default null,
	p_attribute7          in         varchar2 default null,
	p_attribute8          in         varchar2 default null,
	p_attribute9          in         varchar2 default null,
	p_attribute10         in         varchar2 default null,
	p_attribute11         in         varchar2 default null,
	p_attribute12         in         varchar2 default null,
	p_attribute13         in         varchar2 default null,
	p_attribute14         in         varchar2 default null,
	p_attribute15         in         varchar2 default null,
	p_attribute16         in         varchar2 default null,
	p_attribute17         in         varchar2 default null,
	p_attribute18         in         varchar2 default null,
	p_attribute19         in         varchar2 default null,
	p_attribute20         in         varchar2 default null,
	--
	p_means_code          in         varchar2 default null,
	p_vehicle_info_id     in         number   default null,
	p_period_code         in         varchar2 default null,
	p_distance            in         number   default null,
	p_fuel_cost_code      in         varchar2 default null,
	p_amount              in         number   default null,
	p_parking_fees        in         number   default null,
	p_equivalent_cost     in         number   default null,
	p_pay_start_month     in         varchar2 default null,
	p_pay_end_month       in         varchar2 default null,
	p_si_start_month_code in         varchar2 default null,
	p_update_date         in         date     default null,
	p_update_reason_code  in         varchar2 default null,
	p_comments            in         varchar2 default null,
	--
	p_new_car_amount      out nocopy number,
	p_val_returned        out nocopy number,
	--
	p_error_message       out nocopy long
	--
);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< set_train_transaction_step >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure creates a transaction step for transportation information.
--
-- Pre-Requisities:
--   N/A
--
-- In Parameters:
--   p_item_type               varchar2
--   p_item_key                varchar2
--   p_activity_id             number
--   p_login_person_id         number
--   p_commutation_type        varchar2
--   p_action_type             varchar2
--   p_effective_date          date     default null
--   p_date_track_option       varchar2 default null
--   p_element_entry_id        number   default null
--   p_business_group_id       number   default null
--   p_assignment_id           number   default null
--   p_element_link_id         number   default null
--   p_entry_type              number   default null
--   p_object_version_number   number   default null
--   p_attribute_category      varchar2 default null
--   p_attribute1 - 20         varchar2 default null
--   p_input_value_id1 - 13    number   default null
--   p_means_code              varchar2 default null
--   p_departure_place         varchar2 default null
--   p_arrival_place           varchar2 default null
--   p_via                     varchar2 default null
--   p_period_code             varchar2 default null
--   p_payment_option_code     varchar2 default null
--   p_amount                  number   default null
--   p_pay_start_month         varchar2 default null
--   p_pay_end_month           varchar2 default null
--   p_si_start_month_code     varchar2 default null
--   p_update_date             date     default null
--   p_update_reason_code      varchar2 default null
--   p_comments                varchar2 default null
--
-- Out Patameters:
--   p_error_message           nocopy long
--
-- Post Success:
--   The transaction step will be created.
--
-- Post Failure:
--   The transaction step will no be created and an error will be raised.
--
-- Developer Implementation Notes:
--   N/A
--
-- Access Status:
--   Public
--
-- {End Of Comments}
-------------------------------------------------------------------------------
procedure set_train_transaction_step
(
	--
	p_item_type             in         varchar2,
	p_item_key              in         varchar2,
	p_activity_id           in         number,
	p_login_person_id       in         number,
	--
	p_action_type           in         varchar2,
	p_effective_date        in         date     default null,
	p_date_track_option     in         varchar2 default null,
	p_element_entry_id      in         number   default null,
	p_business_group_id     in         number   default null,
	p_assignment_id         in         number   default null,
	p_element_link_id       in         number   default null,
	p_entry_type            in         varchar2 default null,
	p_object_version_number in         number   default null,
	--
	p_attribute_category    in         varchar2 default null,
	p_attribute1            in         varchar2 default null,
	p_attribute2            in         varchar2 default null,
	p_attribute3            in         varchar2 default null,
	p_attribute4            in         varchar2 default null,
	p_attribute5            in         varchar2 default null,
	p_attribute6            in         varchar2 default null,
	p_attribute7            in         varchar2 default null,
	p_attribute8            in         varchar2 default null,
	p_attribute9            in         varchar2 default null,
	p_attribute10           in         varchar2 default null,
	p_attribute11           in         varchar2 default null,
	p_attribute12           in         varchar2 default null,
	p_attribute13           in         varchar2 default null,
	p_attribute14           in         varchar2 default null,
	p_attribute15           in         varchar2 default null,
	p_attribute16           in         varchar2 default null,
	p_attribute17           in         varchar2 default null,
	p_attribute18           in         varchar2 default null,
	p_attribute19           in         varchar2 default null,
	p_attribute20           in         varchar2 default null,
	--
	p_input_value_id1       in         number   default null,
	p_input_value_id2       in         number   default null,
	p_input_value_id3       in         number   default null,
	p_input_value_id4       in         number   default null,
	p_input_value_id5       in         number   default null,
	p_input_value_id6       in         number   default null,
	p_input_value_id7       in         number   default null,
	p_input_value_id8       in         number   default null,
	p_input_value_id9       in         number   default null,
	p_input_value_id10      in         number   default null,
	p_input_value_id11      in         number   default null,
	p_input_value_id12      in         number   default null,
	p_input_value_id13      in         number   default null,
	--
	p_means_code            in         varchar2 default null,
	p_departure_place       in         varchar2 default null,
	p_arrival_place         in         varchar2 default null,
	p_via                   in         varchar2 default null,
	p_period_code           in         varchar2 default null,
	p_payment_option_code   in         varchar2 default null,
	p_amount                in         number   default null,
	p_pay_start_month       in         varchar2 default null,
	p_pay_end_month         in         varchar2 default null,
	p_si_start_month_code   in         varchar2 default null,
	p_update_date           in         date     default null,
	p_update_reason_code    in         varchar2 default null,
	p_comments              in         varchar2 default null,
	--
	p_error_message         out nocopy long
	--
);
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_car_transaction_step >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure creates a transaction step for traffic tools information.
--
-- Pre-Requisities:
--   N/A
--
-- In Parameters:
--   p_item_type               varchar2
--   p_item_key                varchar2
--   p_activity_id             number
--   p_login_person_id         number
--   p_commutation_type        varchar2
--   p_action_type             varchar2
--   p_effective_date          date     default null
--   p_date_track_option       varchar2 default null
--   p_element_entry_id        number   default null
--   p_business_group_id       number   default null
--   p_assignment_id           number   default null
--   p_element_link_id         number   default null
--   p_entry_type              number   default null
--   p_object_version_number   number   default null
--   p_attribute_category      varchar2 default null
--   p_attribute1 - 20         varchar2 default null
--   p_input_value_id1 - 14    number   default null
--   p_means_code              varchar2 default null
--   p_vehicle_info_id         number   default null
--   p_period_code             varchar2 default null
--   p_distance                number   default null
--   p_fuel_cost_code          varchar2 default null
--   p_amount                  number   default null
--   p_parking_fees            number   default null
--   p_equivalent_cost         number   default null
--   p_pay_start_month         varchar2 default null
--   p_pay_end_month           varchar2 default null
--   p_si_start_month_code     varchar2 default null
--   p_update_date             date     default null
--   p_update_reason_code      varchar2 default null
--   p_comments                varchar2 default null
--
-- Out Patameters:
--   p_error_message           nocopy long
--
-- Post Success:
--   The transaction step will be created.
--
-- Post Failure:
--   The transaction step will no be created and an error will be raised.
--
-- Developer Implementation Notes:
--   N/A
--
-- Access Status:
--   Public
--
-- {End Of Comments}
-------------------------------------------------------------------------------
procedure set_car_transaction_step
(
	--
	p_item_type             in         varchar2,
	p_item_key              in         varchar2,
	p_activity_id           in         number,
	p_login_person_id       in         number,
	--
	p_action_type           in         varchar2,
	p_effective_date        in         date     default null,
	p_date_track_option     in         varchar2 default null,
	p_element_entry_id      in         number   default null,
	p_business_group_id     in         number   default null,
	p_assignment_id         in         number   default null,
	p_element_link_id       in         number   default null,
	p_entry_type            in         varchar2 default null,
	p_object_version_number in         number   default null,
	--
	p_attribute_category    in         varchar2 default null,
	p_attribute1            in         varchar2 default null,
	p_attribute2            in         varchar2 default null,
	p_attribute3            in         varchar2 default null,
	p_attribute4            in         varchar2 default null,
	p_attribute5            in         varchar2 default null,
	p_attribute6            in         varchar2 default null,
	p_attribute7            in         varchar2 default null,
	p_attribute8            in         varchar2 default null,
	p_attribute9            in         varchar2 default null,
	p_attribute10           in         varchar2 default null,
	p_attribute11           in         varchar2 default null,
	p_attribute12           in         varchar2 default null,
	p_attribute13           in         varchar2 default null,
	p_attribute14           in         varchar2 default null,
	p_attribute15           in         varchar2 default null,
	p_attribute16           in         varchar2 default null,
	p_attribute17           in         varchar2 default null,
	p_attribute18           in         varchar2 default null,
	p_attribute19           in         varchar2 default null,
	p_attribute20           in         varchar2 default null,
	--
	p_input_value_id1       in         number   default null,
	p_input_value_id2       in         number   default null,
	p_input_value_id3       in         number   default null,
	p_input_value_id4       in         number   default null,
	p_input_value_id5       in         number   default null,
	p_input_value_id6       in         number   default null,
	p_input_value_id7       in         number   default null,
	p_input_value_id8       in         number   default null,
	p_input_value_id9       in         number   default null,
	p_input_value_id10      in         number   default null,
	p_input_value_id11      in         number   default null,
	p_input_value_id12      in         number   default null,
	p_input_value_id13      in         number   default null,
	p_input_value_id14      in         number   default null,
	--
	p_means_code            in         varchar2 default null,
	p_vehicle_info_id       in         number   default null,
	p_period_code           in         varchar2 default null,
	p_distance              in         number   default null,
	p_fuel_cost_code        in         varchar2 default null,
	p_amount                in         number   default null,
	p_parking_fees          in         number   default null,
	p_equivalent_cost       in         number   default null,
	p_pay_start_month       in         varchar2 default null,
	p_pay_end_month         in         varchar2 default null,
	p_si_start_month_code   in         varchar2 default null,
	p_update_date           in         date     default null,
	p_update_reason_code    in         varchar2 default null,
	p_comments              in         varchar2 default null,
	--
	p_error_message         out nocopy long
	--
);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_train_entry >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure creates an element entry for transportation information.
--
-- Pre-Requisities:
--   N/A
--
-- In Parameters:
--   p_validate              number   default 0
--   p_effective_date        date
--   p_business_group_id     number
--   p_assignment_id         number
--   p_element_link_id       number
--   p_entry_type            varchar2
--   p_attribute_category    varchar2 default null
--   p_attribute1 - 20       varchar2 default null
--   p_input_value_id1 - 13  number   default null
--   p_means_code            varchar2 default null
--   p_departure_place       varchar2 default null
--   p_arrival_place         varchar2 default null
--   p_via                   varchar2 default null
--   p_period_code           varchar2 default null
--   p_payment_option_code   varchar2 default null
--   p_amount                number   default null
--   p_pay_start_month       varchar2 default null
--   p_pay_end_month         varchar2 default null
--   p_si_start_month_code   varchar2 default null
--   p_update_date           date     default null
--   p_update_reason_code    varchar2 default null
--   p_comments              varchar2 default null
--
-- Out Parameters:
--   p_error_message         long
--
-- Post Success:
--   The element entry will be created.
--
-- Post Failure:
--   The element entry will no be created and an error will be raised.
--
-- Developer Implementation Notes:
--   N/A
--
-- Access Status:
--   Public
--
-- {End Of Comments}
-------------------------------------------------------------------------------
procedure create_train_entry
(
	--
	p_validate              in         number   default 0,
	--
	p_effective_date        in         date,
	p_business_group_id     in         number,
	p_assignment_id         in         number,
	p_element_link_id       in         number,
	p_entry_type            in         varchar2,
	--
	p_attribute_category    in         varchar2 default null,
	p_attribute1            in         varchar2 default null,
	p_attribute2            in         varchar2 default null,
	p_attribute3            in         varchar2 default null,
	p_attribute4            in         varchar2 default null,
	p_attribute5            in         varchar2 default null,
	p_attribute6            in         varchar2 default null,
	p_attribute7            in         varchar2 default null,
	p_attribute8            in         varchar2 default null,
	p_attribute9            in         varchar2 default null,
	p_attribute10           in         varchar2 default null,
	p_attribute11           in         varchar2 default null,
	p_attribute12           in         varchar2 default null,
	p_attribute13           in         varchar2 default null,
	p_attribute14           in         varchar2 default null,
	p_attribute15           in         varchar2 default null,
	p_attribute16           in         varchar2 default null,
	p_attribute17           in         varchar2 default null,
	p_attribute18           in         varchar2 default null,
	p_attribute19           in         varchar2 default null,
	p_attribute20           in         varchar2 default null,
	--
	p_input_value_id1       in         number   default null,
	p_input_value_id2       in         number   default null,
	p_input_value_id3       in         number   default null,
	p_input_value_id4       in         number   default null,
	p_input_value_id5       in         number   default null,
	p_input_value_id6       in         number   default null,
	p_input_value_id7       in         number   default null,
	p_input_value_id8       in         number   default null,
	p_input_value_id9       in         number   default null,
	p_input_value_id10      in         number   default null,
	p_input_value_id11      in         number   default null,
	p_input_value_id12      in         number   default null,
	p_input_value_id13      in         number   default null,
	--
	p_means_code            in         varchar2 default null,
	p_departure_place       in         varchar2 default null,
	p_arrival_place         in         varchar2 default null,
	p_via                   in         varchar2 default null,
	p_period_code           in         varchar2 default null,
	p_payment_option_code   in         varchar2 default null,
	p_amount                in         number   default null,
	p_pay_start_month       in         varchar2 default null,
	p_pay_end_month         in         varchar2 default null,
	p_si_start_month_code   in         varchar2 default null,
	p_update_date           in         date     default null,
	p_update_reason_code    in         varchar2 default null,
	p_comments              in         varchar2 default null,
	--
	p_error_message         out nocopy long
	--
);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_train_entry >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure updates an element entry for transportation information.
--
-- Pre-Requisities:
--   N/A
--
-- In Parameters:
--   p_validate              number   default 0
--   p_datetrack_update_mode varchar2
--   p_effective_date        date
--   p_business_group_id     number
--   p_element_entry_id      number
--   p_attribute_category    varchar2 default null
--   p_attribute1 - 20       varchar2 default null
--   p_input_value_id1 - 13  number   default null
--   p_means_code            varchar2 default null
--   p_departure_place       varchar2 default null
--   p_arrival_place         varchar2 default null
--   p_via                   varchar2 default null
--   p_period_code           varchar2 default null
--   p_payment_option_code   varchar2 default null
--   p_amount                number   default null
--   p_pay_start_month       varchar2 default null
--   p_pay_end_month         varchar2 default null
--   p_si_start_month_code   varchar2 default null
--   p_update_date           date     default null
--   p_update_reason_code    varchar2 default null
--   p_comments              varchar2 default null
--
-- Out Parameters:
--   p_error_message         long
--
-- In Out Parameters:
--   p_object_version_number number
--
-- Post Success:
--   The element entry will be updated.
--
-- Post Failure:
--   The element entry will no be updated and an error will be raised.
--
-- Developer Implementation Notes:
--   N/A
--
-- Access Status:
--   Public
--
-- {End Of Comments}
-------------------------------------------------------------------------------
procedure update_train_entry
(
	p_validate              in            number   default 0,
	--
	p_datetrack_update_mode in            varchar2,
	p_effective_date        in            date,
	p_business_group_id     in            number,
	p_element_entry_id      in            number,
	p_object_version_number in out nocopy number,
	--
	p_attribute_category    in            varchar2 default null,
	p_attribute1            in            varchar2 default null,
	p_attribute2            in            varchar2 default null,
	p_attribute3            in            varchar2 default null,
	p_attribute4            in            varchar2 default null,
	p_attribute5            in            varchar2 default null,
	p_attribute6            in            varchar2 default null,
	p_attribute7            in            varchar2 default null,
	p_attribute8            in            varchar2 default null,
	p_attribute9            in            varchar2 default null,
	p_attribute10           in            varchar2 default null,
	p_attribute11           in            varchar2 default null,
	p_attribute12           in            varchar2 default null,
	p_attribute13           in            varchar2 default null,
	p_attribute14           in            varchar2 default null,
	p_attribute15           in            varchar2 default null,
	p_attribute16           in            varchar2 default null,
	p_attribute17           in            varchar2 default null,
	p_attribute18           in            varchar2 default null,
	p_attribute19           in            varchar2 default null,
	p_attribute20           in            varchar2 default null,
	--
	p_input_value_id1       in            number   default null,
	p_input_value_id2       in            number   default null,
	p_input_value_id3       in            number   default null,
	p_input_value_id4       in            number   default null,
	p_input_value_id5       in            number   default null,
	p_input_value_id6       in            number   default null,
	p_input_value_id7       in            number   default null,
	p_input_value_id8       in            number   default null,
	p_input_value_id9       in            number   default null,
	p_input_value_id10      in            number   default null,
	p_input_value_id11      in            number   default null,
	p_input_value_id12      in            number   default null,
	p_input_value_id13      in            number   default null,
	--
	p_means_code            in            varchar2 default null,
	p_departure_place       in            varchar2 default null,
	p_arrival_place         in            varchar2 default null,
	p_via                   in            varchar2 default null,
	p_period_code           in            varchar2 default null,
	p_payment_option_code   in            varchar2 default null,
	p_amount                in            number   default null,
	p_pay_start_month       in            varchar2 default null,
	p_pay_end_month         in            varchar2 default null,
	p_si_start_month_code   in            varchar2 default null,
	p_update_date           in            date     default null,
	p_update_reason_code    in            varchar2 default null,
	p_comments              in            varchar2 default null,
	--
	p_error_message         out nocopy    long
	--
);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_car_entry >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure creates an element entry for traffic tools information.
--
-- Pre-Requisities:
--   N/A
--
-- In Parameters:
--   p_validate              number   default 0
--   p_effective_date        date
--   p_business_group_id     number
--   p_assignment_id         number
--   p_element_link_id       number
--   p_entry_type            varchar2
--   p_attribute_category    varchar2 default null
--   p_attribute1 - 20       varchar2 default null
--   p_input_value_id1 - 14  number   default null
--   p_means_code            varchar2 default null
--   p_vehicle_info_id       number   default null
--   p_period_code           varchar2 default null
--   p_distance              number   default null
--   p_fuel_cost_code        varchar2 default null
--   p_amount                number   default null
--   p_parking_fees          number   default null
--   p_equivalent_cost       number   default null
--   p_pay_start_month       varchar2 default null
--   p_pay_end_month         varchar2 default null
--   p_si_start_month_code   varchar2 default null
--   p_update_date           date     default null
--   p_update_reason_code    varchar2 default null
--   p_comments              varchar2 default null
--
-- Out Parameters:
--   p_error_message         long
--
-- Post Success:
--   The element entry will be created.
--
-- Post Failure:
--   The element entry will no be created and an error will be raised.
--
-- Developer Implementation Notes:
--   N/A
--
-- Access Status:
--   Public
--
-- {End Of Comments}
-------------------------------------------------------------------------------
procedure create_car_entry
(
	--
	p_validate              in         number   default 0,
	--
	p_effective_date        in         date,
	p_business_group_id     in         number,
	p_assignment_id         in         number,
	p_element_link_id       in         number,
	p_entry_type            in         varchar2,
	--
	p_attribute_category    in         varchar2 default null,
	p_attribute1            in         varchar2 default null,
	p_attribute2            in         varchar2 default null,
	p_attribute3            in         varchar2 default null,
	p_attribute4            in         varchar2 default null,
	p_attribute5            in         varchar2 default null,
	p_attribute6            in         varchar2 default null,
	p_attribute7            in         varchar2 default null,
	p_attribute8            in         varchar2 default null,
	p_attribute9            in         varchar2 default null,
	p_attribute10           in         varchar2 default null,
	p_attribute11           in         varchar2 default null,
	p_attribute12           in         varchar2 default null,
	p_attribute13           in         varchar2 default null,
	p_attribute14           in         varchar2 default null,
	p_attribute15           in         varchar2 default null,
	p_attribute16           in         varchar2 default null,
	p_attribute17           in         varchar2 default null,
	p_attribute18           in         varchar2 default null,
	p_attribute19           in         varchar2 default null,
	p_attribute20           in         varchar2 default null,
	--
	p_input_value_id1       in         number   default null,
	p_input_value_id2       in         number   default null,
	p_input_value_id3       in         number   default null,
	p_input_value_id4       in         number   default null,
	p_input_value_id5       in         number   default null,
	p_input_value_id6       in         number   default null,
	p_input_value_id7       in         number   default null,
	p_input_value_id8       in         number   default null,
	p_input_value_id9       in         number   default null,
	p_input_value_id10      in         number   default null,
	p_input_value_id11      in         number   default null,
	p_input_value_id12      in         number   default null,
	p_input_value_id13      in         number   default null,
	p_input_value_id14      in         number   default null,
	--
	p_means_code            in         varchar2 default null,
	p_vehicle_info_id       in         number   default null,
	p_period_code           in         varchar2 default null,
	p_distance              in         number   default null,
	p_fuel_cost_code        in         varchar2 default null,
	p_amount                in         number   default null,
	p_parking_fees          in         number   default null,
	p_equivalent_cost       in         number   default null,
	p_pay_start_month       in         varchar2 default null,
	p_pay_end_month         in         varchar2 default null,
	p_si_start_month_code   in         varchar2 default null,
	p_update_date           in         date     default null,
	p_update_reason_code    in         varchar2 default null,
	p_comments              in         varchar2 default null,
	--
	p_error_message         out nocopy long
	--
);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_car_entry >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure updates an element entry for trafic tools information.
--
-- Pre-Requisities:
--   N/A
--
-- In Parameters:
--   p_validate              number   default 0
--   p_datetrack_update_mode varchar2
--   p_effective_date        date
--   p_business_group_id     number
--   p_element_entry_id      number
--   p_attribute_category    varchar2 default null
--   p_attribute1 - 20       varchar2 default null
--   p_input_value_id1 - 14  number   default null
--   p_means_code            varchar2 default null
--   p_vehicle_info_id       number   default null
--   p_period_code           varchar2 default null
--   p_distance              number   default null
--   p_fuel_cost_code        varchar2 default null
--   p_amount                number   default null
--   p_parking_fees          number   default null
--   p_equivalent_cost       number   default null
--   p_pay_start_month       varchar2 default null
--   p_pay_end_month         varchar2 default null
--   p_si_start_month_code   varchar2 default null
--   p_update_date           date     default null
--   p_update_reason_code    varchar2 default null
--   p_comments              varchar2 default null
--
-- Out Parameters:
--   p_error_message         long
--
-- In Out Parameters:
--   p_object_version_number number
--
-- Post Success:
--   The element entry will be updated.
--
-- Post Failure:
--   The element entry will no be updated and an error will be raised.
--
-- Developer Implementation Notes:
--   N/A
--
-- Access Status:
--   Public
--
-- {End Of Comments}
-------------------------------------------------------------------------------
procedure update_car_entry
(
	--
	p_validate              in            number   default 0,
	--
	p_datetrack_update_mode in            varchar2,
	p_effective_date        in            date,
	p_business_group_id     in            number,
	p_element_entry_id      in            number,
	p_object_version_number in out nocopy number,
	--
	p_attribute_category    in            varchar2 default null,
	p_attribute1            in            varchar2 default null,
	p_attribute2            in            varchar2 default null,
	p_attribute3            in            varchar2 default null,
	p_attribute4            in            varchar2 default null,
	p_attribute5            in            varchar2 default null,
	p_attribute6            in            varchar2 default null,
	p_attribute7            in            varchar2 default null,
	p_attribute8            in            varchar2 default null,
	p_attribute9            in            varchar2 default null,
	p_attribute10           in            varchar2 default null,
	p_attribute11           in            varchar2 default null,
	p_attribute12           in            varchar2 default null,
	p_attribute13           in            varchar2 default null,
	p_attribute14           in            varchar2 default null,
	p_attribute15           in            varchar2 default null,
	p_attribute16           in            varchar2 default null,
	p_attribute17           in            varchar2 default null,
	p_attribute18           in            varchar2 default null,
	p_attribute19           in            varchar2 default null,
	p_attribute20           in            varchar2 default null,
	--
	p_input_value_id1       in            number   default null,
	p_input_value_id2       in            number   default null,
	p_input_value_id3       in            number   default null,
	p_input_value_id4       in            number   default null,
	p_input_value_id5       in            number   default null,
	p_input_value_id6       in            number   default null,
	p_input_value_id7       in            number   default null,
	p_input_value_id8       in            number   default null,
	p_input_value_id9       in            number   default null,
	p_input_value_id10      in            number   default null,
	p_input_value_id11      in            number   default null,
	p_input_value_id12      in            number   default null,
	p_input_value_id13      in            number   default null,
	p_input_value_id14      in            number   default null,
	--
	p_means_code            in            varchar2 default null,
	p_vehicle_info_id       in            number   default null,
	p_period_code           in            varchar2 default null,
	p_distance              in            number   default null,
	p_fuel_cost_code        in            varchar2 default null,
	p_amount                in            number   default null,
	p_parking_fees          in            number   default null,
	p_equivalent_cost       in            number   default null,
	p_pay_start_month       in            varchar2 default null,
	p_pay_end_month         in            varchar2 default null,
	p_si_start_month_code   in            varchar2 default null,
	p_update_date           in            date     default null,
	p_update_reason_code    in            varchar2 default null,
	p_comments              in            varchar2 default null,
	--
	p_error_message         out nocopy    long
	--
);
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_entry >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure deletes an element entry for commutation information.
--
-- Pre-Requisities:
--   N/A
--
-- In Parameters:
--   p_validate              number   default 0
--   p_datetrack_delete_mode varchar2
--   p_effective_date        date
--   p_element_entry_id      number
--
-- Out Parameters:
--   p_error_message         long
--
-- In Out Parameters:
--   p_object_version_number number
--
-- Post Success:
--   The element entry will be deleted.
--
-- Post Failure:
--   The element entry will no be deleted and an error will be raised.
--
-- Developer Implementation Notes:
--   N/A
--
-- Access Status:
--   Public
--
-- {End Of Comments}
-------------------------------------------------------------------------------
procedure delete_entry
(
	--
	p_validate              in            number   default 0,
	--
	p_datetrack_delete_mode in            varchar2,
	p_effective_date        in            date,
	p_element_entry_id      in            number,
	p_object_version_number in out nocopy number,
	--
	p_error_message         out nocopy    long
	--
);
--
-- ----------------------------------------------------------------------------
-- |------------------------------< process_api >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure execute create, update or delete commutation information
--   APIs depending on the action type.
--
-- Pre-Requisities:
--   Transaction step exists in the database against transaction_step_id
--   parameter.
--
-- In Parameters:
--   p_validate            boolean  default false
--   p_transaction_step_id number   default null
--   p_effective_date      varchar2 default null
--
-- Post Success:
--   One of insert, update or delete API will be executed and the record of
--   contact extra information will be created, updated or deleted.
--
-- Post Failure:
--   The record of contact extra information will not be created, updated or
--   deleted and an error will be raised.
--
-- Developer Implementation Notes:
--   N/A
--
-- Access Status:
--   Public
--
-- {End Of Comments}
-------------------------------------------------------------------------------
procedure process_api
(
	p_validate            in boolean  default false,
	p_transaction_step_id in number   default null,
	p_effective_date      in varchar2 default null
);
--
function get_txn_value_char(
  p_transaction_step_id in number,
  p_name                in varchar2)
return varchar2;
--
function get_txn_value_date(
  p_transaction_step_id in number,
  p_name                in varchar2)
return date;
--
function get_txn_value_number(
  p_transaction_step_id in number,
  p_name                in varchar2)
return number;
--
end pay_jp_process_cmi_ss;

 

/
