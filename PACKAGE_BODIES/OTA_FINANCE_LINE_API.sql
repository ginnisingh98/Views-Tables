--------------------------------------------------------
--  DDL for Package Body OTA_FINANCE_LINE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_FINANCE_LINE_API" as
    /* $Header: ottflapi.pkb 120.1 2005/08/10 15:12:41 asud noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'OTA_FINANCE_LINE_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_FINANCE_LINE >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_FINANCE_LINE(
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
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Create Finance Line';
  l_finance_line_id number;
  l_object_version_number   number;
  l_effective_date          date;
  l_name varchar2(80);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_FINANCE_LINE;
  --
  -- Truncate the time portion from all IN date parameters
  --
 l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --

  begin
    OTA_FINANCE_LINE_BK1.CREATE_FINANCE_LINE_B
  (
P_FINANCE_HEADER_ID               => 	 P_FINANCE_HEADER_ID,
P_CANCELLED_FLAG                  => 	 P_CANCELLED_FLAG,
P_DATE_RAISED                     => 	 P_DATE_RAISED,
P_LINE_TYPE                       => 	 P_LINE_TYPE,
P_SEQUENCE_NUMBER                 => 	 P_SEQUENCE_NUMBER,
P_TRANSFER_STATUS                 => 	 P_TRANSFER_STATUS,
P_COMMENTS                        => 	 P_COMMENTS,
P_CURRENCY_CODE                   => 	 P_CURRENCY_CODE,
P_MONEY_AMOUNT                    => 	 P_MONEY_AMOUNT,
P_STANDARD_AMOUNT                 => 	 P_STANDARD_AMOUNT,
P_TRANS_INFORMATION_CATEGORY      => 	 P_TRANS_INFORMATION_CATEGORY,
P_TRANS_INFORMATION1              => 	 P_TRANS_INFORMATION1,
P_TRANS_INFORMATION10             => 	 P_TRANS_INFORMATION10,
P_TRANS_INFORMATION11             => 	 P_TRANS_INFORMATION11,
P_TRANS_INFORMATION12             => 	 P_TRANS_INFORMATION12,
P_TRANS_INFORMATION13             => 	 P_TRANS_INFORMATION13,
P_TRANS_INFORMATION14             => 	 P_TRANS_INFORMATION14,
P_TRANS_INFORMATION15             => 	 P_TRANS_INFORMATION15,
P_TRANS_INFORMATION16             => 	 P_TRANS_INFORMATION16,
P_TRANS_INFORMATION17             => 	 P_TRANS_INFORMATION17,
P_TRANS_INFORMATION18             => 	 P_TRANS_INFORMATION18,
P_TRANS_INFORMATION19             => 	 P_TRANS_INFORMATION19,
P_TRANS_INFORMATION2              => 	 P_TRANS_INFORMATION2,
P_TRANS_INFORMATION20             => 	 P_TRANS_INFORMATION20,
P_TRANS_INFORMATION3              => 	 P_TRANS_INFORMATION3,
P_TRANS_INFORMATION4              => 	 P_TRANS_INFORMATION4,
P_TRANS_INFORMATION5              => 	 P_TRANS_INFORMATION5,
P_TRANS_INFORMATION6              => 	 P_TRANS_INFORMATION6,
P_TRANS_INFORMATION7              => 	 P_TRANS_INFORMATION7,
P_TRANS_INFORMATION8              => 	 P_TRANS_INFORMATION8,
P_TRANS_INFORMATION9              => 	 P_TRANS_INFORMATION9,
P_TRANSFER_DATE                   => 	 P_TRANSFER_DATE,
P_TRANSFER_MESSAGE                => 	 P_TRANSFER_MESSAGE,
P_UNITARY_AMOUNT                  => 	 P_UNITARY_AMOUNT,
P_BOOKING_DEAL_ID                 => 	 P_BOOKING_DEAL_ID,
P_BOOKING_ID                      => 	 P_BOOKING_ID,
P_RESOURCE_ALLOCATION_ID          => 	 P_RESOURCE_ALLOCATION_ID,
P_RESOURCE_BOOKING_ID         => 	 P_RESOURCE_BOOKING_ID,
	P_LAST_UPDATE_DATE                => 	 P_LAST_UPDATE_DATE,
	P_LAST_UPDATED_BY                 => 	 P_LAST_UPDATED_BY,
	P_LAST_UPDATE_LOGIN               => 	 P_LAST_UPDATE_LOGIN,
	P_CREATED_BY                      => 	 P_CREATED_BY,
	P_CREATION_DATE                   => 	 P_CREATION_DATE,
P_TFL_INFORMATION_CATEGORY        => 	 P_TFL_INFORMATION_CATEGORY,
P_TFL_INFORMATION1                => 	 P_TFL_INFORMATION1,
P_TFL_INFORMATION2                => 	 P_TFL_INFORMATION2,
P_TFL_INFORMATION3                => 	 P_TFL_INFORMATION3,
P_TFL_INFORMATION4                => 	 P_TFL_INFORMATION4,
P_TFL_INFORMATION5                => 	 P_TFL_INFORMATION5,
P_TFL_INFORMATION6                => 	 P_TFL_INFORMATION6,
P_TFL_INFORMATION7                => 	 P_TFL_INFORMATION7,
P_TFL_INFORMATION8                => 	 P_TFL_INFORMATION8,
P_TFL_INFORMATION9                => 	 P_TFL_INFORMATION9,
P_TFL_INFORMATION10               => 	 P_TFL_INFORMATION10,
P_TFL_INFORMATION11               => 	 P_TFL_INFORMATION11,
P_TFL_INFORMATION12               => 	 P_TFL_INFORMATION12,
P_TFL_INFORMATION13               => 	 P_TFL_INFORMATION13,
P_TFL_INFORMATION14               => 	 P_TFL_INFORMATION14,
P_TFL_INFORMATION15               => 	 P_TFL_INFORMATION15,
P_TFL_INFORMATION16               => 	 P_TFL_INFORMATION16,
P_TFL_INFORMATION17               => 	 P_TFL_INFORMATION17,
P_TFL_INFORMATION18               => 	 P_TFL_INFORMATION18,
P_TFL_INFORMATION19               => 	 P_TFL_INFORMATION19,
P_TFL_INFORMATION20               => 	 P_TFL_INFORMATION20,
P_EFFECTIVE_DATE                  => 	 P_EFFECTIVE_DATE

   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_FINANCE_LINE'
        ,p_hook_type   => 'BP'
        );
  end;

     ota_tfl_api_ins.ins
       (
        P_FINANCE_LINE_ID                => 	 P_FINANCE_LINE_ID,
	P_FINANCE_HEADER_ID               => 	 P_FINANCE_HEADER_ID,
	P_CANCELLED_FLAG                  => 	 P_CANCELLED_FLAG,
	P_DATE_RAISED                     => 	 P_DATE_RAISED,
	P_LINE_TYPE                       => 	 P_LINE_TYPE,
	P_OBJECT_VERSION_NUMBER           => 	 P_OBJECT_VERSION_NUMBER,
	P_SEQUENCE_NUMBER                 => 	 P_SEQUENCE_NUMBER,
	P_TRANSFER_STATUS                 => 	 P_TRANSFER_STATUS,
	P_COMMENTS                        => 	 P_COMMENTS,
	P_CURRENCY_CODE                   => 	 P_CURRENCY_CODE,
	P_MONEY_AMOUNT                    => 	 P_MONEY_AMOUNT,
	P_STANDARD_AMOUNT                 => 	 P_STANDARD_AMOUNT,
	P_TRANS_INFORMATION_CATEGORY      => 	 P_TRANS_INFORMATION_CATEGORY,
	P_TRANS_INFORMATION1              => 	 P_TRANS_INFORMATION1,
	P_TRANS_INFORMATION10             => 	 P_TRANS_INFORMATION10,
	P_TRANS_INFORMATION11             => 	 P_TRANS_INFORMATION11,
	P_TRANS_INFORMATION12             => 	 P_TRANS_INFORMATION12,
	P_TRANS_INFORMATION13             => 	 P_TRANS_INFORMATION13,
	P_TRANS_INFORMATION14             => 	 P_TRANS_INFORMATION14,
	P_TRANS_INFORMATION15             => 	 P_TRANS_INFORMATION15,
	P_TRANS_INFORMATION16             => 	 P_TRANS_INFORMATION16,
	P_TRANS_INFORMATION17             => 	 P_TRANS_INFORMATION17,
	P_TRANS_INFORMATION18             => 	 P_TRANS_INFORMATION18,
	P_TRANS_INFORMATION19             => 	 P_TRANS_INFORMATION19,
	P_TRANS_INFORMATION2              => 	 P_TRANS_INFORMATION2,
	P_TRANS_INFORMATION20             => 	 P_TRANS_INFORMATION20,
	P_TRANS_INFORMATION3              => 	 P_TRANS_INFORMATION3,
	P_TRANS_INFORMATION4              => 	 P_TRANS_INFORMATION4,
	P_TRANS_INFORMATION5              => 	 P_TRANS_INFORMATION5,
	P_TRANS_INFORMATION6              => 	 P_TRANS_INFORMATION6,
	P_TRANS_INFORMATION7              => 	 P_TRANS_INFORMATION7,
	P_TRANS_INFORMATION8              => 	 P_TRANS_INFORMATION8,
	P_TRANS_INFORMATION9              => 	 P_TRANS_INFORMATION9,
	P_TRANSFER_DATE                   => 	 P_TRANSFER_DATE,
	P_TRANSFER_MESSAGE                => 	 P_TRANSFER_MESSAGE,
	P_UNITARY_AMOUNT                  => 	 P_UNITARY_AMOUNT,
	P_BOOKING_DEAL_ID                 => 	 P_BOOKING_DEAL_ID,
	P_BOOKING_ID                      => 	 P_BOOKING_ID,
	P_RESOURCE_ALLOCATION_ID          => 	 P_RESOURCE_ALLOCATION_ID,
	P_RESOURCE_BOOKING_ID         => 	 P_RESOURCE_BOOKING_ID,

	P_TFL_INFORMATION_CATEGORY        => 	 P_TFL_INFORMATION_CATEGORY,
	P_TFL_INFORMATION1                => 	 P_TFL_INFORMATION1,
	P_TFL_INFORMATION2                => 	 P_TFL_INFORMATION2,
	P_TFL_INFORMATION3                => 	 P_TFL_INFORMATION3,
	P_TFL_INFORMATION4                => 	 P_TFL_INFORMATION4,
	P_TFL_INFORMATION5                => 	 P_TFL_INFORMATION5,
	P_TFL_INFORMATION6                => 	 P_TFL_INFORMATION6,
	P_TFL_INFORMATION7                => 	 P_TFL_INFORMATION7,
	P_TFL_INFORMATION8                => 	 P_TFL_INFORMATION8,
	P_TFL_INFORMATION9                => 	 P_TFL_INFORMATION9,
	P_TFL_INFORMATION10               => 	 P_TFL_INFORMATION10,
	P_TFL_INFORMATION11               => 	 P_TFL_INFORMATION11,
	P_TFL_INFORMATION12               => 	 P_TFL_INFORMATION12,
	P_TFL_INFORMATION13               => 	 P_TFL_INFORMATION13,
	P_TFL_INFORMATION14               => 	 P_TFL_INFORMATION14,
	P_TFL_INFORMATION15               => 	 P_TFL_INFORMATION15,
	P_TFL_INFORMATION16               => 	 P_TFL_INFORMATION16,
	P_TFL_INFORMATION17               => 	 P_TFL_INFORMATION17,
	P_TFL_INFORMATION18               => 	 P_TFL_INFORMATION18,
	P_TFL_INFORMATION19               => 	 P_TFL_INFORMATION19,
	P_TFL_INFORMATION20               => 	 P_TFL_INFORMATION20,
	p_validate                  =>  false
       ,P_transaction_type          =>  'INSERT'
);

  --
  -- Call After Process User Hook
  --

  begin
  OTA_FINANCE_LINE_BK1.CREATE_FINANCE_LINE_A
  (
        P_FINANCE_LINE_ID                => 	 P_FINANCE_LINE_ID,
P_FINANCE_HEADER_ID               => 	 P_FINANCE_HEADER_ID,
P_CANCELLED_FLAG                  => 	 P_CANCELLED_FLAG,
P_DATE_RAISED                     => 	 P_DATE_RAISED,
P_LINE_TYPE                       => 	 P_LINE_TYPE,
P_SEQUENCE_NUMBER                 => 	 P_SEQUENCE_NUMBER,
P_TRANSFER_STATUS                 => 	 P_TRANSFER_STATUS,
P_COMMENTS                        => 	 P_COMMENTS,
P_CURRENCY_CODE                   => 	 P_CURRENCY_CODE,
P_MONEY_AMOUNT                    => 	 P_MONEY_AMOUNT,
P_STANDARD_AMOUNT                 => 	 P_STANDARD_AMOUNT,
P_TRANS_INFORMATION_CATEGORY      => 	 P_TRANS_INFORMATION_CATEGORY,
P_TRANS_INFORMATION1              => 	 P_TRANS_INFORMATION1,
P_TRANS_INFORMATION10             => 	 P_TRANS_INFORMATION10,
P_TRANS_INFORMATION11             => 	 P_TRANS_INFORMATION11,
P_TRANS_INFORMATION12             => 	 P_TRANS_INFORMATION12,
P_TRANS_INFORMATION13             => 	 P_TRANS_INFORMATION13,
P_TRANS_INFORMATION14             => 	 P_TRANS_INFORMATION14,
P_TRANS_INFORMATION15             => 	 P_TRANS_INFORMATION15,
P_TRANS_INFORMATION16             => 	 P_TRANS_INFORMATION16,
P_TRANS_INFORMATION17             => 	 P_TRANS_INFORMATION17,
P_TRANS_INFORMATION18             => 	 P_TRANS_INFORMATION18,
P_TRANS_INFORMATION19             => 	 P_TRANS_INFORMATION19,
P_TRANS_INFORMATION2              => 	 P_TRANS_INFORMATION2,
P_TRANS_INFORMATION20             => 	 P_TRANS_INFORMATION20,
P_TRANS_INFORMATION3              => 	 P_TRANS_INFORMATION3,
P_TRANS_INFORMATION4              => 	 P_TRANS_INFORMATION4,
P_TRANS_INFORMATION5              => 	 P_TRANS_INFORMATION5,
P_TRANS_INFORMATION6              => 	 P_TRANS_INFORMATION6,
P_TRANS_INFORMATION7              => 	 P_TRANS_INFORMATION7,
P_TRANS_INFORMATION8              => 	 P_TRANS_INFORMATION8,
P_TRANS_INFORMATION9              => 	 P_TRANS_INFORMATION9,
P_TRANSFER_DATE                   => 	 P_TRANSFER_DATE,
P_TRANSFER_MESSAGE                => 	 P_TRANSFER_MESSAGE,
P_UNITARY_AMOUNT                  => 	 P_UNITARY_AMOUNT,
P_BOOKING_DEAL_ID                 => 	 P_BOOKING_DEAL_ID,
P_BOOKING_ID                      => 	 P_BOOKING_ID,
P_RESOURCE_ALLOCATION_ID          => 	 P_RESOURCE_ALLOCATION_ID,
P_RESOURCE_BOOKING_ID         => 	 P_RESOURCE_BOOKING_ID,
P_LAST_UPDATE_DATE                => 	 P_LAST_UPDATE_DATE,
P_LAST_UPDATED_BY                 => 	 P_LAST_UPDATED_BY,
P_LAST_UPDATE_LOGIN               => 	 P_LAST_UPDATE_LOGIN,
P_CREATED_BY                      => 	 P_CREATED_BY,
P_CREATION_DATE                   => 	 P_CREATION_DATE,
P_TFL_INFORMATION_CATEGORY        => 	 P_TFL_INFORMATION_CATEGORY,
P_TFL_INFORMATION1                => 	 P_TFL_INFORMATION1,
P_TFL_INFORMATION2                => 	 P_TFL_INFORMATION2,
P_TFL_INFORMATION3                => 	 P_TFL_INFORMATION3,
P_TFL_INFORMATION4                => 	 P_TFL_INFORMATION4,
P_TFL_INFORMATION5                => 	 P_TFL_INFORMATION5,
P_TFL_INFORMATION6                => 	 P_TFL_INFORMATION6,
P_TFL_INFORMATION7                => 	 P_TFL_INFORMATION7,
P_TFL_INFORMATION8                => 	 P_TFL_INFORMATION8,
P_TFL_INFORMATION9                => 	 P_TFL_INFORMATION9,
P_TFL_INFORMATION10               => 	 P_TFL_INFORMATION10,
P_TFL_INFORMATION11               => 	 P_TFL_INFORMATION11,
P_TFL_INFORMATION12               => 	 P_TFL_INFORMATION12,
P_TFL_INFORMATION13               => 	 P_TFL_INFORMATION13,
P_TFL_INFORMATION14               => 	 P_TFL_INFORMATION14,
P_TFL_INFORMATION15               => 	 P_TFL_INFORMATION15,
P_TFL_INFORMATION16               => 	 P_TFL_INFORMATION16,
P_TFL_INFORMATION17               => 	 P_TFL_INFORMATION17,
P_TFL_INFORMATION18               => 	 P_TFL_INFORMATION18,
P_TFL_INFORMATION19               => 	 P_TFL_INFORMATION19,
P_TFL_INFORMATION20               => 	 P_TFL_INFORMATION20,
P_EFFECTIVE_DATE                  => 	 P_EFFECTIVE_DATE

  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_FINANCE_LINE'
        ,p_hook_type   => 'AP'
        );
  end;

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_finance_line_id        := l_finance_line_id;
  p_object_version_number   := l_object_version_number;


  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_FINANCE_LINE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_finance_line_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_FINANCE_LINE;
    p_finance_line_id        := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_FINANCE_LINE;
-- ----------------------------------------------------------------------------
-- |---------------------------< UPDATE_FINANCE_LINE >------------------------|
-- ----------------------------------------------------------------------------
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
  P_VALIDATE                          IN  boolean  default false,
  P_TRANSACTION_TYPE                  IN  VARCHAR2 default 'UPDATE',
  P_EFFECTIVE_DATE                    IN  DATE
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Update Finance Line';
  l_effective_date          date;
  l_object_version_number   number := p_object_version_number;
  l_name varchar2(80);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_FINANCE_LINE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --

  begin
    OTA_FINANCE_LINE_BK2.UPDATE_FINANCE_LINE_B
  (    P_FINANCE_LINE_ID                => 	 P_FINANCE_LINE_ID,
P_FINANCE_HEADER_ID               => 	 P_FINANCE_HEADER_ID,
P_CANCELLED_FLAG                  => 	 P_CANCELLED_FLAG,
P_DATE_RAISED                     => 	 P_DATE_RAISED,
P_LINE_TYPE                       => 	 P_LINE_TYPE,
P_SEQUENCE_NUMBER                 => 	 P_SEQUENCE_NUMBER,
P_TRANSFER_STATUS                 => 	 P_TRANSFER_STATUS,
P_COMMENTS                        => 	 P_COMMENTS,
P_CURRENCY_CODE                   => 	 P_CURRENCY_CODE,
P_MONEY_AMOUNT                    => 	 P_MONEY_AMOUNT,
P_STANDARD_AMOUNT                 => 	 P_STANDARD_AMOUNT,
P_TRANS_INFORMATION_CATEGORY      => 	 P_TRANS_INFORMATION_CATEGORY,
P_TRANS_INFORMATION1              => 	 P_TRANS_INFORMATION1,
P_TRANS_INFORMATION10             => 	 P_TRANS_INFORMATION10,
P_TRANS_INFORMATION11             => 	 P_TRANS_INFORMATION11,
P_TRANS_INFORMATION12             => 	 P_TRANS_INFORMATION12,
P_TRANS_INFORMATION13             => 	 P_TRANS_INFORMATION13,
P_TRANS_INFORMATION14             => 	 P_TRANS_INFORMATION14,
P_TRANS_INFORMATION15             => 	 P_TRANS_INFORMATION15,
P_TRANS_INFORMATION16             => 	 P_TRANS_INFORMATION16,
P_TRANS_INFORMATION17             => 	 P_TRANS_INFORMATION17,
P_TRANS_INFORMATION18             => 	 P_TRANS_INFORMATION18,
P_TRANS_INFORMATION19             => 	 P_TRANS_INFORMATION19,
P_TRANS_INFORMATION2              => 	 P_TRANS_INFORMATION2,
P_TRANS_INFORMATION20             => 	 P_TRANS_INFORMATION20,
P_TRANS_INFORMATION3              => 	 P_TRANS_INFORMATION3,
P_TRANS_INFORMATION4              => 	 P_TRANS_INFORMATION4,
P_TRANS_INFORMATION5              => 	 P_TRANS_INFORMATION5,
P_TRANS_INFORMATION6              => 	 P_TRANS_INFORMATION6,
P_TRANS_INFORMATION7              => 	 P_TRANS_INFORMATION7,
P_TRANS_INFORMATION8              => 	 P_TRANS_INFORMATION8,
P_TRANS_INFORMATION9              => 	 P_TRANS_INFORMATION9,
P_TRANSFER_DATE                   => 	 P_TRANSFER_DATE,
P_TRANSFER_MESSAGE                => 	 P_TRANSFER_MESSAGE,
P_UNITARY_AMOUNT                  => 	 P_UNITARY_AMOUNT,
P_BOOKING_DEAL_ID                 => 	 P_BOOKING_DEAL_ID,
P_BOOKING_ID                      => 	 P_BOOKING_ID,
P_RESOURCE_ALLOCATION_ID          => 	 P_RESOURCE_ALLOCATION_ID,
P_RESOURCE_BOOKING_ID         => 	 P_RESOURCE_BOOKING_ID,
P_LAST_UPDATE_DATE                => 	 P_LAST_UPDATE_DATE,
P_LAST_UPDATED_BY                 => 	 P_LAST_UPDATED_BY,
P_LAST_UPDATE_LOGIN               => 	 P_LAST_UPDATE_LOGIN,
P_CREATED_BY                      => 	 P_CREATED_BY,
P_CREATION_DATE                   => 	 P_CREATION_DATE,
P_TFL_INFORMATION_CATEGORY        => 	 P_TFL_INFORMATION_CATEGORY,
P_TFL_INFORMATION1                => 	 P_TFL_INFORMATION1,
P_TFL_INFORMATION2                => 	 P_TFL_INFORMATION2,
P_TFL_INFORMATION3                => 	 P_TFL_INFORMATION3,
P_TFL_INFORMATION4                => 	 P_TFL_INFORMATION4,
P_TFL_INFORMATION5                => 	 P_TFL_INFORMATION5,
P_TFL_INFORMATION6                => 	 P_TFL_INFORMATION6,
P_TFL_INFORMATION7                => 	 P_TFL_INFORMATION7,
P_TFL_INFORMATION8                => 	 P_TFL_INFORMATION8,
P_TFL_INFORMATION9                => 	 P_TFL_INFORMATION9,
P_TFL_INFORMATION10               => 	 P_TFL_INFORMATION10,
P_TFL_INFORMATION11               => 	 P_TFL_INFORMATION11,
P_TFL_INFORMATION12               => 	 P_TFL_INFORMATION12,
P_TFL_INFORMATION13               => 	 P_TFL_INFORMATION13,
P_TFL_INFORMATION14               => 	 P_TFL_INFORMATION14,
P_TFL_INFORMATION15               => 	 P_TFL_INFORMATION15,
P_TFL_INFORMATION16               => 	 P_TFL_INFORMATION16,
P_TFL_INFORMATION17               => 	 P_TFL_INFORMATION17,
P_TFL_INFORMATION18               => 	 P_TFL_INFORMATION18,
P_TFL_INFORMATION19               => 	 P_TFL_INFORMATION19,
P_TFL_INFORMATION20               => 	 P_TFL_INFORMATION20,
P_EFFECTIVE_DATE                  => 	 P_EFFECTIVE_DATE
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_FINANCE_LINE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
    ota_tfl_api_upd.Upd

       (
        P_FINANCE_LINE_ID                => 	 P_FINANCE_LINE_ID,
	P_FINANCE_HEADER_ID               => 	 P_FINANCE_HEADER_ID,
	P_CANCELLED_FLAG                  => 	 P_CANCELLED_FLAG,
	P_DATE_RAISED                     => 	 P_DATE_RAISED,
	P_LINE_TYPE                       => 	 P_LINE_TYPE,
	P_OBJECT_VERSION_NUMBER           => 	 P_OBJECT_VERSION_NUMBER,
	P_SEQUENCE_NUMBER                 => 	 P_SEQUENCE_NUMBER,
	P_TRANSFER_STATUS                 => 	 P_TRANSFER_STATUS,
	P_COMMENTS                        => 	 P_COMMENTS,
	P_CURRENCY_CODE                   => 	 P_CURRENCY_CODE,
	P_MONEY_AMOUNT                    => 	 P_MONEY_AMOUNT,
	P_STANDARD_AMOUNT                 => 	 P_STANDARD_AMOUNT,
	P_TRANS_INFORMATION_CATEGORY      => 	 P_TRANS_INFORMATION_CATEGORY,
	P_TRANS_INFORMATION1              => 	 P_TRANS_INFORMATION1,
	P_TRANS_INFORMATION10             => 	 P_TRANS_INFORMATION10,
	P_TRANS_INFORMATION11             => 	 P_TRANS_INFORMATION11,
	P_TRANS_INFORMATION12             => 	 P_TRANS_INFORMATION12,
	P_TRANS_INFORMATION13             => 	 P_TRANS_INFORMATION13,
	P_TRANS_INFORMATION14             => 	 P_TRANS_INFORMATION14,
	P_TRANS_INFORMATION15             => 	 P_TRANS_INFORMATION15,
	P_TRANS_INFORMATION16             => 	 P_TRANS_INFORMATION16,
	P_TRANS_INFORMATION17             => 	 P_TRANS_INFORMATION17,
	P_TRANS_INFORMATION18             => 	 P_TRANS_INFORMATION18,
	P_TRANS_INFORMATION19             => 	 P_TRANS_INFORMATION19,
	P_TRANS_INFORMATION2              => 	 P_TRANS_INFORMATION2,
	P_TRANS_INFORMATION20             => 	 P_TRANS_INFORMATION20,
	P_TRANS_INFORMATION3              => 	 P_TRANS_INFORMATION3,
	P_TRANS_INFORMATION4              => 	 P_TRANS_INFORMATION4,
	P_TRANS_INFORMATION5              => 	 P_TRANS_INFORMATION5,
	P_TRANS_INFORMATION6              => 	 P_TRANS_INFORMATION6,
	P_TRANS_INFORMATION7              => 	 P_TRANS_INFORMATION7,
	P_TRANS_INFORMATION8              => 	 P_TRANS_INFORMATION8,
	P_TRANS_INFORMATION9              => 	 P_TRANS_INFORMATION9,
	P_TRANSFER_DATE                   => 	 P_TRANSFER_DATE,
	P_TRANSFER_MESSAGE                => 	 P_TRANSFER_MESSAGE,
	P_UNITARY_AMOUNT                  => 	 P_UNITARY_AMOUNT,
	P_BOOKING_DEAL_ID                 => 	 P_BOOKING_DEAL_ID,
	P_BOOKING_ID                      => 	 P_BOOKING_ID,
	P_RESOURCE_ALLOCATION_ID          => 	 P_RESOURCE_ALLOCATION_ID,
	P_RESOURCE_BOOKING_ID         => 	 P_RESOURCE_BOOKING_ID,
	P_TFL_INFORMATION_CATEGORY        => 	 P_TFL_INFORMATION_CATEGORY,
	P_TFL_INFORMATION1                => 	 P_TFL_INFORMATION1,
	P_TFL_INFORMATION2                => 	 P_TFL_INFORMATION2,
	P_TFL_INFORMATION3                => 	 P_TFL_INFORMATION3,
	P_TFL_INFORMATION4                => 	 P_TFL_INFORMATION4,
	P_TFL_INFORMATION5                => 	 P_TFL_INFORMATION5,
	P_TFL_INFORMATION6                => 	 P_TFL_INFORMATION6,
	P_TFL_INFORMATION7                => 	 P_TFL_INFORMATION7,
	P_TFL_INFORMATION8                => 	 P_TFL_INFORMATION8,
	P_TFL_INFORMATION9                => 	 P_TFL_INFORMATION9,
	P_TFL_INFORMATION10               => 	 P_TFL_INFORMATION10,
	P_TFL_INFORMATION11               => 	 P_TFL_INFORMATION11,
	P_TFL_INFORMATION12               => 	 P_TFL_INFORMATION12,
	P_TFL_INFORMATION13               => 	 P_TFL_INFORMATION13,
	P_TFL_INFORMATION14               => 	 P_TFL_INFORMATION14,
	P_TFL_INFORMATION15               => 	 P_TFL_INFORMATION15,
	P_TFL_INFORMATION16               => 	 P_TFL_INFORMATION16,
	P_TFL_INFORMATION17               => 	 P_TFL_INFORMATION17,
	P_TFL_INFORMATION18               => 	 P_TFL_INFORMATION18,
	P_TFL_INFORMATION19               => 	 P_TFL_INFORMATION19,
	P_TFL_INFORMATION20               => 	 P_TFL_INFORMATION20,
        P_validate                        =>     false,
        P_TRANSACTION_TYPE                =>	 P_TRANSACTION_TYPE
       );

  begin
  OTA_FINANCE_LINE_BK2.UPDATE_FINANCE_LINE_A
  (     P_FINANCE_LINE_ID                => 	 P_FINANCE_LINE_ID,
P_FINANCE_HEADER_ID               => 	 P_FINANCE_HEADER_ID,
P_CANCELLED_FLAG                  => 	 P_CANCELLED_FLAG,
P_DATE_RAISED                     => 	 P_DATE_RAISED,
P_LINE_TYPE                       => 	 P_LINE_TYPE,
P_SEQUENCE_NUMBER                 => 	 P_SEQUENCE_NUMBER,
P_TRANSFER_STATUS                 => 	 P_TRANSFER_STATUS,
P_COMMENTS                        => 	 P_COMMENTS,
P_CURRENCY_CODE                   => 	 P_CURRENCY_CODE,
P_MONEY_AMOUNT                    => 	 P_MONEY_AMOUNT,
P_STANDARD_AMOUNT                 => 	 P_STANDARD_AMOUNT,
P_TRANS_INFORMATION_CATEGORY      => 	 P_TRANS_INFORMATION_CATEGORY,
P_TRANS_INFORMATION1              => 	 P_TRANS_INFORMATION1,
P_TRANS_INFORMATION10             => 	 P_TRANS_INFORMATION10,
P_TRANS_INFORMATION11             => 	 P_TRANS_INFORMATION11,
P_TRANS_INFORMATION12             => 	 P_TRANS_INFORMATION12,
P_TRANS_INFORMATION13             => 	 P_TRANS_INFORMATION13,
P_TRANS_INFORMATION14             => 	 P_TRANS_INFORMATION14,
P_TRANS_INFORMATION15             => 	 P_TRANS_INFORMATION15,
P_TRANS_INFORMATION16             => 	 P_TRANS_INFORMATION16,
P_TRANS_INFORMATION17             => 	 P_TRANS_INFORMATION17,
P_TRANS_INFORMATION18             => 	 P_TRANS_INFORMATION18,
P_TRANS_INFORMATION19             => 	 P_TRANS_INFORMATION19,
P_TRANS_INFORMATION2              => 	 P_TRANS_INFORMATION2,
P_TRANS_INFORMATION20             => 	 P_TRANS_INFORMATION20,
P_TRANS_INFORMATION3              => 	 P_TRANS_INFORMATION3,
P_TRANS_INFORMATION4              => 	 P_TRANS_INFORMATION4,
P_TRANS_INFORMATION5              => 	 P_TRANS_INFORMATION5,
P_TRANS_INFORMATION6              => 	 P_TRANS_INFORMATION6,
P_TRANS_INFORMATION7              => 	 P_TRANS_INFORMATION7,
P_TRANS_INFORMATION8              => 	 P_TRANS_INFORMATION8,
P_TRANS_INFORMATION9              => 	 P_TRANS_INFORMATION9,
P_TRANSFER_DATE                   => 	 P_TRANSFER_DATE,
P_TRANSFER_MESSAGE                => 	 P_TRANSFER_MESSAGE,
P_UNITARY_AMOUNT                  => 	 P_UNITARY_AMOUNT,
P_BOOKING_DEAL_ID                 => 	 P_BOOKING_DEAL_ID,
P_BOOKING_ID                      => 	 P_BOOKING_ID,
P_RESOURCE_ALLOCATION_ID          => 	 P_RESOURCE_ALLOCATION_ID,
P_RESOURCE_BOOKING_ID         => 	 P_RESOURCE_BOOKING_ID,
P_LAST_UPDATE_DATE                => 	 P_LAST_UPDATE_DATE,
P_LAST_UPDATED_BY                 => 	 P_LAST_UPDATED_BY,
P_LAST_UPDATE_LOGIN               => 	 P_LAST_UPDATE_LOGIN,
P_CREATED_BY                      => 	 P_CREATED_BY,
P_CREATION_DATE                   => 	 P_CREATION_DATE,
P_TFL_INFORMATION_CATEGORY        => 	 P_TFL_INFORMATION_CATEGORY,
P_TFL_INFORMATION1                => 	 P_TFL_INFORMATION1,
P_TFL_INFORMATION2                => 	 P_TFL_INFORMATION2,
P_TFL_INFORMATION3                => 	 P_TFL_INFORMATION3,
P_TFL_INFORMATION4                => 	 P_TFL_INFORMATION4,
P_TFL_INFORMATION5                => 	 P_TFL_INFORMATION5,
P_TFL_INFORMATION6                => 	 P_TFL_INFORMATION6,
P_TFL_INFORMATION7                => 	 P_TFL_INFORMATION7,
P_TFL_INFORMATION8                => 	 P_TFL_INFORMATION8,
P_TFL_INFORMATION9                => 	 P_TFL_INFORMATION9,
P_TFL_INFORMATION10               => 	 P_TFL_INFORMATION10,
P_TFL_INFORMATION11               => 	 P_TFL_INFORMATION11,
P_TFL_INFORMATION12               => 	 P_TFL_INFORMATION12,
P_TFL_INFORMATION13               => 	 P_TFL_INFORMATION13,
P_TFL_INFORMATION14               => 	 P_TFL_INFORMATION14,
P_TFL_INFORMATION15               => 	 P_TFL_INFORMATION15,
P_TFL_INFORMATION16               => 	 P_TFL_INFORMATION16,
P_TFL_INFORMATION17               => 	 P_TFL_INFORMATION17,
P_TFL_INFORMATION18               => 	 P_TFL_INFORMATION18,
P_TFL_INFORMATION19               => 	 P_TFL_INFORMATION19,
P_TFL_INFORMATION20               => 	 P_TFL_INFORMATION20,
P_EFFECTIVE_DATE                  => 	 P_EFFECTIVE_DATE
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_FINANCE_LINE'
        ,p_hook_type   => 'AP'
        );
  end;

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_FINANCE_LINE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_FINANCE_LINE;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_FINANCE_LINE;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_FINANCE_LINE >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_FINANCE_LINE
  (p_validate                      in     boolean  default false
  ,p_finance_line_id               in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Delete Finance Line';
  l_object_version_id       number;
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_FINANCE_LINE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --

  -- Call Before Process User Hook
  --
  begin
    OTA_FINANCE_LINE_BK3.DELETE_FINANCE_LINE_B
  (p_finance_line_id            => p_finance_line_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_FINANCE_LINE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_tfl_api_del.del
  (p_finance_line_id        => p_finance_line_id
  ,p_object_version_number   => p_object_version_number
  );

  --
  -- Call After Process User Hook
  --
  begin
  OTA_FINANCE_LINE_BK3.DELETE_FINANCE_LINE_A
  (p_finance_line_id            => p_finance_line_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_FINANCE_LINE'
        ,p_hook_type   => 'AP'
        );
  end;

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 170);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_FINANCE_LINE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 180);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_FINANCE_LINE;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end DELETE_FINANCE_LINE;
--


END OTA_FINANCE_LINE_API;

/
