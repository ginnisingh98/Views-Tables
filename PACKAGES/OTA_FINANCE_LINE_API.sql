--------------------------------------------------------
--  DDL for Package OTA_FINANCE_LINE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FINANCE_LINE_API" AUTHID CURRENT_USER as
/* $Header: ottflapi.pkh 120.5 2006/09/11 10:28:57 niarora noship $ */
/*#
 * This package contains Finance Lines APIs.
 * @rep:scope public
 * @rep:product OTA
 * @rep:displayname Finance Lines.
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_finance_line >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a Finance Line.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * Finance Header record must exist.
 *
 * <p><b>Post Success</b><br>
 * The Finance Line is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a Finance Line record, and raises an error.
 *
 * @param p_finance_line_id The unique identifier for finance line.
 * @param p_finance_header_id The identifier of the finance header
 * to which this finance line is linked.
 * @param p_cancelled_flag The current state of this finance line.
 * Permissible values Y and N.
 * @param p_date_raised The date of creation of theis finance line.
 * @param p_line_type The type of line. Valid values are: course payment,
 * pre-purchase,delegate etc.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created learning path section.
 * If p_validate is true, then the value will be null.
 * @param p_sequence_number The order in which this line appears under the header.
 * @param p_transfer_status Status of transfer.
 * @param p_comments Comments text.
 * @param p_currency_code The currency code of the finance line.
 * @param p_money_amount The money amount which this line is charging or paying.
 * @param p_standard_amount The money or unit value before a discount has
 * been applied.
 * @param p_trans_information_category This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
 * @param p_trans_information1 Transfer Descriptive flexfield segment.
 * @param p_trans_information2 Transfer Descriptive flexfield segment.
 * @param p_trans_information3 Transfer Descriptive flexfield segment.
 * @param p_trans_information4 Transfer Descriptive flexfield segment.
 * @param p_trans_information5 Transfer Descriptive flexfield segment.
 * @param p_trans_information6 Transfer Descriptive flexfield segment.
 * @param p_trans_information7 Transfer Descriptive flexfield segment.
 * @param p_trans_information8 Transfer Descriptive flexfield segment.
 * @param p_trans_information9 Transfer Descriptive flexfield segment.
 * @param p_trans_information10 Transfer Descriptive flexfield segment.
 * @param p_trans_information11 Transfer Descriptive flexfield segment.
 * @param p_trans_information12 Transfer Descriptive flexfield segment.
 * @param p_trans_information13 Transfer Descriptive flexfield segment.
 * @param p_trans_information14 Transfer Descriptive flexfield segment.
 * @param p_trans_information15 Transfer Descriptive flexfield segment.
 * @param p_trans_information16 Transfer Descriptive flexfield segment.
 * @param p_trans_information17 Transfer Descriptive flexfield segment.
 * @param p_trans_information18 Transfer Descriptive flexfield segment.
 * @param p_trans_information19 Transfer Descriptive flexfield segment.
 * @param p_trans_information20 Transfer Descriptive flexfield segment.
 * @param p_transfer_date Date on which the finance header is transferred
 * to a financial system.
 * @param p_transfer_message Message associated with the transfer of the
 * finance header.
 * @param p_unitary_amount The amount of training units being bought or used.
 * @param p_booking_deal_id Foreign key to OTA_BOOKING_DEALS.
 * @param p_booking_id Foreign key to OTA_DELEGATE_BOOKINGS.
 * @param p_resource_allocation_id Foreign key to OTA_RESOURCE_ALLOCATIONS.
 * @param p_resource_booking_id Foreign key to OTA_RESOURCE_BOOKINGS.
 * @param p_last_update_date Standard Who Column.
 * @param p_last_updated_by Standard Who Column.
 * @param p_last_update_login Standard Who Column.
 * @param p_created_by Standard Who Column.
 * @param p_creation_date Standard Who Column.
 * @param p_tfl_information_category This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
 * @param p_tfl_information1 Descriptive flexfield segment.
 * @param p_tfl_information2 Descriptive flexfield segment.
 * @param p_tfl_information3 Descriptive flexfield segment.
 * @param p_tfl_information4 Descriptive flexfield segment.
 * @param p_tfl_information5 Descriptive flexfield segment.
 * @param p_tfl_information6 Descriptive flexfield segment.
 * @param p_tfl_information7 Descriptive flexfield segment.
 * @param p_tfl_information8 Descriptive flexfield segment.
 * @param p_tfl_information9 Descriptive flexfield segment.
 * @param p_tfl_information10 Descriptive flexfield segment.
 * @param p_tfl_information11 Descriptive flexfield segment.
 * @param p_tfl_information12 Descriptive flexfield segment.
 * @param p_tfl_information13 Descriptive flexfield segment.
 * @param p_tfl_information14 Descriptive flexfield segment.
 * @param p_tfl_information15 Descriptive flexfield segment.
 * @param p_tfl_information16 Descriptive flexfield segment.
 * @param p_tfl_information17 Descriptive flexfield segment.
 * @param p_tfl_information18 Descriptive flexfield segment.
 * @param p_tfl_information19 Descriptive flexfield segment.
 * @param p_tfl_information20 Descriptive flexfield segment.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values
 * are applicable during the start to end active date range. This date
 * does not determine when the changes take effect.
 * @rep:displayname Create Finance Lines
 * @rep:category BUSINESS_ENTITY OTA_FINANCE_LINE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure CREATE_FINANCE_LINE
  (
  P_FINANCE_LINE_ID                   OUT NOCOPY  NUMBER,
  P_FINANCE_HEADER_ID                 IN  NUMBER,
  P_CANCELLED_FLAG                    IN  VARCHAR2,
  P_DATE_RAISED                       IN OUT NOCOPY DATE,
  P_LINE_TYPE                         IN  VARCHAR2,
  P_OBJECT_VERSION_NUMBER             OUT NOCOPY  NUMBER,
  P_SEQUENCE_NUMBER                   IN OUT NOCOPY NUMBER,
  P_TRANSFER_STATUS                   IN  VARCHAR2,
  P_COMMENTS                          IN  VARCHAR2,
  P_CURRENCY_CODE                     IN  VARCHAR2,
  P_MONEY_AMOUNT                      IN  NUMBER,
  P_STANDARD_AMOUNT                   IN  NUMBER,
  P_TRANS_INFORMATION_CATEGORY        IN  VARCHAR2,
  P_TRANS_INFORMATION1                IN  VARCHAR2,
  P_TRANS_INFORMATION10               IN  VARCHAR2,
  P_TRANS_INFORMATION11               IN  VARCHAR2,
  P_TRANS_INFORMATION12               IN  VARCHAR2,
  P_TRANS_INFORMATION13               IN  VARCHAR2,
  P_TRANS_INFORMATION14               IN  VARCHAR2,
  P_TRANS_INFORMATION15               IN  VARCHAR2,
  P_TRANS_INFORMATION16               IN  VARCHAR2,
  P_TRANS_INFORMATION17               IN  VARCHAR2,
  P_TRANS_INFORMATION18               IN  VARCHAR2,
  P_TRANS_INFORMATION19               IN  VARCHAR2,
  P_TRANS_INFORMATION2                IN  VARCHAR2,
  P_TRANS_INFORMATION20               IN  VARCHAR2,
  P_TRANS_INFORMATION3                IN  VARCHAR2,
  P_TRANS_INFORMATION4                IN  VARCHAR2,
  P_TRANS_INFORMATION5                IN  VARCHAR2,
  P_TRANS_INFORMATION6                IN  VARCHAR2,
  P_TRANS_INFORMATION7                IN  VARCHAR2,
  P_TRANS_INFORMATION8                IN  VARCHAR2,
  P_TRANS_INFORMATION9                IN  VARCHAR2,
  P_TRANSFER_DATE                     IN  DATE  ,
  P_TRANSFER_MESSAGE                  IN  VARCHAR2,
  P_UNITARY_AMOUNT                    IN  NUMBER,
  P_BOOKING_DEAL_ID                   IN  NUMBER,
  P_BOOKING_ID                        IN  NUMBER,
  P_RESOURCE_ALLOCATION_ID            IN  NUMBER,
  P_RESOURCE_BOOKING_ID           IN  NUMBER,
  P_LAST_UPDATE_DATE                  IN  DATE,
  P_LAST_UPDATED_BY                   IN  NUMBER,
  P_LAST_UPDATE_LOGIN                 IN  NUMBER,
  P_CREATED_BY                        IN  NUMBER,
  P_CREATION_DATE                     IN  DATE   ,
  P_TFL_INFORMATION_CATEGORY          IN  VARCHAR2,
  P_TFL_INFORMATION1                  IN  VARCHAR2,
  P_TFL_INFORMATION2                  IN  VARCHAR2,
  P_TFL_INFORMATION3                  IN  VARCHAR2,
  P_TFL_INFORMATION4                  IN  VARCHAR2,
  P_TFL_INFORMATION5                  IN  VARCHAR2,
  P_TFL_INFORMATION6                  IN  VARCHAR2,
  P_TFL_INFORMATION7                  IN  VARCHAR2,
  P_TFL_INFORMATION8                  IN  VARCHAR2,
  P_TFL_INFORMATION9                  IN  VARCHAR2,
  P_TFL_INFORMATION10                 IN  VARCHAR2,
  P_TFL_INFORMATION11                 IN  VARCHAR2,
  P_TFL_INFORMATION12                 IN  VARCHAR2,
  P_TFL_INFORMATION13                 IN  VARCHAR2,
  P_TFL_INFORMATION14                 IN  VARCHAR2,
  P_TFL_INFORMATION15                 IN  VARCHAR2,
  P_TFL_INFORMATION16                 IN  VARCHAR2,
  P_TFL_INFORMATION17                 IN  VARCHAR2,
  P_TFL_INFORMATION18                 IN  VARCHAR2,
  P_TFL_INFORMATION19                 IN  VARCHAR2,
  P_TFL_INFORMATION20                 IN  VARCHAR2,
  P_VALIDATE                          IN	boolean  default false,
  P_EFFECTIVE_DATE                    IN  DATE

  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_finance_line >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a Finance Line.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * Finance Line record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The Finance Line is updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update a Finance Line record, and raises an error.
 *
 * @param p_finance_line_id The unique identifier for the finance line.
 * @param p_object_version_number If p_validate is false, then set to the version
 * number of the created learning path section. If p_validate is true, then the value will be null.
 * @param p_new_object_version_number obsolete.
 * @param p_finance_header_id The identifier of the finance header to which this finance line is linked.
 * @param p_cancelled_flag The current state of this finance line.
 * Permissible values Y and N.
 * @param p_date_raised The date of creation of this finance line.
 * @param p_line_type The type of line. Valid values are: course payment,pre-purchase,delegate etc.
 * @param p_sequence_number The order in which this line appears under the header.
 * @param p_transfer_status Status of transfer.
 * @param p_comments Comments text.
 * @param p_currency_code The currency code of the finance line.
 * @param p_money_amount The money amount which this line is charging or paying.
 * @param p_standard_amount The money or unit value before a discount has been applied.
 * @param p_trans_information_category This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
 * @param p_trans_information1 Transfer Descriptive flexfield segment.
 * @param p_trans_information2 Transfer Descriptive flexfield segment.
 * @param p_trans_information3 Transfer Descriptive flexfield segment.
 * @param p_trans_information4 Transfer Descriptive flexfield segment.
 * @param p_trans_information5 Transfer Descriptive flexfield segment.
 * @param p_trans_information6 Transfer Descriptive flexfield segment.
 * @param p_trans_information7 Transfer Descriptive flexfield segment.
 * @param p_trans_information8 Transfer Descriptive flexfield segment.
 * @param p_trans_information9 Transfer Descriptive flexfield segment.
 * @param p_trans_information10 Transfer Descriptive flexfield segment.
 * @param p_trans_information11 Transfer Descriptive flexfield segment.
 * @param p_trans_information12 Transfer Descriptive flexfield segment.
 * @param p_trans_information13 Transfer Descriptive flexfield segment.
 * @param p_trans_information14 Transfer Descriptive flexfield segment.
 * @param p_trans_information15 Transfer Descriptive flexfield segment.
 * @param p_trans_information16 Transfer Descriptive flexfield segment.
 * @param p_trans_information17 Transfer Descriptive flexfield segment.
 * @param p_trans_information18 Transfer Descriptive flexfield segment.
 * @param p_trans_information19 Transfer Descriptive flexfield segment.
 * @param p_trans_information20 Transfer Descriptive flexfield segment.
 * @param p_transfer_date Date on which the finance header is transferred
 * to a financial system.
 * @param p_transfer_message Message associated with the transfer of the
 * finance header.
 * @param p_unitary_amount The amount of training units being bought or used.
 * @param p_booking_deal_id Foreign key to OTA_BOOKING_DEALS.
 * @param p_booking_id Foreign key to OTA_DELEGATE_BOOKINGS.
 * @param p_resource_allocation_id Foreign key to OTA_RESOURCE_ALLOCATIONS.
 * @param p_resource_booking_id Foreign key to OTA_RESOURCE_BOOKINGS.
 * @param p_last_update_date Standard Who Column.
 * @param p_last_updated_by Standard Who Column.
 * @param p_last_update_login Standard Who Column.
 * @param p_created_by Standard Who Column.
 * @param p_creation_date Standard Who Column.
 * @param p_tfl_information_category This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
 * @param p_tfl_information1 Descriptive flexfield segment.
 * @param p_tfl_information2 Descriptive flexfield segment.
 * @param p_tfl_information3 Descriptive flexfield segment.
 * @param p_tfl_information4 Descriptive flexfield segment.
 * @param p_tfl_information5 Descriptive flexfield segment.
 * @param p_tfl_information6 Descriptive flexfield segment.
 * @param p_tfl_information7 Descriptive flexfield segment.
 * @param p_tfl_information8 Descriptive flexfield segment.
 * @param p_tfl_information9 Descriptive flexfield segment.
 * @param p_tfl_information10 Descriptive flexfield segment.
 * @param p_tfl_information11 Descriptive flexfield segment.
 * @param p_tfl_information12 Descriptive flexfield segment.
 * @param p_tfl_information13 Descriptive flexfield segment.
 * @param p_tfl_information14 Descriptive flexfield segment.
 * @param p_tfl_information15 Descriptive flexfield segment.
 * @param p_tfl_information16 Descriptive flexfield segment.
 * @param p_tfl_information17 Descriptive flexfield segment.
 * @param p_tfl_information18 Descriptive flexfield segment.
 * @param p_tfl_information19 Descriptive flexfield segment.
 * @param p_tfl_information20 Descriptive flexfield segment.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_transaction_type Type of transaction. Valid values are : cancel_line,reinstate_line,
 * cancel_header_line, etc.
 * @param p_effective_date Reference date for validating that lookup values
 * are applicable during the start to end active date range. This date
 * does not determine when the changes take effect.
 * @rep:displayname Update Finance Lines
 * @rep:category BUSINESS_ENTITY OTA_FINANCE_LINE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure UPDATE_FINANCE_LINE
  (
    P_FINANCE_LINE_ID                   IN  NUMBER,
    P_OBJECT_VERSION_NUMBER             IN OUT NOCOPY  NUMBER,
    P_NEW_OBJECT_VERSION_NUMBER         OUT NOCOPY  NUMBER,
    P_FINANCE_HEADER_ID                 IN  NUMBER,
    P_CANCELLED_FLAG                    IN  VARCHAR2,
    P_DATE_RAISED                       IN OUT NOCOPY DATE,
    P_LINE_TYPE                         IN  VARCHAR2,
    P_SEQUENCE_NUMBER                   IN OUT NOCOPY NUMBER,
    P_TRANSFER_STATUS                   IN  VARCHAR2,
    P_COMMENTS                          IN  VARCHAR2,
    P_CURRENCY_CODE                     IN  VARCHAR2,
    P_MONEY_AMOUNT                      IN  NUMBER,
    P_STANDARD_AMOUNT                   IN  NUMBER,
    P_TRANS_INFORMATION_CATEGORY        IN  VARCHAR2,
    P_TRANS_INFORMATION1                IN  VARCHAR2,
    P_TRANS_INFORMATION10               IN  VARCHAR2,
    P_TRANS_INFORMATION11               IN  VARCHAR2,
    P_TRANS_INFORMATION12               IN  VARCHAR2,
    P_TRANS_INFORMATION13               IN  VARCHAR2,
    P_TRANS_INFORMATION14               IN  VARCHAR2,
    P_TRANS_INFORMATION15               IN  VARCHAR2,
    P_TRANS_INFORMATION16               IN  VARCHAR2,
    P_TRANS_INFORMATION17               IN  VARCHAR2,
    P_TRANS_INFORMATION18               IN  VARCHAR2,
    P_TRANS_INFORMATION19               IN  VARCHAR2,
    P_TRANS_INFORMATION2                IN  VARCHAR2,
    P_TRANS_INFORMATION20               IN  VARCHAR2,
    P_TRANS_INFORMATION3                IN  VARCHAR2,
    P_TRANS_INFORMATION4                IN  VARCHAR2,
    P_TRANS_INFORMATION5                IN  VARCHAR2,
    P_TRANS_INFORMATION6                IN  VARCHAR2,
    P_TRANS_INFORMATION7                IN  VARCHAR2,
    P_TRANS_INFORMATION8                IN  VARCHAR2,
    P_TRANS_INFORMATION9                IN  VARCHAR2,
    P_TRANSFER_DATE                     IN  DATE  ,
    P_TRANSFER_MESSAGE                  IN  VARCHAR2,
    P_UNITARY_AMOUNT                    IN  NUMBER,
    P_BOOKING_DEAL_ID                   IN  NUMBER,
    P_BOOKING_ID                        IN  NUMBER,
    P_RESOURCE_ALLOCATION_ID            IN  NUMBER,
    P_RESOURCE_BOOKING_ID           IN  NUMBER,
    P_LAST_UPDATE_DATE                  IN  DATE,
    P_LAST_UPDATED_BY                   IN  NUMBER,
    P_LAST_UPDATE_LOGIN                 IN  NUMBER,
    P_CREATED_BY                        IN  NUMBER,
    P_CREATION_DATE                     IN  DATE   ,
    P_TFL_INFORMATION_CATEGORY          IN  VARCHAR2,
    P_TFL_INFORMATION1                  IN  VARCHAR2,
    P_TFL_INFORMATION2                  IN  VARCHAR2,
    P_TFL_INFORMATION3                  IN  VARCHAR2,
    P_TFL_INFORMATION4                  IN  VARCHAR2,
    P_TFL_INFORMATION5                  IN  VARCHAR2,
    P_TFL_INFORMATION6                  IN  VARCHAR2,
    P_TFL_INFORMATION7                  IN  VARCHAR2,
    P_TFL_INFORMATION8                  IN  VARCHAR2,
    P_TFL_INFORMATION9                  IN  VARCHAR2,
    P_TFL_INFORMATION10                 IN  VARCHAR2,
    P_TFL_INFORMATION11                 IN  VARCHAR2,
    P_TFL_INFORMATION12                 IN  VARCHAR2,
    P_TFL_INFORMATION13                 IN  VARCHAR2,
    P_TFL_INFORMATION14                 IN  VARCHAR2,
    P_TFL_INFORMATION15                 IN  VARCHAR2,
    P_TFL_INFORMATION16                 IN  VARCHAR2,
    P_TFL_INFORMATION17                 IN  VARCHAR2,
    P_TFL_INFORMATION18                 IN  VARCHAR2,
    P_TFL_INFORMATION19                 IN  VARCHAR2,
    P_TFL_INFORMATION20                 IN  VARCHAR2,
    P_VALIDATE                          IN	boolean  default false,
    P_TRANSACTION_TYPE                  IN  VARCHAR2 default 'UPDATE',
    P_EFFECTIVE_DATE                    IN  DATE

  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_finance_line >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API Deletes a Finance Line.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * Finance Line record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The Finance Line is deleted successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete a Finance Line record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_finance_line_id The unique identifier for the finance line.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created learning path section.
 * If p_validate is true, then the value will be null.
 * @rep:displayname Delete Finance Lines
 * @rep:category BUSINESS_ENTITY OTA_FINANCE_LINE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure DELETE_FINANCE_LINE
  (p_validate                      in     boolean  default false
   ,p_finance_line_id            in number
  ,p_object_version_number        in number
  );

end ota_FINANCE_LINE_api;


 

/
