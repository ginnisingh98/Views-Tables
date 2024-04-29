--------------------------------------------------------
--  DDL for Package HR_FORM_PROPERTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FORM_PROPERTIES_PKG" AUTHID CURRENT_USER as
/* $Header: hrfmplct.pkh 115.2 2002/12/10 11:14:33 hjonnala noship $ */
procedure OWNER_TO_WHO (
  X_OWNER in VARCHAR2,
  X_CREATION_DATE out nocopy DATE,
  X_CREATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_DATE out nocopy DATE,
  X_LAST_UPDATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_LOGIN out nocopy NUMBER
);
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_FORM_PROPERTY_ID in NUMBER,
  X_INFORMATION29 in VARCHAR2,
  X_INFORMATION16 in VARCHAR2,
  X_INFORMATION17 in VARCHAR2,
  X_INFORMATION18 in VARCHAR2,
  X_INFORMATION19 in VARCHAR2,
  X_INFORMATION20 in VARCHAR2,
  X_INFORMATION21 in VARCHAR2,
  X_INFORMATION22 in VARCHAR2,
  X_INFORMATION23 in VARCHAR2,
  X_INFORMATION24 in VARCHAR2,
  X_INFORMATION25 in VARCHAR2,
  X_INFORMATION26 in VARCHAR2,
  X_INFORMATION27 in VARCHAR2,
  X_INFORMATION28 in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in NUMBER,
  X_FORM_TEMPLATE_ID in NUMBER,
  X_HELP_TARGET in VARCHAR2,
  X_INFORMATION_CATEGORY in VARCHAR2,
  X_INFORMATION1 in VARCHAR2,
  X_INFORMATION2 in VARCHAR2,
  X_INFORMATION3 in VARCHAR2,
  X_INFORMATION4 in VARCHAR2,
  X_INFORMATION5 in VARCHAR2,
  X_INFORMATION6 in VARCHAR2,
  X_INFORMATION7 in VARCHAR2,
  X_INFORMATION8 in VARCHAR2,
  X_INFORMATION9 in VARCHAR2,
  X_INFORMATION10 in VARCHAR2,
  X_INFORMATION11 in VARCHAR2,
  X_INFORMATION12 in VARCHAR2,
  X_INFORMATION13 in VARCHAR2,
  X_INFORMATION14 in VARCHAR2,
  X_INFORMATION15 in VARCHAR2,
  X_INFORMATION30 in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_FORM_PROPERTY_ID in NUMBER,
  X_INFORMATION29 in VARCHAR2,
  X_INFORMATION16 in VARCHAR2,
  X_INFORMATION17 in VARCHAR2,
  X_INFORMATION18 in VARCHAR2,
  X_INFORMATION19 in VARCHAR2,
  X_INFORMATION20 in VARCHAR2,
  X_INFORMATION21 in VARCHAR2,
  X_INFORMATION22 in VARCHAR2,
  X_INFORMATION23 in VARCHAR2,
  X_INFORMATION24 in VARCHAR2,
  X_INFORMATION25 in VARCHAR2,
  X_INFORMATION26 in VARCHAR2,
  X_INFORMATION27 in VARCHAR2,
  X_INFORMATION28 in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in NUMBER,
  X_FORM_TEMPLATE_ID in NUMBER,
  X_HELP_TARGET in VARCHAR2,
  X_INFORMATION_CATEGORY in VARCHAR2,
  X_INFORMATION1 in VARCHAR2,
  X_INFORMATION2 in VARCHAR2,
  X_INFORMATION3 in VARCHAR2,
  X_INFORMATION4 in VARCHAR2,
  X_INFORMATION5 in VARCHAR2,
  X_INFORMATION6 in VARCHAR2,
  X_INFORMATION7 in VARCHAR2,
  X_INFORMATION8 in VARCHAR2,
  X_INFORMATION9 in VARCHAR2,
  X_INFORMATION10 in VARCHAR2,
  X_INFORMATION11 in VARCHAR2,
  X_INFORMATION12 in VARCHAR2,
  X_INFORMATION13 in VARCHAR2,
  X_INFORMATION14 in VARCHAR2,
  X_INFORMATION15 in VARCHAR2,
  X_INFORMATION30 in VARCHAR2
);
procedure UPDATE_ROW (
  X_FORM_PROPERTY_ID in NUMBER,
  X_INFORMATION29 in VARCHAR2,
  X_INFORMATION16 in VARCHAR2,
  X_INFORMATION17 in VARCHAR2,
  X_INFORMATION18 in VARCHAR2,
  X_INFORMATION19 in VARCHAR2,
  X_INFORMATION20 in VARCHAR2,
  X_INFORMATION21 in VARCHAR2,
  X_INFORMATION22 in VARCHAR2,
  X_INFORMATION23 in VARCHAR2,
  X_INFORMATION24 in VARCHAR2,
  X_INFORMATION25 in VARCHAR2,
  X_INFORMATION26 in VARCHAR2,
  X_INFORMATION27 in VARCHAR2,
  X_INFORMATION28 in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FORM_ID in NUMBER,
  X_FORM_TEMPLATE_ID in NUMBER,
  X_HELP_TARGET in VARCHAR2,
  X_INFORMATION_CATEGORY in VARCHAR2,
  X_INFORMATION1 in VARCHAR2,
  X_INFORMATION2 in VARCHAR2,
  X_INFORMATION3 in VARCHAR2,
  X_INFORMATION4 in VARCHAR2,
  X_INFORMATION5 in VARCHAR2,
  X_INFORMATION6 in VARCHAR2,
  X_INFORMATION7 in VARCHAR2,
  X_INFORMATION8 in VARCHAR2,
  X_INFORMATION9 in VARCHAR2,
  X_INFORMATION10 in VARCHAR2,
  X_INFORMATION11 in VARCHAR2,
  X_INFORMATION12 in VARCHAR2,
  X_INFORMATION13 in VARCHAR2,
  X_INFORMATION14 in VARCHAR2,
  X_INFORMATION15 in VARCHAR2,
  X_INFORMATION30 in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_FORM_PROPERTY_ID in NUMBER
);
procedure LOAD_ROW (
            X_APPLICATION_SHORT_NAME  IN VARCHAR2,
            X_FORM_NAME            IN VARCHAR2,
            X_TEMPLATE_NAME        IN VARCHAR2,
            X_TERRITORY_SHORT_NAME IN VARCHAR2,
            X_OWNER                IN VARCHAR2,
            X_HELP_TARGET          IN VARCHAR2,
            X_INFORMATION_CATEGORY IN VARCHAR2,
            X_INFORMATION1         IN VARCHAR2,
            X_INFORMATION2         IN VARCHAR2,
            X_INFORMATION3         IN VARCHAR2,
            X_INFORMATION4         IN VARCHAR2,
            X_INFORMATION5         IN VARCHAR2,
            X_INFORMATION6         IN VARCHAR2,
            X_INFORMATION7         IN VARCHAR2,
            X_INFORMATION8         IN VARCHAR2,
            X_INFORMATION9         IN VARCHAR2,
            X_INFORMATION10        IN VARCHAR2,
            X_INFORMATION11        IN VARCHAR2,
            X_INFORMATION12        IN VARCHAR2,
            X_INFORMATION13        IN VARCHAR2,
            X_INFORMATION14        IN VARCHAR2,
            X_INFORMATION15        IN VARCHAR2,
            X_INFORMATION16        IN VARCHAR2,
            X_INFORMATION17        IN VARCHAR2,
            X_INFORMATION18        IN VARCHAR2,
            X_INFORMATION19        IN VARCHAR2,
            X_INFORMATION20        IN VARCHAR2,
            X_INFORMATION21        IN VARCHAR2,
            X_INFORMATION22        IN VARCHAR2,
            X_INFORMATION23        IN VARCHAR2,
            X_INFORMATION24        IN VARCHAR2,
            X_INFORMATION25        IN VARCHAR2,
            X_INFORMATION26        IN VARCHAR2,
            X_INFORMATION27        IN VARCHAR2,
            X_INFORMATION28        IN VARCHAR2,
            X_INFORMATION29        IN VARCHAR2,
            X_INFORMATION30        IN VARCHAR2);
end HR_FORM_PROPERTIES_PKG;

 

/