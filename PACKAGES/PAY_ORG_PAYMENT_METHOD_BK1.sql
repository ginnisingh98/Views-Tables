--------------------------------------------------------
--  DDL for Package PAY_ORG_PAYMENT_METHOD_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ORG_PAYMENT_METHOD_BK1" AUTHID CURRENT_USER as
/* $Header: pyopmapi.pkh 120.5 2005/10/24 00:35:01 adkumar noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_org_payment_method_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_org_payment_method_b
  (P_EFFECTIVE_DATE                in     date
  ,P_LANGUAGE_CODE                 in     varchar2
  ,P_BUSINESS_GROUP_ID             in     number
  ,P_ORG_PAYMENT_METHOD_NAME       in     varchar2
  ,P_PAYMENT_TYPE_ID               in     number
  ,P_CURRENCY_CODE                 in     varchar2
  ,P_ATTRIBUTE_CATEGORY            in     varchar2
  ,P_ATTRIBUTE1                    in     varchar2
  ,P_ATTRIBUTE2                    in     varchar2
  ,P_ATTRIBUTE3                    in     varchar2
  ,P_ATTRIBUTE4                    in     varchar2
  ,P_ATTRIBUTE5                    in     varchar2
  ,P_ATTRIBUTE6                    in     varchar2
  ,P_ATTRIBUTE7                    in     varchar2
  ,P_ATTRIBUTE8                    in     varchar2
  ,P_ATTRIBUTE9                    in     varchar2
  ,P_ATTRIBUTE10                   in     varchar2
  ,P_ATTRIBUTE11                   in     varchar2
  ,P_ATTRIBUTE12                   in     varchar2
  ,P_ATTRIBUTE13                   in     varchar2
  ,P_ATTRIBUTE14                   in     varchar2
  ,P_ATTRIBUTE15                   in     varchar2
  ,P_ATTRIBUTE16                   in     varchar2
  ,P_ATTRIBUTE17                   in     varchar2
  ,P_ATTRIBUTE18                   in     varchar2
  ,P_ATTRIBUTE19                   in     varchar2
  ,P_ATTRIBUTE20                   in     varchar2
--  ,P_PMETH_INFORMATION_CATEGORY    in     varchar2
  ,P_PMETH_INFORMATION1            in     varchar2
  ,P_PMETH_INFORMATION2            in     varchar2
  ,P_PMETH_INFORMATION3            in     varchar2
  ,P_PMETH_INFORMATION4            in     varchar2
  ,P_PMETH_INFORMATION5            in     varchar2
  ,P_PMETH_INFORMATION6            in     varchar2
  ,P_PMETH_INFORMATION7            in     varchar2
  ,P_PMETH_INFORMATION8            in     varchar2
  ,P_PMETH_INFORMATION9            in     varchar2
  ,P_PMETH_INFORMATION10           in     varchar2
  ,P_PMETH_INFORMATION11           in     varchar2
  ,P_PMETH_INFORMATION12           in     varchar2
  ,P_PMETH_INFORMATION13           in     varchar2
  ,P_PMETH_INFORMATION14           in     varchar2
  ,P_PMETH_INFORMATION15           in     varchar2
  ,P_PMETH_INFORMATION16           in     varchar2
  ,P_PMETH_INFORMATION17           in     varchar2
  ,P_PMETH_INFORMATION18           in     varchar2
  ,P_PMETH_INFORMATION19           in     varchar2
  ,P_PMETH_INFORMATION20           in     varchar2
  ,P_COMMENTS                      in     varchar2
  ,P_SEGMENT1                      in     varchar2
  ,P_SEGMENT2                      in     varchar2
  ,P_SEGMENT3                      in     varchar2
  ,P_SEGMENT4                      in     varchar2
  ,P_SEGMENT5                      in     varchar2
  ,P_SEGMENT6                      in     varchar2
  ,P_SEGMENT7                      in     varchar2
  ,P_SEGMENT8                      in     varchar2
  ,P_SEGMENT9                      in     varchar2
  ,P_SEGMENT10                     in     varchar2
  ,P_SEGMENT11                     in     varchar2
  ,P_SEGMENT12                     in     varchar2
  ,P_SEGMENT13                     in     varchar2
  ,P_SEGMENT14                     in     varchar2
  ,P_SEGMENT15                     in     varchar2
  ,P_SEGMENT16                     in     varchar2
  ,P_SEGMENT17                     in     varchar2
  ,P_SEGMENT18                     in     varchar2
  ,P_SEGMENT19                     in     varchar2
  ,P_SEGMENT20                     in     varchar2
  ,P_SEGMENT21                     in     varchar2
  ,P_SEGMENT22                     in     varchar2
  ,P_SEGMENT23                     in     varchar2
  ,P_SEGMENT24                     in     varchar2
  ,P_SEGMENT25                     in     varchar2
  ,P_SEGMENT26                     in     varchar2
  ,P_SEGMENT27                     in     varchar2
  ,P_SEGMENT28                     in     varchar2
  ,P_SEGMENT29                     in     varchar2
  ,P_SEGMENT30                     in     varchar2
  ,P_CONCAT_SEGMENTS               in     varchar2
  ,P_GL_SEGMENT1                   in     varchar2
  ,P_GL_SEGMENT2                   in     varchar2
  ,P_GL_SEGMENT3                   in     varchar2
  ,P_GL_SEGMENT4                   in     varchar2
  ,P_GL_SEGMENT5                   in     varchar2
  ,P_GL_SEGMENT6                   in     varchar2
  ,P_GL_SEGMENT7                   in     varchar2
  ,P_GL_SEGMENT8                   in     varchar2
  ,P_GL_SEGMENT9                   in     varchar2
  ,P_GL_SEGMENT10                  in     varchar2
  ,P_GL_SEGMENT11                  in     varchar2
  ,P_GL_SEGMENT12                  in     varchar2
  ,P_GL_SEGMENT13                  in     varchar2
  ,P_GL_SEGMENT14                  in     varchar2
  ,P_GL_SEGMENT15                  in     varchar2
  ,P_GL_SEGMENT16                  in     varchar2
  ,P_GL_SEGMENT17                  in     varchar2
  ,P_GL_SEGMENT18                  in     varchar2
  ,P_GL_SEGMENT19                  in     varchar2
  ,P_GL_SEGMENT20                  in     varchar2
  ,P_GL_SEGMENT21                  in     varchar2
  ,P_GL_SEGMENT22                  in     varchar2
  ,P_GL_SEGMENT23                  in     varchar2
  ,P_GL_SEGMENT24                  in     varchar2
  ,P_GL_SEGMENT25                  in     varchar2
  ,P_GL_SEGMENT26                  in     varchar2
  ,P_GL_SEGMENT27                  in     varchar2
  ,P_GL_SEGMENT28                  in     varchar2
  ,P_GL_SEGMENT29                  in     varchar2
  ,P_GL_SEGMENT30                  in     varchar2
  ,P_GL_CONCAT_SEGMENTS            in     varchar2
  ,P_GL_CTRL_SEGMENT1              in     varchar2
  ,P_GL_CTRL_SEGMENT2              in     varchar2
  ,P_GL_CTRL_SEGMENT3              in     varchar2
  ,P_GL_CTRL_SEGMENT4              in     varchar2
  ,P_GL_CTRL_SEGMENT5              in     varchar2
  ,P_GL_CTRL_SEGMENT6              in     varchar2
  ,P_GL_CTRL_SEGMENT7              in     varchar2
  ,P_GL_CTRL_SEGMENT8              in     varchar2
  ,P_GL_CTRL_SEGMENT9              in     varchar2
  ,P_GL_CTRL_SEGMENT10             in     varchar2
  ,P_GL_CTRL_SEGMENT11             in     varchar2
  ,P_GL_CTRL_SEGMENT12             in     varchar2
  ,P_GL_CTRL_SEGMENT13             in     varchar2
  ,P_GL_CTRL_SEGMENT14             in     varchar2
  ,P_GL_CTRL_SEGMENT15             in     varchar2
  ,P_GL_CTRL_SEGMENT16             in     varchar2
  ,P_GL_CTRL_SEGMENT17             in     varchar2
  ,P_GL_CTRL_SEGMENT18             in     varchar2
  ,P_GL_CTRL_SEGMENT19             in     varchar2
  ,P_GL_CTRL_SEGMENT20             in     varchar2
  ,P_GL_CTRL_SEGMENT21             in     varchar2
  ,P_GL_CTRL_SEGMENT22             in     varchar2
  ,P_GL_CTRL_SEGMENT23             in     varchar2
  ,P_GL_CTRL_SEGMENT24             in     varchar2
  ,P_GL_CTRL_SEGMENT25             in     varchar2
  ,P_GL_CTRL_SEGMENT26             in     varchar2
  ,P_GL_CTRL_SEGMENT27             in     varchar2
  ,P_GL_CTRL_SEGMENT28             in     varchar2
  ,P_GL_CTRL_SEGMENT29             in     varchar2
  ,P_GL_CTRL_SEGMENT30             in     varchar2
  ,P_GL_CTRL_CONCAT_SEGMENTS       in     varchar2
  ,P_GL_CCRL_SEGMENT1              in     varchar2
  ,P_GL_CCRL_SEGMENT2              in     varchar2
  ,P_GL_CCRL_SEGMENT3              in     varchar2
  ,P_GL_CCRL_SEGMENT4              in     varchar2
  ,P_GL_CCRL_SEGMENT5              in     varchar2
  ,P_GL_CCRL_SEGMENT6              in     varchar2
  ,P_GL_CCRL_SEGMENT7              in     varchar2
  ,P_GL_CCRL_SEGMENT8              in     varchar2
  ,P_GL_CCRL_SEGMENT9              in     varchar2
  ,P_GL_CCRL_SEGMENT10             in     varchar2
  ,P_GL_CCRL_SEGMENT11             in     varchar2
  ,P_GL_CCRL_SEGMENT12             in     varchar2
  ,P_GL_CCRL_SEGMENT13             in     varchar2
  ,P_GL_CCRL_SEGMENT14             in     varchar2
  ,P_GL_CCRL_SEGMENT15             in     varchar2
  ,P_GL_CCRL_SEGMENT16             in     varchar2
  ,P_GL_CCRL_SEGMENT17             in     varchar2
  ,P_GL_CCRL_SEGMENT18             in     varchar2
  ,P_GL_CCRL_SEGMENT19             in     varchar2
  ,P_GL_CCRL_SEGMENT20             in     varchar2
  ,P_GL_CCRL_SEGMENT21             in     varchar2
  ,P_GL_CCRL_SEGMENT22             in     varchar2
  ,P_GL_CCRL_SEGMENT23             in     varchar2
  ,P_GL_CCRL_SEGMENT24             in     varchar2
  ,P_GL_CCRL_SEGMENT25             in     varchar2
  ,P_GL_CCRL_SEGMENT26             in     varchar2
  ,P_GL_CCRL_SEGMENT27             in     varchar2
  ,P_GL_CCRL_SEGMENT28             in     varchar2
  ,P_GL_CCRL_SEGMENT29             in     varchar2
  ,P_GL_CCRL_SEGMENT30             in     varchar2
  ,P_GL_CCRL_CONCAT_SEGMENTS       in     varchar2
  ,P_GL_ERR_SEGMENT1               in     varchar2
  ,P_GL_ERR_SEGMENT2               in     varchar2
  ,P_GL_ERR_SEGMENT3               in     varchar2
  ,P_GL_ERR_SEGMENT4               in     varchar2
  ,P_GL_ERR_SEGMENT5               in     varchar2
  ,P_GL_ERR_SEGMENT6               in     varchar2
  ,P_GL_ERR_SEGMENT7               in     varchar2
  ,P_GL_ERR_SEGMENT8               in     varchar2
  ,P_GL_ERR_SEGMENT9               in     varchar2
  ,P_GL_ERR_SEGMENT10              in     varchar2
  ,P_GL_ERR_SEGMENT11              in     varchar2
  ,P_GL_ERR_SEGMENT12              in     varchar2
  ,P_GL_ERR_SEGMENT13              in     varchar2
  ,P_GL_ERR_SEGMENT14              in     varchar2
  ,P_GL_ERR_SEGMENT15              in     varchar2
  ,P_GL_ERR_SEGMENT16              in     varchar2
  ,P_GL_ERR_SEGMENT17              in     varchar2
  ,P_GL_ERR_SEGMENT18              in     varchar2
  ,P_GL_ERR_SEGMENT19              in     varchar2
  ,P_GL_ERR_SEGMENT20              in     varchar2
  ,P_GL_ERR_SEGMENT21              in     varchar2
  ,P_GL_ERR_SEGMENT22              in     varchar2
  ,P_GL_ERR_SEGMENT23              in     varchar2
  ,P_GL_ERR_SEGMENT24              in     varchar2
  ,P_GL_ERR_SEGMENT25              in     varchar2
  ,P_GL_ERR_SEGMENT26              in     varchar2
  ,P_GL_ERR_SEGMENT27              in     varchar2
  ,P_GL_ERR_SEGMENT28              in     varchar2
  ,P_GL_ERR_SEGMENT29              in     varchar2
  ,P_GL_ERR_SEGMENT30              in     varchar2
  ,P_GL_ERR_CONCAT_SEGMENTS        in     varchar2
  ,P_SETS_OF_BOOK_ID               in     number
  ,P_THIRD_PARTY_PAYMENT           in     varchar2
  ,P_TRANSFER_TO_GL_FLAG           in     varchar2
  ,P_COST_PAYMENT                  in     varchar2
  ,P_COST_CLEARED_PAYMENT          in     varchar2
  ,P_COST_CLEARED_VOID_PAYMENT     in     varchar2
  ,P_EXCLUDE_MANUAL_PAYMENT        in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_org_payment_method_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_org_payment_method_a
  (P_EFFECTIVE_DATE                in     date
  ,P_LANGUAGE_CODE                 in     varchar2
  ,P_BUSINESS_GROUP_ID             in     number
  ,P_ORG_PAYMENT_METHOD_NAME       in     varchar2
  ,P_PAYMENT_TYPE_ID               in     number
  ,P_CURRENCY_CODE                 in     varchar2
  ,P_ATTRIBUTE_CATEGORY            in     varchar2
  ,P_ATTRIBUTE1                    in     varchar2
  ,P_ATTRIBUTE2                    in     varchar2
  ,P_ATTRIBUTE3                    in     varchar2
  ,P_ATTRIBUTE4                    in     varchar2
  ,P_ATTRIBUTE5                    in     varchar2
  ,P_ATTRIBUTE6                    in     varchar2
  ,P_ATTRIBUTE7                    in     varchar2
  ,P_ATTRIBUTE8                    in     varchar2
  ,P_ATTRIBUTE9                    in     varchar2
  ,P_ATTRIBUTE10                   in     varchar2
  ,P_ATTRIBUTE11                   in     varchar2
  ,P_ATTRIBUTE12                   in     varchar2
  ,P_ATTRIBUTE13                   in     varchar2
  ,P_ATTRIBUTE14                   in     varchar2
  ,P_ATTRIBUTE15                   in     varchar2
  ,P_ATTRIBUTE16                   in     varchar2
  ,P_ATTRIBUTE17                   in     varchar2
  ,P_ATTRIBUTE18                   in     varchar2
  ,P_ATTRIBUTE19                   in     varchar2
  ,P_ATTRIBUTE20                   in     varchar2
--  ,P_PMETH_INFORMATION_CATEGORY    in     varchar2
  ,P_PMETH_INFORMATION1            in     varchar2
  ,P_PMETH_INFORMATION2            in     varchar2
  ,P_PMETH_INFORMATION3            in     varchar2
  ,P_PMETH_INFORMATION4            in     varchar2
  ,P_PMETH_INFORMATION5            in     varchar2
  ,P_PMETH_INFORMATION6            in     varchar2
  ,P_PMETH_INFORMATION7            in     varchar2
  ,P_PMETH_INFORMATION8            in     varchar2
  ,P_PMETH_INFORMATION9            in     varchar2
  ,P_PMETH_INFORMATION10           in     varchar2
  ,P_PMETH_INFORMATION11           in     varchar2
  ,P_PMETH_INFORMATION12           in     varchar2
  ,P_PMETH_INFORMATION13           in     varchar2
  ,P_PMETH_INFORMATION14           in     varchar2
  ,P_PMETH_INFORMATION15           in     varchar2
  ,P_PMETH_INFORMATION16           in     varchar2
  ,P_PMETH_INFORMATION17           in     varchar2
  ,P_PMETH_INFORMATION18           in     varchar2
  ,P_PMETH_INFORMATION19           in     varchar2
  ,P_PMETH_INFORMATION20           in     varchar2
  ,P_COMMENTS                      in     varchar2
  ,P_SEGMENT1                      in     varchar2
  ,P_SEGMENT2                      in     varchar2
  ,P_SEGMENT3                      in     varchar2
  ,P_SEGMENT4                      in     varchar2
  ,P_SEGMENT5                      in     varchar2
  ,P_SEGMENT6                      in     varchar2
  ,P_SEGMENT7                      in     varchar2
  ,P_SEGMENT8                      in     varchar2
  ,P_SEGMENT9                      in     varchar2
  ,P_SEGMENT10                     in     varchar2
  ,P_SEGMENT11                     in     varchar2
  ,P_SEGMENT12                     in     varchar2
  ,P_SEGMENT13                     in     varchar2
  ,P_SEGMENT14                     in     varchar2
  ,P_SEGMENT15                     in     varchar2
  ,P_SEGMENT16                     in     varchar2
  ,P_SEGMENT17                     in     varchar2
  ,P_SEGMENT18                     in     varchar2
  ,P_SEGMENT19                     in     varchar2
  ,P_SEGMENT20                     in     varchar2
  ,P_SEGMENT21                     in     varchar2
  ,P_SEGMENT22                     in     varchar2
  ,P_SEGMENT23                     in     varchar2
  ,P_SEGMENT24                     in     varchar2
  ,P_SEGMENT25                     in     varchar2
  ,P_SEGMENT26                     in     varchar2
  ,P_SEGMENT27                     in     varchar2
  ,P_SEGMENT28                     in     varchar2
  ,P_SEGMENT29                     in     varchar2
  ,P_SEGMENT30                     in     varchar2
  ,P_CONCAT_SEGMENTS               in     varchar2
  ,P_GL_SEGMENT1                   in     varchar2
  ,P_GL_SEGMENT2                   in     varchar2
  ,P_GL_SEGMENT3                   in     varchar2
  ,P_GL_SEGMENT4                   in     varchar2
  ,P_GL_SEGMENT5                   in     varchar2
  ,P_GL_SEGMENT6                   in     varchar2
  ,P_GL_SEGMENT7                   in     varchar2
  ,P_GL_SEGMENT8                   in     varchar2
  ,P_GL_SEGMENT9                   in     varchar2
  ,P_GL_SEGMENT10                  in     varchar2
  ,P_GL_SEGMENT11                  in     varchar2
  ,P_GL_SEGMENT12                  in     varchar2
  ,P_GL_SEGMENT13                  in     varchar2
  ,P_GL_SEGMENT14                  in     varchar2
  ,P_GL_SEGMENT15                  in     varchar2
  ,P_GL_SEGMENT16                  in     varchar2
  ,P_GL_SEGMENT17                  in     varchar2
  ,P_GL_SEGMENT18                  in     varchar2
  ,P_GL_SEGMENT19                  in     varchar2
  ,P_GL_SEGMENT20                  in     varchar2
  ,P_GL_SEGMENT21                  in     varchar2
  ,P_GL_SEGMENT22                  in     varchar2
  ,P_GL_SEGMENT23                  in     varchar2
  ,P_GL_SEGMENT24                  in     varchar2
  ,P_GL_SEGMENT25                  in     varchar2
  ,P_GL_SEGMENT26                  in     varchar2
  ,P_GL_SEGMENT27                  in     varchar2
  ,P_GL_SEGMENT28                  in     varchar2
  ,P_GL_SEGMENT29                  in     varchar2
  ,P_GL_SEGMENT30                  in     varchar2
  ,P_GL_CONCAT_SEGMENTS            in     varchar2
  ,P_GL_CTRL_SEGMENT1              in     varchar2
  ,P_GL_CTRL_SEGMENT2              in     varchar2
  ,P_GL_CTRL_SEGMENT3              in     varchar2
  ,P_GL_CTRL_SEGMENT4              in     varchar2
  ,P_GL_CTRL_SEGMENT5              in     varchar2
  ,P_GL_CTRL_SEGMENT6              in     varchar2
  ,P_GL_CTRL_SEGMENT7              in     varchar2
  ,P_GL_CTRL_SEGMENT8              in     varchar2
  ,P_GL_CTRL_SEGMENT9              in     varchar2
  ,P_GL_CTRL_SEGMENT10             in     varchar2
  ,P_GL_CTRL_SEGMENT11             in     varchar2
  ,P_GL_CTRL_SEGMENT12             in     varchar2
  ,P_GL_CTRL_SEGMENT13             in     varchar2
  ,P_GL_CTRL_SEGMENT14             in     varchar2
  ,P_GL_CTRL_SEGMENT15             in     varchar2
  ,P_GL_CTRL_SEGMENT16             in     varchar2
  ,P_GL_CTRL_SEGMENT17             in     varchar2
  ,P_GL_CTRL_SEGMENT18             in     varchar2
  ,P_GL_CTRL_SEGMENT19             in     varchar2
  ,P_GL_CTRL_SEGMENT20             in     varchar2
  ,P_GL_CTRL_SEGMENT21             in     varchar2
  ,P_GL_CTRL_SEGMENT22             in     varchar2
  ,P_GL_CTRL_SEGMENT23             in     varchar2
  ,P_GL_CTRL_SEGMENT24             in     varchar2
  ,P_GL_CTRL_SEGMENT25             in     varchar2
  ,P_GL_CTRL_SEGMENT26             in     varchar2
  ,P_GL_CTRL_SEGMENT27             in     varchar2
  ,P_GL_CTRL_SEGMENT28             in     varchar2
  ,P_GL_CTRL_SEGMENT29             in     varchar2
  ,P_GL_CTRL_SEGMENT30             in     varchar2
  ,P_GL_CTRL_CONCAT_SEGMENTS       in     varchar2
  ,P_GL_CCRL_SEGMENT1              in     varchar2
  ,P_GL_CCRL_SEGMENT2              in     varchar2
  ,P_GL_CCRL_SEGMENT3              in     varchar2
  ,P_GL_CCRL_SEGMENT4              in     varchar2
  ,P_GL_CCRL_SEGMENT5              in     varchar2
  ,P_GL_CCRL_SEGMENT6              in     varchar2
  ,P_GL_CCRL_SEGMENT7              in     varchar2
  ,P_GL_CCRL_SEGMENT8              in     varchar2
  ,P_GL_CCRL_SEGMENT9              in     varchar2
  ,P_GL_CCRL_SEGMENT10             in     varchar2
  ,P_GL_CCRL_SEGMENT11             in     varchar2
  ,P_GL_CCRL_SEGMENT12             in     varchar2
  ,P_GL_CCRL_SEGMENT13             in     varchar2
  ,P_GL_CCRL_SEGMENT14             in     varchar2
  ,P_GL_CCRL_SEGMENT15             in     varchar2
  ,P_GL_CCRL_SEGMENT16             in     varchar2
  ,P_GL_CCRL_SEGMENT17             in     varchar2
  ,P_GL_CCRL_SEGMENT18             in     varchar2
  ,P_GL_CCRL_SEGMENT19             in     varchar2
  ,P_GL_CCRL_SEGMENT20             in     varchar2
  ,P_GL_CCRL_SEGMENT21             in     varchar2
  ,P_GL_CCRL_SEGMENT22             in     varchar2
  ,P_GL_CCRL_SEGMENT23             in     varchar2
  ,P_GL_CCRL_SEGMENT24             in     varchar2
  ,P_GL_CCRL_SEGMENT25             in     varchar2
  ,P_GL_CCRL_SEGMENT26             in     varchar2
  ,P_GL_CCRL_SEGMENT27             in     varchar2
  ,P_GL_CCRL_SEGMENT28             in     varchar2
  ,P_GL_CCRL_SEGMENT29             in     varchar2
  ,P_GL_CCRL_SEGMENT30             in     varchar2
  ,P_GL_CCRL_CONCAT_SEGMENTS       in     varchar2
  ,P_GL_ERR_SEGMENT1               in     varchar2
  ,P_GL_ERR_SEGMENT2               in     varchar2
  ,P_GL_ERR_SEGMENT3               in     varchar2
  ,P_GL_ERR_SEGMENT4               in     varchar2
  ,P_GL_ERR_SEGMENT5               in     varchar2
  ,P_GL_ERR_SEGMENT6               in     varchar2
  ,P_GL_ERR_SEGMENT7               in     varchar2
  ,P_GL_ERR_SEGMENT8               in     varchar2
  ,P_GL_ERR_SEGMENT9               in     varchar2
  ,P_GL_ERR_SEGMENT10              in     varchar2
  ,P_GL_ERR_SEGMENT11              in     varchar2
  ,P_GL_ERR_SEGMENT12              in     varchar2
  ,P_GL_ERR_SEGMENT13              in     varchar2
  ,P_GL_ERR_SEGMENT14              in     varchar2
  ,P_GL_ERR_SEGMENT15              in     varchar2
  ,P_GL_ERR_SEGMENT16              in     varchar2
  ,P_GL_ERR_SEGMENT17              in     varchar2
  ,P_GL_ERR_SEGMENT18              in     varchar2
  ,P_GL_ERR_SEGMENT19              in     varchar2
  ,P_GL_ERR_SEGMENT20              in     varchar2
  ,P_GL_ERR_SEGMENT21              in     varchar2
  ,P_GL_ERR_SEGMENT22              in     varchar2
  ,P_GL_ERR_SEGMENT23              in     varchar2
  ,P_GL_ERR_SEGMENT24              in     varchar2
  ,P_GL_ERR_SEGMENT25              in     varchar2
  ,P_GL_ERR_SEGMENT26              in     varchar2
  ,P_GL_ERR_SEGMENT27              in     varchar2
  ,P_GL_ERR_SEGMENT28              in     varchar2
  ,P_GL_ERR_SEGMENT29              in     varchar2
  ,P_GL_ERR_SEGMENT30              in     varchar2
  ,P_GL_ERR_CONCAT_SEGMENTS        in     varchar2
  ,P_SETS_OF_BOOK_ID               in     number
  ,P_THIRD_PARTY_PAYMENT           in     varchar2
  ,P_ORG_PAYMENT_METHOD_ID         in     number
  ,P_EFFECTIVE_START_DATE          in     date
  ,P_EFFECTIVE_END_DATE            in     date
  ,P_OBJECT_VERSION_NUMBER         in     number
  ,P_ASSET_CODE_COMBINATION_ID     in     number
  ,P_COMMENT_ID                    in     number
  ,P_EXTERNAL_ACCOUNT_ID           in     number
  ,P_TRANSFER_TO_GL_FLAG           in     varchar2
  ,P_COST_PAYMENT                  in     varchar2
  ,P_COST_CLEARED_PAYMENT          in     varchar2
  ,P_COST_CLEARED_VOID_PAYMENT     in     varchar2
  ,P_EXCLUDE_MANUAL_PAYMENT        in     varchar2
  );
--
end pay_org_payment_method_bk1;

 

/
