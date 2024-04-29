--------------------------------------------------------
--  DDL for Package HR_GRADE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GRADE_BK2" AUTHID CURRENT_USER as
/* $Header: pegrdapi.pkh 120.1.12010000.3 2008/12/05 08:02:39 sidsaxen ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_grade_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_grade_b
  (P_GRADE_ID             	   IN      NUMBER
   ,P_SEQUENCE                      IN     NUMBER
   ,P_DATE_FROM                     IN     DATE
   ,P_DATE_TO                       IN     DATE
   ,p_effective_date		    in     date
   ,P_REQUEST_ID                    IN     NUMBER
   ,P_PROGRAM_APPLICATION_ID        IN     NUMBER
   ,P_PROGRAM_ID                    IN     NUMBER
   ,P_PROGRAM_UPDATE_DATE           IN     DATE
   ,P_ATTRIBUTE_CATEGORY            IN     VARCHAR2
   ,P_ATTRIBUTE1                    IN     VARCHAR2
   ,P_ATTRIBUTE2                    IN     VARCHAR2
   ,P_ATTRIBUTE3                    IN     VARCHAR2
   ,P_ATTRIBUTE4                    IN     VARCHAR2
   ,P_ATTRIBUTE5                    IN     VARCHAR2
   ,P_ATTRIBUTE6                    IN     VARCHAR2
   ,P_ATTRIBUTE7                    IN     VARCHAR2
   ,P_ATTRIBUTE8                    IN     VARCHAR2
   ,P_ATTRIBUTE9                    IN     VARCHAR2
   ,P_ATTRIBUTE10                   IN     VARCHAR2
   ,P_ATTRIBUTE11                   IN     VARCHAR2
   ,P_ATTRIBUTE12                   IN     VARCHAR2
   ,P_ATTRIBUTE13                   IN     VARCHAR2
   ,P_ATTRIBUTE14                   IN     VARCHAR2
   ,P_ATTRIBUTE15                   IN     VARCHAR2
   ,P_ATTRIBUTE16                   IN     VARCHAR2
   ,P_ATTRIBUTE17                   IN     VARCHAR2
   ,P_ATTRIBUTE18                   IN     VARCHAR2
   ,P_ATTRIBUTE19                   IN     VARCHAR2
   ,P_ATTRIBUTE20                   IN     VARCHAR2
   ,P_INFORMATION_CATEGORY          IN     VARCHAR2
   ,P_INFORMATION1                  IN     VARCHAR2
   ,P_INFORMATION2                  IN     VARCHAR2
   ,P_INFORMATION3                  IN     VARCHAR2
   ,P_INFORMATION4                  IN     VARCHAR2
   ,P_INFORMATION5                  IN     VARCHAR2
   ,P_INFORMATION6                  IN     VARCHAR2
   ,P_INFORMATION7                  IN     VARCHAR2
   ,P_INFORMATION8                  IN     VARCHAR2
   ,P_INFORMATION9                  IN     VARCHAR2
   ,P_INFORMATION10                 IN     VARCHAR2
   ,P_INFORMATION11                 IN     VARCHAR2
   ,P_INFORMATION12                 IN     VARCHAR2
   ,P_INFORMATION13                 IN     VARCHAR2
   ,P_INFORMATION14                 IN     VARCHAR2
   ,P_INFORMATION15                 IN     VARCHAR2
   ,P_INFORMATION16                 IN     VARCHAR2
   ,P_INFORMATION17                 IN     VARCHAR2
   ,P_INFORMATION18                 IN     VARCHAR2
   ,P_INFORMATION19                 IN     VARCHAR2
   ,P_INFORMATION20                 IN     VARCHAR2
   ,P_LAST_UPDATE_DATE              IN     DATE
   ,P_LAST_UPDATED_BY               IN     NUMBER
   ,P_LAST_UPDATE_LOGIN             IN     NUMBER
   ,P_CREATED_BY                    IN     NUMBER
   ,P_CREATION_DATE                 IN     DATE
   ,P_SEGMENT1                      IN     VARCHAR2
   ,P_SEGMENT2                      IN     VARCHAR2
   ,P_SEGMENT3                      IN     VARCHAR2
   ,P_SEGMENT4                      IN     VARCHAR2
   ,P_SEGMENT5                      IN     VARCHAR2
   ,P_SEGMENT6                      IN     VARCHAR2
   ,P_SEGMENT7                      IN     VARCHAR2
   ,P_SEGMENT8                      IN     VARCHAR2
   ,P_SEGMENT9                      IN     VARCHAR2
   ,P_SEGMENT10                     IN     VARCHAR2
   ,P_SEGMENT11                     IN     VARCHAR2
   ,P_SEGMENT12                     IN     VARCHAR2
   ,P_SEGMENT13                     IN     VARCHAR2
   ,P_SEGMENT14                     IN     VARCHAR2
   ,P_SEGMENT15                     IN     VARCHAR2
   ,P_SEGMENT16                     IN     VARCHAR2
   ,P_SEGMENT17                     IN     VARCHAR2
   ,P_SEGMENT18                     IN     VARCHAR2
   ,P_SEGMENT19                     IN     VARCHAR2
   ,P_SEGMENT20                     IN     VARCHAR2
   ,P_SEGMENT21                     IN     VARCHAR2
   ,P_SEGMENT22                     IN     VARCHAR2
   ,P_SEGMENT23                     IN     VARCHAR2
   ,P_SEGMENT24                     IN     VARCHAR2
   ,P_SEGMENT25                     IN     VARCHAR2
   ,P_SEGMENT26                     IN     VARCHAR2
   ,P_SEGMENT27                     IN     VARCHAR2
   ,P_SEGMENT28                     IN     VARCHAR2
   ,P_SEGMENT29                     IN     VARCHAR2
   ,P_SEGMENT30                     IN     VARCHAR2
   ,P_CONCAT_SEGMENTS               IN     VARCHAR2
   ,P_LANGUAGE_CODE                 IN     VARCHAR2
   ,P_NAME                          IN     VARCHAR2
   ,P_OBJECT_VERSION_NUMBER	    IN     NUMBER
   ,P_GRADE_DEFINITION_ID           IN     NUMBER
   ,P_SHORT_NAME	            IN     VARCHAR2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_grade_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_grade_a
  (P_GRADE_ID             	   IN      NUMBER
   ,P_SEQUENCE                      IN     NUMBER
   ,P_DATE_FROM                     IN     DATE
   ,P_DATE_TO                       IN     DATE
   ,p_effective_date		    in     date
   ,P_REQUEST_ID                    IN     NUMBER
   ,P_PROGRAM_APPLICATION_ID        IN     NUMBER
   ,P_PROGRAM_ID                    IN     NUMBER
   ,P_PROGRAM_UPDATE_DATE           IN     DATE
   ,P_ATTRIBUTE_CATEGORY            IN     VARCHAR2
   ,P_ATTRIBUTE1                    IN     VARCHAR2
   ,P_ATTRIBUTE2                    IN     VARCHAR2
   ,P_ATTRIBUTE3                    IN     VARCHAR2
   ,P_ATTRIBUTE4                    IN     VARCHAR2
   ,P_ATTRIBUTE5                    IN     VARCHAR2
   ,P_ATTRIBUTE6                    IN     VARCHAR2
   ,P_ATTRIBUTE7                    IN     VARCHAR2
   ,P_ATTRIBUTE8                    IN     VARCHAR2
   ,P_ATTRIBUTE9                    IN     VARCHAR2
   ,P_ATTRIBUTE10                   IN     VARCHAR2
   ,P_ATTRIBUTE11                   IN     VARCHAR2
   ,P_ATTRIBUTE12                   IN     VARCHAR2
   ,P_ATTRIBUTE13                   IN     VARCHAR2
   ,P_ATTRIBUTE14                   IN     VARCHAR2
   ,P_ATTRIBUTE15                   IN     VARCHAR2
   ,P_ATTRIBUTE16                   IN     VARCHAR2
   ,P_ATTRIBUTE17                   IN     VARCHAR2
   ,P_ATTRIBUTE18                   IN     VARCHAR2
   ,P_ATTRIBUTE19                   IN     VARCHAR2
   ,P_ATTRIBUTE20                   IN     VARCHAR2
   ,P_INFORMATION_CATEGORY          IN     VARCHAR2
   ,P_INFORMATION1                  IN     VARCHAR2
   ,P_INFORMATION2                  IN     VARCHAR2
   ,P_INFORMATION3                  IN     VARCHAR2
   ,P_INFORMATION4                  IN     VARCHAR2
   ,P_INFORMATION5                  IN     VARCHAR2
   ,P_INFORMATION6                  IN     VARCHAR2
   ,P_INFORMATION7                  IN     VARCHAR2
   ,P_INFORMATION8                  IN     VARCHAR2
   ,P_INFORMATION9                  IN     VARCHAR2
   ,P_INFORMATION10                 IN     VARCHAR2
   ,P_INFORMATION11                 IN     VARCHAR2
   ,P_INFORMATION12                 IN     VARCHAR2
   ,P_INFORMATION13                 IN     VARCHAR2
   ,P_INFORMATION14                 IN     VARCHAR2
   ,P_INFORMATION15                 IN     VARCHAR2
   ,P_INFORMATION16                 IN     VARCHAR2
   ,P_INFORMATION17                 IN     VARCHAR2
   ,P_INFORMATION18                 IN     VARCHAR2
   ,P_INFORMATION19                 IN     VARCHAR2
   ,P_INFORMATION20                 IN     VARCHAR2
   ,P_LAST_UPDATE_DATE              IN     DATE
   ,P_LAST_UPDATED_BY               IN     NUMBER
   ,P_LAST_UPDATE_LOGIN             IN     NUMBER
   ,P_CREATED_BY                    IN     NUMBER
   ,P_CREATION_DATE                 IN     DATE
   ,P_SEGMENT1                      IN     VARCHAR2
   ,P_SEGMENT2                      IN     VARCHAR2
   ,P_SEGMENT3                      IN     VARCHAR2
   ,P_SEGMENT4                      IN     VARCHAR2
   ,P_SEGMENT5                      IN     VARCHAR2
   ,P_SEGMENT6                      IN     VARCHAR2
   ,P_SEGMENT7                      IN     VARCHAR2
   ,P_SEGMENT8                      IN     VARCHAR2
   ,P_SEGMENT9                      IN     VARCHAR2
   ,P_SEGMENT10                     IN     VARCHAR2
   ,P_SEGMENT11                     IN     VARCHAR2
   ,P_SEGMENT12                     IN     VARCHAR2
   ,P_SEGMENT13                     IN     VARCHAR2
   ,P_SEGMENT14                     IN     VARCHAR2
   ,P_SEGMENT15                     IN     VARCHAR2
   ,P_SEGMENT16                     IN     VARCHAR2
   ,P_SEGMENT17                     IN     VARCHAR2
   ,P_SEGMENT18                     IN     VARCHAR2
   ,P_SEGMENT19                     IN     VARCHAR2
   ,P_SEGMENT20                     IN     VARCHAR2
   ,P_SEGMENT21                     IN     VARCHAR2
   ,P_SEGMENT22                     IN     VARCHAR2
   ,P_SEGMENT23                     IN     VARCHAR2
   ,P_SEGMENT24                     IN     VARCHAR2
   ,P_SEGMENT25                     IN     VARCHAR2
   ,P_SEGMENT26                     IN     VARCHAR2
   ,P_SEGMENT27                     IN     VARCHAR2
   ,P_SEGMENT28                     IN     VARCHAR2
   ,P_SEGMENT29                     IN     VARCHAR2
   ,P_SEGMENT30                     IN     VARCHAR2
   ,P_LANGUAGE_CODE                 IN     VARCHAR2
   ,P_CONCAT_SEGMENTS               IN     VARCHAR2
   ,P_NAME                          IN     VARCHAR2
   ,P_OBJECT_VERSION_NUMBER	    IN     NUMBER
   ,P_GRADE_DEFINITION_ID           IN     NUMBER
   ,P_SHORT_NAME	            IN     VARCHAR2
  );
--
end hr_grade_bk2;

/
