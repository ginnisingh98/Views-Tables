--------------------------------------------------------
--  DDL for Package PAY_PSS_TX_STEPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PSS_TX_STEPS_PKG" AUTHID CURRENT_USER as
/* $Header: pypsst.pkh 120.0.12010000.2 2009/09/26 06:11:28 pgongada ship $ */
--
-- Valid source tables.
--
C_PAY_PERSONAL_PAYMENT_METHODS constant varchar2(2000) default
'PAY_PERSONAL_PAYMENT_METHODS_F';
--
-- Valid Amount Types.
--
C_PERCENTAGE      constant varchar2(64) default 'PERCENTAGE';
C_PERCENTAGE_ONLY constant varchar2(64) default 'PERCENTAGE_ONLY';
C_MONETARY        constant varchar2(64) default 'MONETARY';
C_MONETARY_ONLY   constant varchar2(64) default 'MONETARY_ONLY';
C_REMAINING_PAY   constant varchar2(64) default 'REMAINING_PAY';
--
-- Valid Payment Types.
--
C_CASH    constant varchar2(2000) default 'CA';
C_CHECK   constant varchar2(2000) default 'CH';
C_DEPOSIT constant varchar2(2000) default 'MT';
--
-- Valid states.
--
C_STATE_NEW      constant varchar2(2000) default 'NEW';
C_STATE_FREED    constant varchar2(2000) default 'FREED';
C_STATE_EXISTING constant varchar2(2000) default 'EXISTING';
C_STATE_DELETED  constant varchar2(2000) default 'DELETED';
C_STATE_UPDATED  constant varchar2(2000) default 'UPDATED';
----------------------------------< insert_row >----------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Inserts a row into PAY_PSS_TRANSACTION_STEPS.
--
-- Prerequisites:
--   None.
--
-- Post Success:
--   The row is inserted and the OUT parameters are populated.
--
-- Post Failure:
--   An exception is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure insert_row
(p_transaction_id             in out nocopy number
,p_transaction_step_id           out nocopy number
,p_source_table               in     varchar2
,p_state                      in     varchar2
,p_personal_payment_method_id in     number
,p_update_ovn                 in     number
,p_delete_ovn                 in     number
,p_update_datetrack_mode      in     varchar2
,p_delete_datetrack_mode      in     varchar2
,p_delete_disabled            in     varchar2
,p_effective_date             in     date
,p_org_payment_method_id      in     number
,p_assignment_id              in     number
,p_payment_type               in     varchar2
,p_currency_code              in     varchar2
,p_territory_code             in     varchar2
,p_run_type_id                in     number
,p_real_priority              in     number
,p_logical_priority           in     number
,p_amount_type                in     varchar2
,p_amount                     in     number
,p_external_account_id        in     number
,p_attribute_category         in     varchar2
,p_attribute1                 in     varchar2
,p_attribute2                 in     varchar2
,p_attribute3                 in     varchar2
,p_attribute4                 in     varchar2
,p_attribute5                 in     varchar2
,p_attribute6                 in     varchar2
,p_attribute7                 in     varchar2
,p_attribute8                 in     varchar2
,p_attribute9                 in     varchar2
,p_attribute10                in     varchar2
,p_attribute11                in     varchar2
,p_attribute12                in     varchar2
,p_attribute13                in     varchar2
,p_attribute14                in     varchar2
,p_attribute15                in     varchar2
,p_attribute16                in     varchar2
,p_attribute17                in     varchar2
,p_attribute18                in     varchar2
,p_attribute19                in     varchar2
,p_attribute20                in     varchar2
,p_o_real_priority            in     number
,p_o_logical_priority         in     number
,p_o_amount_type              in     varchar2
,p_o_amount                   in     number
,p_o_external_account_id      in     number
,p_o_attribute_category       in     varchar2
,p_o_attribute1               in     varchar2
,p_o_attribute2               in     varchar2
,p_o_attribute3               in     varchar2
,p_o_attribute4               in     varchar2
,p_o_attribute5               in     varchar2
,p_o_attribute6               in     varchar2
,p_o_attribute7               in     varchar2
,p_o_attribute8               in     varchar2
,p_o_attribute9               in     varchar2
,p_o_attribute10              in     varchar2
,p_o_attribute11              in     varchar2
,p_o_attribute12              in     varchar2
,p_o_attribute13              in     varchar2
,p_o_attribute14              in     varchar2
,p_o_attribute15              in     varchar2
,p_o_attribute16              in     varchar2
,p_o_attribute17              in     varchar2
,p_o_attribute18              in     varchar2
,p_o_attribute19              in     varchar2
,p_o_attribute20              in     varchar2
,p_ppm_information_category   in     varchar2
,p_ppm_information1           in     varchar2
,p_ppm_information2           in     varchar2
,p_ppm_information3           in     varchar2
,p_ppm_information4           in     varchar2
,p_ppm_information5           in     varchar2
,p_ppm_information6           in     varchar2
,p_ppm_information7           in     varchar2
,p_ppm_information8           in     varchar2
,p_ppm_information9           in     varchar2
,p_ppm_information10          in     varchar2
,p_ppm_information11          in     varchar2
,p_ppm_information12          in     varchar2
,p_ppm_information13          in     varchar2
,p_ppm_information14          in     varchar2
,p_ppm_information15          in     varchar2
,p_ppm_information16          in     varchar2
,p_ppm_information17          in     varchar2
,p_ppm_information18          in     varchar2
,p_ppm_information19          in     varchar2
,p_ppm_information20          in     varchar2
,p_ppm_information21          in     varchar2
,p_ppm_information22          in     varchar2
,p_ppm_information23          in     varchar2
,p_ppm_information24          in     varchar2
,p_ppm_information25          in     varchar2
,p_ppm_information26          in     varchar2
,p_ppm_information27          in     varchar2
,p_ppm_information28          in     varchar2
,p_ppm_information29          in     varchar2
,p_ppm_information30          in     varchar2
,p_o_ppm_information_category in     varchar2
,p_o_ppm_information1         in     varchar2
,p_o_ppm_information2         in     varchar2
,p_o_ppm_information3         in     varchar2
,p_o_ppm_information4         in     varchar2
,p_o_ppm_information5         in     varchar2
,p_o_ppm_information6         in     varchar2
,p_o_ppm_information7         in     varchar2
,p_o_ppm_information8         in     varchar2
,p_o_ppm_information9         in     varchar2
,p_o_ppm_information10        in     varchar2
,p_o_ppm_information11        in     varchar2
,p_o_ppm_information12        in     varchar2
,p_o_ppm_information13        in     varchar2
,p_o_ppm_information14        in     varchar2
,p_o_ppm_information15        in     varchar2
,p_o_ppm_information16        in     varchar2
,p_o_ppm_information17        in     varchar2
,p_o_ppm_information18        in     varchar2
,p_o_ppm_information19        in     varchar2
,p_o_ppm_information20        in     varchar2
,p_o_ppm_information21        in     varchar2
,p_o_ppm_information22        in     varchar2
,p_o_ppm_information23        in     varchar2
,p_o_ppm_information24        in     varchar2
,p_o_ppm_information25        in     varchar2
,p_o_ppm_information26        in     varchar2
,p_o_ppm_information27        in     varchar2
,p_o_ppm_information28        in     varchar2
,p_o_ppm_information29        in     varchar2
,p_o_ppm_information30        in     varchar2
);
----------------------------------< update_row >----------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Updates a row from PAY_PSS_TRANSACTION_STEPS.
--
-- Prerequisites:
--   P_TRANSACTION_STEP_ID must refer to an existing row.
--
-- Post Success:
--   The row is updated.
--
-- Post Failure:
--   An exception is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_row
(p_transaction_step_id        in     number
,p_source_table               in     varchar2
,p_state                      in     varchar2
,p_personal_payment_method_id in     number
,p_update_ovn                 in     number
,p_delete_ovn                 in     number
,p_update_datetrack_mode      in     varchar2
,p_delete_datetrack_mode      in     varchar2
,p_delete_disabled            in     varchar2
,p_effective_date             in     date
,p_org_payment_method_id      in     number
,p_assignment_id              in     number
,p_payment_type               in     varchar2
,p_currency_code              in     varchar2
,p_territory_code             in     varchar2
,p_run_type_id                in     number
,p_real_priority              in     number
,p_logical_priority           in     number
,p_amount_type                in     varchar2
,p_amount                     in     number
,p_external_account_id        in     number
,p_attribute_category         in     varchar2
,p_attribute1                 in     varchar2
,p_attribute2                 in     varchar2
,p_attribute3                 in     varchar2
,p_attribute4                 in     varchar2
,p_attribute5                 in     varchar2
,p_attribute6                 in     varchar2
,p_attribute7                 in     varchar2
,p_attribute8                 in     varchar2
,p_attribute9                 in     varchar2
,p_attribute10                in     varchar2
,p_attribute11                in     varchar2
,p_attribute12                in     varchar2
,p_attribute13                in     varchar2
,p_attribute14                in     varchar2
,p_attribute15                in     varchar2
,p_attribute16                in     varchar2
,p_attribute17                in     varchar2
,p_attribute18                in     varchar2
,p_attribute19                in     varchar2
,p_attribute20                in     varchar2
,p_o_real_priority            in     number
,p_o_logical_priority         in     number
,p_o_amount_type              in     varchar2
,p_o_amount                   in     number
,p_o_external_account_id      in     number
,p_o_attribute_category       in     varchar2
,p_o_attribute1               in     varchar2
,p_o_attribute2               in     varchar2
,p_o_attribute3               in     varchar2
,p_o_attribute4               in     varchar2
,p_o_attribute5               in     varchar2
,p_o_attribute6               in     varchar2
,p_o_attribute7               in     varchar2
,p_o_attribute8               in     varchar2
,p_o_attribute9               in     varchar2
,p_o_attribute10              in     varchar2
,p_o_attribute11              in     varchar2
,p_o_attribute12              in     varchar2
,p_o_attribute13              in     varchar2
,p_o_attribute14              in     varchar2
,p_o_attribute15              in     varchar2
,p_o_attribute16              in     varchar2
,p_o_attribute17              in     varchar2
,p_o_attribute18              in     varchar2
,p_o_attribute19              in     varchar2
,p_o_attribute20              in     varchar2
,p_ppm_information_category   in     varchar2
,p_ppm_information1           in     varchar2
,p_ppm_information2           in     varchar2
,p_ppm_information3           in     varchar2
,p_ppm_information4           in     varchar2
,p_ppm_information5           in     varchar2
,p_ppm_information6           in     varchar2
,p_ppm_information7           in     varchar2
,p_ppm_information8           in     varchar2
,p_ppm_information9           in     varchar2
,p_ppm_information10          in     varchar2
,p_ppm_information11          in     varchar2
,p_ppm_information12          in     varchar2
,p_ppm_information13          in     varchar2
,p_ppm_information14          in     varchar2
,p_ppm_information15          in     varchar2
,p_ppm_information16          in     varchar2
,p_ppm_information17          in     varchar2
,p_ppm_information18          in     varchar2
,p_ppm_information19          in     varchar2
,p_ppm_information20          in     varchar2
,p_ppm_information21          in     varchar2
,p_ppm_information22          in     varchar2
,p_ppm_information23          in     varchar2
,p_ppm_information24          in     varchar2
,p_ppm_information25          in     varchar2
,p_ppm_information26          in     varchar2
,p_ppm_information27          in     varchar2
,p_ppm_information28          in     varchar2
,p_ppm_information29          in     varchar2
,p_ppm_information30          in     varchar2
,p_o_ppm_information_category in     varchar2
,p_o_ppm_information1         in     varchar2
,p_o_ppm_information2         in     varchar2
,p_o_ppm_information3         in     varchar2
,p_o_ppm_information4         in     varchar2
,p_o_ppm_information5         in     varchar2
,p_o_ppm_information6         in     varchar2
,p_o_ppm_information7         in     varchar2
,p_o_ppm_information8         in     varchar2
,p_o_ppm_information9         in     varchar2
,p_o_ppm_information10        in     varchar2
,p_o_ppm_information11        in     varchar2
,p_o_ppm_information12        in     varchar2
,p_o_ppm_information13        in     varchar2
,p_o_ppm_information14        in     varchar2
,p_o_ppm_information15        in     varchar2
,p_o_ppm_information16        in     varchar2
,p_o_ppm_information17        in     varchar2
,p_o_ppm_information18        in     varchar2
,p_o_ppm_information19        in     varchar2
,p_o_ppm_information20        in     varchar2
,p_o_ppm_information21        in     varchar2
,p_o_ppm_information22        in     varchar2
,p_o_ppm_information23        in     varchar2
,p_o_ppm_information24        in     varchar2
,p_o_ppm_information25        in     varchar2
,p_o_ppm_information26        in     varchar2
,p_o_ppm_information27        in     varchar2
,p_o_ppm_information28        in     varchar2
,p_o_ppm_information29        in     varchar2
,p_o_ppm_information30        in     varchar2
);
----------------------------------< delete_row >----------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Deletes a row from PAY_PSS_TRANSACTION_STEPS.
--
-- Prerequisites:
--   P_TRANSACTION_STEP_ID must refer to an existing row.
--
-- Post Success:
--   The row is deleted.
--
-- Post Failure:
--   An exception is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure delete_row
(p_transaction_step_id in number
);
---------------------------------< delete_rows >----------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Deletes all rows, for a given transaction_id, from
--   PAY_PSS_TRANSACTION_STEPS.
--
-- Prerequisites:
--   P_TRANSACTION_ID must be in use.
--
-- Post Success:
--   The rows are deleted.
--
-- Post Failure:
--   An exception is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure delete_rows
(p_transaction_id in number
);
--
end pay_pss_tx_steps_pkg;

/
