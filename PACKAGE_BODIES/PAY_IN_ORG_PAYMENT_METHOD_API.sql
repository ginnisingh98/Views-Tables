--------------------------------------------------------
--  DDL for Package Body PAY_IN_ORG_PAYMENT_METHOD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_ORG_PAYMENT_METHOD_API" AS
/* $Header: pyopmini.pkb 120.0 2005/05/29 07:09 appldev noship $ */

g_package  VARCHAR2(32) := 'pay_in_org_payment_method_api.';
g_trace BOOLEAN ;

-- ----------------------------------------------------------------------------
-- |----------------------< create_in_org_payment_method >-----------------------|
-- ----------------------------------------------------------------------------

PROCEDURE create_in_org_payment_method
  (P_VALIDATE                      IN     BOOLEAN  DEFAULT false
  ,P_EFFECTIVE_DATE                IN     DATE
  ,P_LANGUAGE_CODE                 IN     VARCHAR2 DEFAULT hr_api.userenv_lang
  ,P_BUSINESS_GROUP_ID             IN     NUMBER
  ,P_ORG_PAYMENT_METHOD_NAME       IN     VARCHAR2
  ,P_PAYMENT_TYPE_ID               IN     NUMBER
  ,P_CURRENCY_CODE                 IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE_CATEGORY            IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE1                    IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE2                    IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE3                    IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE4                    IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE5                    IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE6                    IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE7                    IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE8                    IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE9                    IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE10                   IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE11                   IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE12                   IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE13                   IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE14                   IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE15                   IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE16                   IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE17                   IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE18                   IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE19                   IN     VARCHAR2 DEFAULT null
  ,P_ATTRIBUTE20                   IN     VARCHAR2 DEFAULT null
  ,p_payable_at                    IN     VARCHAR2 DEFAULT null -- Bugfix 3762728
  ,P_COMMENTS                      IN     VARCHAR2 DEFAULT null
  ,p_account_number                IN     VARCHAR2 DEFAULT null -- Bugfix 3762728
  ,p_account_type                  IN     VARCHAR2 DEFAULT null
  ,p_bank_code                     IN     VARCHAR2 DEFAULT null
  ,p_branch_code                   IN     VARCHAR2 DEFAULT null
  ,P_CONCAT_SEGMENTS               IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT1                   IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT2                   IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT3                   IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT4                   IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT5                   IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT6                   IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT7                   IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT8                   IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT9                   IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT10                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT11                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT12                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT13                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT14                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT15                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT16                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT17                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT18                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT19                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT20                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT21                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT22                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT23                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT24                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT25                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT26                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT27                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT28                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT29                  IN     VARCHAR2 DEFAULT null
  ,P_GL_SEGMENT30                  IN     VARCHAR2 DEFAULT null
  ,P_GL_CONCAT_SEGMENTS            IN     VARCHAR2 DEFAULT null
  ,P_SETS_OF_BOOK_ID               IN     NUMBER   DEFAULT null
  ,P_THIRD_PARTY_PAYMENT           IN     VARCHAR2 DEFAULT 'N'
  ,P_ORG_PAYMENT_METHOD_ID            OUT NOCOPY NUMBER
  ,P_EFFECTIVE_START_DATE             OUT NOCOPY DATE
  ,P_EFFECTIVE_END_DATE               OUT NOCOPY DATE
  ,P_OBJECT_VERSION_NUMBER            OUT NOCOPY NUMBER
  ,P_ASSET_CODE_COMBINATION_ID        OUT NOCOPY NUMBER
  ,P_COMMENT_ID                       OUT NOCOPY NUMBER
  ,P_EXTERNAL_ACCOUNT_ID              OUT NOCOPY NUMBER) IS

  --
  -- Declare cursors and local variables
  --
    l_proc  VARCHAR2(72);
  BEGIN

    l_proc := g_package||'create_in_org_payment_method';
    g_trace := hr_utility.debug_enabled ;

    IF g_trace THEN
      hr_utility.set_location('Entering: '||l_proc, 10);
    END IF ;

   IF  hr_general2.IS_BG(p_business_group_id, 'IN') = false then
     hr_utility.set_message(800, 'HR_7208_API_BUS_GRP_INVALID');
     hr_utility.raise_error;
   END IF;

   IF g_trace THEN
       hr_utility.set_location(l_proc, 20);
   END IF ;

   PAY_ORG_PAYMENT_METHOD_API.create_org_payment_method
   (P_VALIDATE                   =>  P_VALIDATE
   ,P_EFFECTIVE_DATE             =>  P_EFFECTIVE_DATE
   ,P_LANGUAGE_CODE              =>  P_LANGUAGE_CODE
   ,P_BUSINESS_GROUP_ID          =>  P_BUSINESS_GROUP_ID
   ,P_ORG_PAYMENT_METHOD_NAME    =>  P_ORG_PAYMENT_METHOD_NAME
   ,P_PAYMENT_TYPE_ID            =>  P_PAYMENT_TYPE_ID
   ,P_CURRENCY_CODE              =>  P_CURRENCY_CODE
   ,P_ATTRIBUTE_CATEGORY         =>  P_ATTRIBUTE_CATEGORY
   ,P_ATTRIBUTE1                 =>  P_ATTRIBUTE1
   ,P_ATTRIBUTE2                 =>  P_ATTRIBUTE2
   ,P_ATTRIBUTE3                 =>  P_ATTRIBUTE3
   ,P_ATTRIBUTE4                 =>  P_ATTRIBUTE4
   ,P_ATTRIBUTE5                 =>  P_ATTRIBUTE5
   ,P_ATTRIBUTE6                 =>  P_ATTRIBUTE6
   ,P_ATTRIBUTE7                 =>  P_ATTRIBUTE7
   ,P_ATTRIBUTE8                 =>  P_ATTRIBUTE8
   ,P_ATTRIBUTE9                 =>  P_ATTRIBUTE9
   ,P_ATTRIBUTE10                =>  P_ATTRIBUTE10
   ,P_ATTRIBUTE11                =>  P_ATTRIBUTE11
   ,P_ATTRIBUTE12                =>  P_ATTRIBUTE12
   ,P_ATTRIBUTE13                =>  P_ATTRIBUTE13
   ,P_ATTRIBUTE14                =>  P_ATTRIBUTE14
   ,P_ATTRIBUTE15                =>  P_ATTRIBUTE15
   ,P_ATTRIBUTE16                =>  P_ATTRIBUTE16
   ,P_ATTRIBUTE17                =>  P_ATTRIBUTE17
   ,P_ATTRIBUTE18                =>  P_ATTRIBUTE18
   ,P_ATTRIBUTE19                =>  P_ATTRIBUTE19
   ,P_ATTRIBUTE20                =>  P_ATTRIBUTE20
   ,P_PMETH_INFORMATION1         =>  p_payable_at      -- Bugfix 3762728
   ,P_COMMENTS                   =>  P_COMMENTS
   ,P_SEGMENT1                   =>  p_account_number  -- Bugfix 3762728
   ,P_SEGMENT2                   =>  p_account_type
   ,P_SEGMENT3                   =>  p_bank_code
   ,P_SEGMENT4                   =>  p_branch_code
   ,P_CONCAT_SEGMENTS            =>  P_CONCAT_SEGMENTS
   ,P_GL_SEGMENT1                =>  P_GL_SEGMENT1
   ,P_GL_SEGMENT2                =>  P_GL_SEGMENT2
   ,P_GL_SEGMENT3                =>  P_GL_SEGMENT3
   ,P_GL_SEGMENT4                =>  P_GL_SEGMENT4
   ,P_GL_SEGMENT5                =>  P_GL_SEGMENT5
   ,P_GL_SEGMENT6                =>  P_GL_SEGMENT6
   ,P_GL_SEGMENT7                =>  P_GL_SEGMENT7
   ,P_GL_SEGMENT8                =>  P_GL_SEGMENT8
   ,P_GL_SEGMENT9                =>  P_GL_SEGMENT9
   ,P_GL_SEGMENT10               =>  P_GL_SEGMENT10
   ,P_GL_SEGMENT11               =>  P_GL_SEGMENT11
   ,P_GL_SEGMENT12               =>  P_GL_SEGMENT12
   ,P_GL_SEGMENT13               =>  P_GL_SEGMENT13
   ,P_GL_SEGMENT14               =>  P_GL_SEGMENT14
   ,P_GL_SEGMENT15               =>  P_GL_SEGMENT15
   ,P_GL_SEGMENT16               =>  P_GL_SEGMENT16
   ,P_GL_SEGMENT17               =>  P_GL_SEGMENT17
   ,P_GL_SEGMENT18               =>  P_GL_SEGMENT18
   ,P_GL_SEGMENT19               =>  P_GL_SEGMENT19
   ,P_GL_SEGMENT20               =>  P_GL_SEGMENT20
   ,P_GL_SEGMENT21               =>  P_GL_SEGMENT21
   ,P_GL_SEGMENT22               =>  P_GL_SEGMENT22
   ,P_GL_SEGMENT23               =>  P_GL_SEGMENT23
   ,P_GL_SEGMENT24               =>  P_GL_SEGMENT24
   ,P_GL_SEGMENT25               =>  P_GL_SEGMENT25
   ,P_GL_SEGMENT26               =>  P_GL_SEGMENT26
   ,P_GL_SEGMENT27               =>  P_GL_SEGMENT27
   ,P_GL_SEGMENT28               =>  P_GL_SEGMENT28
   ,P_GL_SEGMENT29               =>  P_GL_SEGMENT29
   ,P_GL_SEGMENT30               =>  P_GL_SEGMENT30
   ,P_GL_CONCAT_SEGMENTS         =>  P_GL_CONCAT_SEGMENTS
   ,P_SETS_OF_BOOK_ID            =>  P_SETS_OF_BOOK_ID
   ,P_THIRD_PARTY_PAYMENT        =>  P_THIRD_PARTY_PAYMENT
   ,P_ORG_PAYMENT_METHOD_ID      =>  P_ORG_PAYMENT_METHOD_ID
   ,P_EFFECTIVE_START_DATE       =>  P_EFFECTIVE_START_DATE
   ,P_EFFECTIVE_END_DATE         =>  P_EFFECTIVE_END_DATE
   ,P_OBJECT_VERSION_NUMBER      =>  P_OBJECT_VERSION_NUMBER
   ,P_ASSET_CODE_COMBINATION_ID  =>  P_ASSET_CODE_COMBINATION_ID
   ,P_COMMENT_ID                 =>  P_COMMENT_ID
   ,P_EXTERNAL_ACCOUNT_ID        =>  P_EXTERNAL_ACCOUNT_ID);

   IF g_trace THEN
       hr_utility.set_location(l_proc, 30);
   END IF ;

 END  create_in_org_payment_method;

-- ----------------------------------------------------------------------------
-- |----------------------< update_in_org_payment_method >-----------------------|
-- ----------------------------------------------------------------------------

PROCEDURE update_in_org_payment_method
  (P_VALIDATE                      IN     BOOLEAN  DEFAULT false
  ,P_EFFECTIVE_DATE                IN     DATE
  ,P_DATETRACK_UPDATE_MODE         IN     VARCHAR2
  ,P_LANGUAGE_CODE                 IN     VARCHAR2 DEFAULT hr_api.userenv_lang
  ,P_ORG_PAYMENT_METHOD_ID         IN     NUMBER
  ,P_OBJECT_VERSION_NUMBER         IN OUT NOCOPY NUMBER
  ,P_ORG_PAYMENT_METHOD_NAME       IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_CURRENCY_CODE                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE_CATEGORY            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE1                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE2                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE3                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE4                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE5                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE6                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE7                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE8                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE9                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE10                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE11                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE12                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE13                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE14                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE15                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE16                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE17                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE18                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE19                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_ATTRIBUTE20                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_payable_at                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2 -- Bugfix 3762728
  ,P_COMMENTS                      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_account_number                IN     VARCHAR2 DEFAULT hr_api.g_varchar2 -- Bugfix 3762728
  ,p_account_type                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_bank_code                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_branch_code                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_CONCAT_SEGMENTS               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT1                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT2                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT3                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT4                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT5                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT6                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT7                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT8                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT9                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT10                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT11                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT12                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT13                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT14                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT15                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT16                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT17                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT18                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT19                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT20                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT21                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT22                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT23                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT24                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT25                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT26                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT27                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT28                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT29                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_SEGMENT30                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_GL_CONCAT_SEGMENTS            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,P_SETS_OF_BOOK_ID               IN     NUMBER   DEFAULT hr_api.g_number
  ,P_EFFECTIVE_START_DATE             OUT NOCOPY DATE
  ,P_EFFECTIVE_END_DATE               OUT NOCOPY DATE
  ,P_ASSET_CODE_COMBINATION_ID        OUT NOCOPY NUMBER
  ,P_COMMENT_ID                       OUT NOCOPY NUMBER
  ,P_EXTERNAL_ACCOUNT_ID              OUT NOCOPY NUMBER
  ) IS

    l_proc  VARCHAR2(72);
    L_LANGUAGE_CODE varchar2(100);
  BEGIN

    l_proc := g_package||'update_in_org_payment_method';
    g_trace := hr_utility.debug_enabled ;

    IF g_trace THEN
      hr_utility.set_location('Entering: '||l_proc, 10);
    END IF ;

     hr_utility.trace('P_LANG'||P_LANGUAGE_CODE);
     l_language_code :=p_language_code;
   IF p_language_code = hr_api.g_varchar2 THEN
    l_language_code :='US';
   END IF;
   pay_org_payment_method_api.update_org_payment_method
   (P_VALIDATE                       =>  P_VALIDATE
   ,P_EFFECTIVE_DATE                 =>  P_EFFECTIVE_DATE
   ,P_DATETRACK_UPDATE_MODE          =>  P_DATETRACK_UPDATE_MODE
   ,P_LANGUAGE_CODE                  =>  P_LANGUAGE_CODE
   ,P_ORG_PAYMENT_METHOD_ID          =>  P_ORG_PAYMENT_METHOD_ID
   ,P_OBJECT_VERSION_NUMBER          =>  P_OBJECT_VERSION_NUMBER
   ,P_ORG_PAYMENT_METHOD_NAME        =>  P_ORG_PAYMENT_METHOD_NAME
   ,P_CURRENCY_CODE                  =>  P_CURRENCY_CODE
   ,P_ATTRIBUTE_CATEGORY             =>  P_ATTRIBUTE_CATEGORY
   ,P_ATTRIBUTE1                     =>  P_ATTRIBUTE1
   ,P_ATTRIBUTE2                     =>  P_ATTRIBUTE2
   ,P_ATTRIBUTE3                     =>  P_ATTRIBUTE3
   ,P_ATTRIBUTE4                     =>  P_ATTRIBUTE4
   ,P_ATTRIBUTE5                     =>  P_ATTRIBUTE5
   ,P_ATTRIBUTE6                     =>  P_ATTRIBUTE6
   ,P_ATTRIBUTE7                     =>  P_ATTRIBUTE7
   ,P_ATTRIBUTE8                     =>  P_ATTRIBUTE8
   ,P_ATTRIBUTE9                     =>  P_ATTRIBUTE9
   ,P_ATTRIBUTE10                    =>  P_ATTRIBUTE10
   ,P_ATTRIBUTE11                    =>  P_ATTRIBUTE11
   ,P_ATTRIBUTE12                    =>  P_ATTRIBUTE12
   ,P_ATTRIBUTE13                    =>  P_ATTRIBUTE13
   ,P_ATTRIBUTE14                    =>  P_ATTRIBUTE14
   ,P_ATTRIBUTE15                    =>  P_ATTRIBUTE15
   ,P_ATTRIBUTE16                    =>  P_ATTRIBUTE16
   ,P_ATTRIBUTE17                    =>  P_ATTRIBUTE17
   ,P_ATTRIBUTE18                    =>  P_ATTRIBUTE18
   ,P_ATTRIBUTE19                    =>  P_ATTRIBUTE19
   ,P_ATTRIBUTE20                    =>  P_ATTRIBUTE20
   ,P_PMETH_INFORMATION1             =>  p_payable_at    -- Bugfix 3762728
   ,P_COMMENTS                       =>  P_COMMENTS
   ,P_SEGMENT1                       =>  p_account_number -- Bugfix 3762728
   ,P_SEGMENT2                       =>  p_account_type
   ,P_SEGMENT3                       =>  p_bank_code
   ,P_SEGMENT4                       =>  p_branch_code
   ,P_CONCAT_SEGMENTS                =>  P_CONCAT_SEGMENTS
   ,P_GL_SEGMENT1                    =>  P_GL_SEGMENT1
   ,P_GL_SEGMENT2                    =>  P_GL_SEGMENT2
   ,P_GL_SEGMENT3                    =>  P_GL_SEGMENT3
   ,P_GL_SEGMENT4                    =>  P_GL_SEGMENT4
   ,P_GL_SEGMENT5                    =>  P_GL_SEGMENT5
   ,P_GL_SEGMENT6                    =>  P_GL_SEGMENT6
   ,P_GL_SEGMENT7                    =>  P_GL_SEGMENT7
   ,P_GL_SEGMENT8                    =>  P_GL_SEGMENT8
   ,P_GL_SEGMENT9                    =>  P_GL_SEGMENT9
   ,P_GL_SEGMENT10                   =>  P_GL_SEGMENT10
   ,P_GL_SEGMENT11                   =>  P_GL_SEGMENT11
   ,P_GL_SEGMENT12                   =>  P_GL_SEGMENT12
   ,P_GL_SEGMENT13                   =>  P_GL_SEGMENT13
   ,P_GL_SEGMENT14                   =>  P_GL_SEGMENT14
   ,P_GL_SEGMENT15                   =>  P_GL_SEGMENT15
   ,P_GL_SEGMENT16                   =>  P_GL_SEGMENT16
   ,P_GL_SEGMENT17                   =>  P_GL_SEGMENT17
   ,P_GL_SEGMENT18                   =>  P_GL_SEGMENT18
   ,P_GL_SEGMENT19                   =>  P_GL_SEGMENT19
   ,P_GL_SEGMENT20                   =>  P_GL_SEGMENT20
   ,P_GL_SEGMENT21                   =>  P_GL_SEGMENT21
   ,P_GL_SEGMENT22                   =>  P_GL_SEGMENT22
   ,P_GL_SEGMENT23                   =>  P_GL_SEGMENT23
   ,P_GL_SEGMENT24                   =>  P_GL_SEGMENT24
   ,P_GL_SEGMENT25                   =>  P_GL_SEGMENT25
   ,P_GL_SEGMENT26                   =>  P_GL_SEGMENT26
   ,P_GL_SEGMENT27                   =>  P_GL_SEGMENT27
   ,P_GL_SEGMENT28                   =>  P_GL_SEGMENT28
   ,P_GL_SEGMENT29                   =>  P_GL_SEGMENT29
   ,P_GL_SEGMENT30                   =>  P_GL_SEGMENT30
   ,P_GL_CONCAT_SEGMENTS             =>  P_GL_CONCAT_SEGMENTS
   ,P_SETS_OF_BOOK_ID                =>  P_SETS_OF_BOOK_ID
   ,P_EFFECTIVE_START_DATE           =>  P_EFFECTIVE_START_DATE
   ,P_EFFECTIVE_END_DATE             =>  P_EFFECTIVE_END_DATE
   ,P_ASSET_CODE_COMBINATION_ID      =>  P_ASSET_CODE_COMBINATION_ID
   ,P_COMMENT_ID                     =>  P_COMMENT_ID
   ,P_EXTERNAL_ACCOUNT_ID            =>  P_EXTERNAL_ACCOUNT_ID);


   IF g_trace THEN
       hr_utility.set_location(l_proc, 20);
   END IF ;

 END  update_in_org_payment_method;

END pay_in_org_payment_method_api;



/
