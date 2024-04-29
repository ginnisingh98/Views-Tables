--------------------------------------------------------
--  DDL for Package Body HR_TAB_PAGE_PROPERTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TAB_PAGE_PROPERTIES_PKG" as
/* $Header: hrtpplct.pkb 120.1 2006/06/27 07:32:02 rvarshne noship $ */
-- -----------------------------------------------------------------------------
-- |-----------------------------< update_copies >-----------------------------|
-- -----------------------------------------------------------------------------
procedure UPDATE_COPIES (
  X_TAB_PAGE_PROPERTY_ID in NUMBER,
  X_FORM_TAB_PAGE_ID in NUMBER,
  X_TEMPLATE_TAB_PAGE_ID in NUMBER,
  X_NAVIGATION_DIRECTION in VARCHAR2,
  X_VISIBLE in NUMBER,
  X_LABEL in VARCHAR2,
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
  X_INFORMATION29 in VARCHAR2,
  X_INFORMATION30 in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor csr_original is
    select *
      from HR_TAB_PAGE_PROPERTIES_VL
     where TAB_PAGE_PROPERTY_ID = X_TAB_PAGE_PROPERTY_ID;
  l_original csr_original%rowtype;
  cursor csr_copies is
    select tpp.tab_page_property_id
      from HR_TAB_PAGE_PROPERTIES_B tpp
          ,HR_TEMPLATE_TAB_PAGES_B ttp
          ,HR_TEMPLATE_CANVASES_B tcn
          ,HR_TEMPLATE_WINDOWS_B twn
          ,HR_TEMPLATE_TAB_PAGES_B tto
     where tpp.TEMPLATE_TAB_PAGE_ID = ttp.TEMPLATE_TAB_PAGE_ID
       and ttp.TEMPLATE_CANVAS_ID = tcn.TEMPLATE_CANVAS_ID
       and tcn.TEMPLATE_WINDOW_ID = twn.TEMPLATE_WINDOW_ID
       and twn.FORM_TEMPLATE_ID in (select sft.FORM_TEMPLATE_ID_TO
                                      from HR_SOURCE_FORM_TEMPLATES sft
                                start with sft.FORM_TEMPLATE_ID_FROM = (select tw1.FORM_TEMPLATE_ID
                                                                          from HR_TEMPLATE_WINDOWS_B tw1
                                                                              ,HR_TEMPLATE_CANVASES_B tc1
                                                                         where tw1.TEMPLATE_WINDOW_ID = tc1.TEMPLATE_WINDOW_ID
                                                                           and tc1.TEMPLATE_CANVAS_ID = tto.TEMPLATE_CANVAS_ID)
                                connect by sft.FORM_TEMPLATE_ID_FROM = prior sft.FORM_TEMPLATE_ID_TO)
       and ttp.FORM_TAB_PAGE_ID = tto.FORM_TAB_PAGE_ID
       and tto.TEMPLATE_TAB_PAGE_ID = X_TEMPLATE_TAB_PAGE_ID;
begin
  if (X_TEMPLATE_TAB_PAGE_ID is not null) then
    open csr_original;
    fetch csr_original into l_original;
    if csr_original%found then
      close csr_original;
      for l_copy in csr_copies loop
        update HR_TAB_PAGE_PROPERTIES_B set
          NAVIGATION_DIRECTION = decode(nvl(NAVIGATION_DIRECTION,hr_api.g_varchar2),nvl(l_original.NAVIGATION_DIRECTION,hr_api.g_varchar2),X_NAVIGATION_DIRECTION,NAVIGATION_DIRECTION),
          VISIBLE = decode(nvl(VISIBLE,hr_api.g_number),nvl(l_original.VISIBLE,hr_api.g_number),X_VISIBLE,VISIBLE),
          INFORMATION_CATEGORY = decode(nvl(INFORMATION_CATEGORY,hr_api.g_varchar2),nvl(l_original.INFORMATION_CATEGORY,hr_api.g_varchar2),X_INFORMATION_CATEGORY,INFORMATION_CATEGORY),
          INFORMATION1  = decode(nvl(INFORMATION1 ,hr_api.g_varchar2),nvl(l_original.INFORMATION1 ,hr_api.g_varchar2),X_INFORMATION1 ,INFORMATION1 ),
          INFORMATION2  = decode(nvl(INFORMATION2 ,hr_api.g_varchar2),nvl(l_original.INFORMATION2 ,hr_api.g_varchar2),X_INFORMATION2 ,INFORMATION2 ),
          INFORMATION3  = decode(nvl(INFORMATION3 ,hr_api.g_varchar2),nvl(l_original.INFORMATION3 ,hr_api.g_varchar2),X_INFORMATION3 ,INFORMATION3 ),
          INFORMATION4  = decode(nvl(INFORMATION4 ,hr_api.g_varchar2),nvl(l_original.INFORMATION4 ,hr_api.g_varchar2),X_INFORMATION4 ,INFORMATION4 ),
          INFORMATION5  = decode(nvl(INFORMATION5 ,hr_api.g_varchar2),nvl(l_original.INFORMATION5 ,hr_api.g_varchar2),X_INFORMATION5 ,INFORMATION5 ),
          INFORMATION6  = decode(nvl(INFORMATION6 ,hr_api.g_varchar2),nvl(l_original.INFORMATION6 ,hr_api.g_varchar2),X_INFORMATION6 ,INFORMATION6 ),
          INFORMATION7  = decode(nvl(INFORMATION7 ,hr_api.g_varchar2),nvl(l_original.INFORMATION7 ,hr_api.g_varchar2),X_INFORMATION7 ,INFORMATION7 ),
          INFORMATION8  = decode(nvl(INFORMATION8 ,hr_api.g_varchar2),nvl(l_original.INFORMATION8 ,hr_api.g_varchar2),X_INFORMATION8 ,INFORMATION8 ),
          INFORMATION9  = decode(nvl(INFORMATION9 ,hr_api.g_varchar2),nvl(l_original.INFORMATION9 ,hr_api.g_varchar2),X_INFORMATION9 ,INFORMATION9 ),
          INFORMATION10 = decode(nvl(INFORMATION10,hr_api.g_varchar2),nvl(l_original.INFORMATION10,hr_api.g_varchar2),X_INFORMATION10,INFORMATION10),
          INFORMATION11 = decode(nvl(INFORMATION11,hr_api.g_varchar2),nvl(l_original.INFORMATION11,hr_api.g_varchar2),X_INFORMATION11,INFORMATION11),
          INFORMATION12 = decode(nvl(INFORMATION12,hr_api.g_varchar2),nvl(l_original.INFORMATION12,hr_api.g_varchar2),X_INFORMATION12,INFORMATION12),
          INFORMATION13 = decode(nvl(INFORMATION13,hr_api.g_varchar2),nvl(l_original.INFORMATION13,hr_api.g_varchar2),X_INFORMATION13,INFORMATION13),
          INFORMATION14 = decode(nvl(INFORMATION14,hr_api.g_varchar2),nvl(l_original.INFORMATION14,hr_api.g_varchar2),X_INFORMATION14,INFORMATION14),
          INFORMATION15 = decode(nvl(INFORMATION15,hr_api.g_varchar2),nvl(l_original.INFORMATION15,hr_api.g_varchar2),X_INFORMATION15,INFORMATION15),
          INFORMATION16 = decode(nvl(INFORMATION16,hr_api.g_varchar2),nvl(l_original.INFORMATION16,hr_api.g_varchar2),X_INFORMATION16,INFORMATION16),
          INFORMATION17 = decode(nvl(INFORMATION17,hr_api.g_varchar2),nvl(l_original.INFORMATION17,hr_api.g_varchar2),X_INFORMATION17,INFORMATION17),
          INFORMATION18 = decode(nvl(INFORMATION18,hr_api.g_varchar2),nvl(l_original.INFORMATION18,hr_api.g_varchar2),X_INFORMATION18,INFORMATION18),
          INFORMATION19 = decode(nvl(INFORMATION19,hr_api.g_varchar2),nvl(l_original.INFORMATION19,hr_api.g_varchar2),X_INFORMATION19,INFORMATION19),
          INFORMATION20 = decode(nvl(INFORMATION20,hr_api.g_varchar2),nvl(l_original.INFORMATION20,hr_api.g_varchar2),X_INFORMATION20,INFORMATION20),
          INFORMATION21 = decode(nvl(INFORMATION21,hr_api.g_varchar2),nvl(l_original.INFORMATION21,hr_api.g_varchar2),X_INFORMATION21,INFORMATION21),
          INFORMATION22 = decode(nvl(INFORMATION22,hr_api.g_varchar2),nvl(l_original.INFORMATION22,hr_api.g_varchar2),X_INFORMATION22,INFORMATION22),
          INFORMATION23 = decode(nvl(INFORMATION23,hr_api.g_varchar2),nvl(l_original.INFORMATION23,hr_api.g_varchar2),X_INFORMATION23,INFORMATION23),
          INFORMATION24 = decode(nvl(INFORMATION24,hr_api.g_varchar2),nvl(l_original.INFORMATION24,hr_api.g_varchar2),X_INFORMATION24,INFORMATION24),
          INFORMATION25 = decode(nvl(INFORMATION25,hr_api.g_varchar2),nvl(l_original.INFORMATION25,hr_api.g_varchar2),X_INFORMATION25,INFORMATION25),
          INFORMATION26 = decode(nvl(INFORMATION26,hr_api.g_varchar2),nvl(l_original.INFORMATION26,hr_api.g_varchar2),X_INFORMATION26,INFORMATION26),
          INFORMATION27 = decode(nvl(INFORMATION27,hr_api.g_varchar2),nvl(l_original.INFORMATION27,hr_api.g_varchar2),X_INFORMATION27,INFORMATION27),
          INFORMATION28 = decode(nvl(INFORMATION28,hr_api.g_varchar2),nvl(l_original.INFORMATION28,hr_api.g_varchar2),X_INFORMATION28,INFORMATION28),
          INFORMATION29 = decode(nvl(INFORMATION29,hr_api.g_varchar2),nvl(l_original.INFORMATION29,hr_api.g_varchar2),X_INFORMATION29,INFORMATION29),
          INFORMATION30 = decode(nvl(INFORMATION30,hr_api.g_varchar2),nvl(l_original.INFORMATION30,hr_api.g_varchar2),X_INFORMATION30,INFORMATION30),
          LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
          LAST_UPDATED_BY = X_LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
        where TAB_PAGE_PROPERTY_ID = l_copy.TAB_PAGE_PROPERTY_ID;
        if (sql%notfound) then
          raise no_data_found;
        end if;
        update HR_TAB_PAGE_PROPERTIES_TL set
          LABEL = decode(nvl(LABEL,hr_api.g_varchar2),nvl(l_original.LABEL,hr_api.g_varchar2),X_LABEL,LABEL),
          LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
          LAST_UPDATED_BY = X_LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
          SOURCE_LANG = userenv('LANG')
        where TAB_PAGE_PROPERTY_ID = l_copy.TAB_PAGE_PROPERTY_ID
          and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
        if (sql%notfound) then
          raise no_data_found;
        end if;
      end loop;
    else
      close csr_original;
    end if;
  end if;
end UPDATE_COPIES;
--
procedure OWNER_TO_WHO (
  X_OWNER in VARCHAR2,
  X_CREATION_DATE out nocopy DATE,
  X_CREATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_DATE out nocopy DATE,
  X_LAST_UPDATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_LOGIN out nocopy NUMBER
) is
begin
  if X_OWNER = 'SEED' then
    X_CREATED_BY := 1;
    X_LAST_UPDATED_BY := 1;
  else
    X_CREATED_BY := 0;
    X_LAST_UPDATED_BY := 0;
  end if;
  X_CREATION_DATE := sysdate;
  X_LAST_UPDATE_DATE := sysdate;
  X_LAST_UPDATE_LOGIN := 0;
end OWNER_TO_WHO;
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TAB_PAGE_PROPERTY_ID in NUMBER,
  X_FORM_TAB_PAGE_ID in NUMBER,
  X_TEMPLATE_TAB_PAGE_ID in NUMBER,
  X_NAVIGATION_DIRECTION in VARCHAR2,
  X_VISIBLE in NUMBER,
  X_INFORMATION_CATEGORY in VARCHAR2,
  X_INFORMATION9 in VARCHAR2,
  X_INFORMATION10 in VARCHAR2,
  X_INFORMATION11 in VARCHAR2,
  X_INFORMATION12 in VARCHAR2,
  X_INFORMATION13 in VARCHAR2,
  X_INFORMATION14 in VARCHAR2,
  X_INFORMATION15 in VARCHAR2,
  X_INFORMATION16 in VARCHAR2,
  X_INFORMATION17 in VARCHAR2,
  X_INFORMATION18 in VARCHAR2,
  X_INFORMATION19 in VARCHAR2,
  X_INFORMATION20 in VARCHAR2,
  X_INFORMATION21 in VARCHAR2,
  X_INFORMATION7 in VARCHAR2,
  X_INFORMATION8 in VARCHAR2,
  X_INFORMATION29 in VARCHAR2,
  X_INFORMATION30 in VARCHAR2,
  X_INFORMATION6 in VARCHAR2,
  X_INFORMATION1 in VARCHAR2,
  X_INFORMATION2 in VARCHAR2,
  X_INFORMATION3 in VARCHAR2,
  X_INFORMATION4 in VARCHAR2,
  X_INFORMATION5 in VARCHAR2,
  X_INFORMATION22 in VARCHAR2,
  X_INFORMATION23 in VARCHAR2,
  X_INFORMATION24 in VARCHAR2,
  X_INFORMATION25 in VARCHAR2,
  X_INFORMATION26 in VARCHAR2,
  X_INFORMATION27 in VARCHAR2,
  X_INFORMATION28 in VARCHAR2,
  X_LABEL in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from HR_TAB_PAGE_PROPERTIES_B
    where TAB_PAGE_PROPERTY_ID = X_TAB_PAGE_PROPERTY_ID
    ;
begin
  insert into HR_TAB_PAGE_PROPERTIES_B (
    TAB_PAGE_PROPERTY_ID,
    FORM_TAB_PAGE_ID,
    TEMPLATE_TAB_PAGE_ID,
    NAVIGATION_DIRECTION,
    VISIBLE,
    INFORMATION_CATEGORY,
    INFORMATION9,
    INFORMATION10,
    INFORMATION11,
    INFORMATION12,
    INFORMATION13,
    INFORMATION14,
    INFORMATION15,
    INFORMATION16,
    INFORMATION17,
    INFORMATION18,
    INFORMATION19,
    INFORMATION20,
    INFORMATION21,
    INFORMATION7,
    INFORMATION8,
    INFORMATION29,
    INFORMATION30,
    INFORMATION6,
    INFORMATION1,
    INFORMATION2,
    INFORMATION3,
    INFORMATION4,
    INFORMATION5,
    INFORMATION22,
    INFORMATION23,
    INFORMATION24,
    INFORMATION25,
    INFORMATION26,
    INFORMATION27,
    INFORMATION28,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_TAB_PAGE_PROPERTY_ID,
    X_FORM_TAB_PAGE_ID,
    X_TEMPLATE_TAB_PAGE_ID,
    X_NAVIGATION_DIRECTION,
    X_VISIBLE,
    X_INFORMATION_CATEGORY,
    X_INFORMATION9,
    X_INFORMATION10,
    X_INFORMATION11,
    X_INFORMATION12,
    X_INFORMATION13,
    X_INFORMATION14,
    X_INFORMATION15,
    X_INFORMATION16,
    X_INFORMATION17,
    X_INFORMATION18,
    X_INFORMATION19,
    X_INFORMATION20,
    X_INFORMATION21,
    X_INFORMATION7,
    X_INFORMATION8,
    X_INFORMATION29,
    X_INFORMATION30,
    X_INFORMATION6,
    X_INFORMATION1,
    X_INFORMATION2,
    X_INFORMATION3,
    X_INFORMATION4,
    X_INFORMATION5,
    X_INFORMATION22,
    X_INFORMATION23,
    X_INFORMATION24,
    X_INFORMATION25,
    X_INFORMATION26,
    X_INFORMATION27,
    X_INFORMATION28,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into HR_TAB_PAGE_PROPERTIES_TL (
    TAB_PAGE_PROPERTY_ID,
    LABEL,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TAB_PAGE_PROPERTY_ID,
    X_LABEL,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_CREATION_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from HR_TAB_PAGE_PROPERTIES_TL T
    where T.TAB_PAGE_PROPERTY_ID = X_TAB_PAGE_PROPERTY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_TAB_PAGE_PROPERTY_ID in NUMBER,
  X_FORM_TAB_PAGE_ID in NUMBER,
  X_TEMPLATE_TAB_PAGE_ID in NUMBER,
  X_NAVIGATION_DIRECTION in VARCHAR2,
  X_VISIBLE in NUMBER,
  X_INFORMATION_CATEGORY in VARCHAR2,
  X_INFORMATION9 in VARCHAR2,
  X_INFORMATION10 in VARCHAR2,
  X_INFORMATION11 in VARCHAR2,
  X_INFORMATION12 in VARCHAR2,
  X_INFORMATION13 in VARCHAR2,
  X_INFORMATION14 in VARCHAR2,
  X_INFORMATION15 in VARCHAR2,
  X_INFORMATION16 in VARCHAR2,
  X_INFORMATION17 in VARCHAR2,
  X_INFORMATION18 in VARCHAR2,
  X_INFORMATION19 in VARCHAR2,
  X_INFORMATION20 in VARCHAR2,
  X_INFORMATION21 in VARCHAR2,
  X_INFORMATION7 in VARCHAR2,
  X_INFORMATION8 in VARCHAR2,
  X_INFORMATION29 in VARCHAR2,
  X_INFORMATION30 in VARCHAR2,
  X_INFORMATION6 in VARCHAR2,
  X_INFORMATION1 in VARCHAR2,
  X_INFORMATION2 in VARCHAR2,
  X_INFORMATION3 in VARCHAR2,
  X_INFORMATION4 in VARCHAR2,
  X_INFORMATION5 in VARCHAR2,
  X_INFORMATION22 in VARCHAR2,
  X_INFORMATION23 in VARCHAR2,
  X_INFORMATION24 in VARCHAR2,
  X_INFORMATION25 in VARCHAR2,
  X_INFORMATION26 in VARCHAR2,
  X_INFORMATION27 in VARCHAR2,
  X_INFORMATION28 in VARCHAR2,
  X_LABEL in VARCHAR2
) is
  cursor c is select
      FORM_TAB_PAGE_ID,
      TEMPLATE_TAB_PAGE_ID,
      NAVIGATION_DIRECTION,
      VISIBLE,
      INFORMATION_CATEGORY,
      INFORMATION9,
      INFORMATION10,
      INFORMATION11,
      INFORMATION12,
      INFORMATION13,
      INFORMATION14,
      INFORMATION15,
      INFORMATION16,
      INFORMATION17,
      INFORMATION18,
      INFORMATION19,
      INFORMATION20,
      INFORMATION21,
      INFORMATION7,
      INFORMATION8,
      INFORMATION29,
      INFORMATION30,
      INFORMATION6,
      INFORMATION1,
      INFORMATION2,
      INFORMATION3,
      INFORMATION4,
      INFORMATION5,
      INFORMATION22,
      INFORMATION23,
      INFORMATION24,
      INFORMATION25,
      INFORMATION26,
      INFORMATION27,
      INFORMATION28
    from HR_TAB_PAGE_PROPERTIES_B
    where TAB_PAGE_PROPERTY_ID = X_TAB_PAGE_PROPERTY_ID
    for update of TAB_PAGE_PROPERTY_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      LABEL,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from HR_TAB_PAGE_PROPERTIES_TL
    where TAB_PAGE_PROPERTY_ID = X_TAB_PAGE_PROPERTY_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TAB_PAGE_PROPERTY_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.FORM_TAB_PAGE_ID = X_FORM_TAB_PAGE_ID)
           OR ((recinfo.FORM_TAB_PAGE_ID is null) AND (X_FORM_TAB_PAGE_ID is null)))
      AND ((recinfo.TEMPLATE_TAB_PAGE_ID = X_TEMPLATE_TAB_PAGE_ID)
           OR ((recinfo.TEMPLATE_TAB_PAGE_ID is null) AND (X_TEMPLATE_TAB_PAGE_ID is null)))
      AND ((recinfo.NAVIGATION_DIRECTION = X_NAVIGATION_DIRECTION)
           OR ((recinfo.NAVIGATION_DIRECTION is null) AND (X_NAVIGATION_DIRECTION is null)))
      AND ((recinfo.VISIBLE = X_VISIBLE)
           OR ((recinfo.VISIBLE is null) AND (X_VISIBLE is null)))
      AND ((recinfo.INFORMATION_CATEGORY = X_INFORMATION_CATEGORY)
           OR ((recinfo.INFORMATION_CATEGORY is null) AND (X_INFORMATION_CATEGORY is null)))
      AND ((recinfo.INFORMATION9 = X_INFORMATION9)
           OR ((recinfo.INFORMATION9 is null) AND (X_INFORMATION9 is null)))
      AND ((recinfo.INFORMATION10 = X_INFORMATION10)
           OR ((recinfo.INFORMATION10 is null) AND (X_INFORMATION10 is null)))
      AND ((recinfo.INFORMATION11 = X_INFORMATION11)
           OR ((recinfo.INFORMATION11 is null) AND (X_INFORMATION11 is null)))
      AND ((recinfo.INFORMATION12 = X_INFORMATION12)
           OR ((recinfo.INFORMATION12 is null) AND (X_INFORMATION12 is null)))
      AND ((recinfo.INFORMATION13 = X_INFORMATION13)
           OR ((recinfo.INFORMATION13 is null) AND (X_INFORMATION13 is null)))
      AND ((recinfo.INFORMATION14 = X_INFORMATION14)
           OR ((recinfo.INFORMATION14 is null) AND (X_INFORMATION14 is null)))
      AND ((recinfo.INFORMATION15 = X_INFORMATION15)
           OR ((recinfo.INFORMATION15 is null) AND (X_INFORMATION15 is null)))
      AND ((recinfo.INFORMATION16 = X_INFORMATION16)
           OR ((recinfo.INFORMATION16 is null) AND (X_INFORMATION16 is null)))
      AND ((recinfo.INFORMATION17 = X_INFORMATION17)
           OR ((recinfo.INFORMATION17 is null) AND (X_INFORMATION17 is null)))
      AND ((recinfo.INFORMATION18 = X_INFORMATION18)
           OR ((recinfo.INFORMATION18 is null) AND (X_INFORMATION18 is null)))
      AND ((recinfo.INFORMATION19 = X_INFORMATION19)
           OR ((recinfo.INFORMATION19 is null) AND (X_INFORMATION19 is null)))
      AND ((recinfo.INFORMATION20 = X_INFORMATION20)
           OR ((recinfo.INFORMATION20 is null) AND (X_INFORMATION20 is null)))
      AND ((recinfo.INFORMATION21 = X_INFORMATION21)
           OR ((recinfo.INFORMATION21 is null) AND (X_INFORMATION21 is null)))
      AND ((recinfo.INFORMATION7 = X_INFORMATION7)
           OR ((recinfo.INFORMATION7 is null) AND (X_INFORMATION7 is null)))
      AND ((recinfo.INFORMATION8 = X_INFORMATION8)
           OR ((recinfo.INFORMATION8 is null) AND (X_INFORMATION8 is null)))
      AND ((recinfo.INFORMATION29 = X_INFORMATION29)
           OR ((recinfo.INFORMATION29 is null) AND (X_INFORMATION29 is null)))
      AND ((recinfo.INFORMATION30 = X_INFORMATION30)
           OR ((recinfo.INFORMATION30 is null) AND (X_INFORMATION30 is null)))
      AND ((recinfo.INFORMATION6 = X_INFORMATION6)
           OR ((recinfo.INFORMATION6 is null) AND (X_INFORMATION6 is null)))
      AND ((recinfo.INFORMATION1 = X_INFORMATION1)
           OR ((recinfo.INFORMATION1 is null) AND (X_INFORMATION1 is null)))
      AND ((recinfo.INFORMATION2 = X_INFORMATION2)
           OR ((recinfo.INFORMATION2 is null) AND (X_INFORMATION2 is null)))
      AND ((recinfo.INFORMATION3 = X_INFORMATION3)
           OR ((recinfo.INFORMATION3 is null) AND (X_INFORMATION3 is null)))
      AND ((recinfo.INFORMATION4 = X_INFORMATION4)
           OR ((recinfo.INFORMATION4 is null) AND (X_INFORMATION4 is null)))
      AND ((recinfo.INFORMATION5 = X_INFORMATION5)
           OR ((recinfo.INFORMATION5 is null) AND (X_INFORMATION5 is null)))
      AND ((recinfo.INFORMATION22 = X_INFORMATION22)
           OR ((recinfo.INFORMATION22 is null) AND (X_INFORMATION22 is null)))
      AND ((recinfo.INFORMATION23 = X_INFORMATION23)
           OR ((recinfo.INFORMATION23 is null) AND (X_INFORMATION23 is null)))
      AND ((recinfo.INFORMATION24 = X_INFORMATION24)
           OR ((recinfo.INFORMATION24 is null) AND (X_INFORMATION24 is null)))
      AND ((recinfo.INFORMATION25 = X_INFORMATION25)
           OR ((recinfo.INFORMATION25 is null) AND (X_INFORMATION25 is null)))
      AND ((recinfo.INFORMATION26 = X_INFORMATION26)
           OR ((recinfo.INFORMATION26 is null) AND (X_INFORMATION26 is null)))
      AND ((recinfo.INFORMATION27 = X_INFORMATION27)
           OR ((recinfo.INFORMATION27 is null) AND (X_INFORMATION27 is null)))
      AND ((recinfo.INFORMATION28 = X_INFORMATION28)
           OR ((recinfo.INFORMATION28 is null) AND (X_INFORMATION28 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.LABEL = X_LABEL)
               OR ((tlinfo.LABEL is null) AND (X_LABEL is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_TAB_PAGE_PROPERTY_ID in NUMBER,
  X_FORM_TAB_PAGE_ID in NUMBER,
  X_TEMPLATE_TAB_PAGE_ID in NUMBER,
  X_NAVIGATION_DIRECTION in VARCHAR2,
  X_VISIBLE in NUMBER,
  X_INFORMATION_CATEGORY in VARCHAR2,
  X_INFORMATION9 in VARCHAR2,
  X_INFORMATION10 in VARCHAR2,
  X_INFORMATION11 in VARCHAR2,
  X_INFORMATION12 in VARCHAR2,
  X_INFORMATION13 in VARCHAR2,
  X_INFORMATION14 in VARCHAR2,
  X_INFORMATION15 in VARCHAR2,
  X_INFORMATION16 in VARCHAR2,
  X_INFORMATION17 in VARCHAR2,
  X_INFORMATION18 in VARCHAR2,
  X_INFORMATION19 in VARCHAR2,
  X_INFORMATION20 in VARCHAR2,
  X_INFORMATION21 in VARCHAR2,
  X_INFORMATION7 in VARCHAR2,
  X_INFORMATION8 in VARCHAR2,
  X_INFORMATION29 in VARCHAR2,
  X_INFORMATION30 in VARCHAR2,
  X_INFORMATION6 in VARCHAR2,
  X_INFORMATION1 in VARCHAR2,
  X_INFORMATION2 in VARCHAR2,
  X_INFORMATION3 in VARCHAR2,
  X_INFORMATION4 in VARCHAR2,
  X_INFORMATION5 in VARCHAR2,
  X_INFORMATION22 in VARCHAR2,
  X_INFORMATION23 in VARCHAR2,
  X_INFORMATION24 in VARCHAR2,
  X_INFORMATION25 in VARCHAR2,
  X_INFORMATION26 in VARCHAR2,
  X_INFORMATION27 in VARCHAR2,
  X_INFORMATION28 in VARCHAR2,
  X_LABEL in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update HR_TAB_PAGE_PROPERTIES_B set
    FORM_TAB_PAGE_ID = X_FORM_TAB_PAGE_ID,
    TEMPLATE_TAB_PAGE_ID = X_TEMPLATE_TAB_PAGE_ID,
    NAVIGATION_DIRECTION = X_NAVIGATION_DIRECTION,
    VISIBLE = X_VISIBLE,
    INFORMATION_CATEGORY = X_INFORMATION_CATEGORY,
    INFORMATION9 = X_INFORMATION9,
    INFORMATION10 = X_INFORMATION10,
    INFORMATION11 = X_INFORMATION11,
    INFORMATION12 = X_INFORMATION12,
    INFORMATION13 = X_INFORMATION13,
    INFORMATION14 = X_INFORMATION14,
    INFORMATION15 = X_INFORMATION15,
    INFORMATION16 = X_INFORMATION16,
    INFORMATION17 = X_INFORMATION17,
    INFORMATION18 = X_INFORMATION18,
    INFORMATION19 = X_INFORMATION19,
    INFORMATION20 = X_INFORMATION20,
    INFORMATION21 = X_INFORMATION21,
    INFORMATION7 = X_INFORMATION7,
    INFORMATION8 = X_INFORMATION8,
    INFORMATION29 = X_INFORMATION29,
    INFORMATION30 = X_INFORMATION30,
    INFORMATION6 = X_INFORMATION6,
    INFORMATION1 = X_INFORMATION1,
    INFORMATION2 = X_INFORMATION2,
    INFORMATION3 = X_INFORMATION3,
    INFORMATION4 = X_INFORMATION4,
    INFORMATION5 = X_INFORMATION5,
    INFORMATION22 = X_INFORMATION22,
    INFORMATION23 = X_INFORMATION23,
    INFORMATION24 = X_INFORMATION24,
    INFORMATION25 = X_INFORMATION25,
    INFORMATION26 = X_INFORMATION26,
    INFORMATION27 = X_INFORMATION27,
    INFORMATION28 = X_INFORMATION28,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where TAB_PAGE_PROPERTY_ID = X_TAB_PAGE_PROPERTY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update HR_TAB_PAGE_PROPERTIES_TL set
    LABEL = X_LABEL,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TAB_PAGE_PROPERTY_ID = X_TAB_PAGE_PROPERTY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TAB_PAGE_PROPERTY_ID in NUMBER
) is
begin
  delete from HR_TAB_PAGE_PROPERTIES_TL
  where TAB_PAGE_PROPERTY_ID = X_TAB_PAGE_PROPERTY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from HR_TAB_PAGE_PROPERTIES_B
  where TAB_PAGE_PROPERTY_ID = X_TAB_PAGE_PROPERTY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from HR_TAB_PAGE_PROPERTIES_TL T
  where not exists
    (select NULL
    from HR_TAB_PAGE_PROPERTIES_B B
    where B.TAB_PAGE_PROPERTY_ID = T.TAB_PAGE_PROPERTY_ID
    );

  update HR_TAB_PAGE_PROPERTIES_TL T set (
      LABEL
    ) = (select
      B.LABEL
    from HR_TAB_PAGE_PROPERTIES_TL B
    where B.TAB_PAGE_PROPERTY_ID = T.TAB_PAGE_PROPERTY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TAB_PAGE_PROPERTY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TAB_PAGE_PROPERTY_ID,
      SUBT.LANGUAGE
    from HR_TAB_PAGE_PROPERTIES_TL SUBB, HR_TAB_PAGE_PROPERTIES_TL SUBT
    where SUBB.TAB_PAGE_PROPERTY_ID = SUBT.TAB_PAGE_PROPERTY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.LABEL <> SUBT.LABEL
      or (SUBB.LABEL is null and SUBT.LABEL is not null)
      or (SUBB.LABEL is not null and SUBT.LABEL is null)
  ));

  insert into HR_TAB_PAGE_PROPERTIES_TL (
    TAB_PAGE_PROPERTY_ID,
    LABEL,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TAB_PAGE_PROPERTY_ID,
    B.LABEL,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from HR_TAB_PAGE_PROPERTIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from HR_TAB_PAGE_PROPERTIES_TL T
    where T.TAB_PAGE_PROPERTY_ID = B.TAB_PAGE_PROPERTY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_TAB_PAGE_NAME in VARCHAR2,
  X_CANVAS_NAME in VARCHAR2,
  X_WINDOW_NAME in VARCHAR2,
  X_TEMPLATE_NAME in VARCHAR2,
  X_TERRITORY_SHORT_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2 default sysdate,
  X_CUSTOM_MODE IN VARCHAR2 default null,
  X_LABEL in VARCHAR2) is
  X_ROWID ROWID;
  X_CREATION_DATE DATE;
  X_CREATED_BY NUMBER;
--  X_LAST_UPDATE_DATE DATE;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  X_FORM_ID NUMBER;
  X_APPLICATION_ID NUMBER;
  X_FORM_WINDOW_ID NUMBER;
  X_FORM_CANVAS_ID NUMBER;
  X_FORM_TAB_PAGE_ID NUMBER;
  X_TEMPLATE_CANVAS_ID NUMBER;
  X_TEMPLATE_TAB_PAGE_ID NUMBER;
  X_TAB_PAGE_PROPERTY_ID NUMBER;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

begin
--This has been commented as LAST_UPDATE_DATE is passed as an parameter
/*OWNER_TO_WHO (
    X_OWNER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );*/

 select application_id
 into x_application_id
 from fnd_application
 where application_short_name = x_application_short_name;

 select form_id
 into x_form_id
 from fnd_form
 where form_name = x_form_name
 and application_id = x_application_id;

-- check this select
 select hfc.form_canvas_id, hfw.form_window_id
 into x_form_canvas_id,x_form_window_id
 from hr_form_canvases_b hfc
      , hr_form_windows_b hfw
 where hfc.canvas_name = x_canvas_name
 and hfw.application_id = x_application_id
 and hfw.form_id = x_form_id
 and hfw.window_name = x_window_name;

 select form_tab_page_id
 into x_form_tab_page_id
 from hr_form_tab_pages_b
 where form_canvas_id = x_form_canvas_id
 and tab_page_name = x_tab_page_name;

 if ltrim(rtrim(x_template_name)) is not null then

 select htc.template_canvas_id
 into x_template_canvas_id
 from hr_template_canvases_b htc
      ,hr_template_windows_b htw
      , hr_form_templates hft
 where htc.form_canvas_id = x_form_canvas_id
 and htc.template_window_id = htw.template_window_id
 and htw.form_window_id = x_form_window_id
 and htw.form_template_id = hft.form_template_id
 and hft.application_id = x_application_id
 and hft.form_id = x_form_id
 and (  (hft.legislation_code is null and x_territory_short_name is null)
     or (hft.legislation_code = x_territory_short_name) )
 and hft.template_name = x_template_name;


 select template_tab_page_id
 into x_template_tab_page_id
 from hr_template_tab_pages
 where template_canvas_id = x_template_canvas_id
 and form_tab_page_id = x_form_tab_page_id;

 x_form_tab_page_id := null;

 else
 x_template_tab_page_id := null;
 end if;

 begin
   select tab_page_property_id
   into x_tab_page_property_id
   from hr_tab_page_properties_b
   where nvl(form_tab_page_id,hr_api.g_number) =  nvl(x_form_tab_page_id,hr_api.g_number)
   and nvl(template_tab_page_id,hr_api.g_number) = nvl(x_template_tab_page_id,hr_api.g_number);
 end;

 -- Translate owner to file_last_updated_by
 f_luby := fnd_load_util.owner_id(X_OWNER);
    -- Translate char last_update_date to date
 f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

          select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from HR_TAB_PAGE_PROPERTIES_TL
          where tab_page_property_id = x_tab_page_property_id
          and LANGUAGE=userenv('LANG');

          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate,X_CUSTOM_MODE)) then

                 update HR_TAB_PAGE_PROPERTIES_TL set
                        LABEL = X_LABEL,
                        LAST_UPDATE_DATE = f_ludate,
                        LAST_UPDATED_BY = f_luby,
                        LAST_UPDATE_LOGIN = 0,
                        SOURCE_LANG = userenv('LANG')
                    where userenv('LANG') in (LANGUAGE,SOURCE_LANG)
                    and tab_page_property_id = x_tab_page_property_id;
          end if;
exception
          when no_data_found then
            -- Do not insert missing translations, skip this row
            null;

end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_TAB_PAGE_NAME in VARCHAR2,
  X_CANVAS_NAME in VARCHAR2,
  X_WINDOW_NAME in VARCHAR2,
  X_TEMPLATE_NAME in VARCHAR2,
  X_TERRITORY_SHORT_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE IN varchar2 default sysdate,
  X_CUSTOM_MODE IN VARCHAR2 default null,
  X_NAVIGATION_DIRECTION in VARCHAR2,
  X_VISIBLE     in VARCHAR2,
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
  X_INFORMATION29 in VARCHAR2,
  X_INFORMATION30 in VARCHAR2,
  X_LABEL in VARCHAR2) is
  X_ROWID ROWID;
  X_CREATION_DATE DATE:=sysdate;
  X_CREATED_BY NUMBER;
--  X_LAST_UPDATE_DATE DATE;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  X_FORM_ID NUMBER;
  X_APPLICATION_ID NUMBER;
  X_FORM_WINDOW_ID NUMBER;
  X_FORM_CANVAS_ID NUMBER;
  X_FORM_TAB_PAGE_ID NUMBER;
  X_TEMPLATE_CANVAS_ID NUMBER;
  X_TEMPLATE_TAB_PAGE_ID NUMBER;
  X_TAB_PAGE_PROPERTY_ID NUMBER;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
begin
--This has been commented as LAST_UPDATE_DATE is passed as an parameter
 /* OWNER_TO_WHO (
    X_OWNER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );*/
 if X_OWNER = 'SEED' then
    X_CREATED_BY := 1;
 else
    X_CREATED_BY := 0;
 end if;

 select application_id
 into x_application_id
 from fnd_application
 where application_short_name = x_application_short_name;

 select form_id
 into x_form_id
 from fnd_form
 where form_name = x_form_name
 and application_id = x_application_id;

 select hfc.form_canvas_id,hfw.form_window_id
 into x_form_canvas_id,x_form_window_id
 from hr_form_canvases_b hfc
      , hr_form_windows_b hfw
 where hfc.canvas_name = x_canvas_name
 and hfw.application_id = x_application_id
 and hfw.form_id = x_form_id
 and hfw.window_name = x_window_name;

 select form_tab_page_id
 into x_form_tab_page_id
 from hr_form_tab_pages_b
 where form_canvas_id = x_form_canvas_id
 and tab_page_name = x_tab_page_name;

 if ltrim(rtrim(x_template_name)) is not null then

 select htc.template_canvas_id
 into x_template_canvas_id
 from hr_template_canvases_b htc
      ,hr_template_windows_b htw
      , hr_form_templates hft
 where htc.form_canvas_id = x_form_canvas_id
 and htc.template_window_id = htw.template_window_id
 and htw.form_window_id = x_form_window_id
 and htw.form_template_id = hft.form_template_id
 and hft.application_id = x_application_id
 and hft.form_id = x_form_id
 and (  (hft.legislation_code is null and x_territory_short_name is null)
     or (hft.legislation_code = x_territory_short_name) )
 and hft.template_name = x_template_name;

 select template_tab_page_id
 into x_template_tab_page_id
 from hr_template_tab_pages
 where template_canvas_id = x_template_canvas_id
 and form_tab_page_id = x_form_tab_page_id;

 x_form_tab_page_id := null;

 else
 x_template_tab_page_id := null;
 end if;

 begin
   select tab_page_property_id
   into x_tab_page_property_id
   from hr_tab_page_properties_b
   where nvl(form_tab_page_id,hr_api.g_number) =  nvl(x_form_tab_page_id,hr_api.g_number)
   and nvl(template_tab_page_id,hr_api.g_number) = nvl(x_template_tab_page_id,hr_api.g_number);
 exception
   when no_data_found then
     select hr_tab_page_properties_b_s.nextval
     into x_tab_page_property_id
     from dual;
 end;

 begin
 -- Translate owner to file_last_updated_by
 f_luby := fnd_load_util.owner_id(X_OWNER);
    -- Translate char last_update_date to date
 f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

          select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from HR_TAB_PAGE_PROPERTIES_TL
          where tab_page_property_id = x_tab_page_property_id
          and LANGUAGE=userenv('LANG');

 if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate,X_CUSTOM_MODE)) then
  UPDATE_COPIES (
    X_TAB_PAGE_PROPERTY_ID,
    X_FORM_TAB_PAGE_ID,
    X_TEMPLATE_TAB_PAGE_ID,
    X_NAVIGATION_DIRECTION,
    X_VISIBLE,
    X_LABEL,
    X_INFORMATION_CATEGORY,
    X_INFORMATION1,
    X_INFORMATION2,
    X_INFORMATION3,
    X_INFORMATION4,
    X_INFORMATION5,
    X_INFORMATION6,
    X_INFORMATION7,
    X_INFORMATION8,
    X_INFORMATION9,
    X_INFORMATION10,
    X_INFORMATION11,
    X_INFORMATION12,
    X_INFORMATION13,
    X_INFORMATION14,
    X_INFORMATION15,
    X_INFORMATION16,
    X_INFORMATION17,
    X_INFORMATION18,
    X_INFORMATION19,
    X_INFORMATION20,
    X_INFORMATION21,
    X_INFORMATION22,
    X_INFORMATION23,
    X_INFORMATION24,
    X_INFORMATION25,
    X_INFORMATION26,
    X_INFORMATION27,
    X_INFORMATION28,
    X_INFORMATION29,
    X_INFORMATION30,
    f_ludate,
    f_luby,
    0
    );

   UPDATE_ROW (
     X_TAB_PAGE_PROPERTY_ID,
     X_FORM_TAB_PAGE_ID,
     X_TEMPLATE_TAB_PAGE_ID,
     X_NAVIGATION_DIRECTION,
     to_number(X_VISIBLE),
     X_INFORMATION_CATEGORY,
     X_INFORMATION9,
     X_INFORMATION10,
     X_INFORMATION11,
     X_INFORMATION12,
     X_INFORMATION13,
     X_INFORMATION14,
     X_INFORMATION15,
     X_INFORMATION16,
     X_INFORMATION17,
     X_INFORMATION18,
     X_INFORMATION19,
     X_INFORMATION20,
     X_INFORMATION21,
     X_INFORMATION7,
     X_INFORMATION8,
     X_INFORMATION29,
     X_INFORMATION30,
     X_INFORMATION6,
     X_INFORMATION1,
     X_INFORMATION2,
     X_INFORMATION3,
     X_INFORMATION4,
     X_INFORMATION5,
     X_INFORMATION22,
     X_INFORMATION23,
     X_INFORMATION24,
     X_INFORMATION25,
     X_INFORMATION26,
     X_INFORMATION27,
     X_INFORMATION28,
     X_LABEL,
     f_ludate,
     f_luby,
     0);
  END IF;
 exception
   when no_data_found then
     INSERT_ROW (
       X_ROWID,
       X_TAB_PAGE_PROPERTY_ID,
       X_FORM_TAB_PAGE_ID,
       X_TEMPLATE_TAB_PAGE_ID,
       X_NAVIGATION_DIRECTION,
       to_number(X_VISIBLE),
       X_INFORMATION_CATEGORY,
       X_INFORMATION9,
       X_INFORMATION10,
       X_INFORMATION11,
       X_INFORMATION12,
       X_INFORMATION13,
       X_INFORMATION14,
       X_INFORMATION15,
       X_INFORMATION16,
       X_INFORMATION17,
       X_INFORMATION18,
       X_INFORMATION19,
       X_INFORMATION20,
       X_INFORMATION21,
       X_INFORMATION7,
       X_INFORMATION8,
       X_INFORMATION29,
       X_INFORMATION30,
       X_INFORMATION6,
       X_INFORMATION1,
       X_INFORMATION2,
       X_INFORMATION3,
       X_INFORMATION4,
       X_INFORMATION5,
       X_INFORMATION22,
       X_INFORMATION23,
       X_INFORMATION24,
       X_INFORMATION25,
       X_INFORMATION26,
       X_INFORMATION27,
       X_INFORMATION28,
       X_LABEL,
       X_CREATION_DATE,
       X_CREATED_BY,
       f_ludate,
       f_luby,
       0);
 end;

end LOAD_ROW;

end HR_TAB_PAGE_PROPERTIES_PKG;

/
