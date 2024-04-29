--------------------------------------------------------
--  DDL for Package PAY_ASSG_COST_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ASSG_COST_SS" AUTHID CURRENT_USER as
/* $Header: pyacosss.pkh 120.0.12010000.2 2008/11/29 21:26:33 pgongada noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------------< CREATE_ASSG_COST >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates transaction and stores the costing KFF data into
--   transaction tables
--
-- Prerequisites:
--  The transaction must exist.
--
-- In Parameters:
--   Name                         Reqd   Type      Description
--   p_validate                   no     boolean   If true, then validation alone will be performed and
--                                                 the database will remain unchanged. If false and all
--		                                   validation checks pass, then the database will be modified.
--   p_item_type                  Yes    varchar2  Identifies Item type
--   p_item_key                   Yes    varchar2  Identifies Item key
--   p_actid                      Yes    number    The ID number of the activity that this procedure is
--                                                  called from.
--   p_login_person_id            Yes    number    Login ID of the user.
--   p_effective_date             Yes    Date      Effective Date
--   p_assignment_id              Yes    number    Assignment id of the person whose costing is getting created/changed
--   p_business_group_id          Yes    number    Business Group ID
--   p_proportion                 Yes    number    Proportion
--   p_segment1                   No     varchar2  Segment1 value
--   p_segment2                   No     varchar2  Segment2 value
--   p_segment3                   No     varchar2  Segment3 value
--   p_segment4                   No     varchar2  Segment4 value
--   p_segment5                   No     varchar2  Segment5 value
--   p_segment6                   No     varchar2  Segment6 value
--   p_segment7                   No     varchar2  Segment7 value
--   p_segment8                   No     varchar2  Segment8 value
--   p_segment9                   No     varchar2  Segment9 value
--   p_segment10                  No     varchar2  Segment10 value
--   p_segment11                  No     varchar2  Segment11 value
--   p_segment12                  No     varchar2  Segment12 value
--   p_segment13                  No     varchar2  Segment13 value
--   p_segment14                  No     varchar2  Segment14 value
--   p_segment15                  No     varchar2  Segment15 value
--   p_segment16                  No     varchar2  Segment16 value
--   p_segment17                  No     varchar2  Segment17 value
--   p_segment18                  No     varchar2  Segment18 value
--   p_segment19                  No     varchar2  Segment19 value
--   p_segment20                  No     varchar2  Segment20 value
--   p_segment21                  No     varchar2  Segment21 value
--   p_segment22                  No     varchar2  Segment22 value
--   p_segment23                  No     varchar2  Segment23 value
--   p_segment24                  No     varchar2  Segment24 value
--   p_segment25                  No     varchar2  Segment25 value
--   p_segment26                  No     varchar2  Segment26 value
--   p_segment27                  No     varchar2  Segment27 value
--   p_segment28                  No     varchar2  Segment28 value
--   p_segment29                  No     varchar2  Segment29 value
--   p_segment30                  No     varchar2  Segment30 value
--   p_cost_allocation_keyflex_id Yes    Number    Cost allocation keyflex id
--
-- Post Success:
--   A transaction will be created and the values into the transaction tables
--   as well. It sets the following out parameters.
--
-- Out Parameters:
--   p_trasaction_id         Number    Identifies the transaction created.
--   p_transaction_step_id   Number    Identifies the transaction step created.
--
-- Post Failure:
--   An exception is raised and nothing will be created.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
PROCEDURE CREATE_ASSG_COST(
          P_ITEM_TYPE                    IN VARCHAR2
         ,P_ITEM_KEY                     IN VARCHAR2
         ,P_ACTID                        IN NUMBER
         ,P_LOGIN_PERSON_ID              IN NUMBER
         ,P_EFFECTIVE_DATE               IN DATE
         ,P_ASSIGNMENT_ID                IN NUMBER
         ,P_BUSINESS_GROUP_ID            IN NUMBER
         ,P_PROPORTION                   IN NUMBER
         ,P_COST_ALLOCATION_KEYFLEX_ID   IN NUMBER
         ,P_SEGMENT1                     IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT2                     IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT3                     IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT4                     IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT5                     IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT6                     IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT7                     IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT8                     IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT9                     IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT10                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT11                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT12                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT13                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT14                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT15                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT16                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT17                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT18                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT19                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT20                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT21                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT22                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT23                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT24                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT25                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT26                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT27                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT28                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT29                    IN VARCHAR2 DEFAULT NULL
         ,P_SEGMENT30                    IN VARCHAR2 DEFAULT NULL
         ,P_CONCATENATED_SEGMENTS        IN VARCHAR2 DEFAULT NULL
         ,P_EFFECTIVE_START_DATE         IN DATE     DEFAULT NULL
         ,P_EFFECTIVE_END_DATE           IN DATE     DEFAULT NULL
         ,P_TRANSACTION_ID               OUT NOCOPY    NUMBER
         ,P_TRANSACTION_STEP_ID          OUT NOCOPY    NUMBER
         );
-- ----------------------------------------------------------------------------
-- |----------------------------< CREATE_DATA >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates data into base tables PAY_COST_ALLOCATIONS_F,
--   PAY_COST_ALLOCATION_KEYFLEX.
--
-- Prerequisites:
--  The transaction must exist.
--
-- In Parameters:
--   Name                         Reqd   Type      Description
--   p_validate                   no     boolean   If true, then validation alone will be performed and
--                                                 the database will remain unchanged. If false and all
--	 	                                             validation checks pass, then the database will be modified.
--   p_transaction_step_id        Yes    Number    Identifies the transaction id.
--   p_effective_date             No     Date      Identifies the effective date
--
-- Post Success:
--   The data will be created in PAY_COST_ALLOCATIONS_F, PAY_COST_ALLOCATION_KEYFLEX
--   It also updated the workflow table with the detials.
--
--
-- Post Failure:
--   An exception is raised and nothing will be created.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
PROCEDURE CREATE_DATA(
p_validate                  in     boolean default false
,p_transaction_step_id      in     number
);
-- ----------------------------------------------------------------------------
-- |----------------------------< UPDATE_ASSG_COST >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates transaction and stores the costing KFF data into
--   transaction tables
--
-- Prerequisites:
--  The transaction must exist.
--
-- In Parameters:
--   Name                         Reqd   Type      Description
--   p_validate                   no     boolean   If true, then validation alone will be performed and
--                                                 the database will remain unchanged. If false and all
--		                                             validation checks pass, then the database will be modified.
--   p_item_type                  Yes    varchar2  Identifies Item type
--   p_item_key                   Yes    varchar2  Identifies Item key
--         p_actid                        in number
--   p_login_person_id            Yes    number    Login ID of the user.
--   p_effective_date             Yes    Date      Effective Date
--   p_assignment_id              Yes    number    Assignment id of the person whose costing is getting changed
--   p_business_group_id          Yes    number    Business Group ID
--   p_proportion                 No     number    Proportion
--   p_cost_allocation_id         Yes    number    Identifies which cost allocation to be changed.
--   p_cost_allocation_keyflex_id Yes    number    Identifies the cost keyflex id.
--   p_object_version_number      Yes    number    Object version number
--   p_segment1                   No     varchar2  Segment1 value
--   p_segment2                   No     varchar2  Segment2 value
--   p_segment3                   No     varchar2  Segment3 value
--   p_segment4                   No     varchar2  Segment4 value
--   p_segment5                   No     varchar2  Segment5 value
--   p_segment6                   No     varchar2  Segment6 value
--   p_segment7                   No     varchar2  Segment7 value
--   p_segment8                   No     varchar2  Segment8 value
--   p_segment9                   No     varchar2  Segment9 value
--   p_segment10                  No     varchar2  Segment10 value
--   p_segment11                  No     varchar2  Segment11 value
--   p_segment12                  No     varchar2  Segment12 value
--   p_segment13                  No     varchar2  Segment13 value
--   p_segment14                  No     varchar2  Segment14 value
--   p_segment15                  No     varchar2  Segment15 value
--   p_segment16                  No     varchar2  Segment16 value
--   p_segment17                  No     varchar2  Segment17 value
--   p_segment18                  No     varchar2  Segment18 value
--   p_segment19                  No     varchar2  Segment19 value
--   p_segment20                  No     varchar2  Segment20 value
--   p_segment21                  No     varchar2  Segment21 value
--   p_segment22                  No     varchar2  Segment22 value
--   p_segment23                  No     varchar2  Segment23 value
--   p_segment24                  No     varchar2  Segment24 value
--   p_segment25                  No     varchar2  Segment25 value
--   p_segment26                  No     varchar2  Segment26 value
--   p_segment27                  No     varchar2  Segment27 value
--   p_segment28                  No     varchar2  Segment28 value
--   p_segment29                  No     varchar2  Segment29 value
--   p_segment30                  No     varchar2  Segment30 value
--
-- Post Success:
--   A transaction will be created and the values into the transaction tables
--   as well. It sets the following out parameters.
--
-- Out Parameters:
--   p_trasaction_id         Number    Identifies the transaction created.
--   p_transaction_step_id   Number    Identifies the transaction step created.
--
-- Post Failure:
--   An exception is raised and nothing will be created.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
PROCEDURE UPDATE_ASSG_COST(
          P_ITEM_TYPE                    IN VARCHAR2
         ,P_ITEM_KEY                     IN VARCHAR2
         ,P_ACTID                        IN NUMBER
         ,P_LOGIN_PERSON_ID              IN NUMBER
         ,P_UPDATE_MODE                  IN VARCHAR2 DEFAULT 'UPDATE'
         ,P_EFFECTIVE_DATE               IN DATE     DEFAULT SYSDATE
         ,P_ASSIGNMENT_ID                IN NUMBER
         ,P_COST_ALLOCATION_ID           IN NUMBER
         ,P_BUSINESS_GROUP_ID            IN NUMBER
         ,P_COST_ALLOCATION_KEYFLEX_ID   IN NUMBER
         ,P_OBJECT_VERSION_NUMBER        IN NUMBER
         ,P_PROPORTION                   IN NUMBER   default hr_api.g_number
         ,P_SEGMENT1                     IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT2                     IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT3                     IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT4                     IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT5                     IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT6                     IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT7                     IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT8                     IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT9                     IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT10                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT11                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT12                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT13                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT14                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT15                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT16                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT17                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT18                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT19                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT20                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT21                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT22                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT23                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT24                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT25                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT26                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT27                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT28                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT29                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_SEGMENT30                    IN VARCHAR2 default hr_api.g_varchar2
         ,P_CONCATENATED_SEGMENTS        IN VARCHAR2 DEFAULT hr_api.g_varchar2
         ,P_EFFECTIVE_START_DATE         IN DATE     DEFAULT NULL
         ,P_EFFECTIVE_END_DATE           IN DATE     DEFAULT NULL
         ,P_TRANSACTION_ID               OUT NOCOPY    NUMBER
         ,P_TRANSACTION_STEP_ID          OUT NOCOPY    NUMBER
         );
-- ----------------------------------------------------------------------------
-- |----------------------------< UPDATE_DATA >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API updates data into base tables PAY_COST_ALLOCATIONS_F,
--   PAY_COST_ALLOCATION_KEYFLEX.
--
-- Prerequisites:
--  The transaction must exist.
--
-- In Parameters:
--   Name                         Reqd   Type      Description
--   p_validate                   no     boolean   If true, then validation alone will be performed and
--                                                 the database will remain unchanged. If false and all
--	 	                                             validation checks pass, then the database will be modified.
--   p_transaction_step_id        Yes    Number    Identifies the transaction id.
--   p_effective_date             No     Date      Identifies the effective date.
--
-- Post Success:
--   The data will be updated in PAY_COST_ALLOCATIONS_F, PAY_COST_ALLOCATION_KEYFLEX
--   It also updated the workflow table with the details.
--
--
-- Post Failure:
--   An exception is raised and nothing will be created.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
PROCEDURE UPDATE_DATA(
P_VALIDATE                  IN     BOOLEAN DEFAULT FALSE
,P_TRANSACTION_STEP_ID      IN     NUMBER
);

-- ----------------------------------------------------------------------------
-- |----------------------------< DELETE_ASSG_COST >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates transaction and stores the costing KFF data into
--   transaction tables pertaining to delete operation.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                         Reqd   Type      Description
--   p_validate                   no     boolean   If true, then validation alone will be performed and
--                                                 the database will remain unchanged. If false and all
--		                                             validation checks pass, then the database will be modified.
--   p_item_type                  Yes    varchar2  Identifies Item type
--   p_item_key                   Yes    varchar2  Identifies Item key
--   p_actid                      Yes    number    Identifies Activity Id.
--   p_login_person_id            Yes    number    Login ID of the user.
--   p_effective_date             Yes    Date      Effective Date
--   p_assignment_id              Yes    number    Assignment id of the person whose costing is getting changed
--   p_business_group_id          Yes    number    Business Group ID
--   p_cost_allocation_id         Yes    number    Identifies which cost allocation to be changed.
--   p_object_version_number      Yes    number    Object version number
-- Post Success:
--   A transaction will be created and the values into the transaction tables
--   as well. It sets the following out parameters.
--
-- Out Parameters:
--   p_trasaction_id         Number    Identifies the transaction created.
--   p_transaction_step_id   Number    Identifies the transaction step created.
--
-- Post Failure:
--   An exception is raised and nothing will be created.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
PROCEDURE DELETE_ASSG_COST(
          P_ITEM_TYPE                    IN VARCHAR2
         ,P_ITEM_KEY                     IN VARCHAR2
         ,P_ACTID                        IN NUMBER
         ,P_LOGIN_PERSON_ID              IN NUMBER
         ,P_DELETE_MODE                  IN VARCHAR2 DEFAULT 'DELETE'
         ,P_EFFECTIVE_DATE               IN DATE
         ,P_ASSIGNMENT_ID                IN NUMBER
         ,P_BUSINESS_GROUP_ID            IN NUMBER
         ,P_COST_ALLOCATION_ID           IN NUMBER
         ,P_OBJECT_VERSION_NUMBER        IN NUMBER
         ,P_CONCATENATED_SEGMENTS        IN VARCHAR2 DEFAULT NULL
         ,P_EFFECTIVE_START_DATE         IN DATE     DEFAULT NULL
         ,P_EFFECTIVE_END_DATE           IN DATE     DEFAULT NULL
         ,P_TRANSACTION_ID               OUT NOCOPY    NUMBER
         ,P_TRANSACTION_STEP_ID          OUT NOCOPY    NUMBER
         );
-- ----------------------------------------------------------------------------
-- |----------------------------< DELETE_DATA >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API deletes data into base tables PAY_COST_ALLOCATIONS_F.
--
-- Prerequisites:
--  The transaction must exist.
--
-- In Parameters:
--   Name                         Reqd   Type      Description
--   p_validate                   no     boolean   If true, then validation alone will be performed and
--                                                 the database will remain unchanged. If false and all
--	 	                                             validation checks pass, then the database will be modified.
--   p_transaction_step_id        Yes    Number    Identifies the transaction id.
--   p_effective_date             No     Date      Identifies the effective date.
--
-- Post Success:
--   The data will be deleted in PAY_COST_ALLOCATIONS_F
--   It also updates the workflow table with the details.
--
--
-- Post Failure:
--   An exception is raised and nothing will be created.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
PROCEDURE DELETE_DATA(
P_VALIDATE                  IN     BOOLEAN DEFAULT FALSE
,P_TRANSACTION_STEP_ID      IN     NUMBER
);
end PAY_ASSG_COST_SS;

/
