--------------------------------------------------------
--  DDL for Package PER_BUDGET_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BUDGET_VALUES_PKG" AUTHID CURRENT_USER as
/* $Header: pebgv01t.pkh 115.3 2004/02/16 10:52:57 nsanghal ship $ */

PROCEDURE Insert_Row(X_Rowid                         IN   OUT NOCOPY VARCHAR2,
                     X_Budget_Value_Id               IN   OUT NOCOPY NUMBER,
                     X_Business_Group_Id             IN     NUMBER,
                     X_Budget_Element_Id             IN     NUMBER,
                     X_Time_Period_Id                IN     NUMBER,
                     X_Value                         IN     NUMBER,
		     X_attribute_category            IN     VARCHAR2,
		     X_attribute1                    IN     VARCHAR2,
                     X_attribute2                    IN     VARCHAR2,
                     X_attribute3                    IN     VARCHAR2,
                     X_attribute4                    IN     VARCHAR2,
                     X_attribute5                    IN     VARCHAR2,
                     X_attribute6                    IN     VARCHAR2,
                     X_attribute7                    IN     VARCHAR2,
                     X_attribute8                    IN     VARCHAR2,
                     X_attribute9                    IN     VARCHAR2,
                     X_attribute10                   IN     VARCHAR2,
                     X_attribute11                   IN     VARCHAR2,
                     X_attribute12                   IN     VARCHAR2,
                     X_attribute13                   IN     VARCHAR2,
                     X_attribute14                   IN     VARCHAR2,
                     X_attribute15                   IN     VARCHAR2,
                     X_attribute16                   IN     VARCHAR2,
                     X_attribute17                   IN     VARCHAR2,
                     X_attribute18                   IN     VARCHAR2,
                     X_attribute19                   IN     VARCHAR2,
                     X_attribute20                   IN     VARCHAR2,
                     X_attribute21                   IN     VARCHAR2,
                     X_attribute22                   IN     VARCHAR2,
                     X_attribute23                   IN     VARCHAR2,
                     X_attribute24                   IN     VARCHAR2,
                     X_attribute25                   IN     VARCHAR2,
                     X_attribute26                   IN     VARCHAR2,
                     X_attribute27                   IN     VARCHAR2,
                     X_attribute28                   IN     VARCHAR2,
                     X_attribute29                   IN     VARCHAR2,
                     X_attribute30                   IN     VARCHAR2,
                     X_information_category          IN     VARCHAR2,
		     X_information1                  IN     VARCHAR2,
                     X_information2                  IN     VARCHAR2,
                     X_information3                  IN     VARCHAR2,
                     X_information4                  IN     VARCHAR2,
                     X_information5                  IN     VARCHAR2,
                     X_information6                  IN     VARCHAR2,
                     X_information7                  IN     VARCHAR2,
                     X_information8                  IN     VARCHAR2,
                     X_information9                  IN     VARCHAR2,
                     X_information10                 IN     VARCHAR2,
                     X_information11                 IN     VARCHAR2,
                     X_information12                 IN     VARCHAR2,
                     X_information13                 IN     VARCHAR2,
                     X_information14                 IN     VARCHAR2,
                     X_information15                 IN     VARCHAR2,
                     X_information16                 IN     VARCHAR2,
                     X_information17                 IN     VARCHAR2,
                     X_information18                 IN     VARCHAR2,
                     X_information19                 IN     VARCHAR2,
                     X_information20                 IN     VARCHAR2,
                     X_information21                 IN     vARCHAR2,
                     X_information22                 IN     VARCHAR2,
                     X_information23                 IN     VARCHAR2,
                     X_information24                 IN     VARCHAR2,
                     X_information25                 IN     VARCHAR2,
                     X_information26                 IN     VARCHAR2,
                     X_information27                 IN     VARCHAR2,
                     X_information28                 IN     VARCHAR2,
                     X_information29                 IN     VARCHAR2,
                     X_information30                 IN     VARCHAR2);

PROCEDURE   Lock_Row(X_Rowid                         IN     VARCHAR2,
                     X_Budget_Value_Id               IN       NUMBER,
                     X_Business_Group_Id             IN       NUMBER,
                     X_Budget_Element_Id             IN       NUMBER,
                     X_Time_Period_Id                IN       NUMBER,
                     X_Value                         IN       NUMBER,
		     X_attribute_category            IN     VARCHAR2,
		     X_attribute1                    IN     VARCHAR2,
                     X_attribute2                    IN     VARCHAR2,
                     X_attribute3                    IN     VARCHAR2,
                     X_attribute4                    IN     VARCHAR2,
                     X_attribute5                    IN     VARCHAR2,
                     X_attribute6                    IN     VARCHAR2,
                     X_attribute7                    IN     VARCHAR2,
                     X_attribute8                    IN     VARCHAR2,
                     X_attribute9                    IN     VARCHAR2,
                     X_attribute10                   IN     VARCHAR2,
                     X_attribute11                   IN     VARCHAR2,
                     X_attribute12                   IN     VARCHAR2,
                     X_attribute13                   IN     VARCHAR2,
                     X_attribute14                   IN     VARCHAR2,
                     X_attribute15                   IN     VARCHAR2,
                     X_attribute16                   IN     VARCHAR2,
                     X_attribute17                   IN     VARCHAR2,
                     X_attribute18                   IN     VARCHAR2,
                     X_attribute19                   IN     VARCHAR2,
                     X_attribute20                   IN     VARCHAR2,
                     X_attribute21                   IN     VARCHAR2,
                     X_attribute22                   IN     VARCHAR2,
                     X_attribute23                   IN     VARCHAR2,
                     X_attribute24                   IN     VARCHAR2,
                     X_attribute25                   IN     VARCHAR2,
                     X_attribute26                   IN     VARCHAR2,
                     X_attribute27                   IN     VARCHAR2,
                     X_attribute28                   IN     VARCHAR2,
                     X_attribute29                   IN     VARCHAR2,
                     X_attribute30                   IN     VARCHAR2,
                     X_information_category          IN     VARCHAR2,
		     X_information1                  IN     VARCHAR2,
                     X_information2                  IN     VARCHAR2,
                     X_information3                  IN     VARCHAR2,
                     X_information4                  IN     VARCHAR2,
                     X_information5                  IN     VARCHAR2,
                     X_information6                  IN     VARCHAR2,
                     X_information7                  IN     VARCHAR2,
                     X_information8                  IN     VARCHAR2,
                     X_information9                  IN     VARCHAR2,
                     X_information10                 IN     VARCHAR2,
                     X_information11                 IN     VARCHAR2,
                     X_information12                 IN     VARCHAR2,
                     X_information13                 IN     VARCHAR2,
                     X_information14                 IN     VARCHAR2,
                     X_information15                 IN     VARCHAR2,
                     X_information16                 IN     VARCHAR2,
                     X_information17                 IN     VARCHAR2,
                     X_information18                 IN     VARCHAR2,
                     X_information19                 IN     VARCHAR2,
                     X_information20                 IN     VARCHAR2,
                     X_information21                 IN     vARCHAR2,
                     X_information22                 IN     VARCHAR2,
                     X_information23                 IN     VARCHAR2,
                     X_information24                 IN     VARCHAR2,
                     X_information25                 IN     VARCHAR2,
                     X_information26                 IN     VARCHAR2,
                     X_information27                 IN     VARCHAR2,
                     X_information28                 IN     VARCHAR2,
                     X_information29                 IN     VARCHAR2,
                     X_information30                 IN     VARCHAR2);

PROCEDURE Update_Row(X_Rowid                         IN     VARCHAR2,
                     X_Budget_Value_Id               IN     NUMBER,
                     X_Business_Group_Id             IN     NUMBER,
                     X_Budget_Element_Id             IN     NUMBER,
                     X_Time_Period_Id                IN     NUMBER,
                     X_Value                         IN     NUMBER,
		     X_attribute_category            IN     VARCHAR2,
		     X_attribute1                    IN     VARCHAR2,
                     X_attribute2                    IN     VARCHAR2,
                     X_attribute3                    IN     VARCHAR2,
                     X_attribute4                    IN     VARCHAR2,
                     X_attribute5                    IN     VARCHAR2,
                     X_attribute6                    IN     VARCHAR2,
                     X_attribute7                    IN     VARCHAR2,
                     X_attribute8                    IN     VARCHAR2,
                     X_attribute9                    IN     VARCHAR2,
                     X_attribute10                   IN     VARCHAR2,
                     X_attribute11                   IN     VARCHAR2,
                     X_attribute12                   IN     VARCHAR2,
                     X_attribute13                   IN     VARCHAR2,
                     X_attribute14                   IN     VARCHAR2,
                     X_attribute15                   IN     VARCHAR2,
                     X_attribute16                   IN     VARCHAR2,
                     X_attribute17                   IN     VARCHAR2,
                     X_attribute18                   IN     VARCHAR2,
                     X_attribute19                   IN     VARCHAR2,
                     X_attribute20                   IN     VARCHAR2,
                     X_attribute21                   IN     VARCHAR2,
                     X_attribute22                   IN     VARCHAR2,
                     X_attribute23                   IN     VARCHAR2,
                     X_attribute24                   IN     VARCHAR2,
                     X_attribute25                   IN     VARCHAR2,
                     X_attribute26                   IN     VARCHAR2,
                     X_attribute27                   IN     VARCHAR2,
                     X_attribute28                   IN     VARCHAR2,
                     X_attribute29                   IN     VARCHAR2,
                     X_attribute30                   IN     VARCHAR2,
                     X_information_category          IN     VARCHAR2,
		     X_information1                  IN     VARCHAR2,
                     X_information2                  IN     VARCHAR2,
                     X_information3                  IN     VARCHAR2,
                     X_information4                  IN     VARCHAR2,
                     X_information5                  IN     VARCHAR2,
                     X_information6                  IN     VARCHAR2,
                     X_information7                  IN     VARCHAR2,
                     X_information8                  IN     VARCHAR2,
                     X_information9                  IN     VARCHAR2,
                     X_information10                 IN     VARCHAR2,
                     X_information11                 IN     VARCHAR2,
                     X_information12                 IN     VARCHAR2,
                     X_information13                 IN     VARCHAR2,
                     X_information14                 IN     VARCHAR2,
                     X_information15                 IN     VARCHAR2,
                     X_information16                 IN     VARCHAR2,
                     X_information17                 IN     VARCHAR2,
                     X_information18                 IN     VARCHAR2,
                     X_information19                 IN     VARCHAR2,
                     X_information20                 IN     VARCHAR2,
                     X_information21                 IN     vARCHAR2,
                     X_information22                 IN     VARCHAR2,
                     X_information23                 IN     VARCHAR2,
                     X_information24                 IN     VARCHAR2,
                     X_information25                 IN     VARCHAR2,
                     X_information26                 IN     VARCHAR2,
                     X_information27                 IN     VARCHAR2,
                     X_information28                 IN     VARCHAR2,
                     X_information29                 IN     VARCHAR2,
                     X_information30                 IN     VARCHAR2);

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END PER_BUDGET_VALUES_PKG;

 

/